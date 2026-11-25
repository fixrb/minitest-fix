# frozen_string_literal: true

require_relative File.join("support", "coverage")
require "minitest"
require_relative File.join("..", "lib", "minitest", "fix")
require_relative File.join("support", "helpers")

# A test of minitest, without its runner: the assertions of minitest and
# those of this gem, as a test class has them after
# `include Minitest::Fix`.
TEST = Class.new(Minitest::Test) { include Minitest::Fix }.new("test")

Fix :MinitestFixTestDuck do
  on :walk do
    it MUST eq "Klop klop!"
  end

  on :swim do
    it SHOULD eq "Swoosh..."
  end

  on :speak do
    it MAY eq "Quaaack!"
  end
end

duck = Struct.new(:walk, :swim, :speak).new("Klop klop!", "Swoosh...", "Quaaack!")
robot = Struct.new(:walk, :swim).new("Klop klop!", "Glug glug...")
decoy = Struct.new(:swim, :speak).new("Swoosh...", "Squeak!")
# Fix writes a location relative to the current directory, whether this
# file was given to ruby by that path or required by an absolute one.
file = File.absolute_path(__FILE__).delete_prefix(File.join(Dir.pwd, ""))
line = __LINE__ - 18
unmet = <<~TEXT.chomp
  Expected the value to fix MinitestFixTestDuck:
    #{file}:#{line}: Error: NoMethodError: undefined method 'walk' for an instance of #{decoy.class}
    #{file}:#{line + 8}: Failure: expected "Squeak!" to eq "Quaaack!"
TEXT
met = <<~TEXT.chomp
  Expected the value not to fix MinitestFixTestDuck:
    #{file}:#{line}: Success: expected "Klop klop!" to eq "Klop klop!"
    #{file}:#{line + 4}: Warning: expected "Glug glug..." to eq "Swoosh..."
    #{file}:#{line + 8}: Info: NoMethodError: undefined method 'speak' for an instance of #{robot.class}
TEXT

# assert_fix passes when every expectation is met, a warning and an info
# included, and fails with the lines of those that are not.
raise unless TEST.assert_fix(:MinitestFixTestDuck, duck).equal?(true)
raise unless TEST.assert_fix(:MinitestFixTestDuck, robot).equal?(true)
error = raised { TEST.assert_fix(:MinitestFixTestDuck, decoy) }
raise unless error.instance_of?(Minitest::Assertion) && error.message.tr("`", "'") == unmet

# refute_fix passes when an expectation is not met, and fails with the
# lines of them all.
raise unless TEST.refute_fix(:MinitestFixTestDuck, decoy).equal?(true)
error = raised { TEST.refute_fix(:MinitestFixTestDuck, robot) }
raise unless error.instance_of?(Minitest::Assertion) && error.message.tr("`", "'") == met

# Each of them is one assertion for minitest, passed or failed.
raise unless TEST.assertions == 5

# The name is the one of a registered specification.
error = raised { TEST.assert_fix(:MinitestFixTestMissing, duck) }
raise unless error.instance_of?(KeyError) && error.key == :MinitestFixTestMissing
error = raised { TEST.refute_fix(:MinitestFixTestMissing, duck) }
raise unless error.instance_of?(KeyError) && error.key == :MinitestFixTestMissing

# The methods of the specification are sent to the value itself, in the
# process of the test. With fork: true, each context runs in a child
# process, as Fix does it, and they are sent to a copy of the value.
parent = Process.pid
Fix(:MinitestFixTestChild) { it MUST(satisfy { |pid| pid == parent && Process.pid != parent }) }
Fix(:MinitestFixTestParent) { it MUST(satisfy { |pid| pid == parent && Process.pid == parent }) }
raise unless TEST.assert_fix(:MinitestFixTestParent, parent)
raise unless TEST.refute_fix(:MinitestFixTestChild, parent)
raise unless TEST.assert_fix(:MinitestFixTestChild, parent, fork: true)
raise unless TEST.refute_fix(:MinitestFixTestParent, parent, fork: true)
Fix(:MinitestFixTestPush) { on(:push, 1) { on(:size) { it MUST eq 1 } } }
stack = []
raise unless TEST.assert_fix(:MinitestFixTestPush, stack, fork: true) && stack.empty?
raise unless TEST.assert_fix(:MinitestFixTestPush, stack) && stack == [1]

# What is not an outcome of an expectation is raised, with children or
# without.
Fix(:MinitestFixTestCall) { on(:call) { it MUST eq 1 } }
raise unless TEST.assert_fix(:MinitestFixTestCall, -> { 1 })
raise unless raised { TEST.assert_fix(:MinitestFixTestCall, -> { raise Interrupt }) }.instance_of?(Interrupt)
error = raised { TEST.refute_fix(:MinitestFixTestCall, -> { raise Interrupt }, fork: true) }
raise unless error.instance_of?(Interrupt)
raise unless raised { TEST.assert_fix(:MinitestFixTestCall, -> { exit! 2 }, fork: true) }.instance_of?(Aw::ChildError)
raise unless raised { TEST.refute_fix(:MinitestFixTestCall, -> { exit! 2 }, fork: true) }.instance_of?(Aw::ChildError)

# The public surface: two assertions.
raise unless Minitest::Fix.public_instance_methods(false).sort == %i[assert_fix refute_fix]
