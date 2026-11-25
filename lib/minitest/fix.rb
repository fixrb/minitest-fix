# frozen_string_literal: true

require "fix"

# The tests of minitest: this gem adds two assertions to them.
module Minitest
  # Two assertions for the tests of minitest: `assert_fix :Name, value`
  # passes when the value meets every expectation of the specification of
  # Fix registered under that name, and tells which it does not;
  # `refute_fix` passes when it does not meet one. Included in a test class,
  # beside the assertions of minitest.
  #
  # @example
  #   class DuckTest < Minitest::Test
  #     include Minitest::Fix
  #
  #     def test_duck
  #       assert_fix :Duck, Duck.new
  #     end
  #   end
  module Fix
    # Fails unless the value meets every expectation of the specification.
    #
    # @param name [Symbol] the name of a registered specification
    # @param value [Object] the value, the subject of every expectation
    # @param fork [Boolean] whether each context runs in a child process, on a
    #   copy of the value, as Fix does it; by default, the methods of the
    #   specification are sent to the value itself, in the process of the test
    # @return [true]
    # @raise [Minitest::Assertion] with the expectations not met, one line each
    # @raise [KeyError] when no specification has that name
    # @raise [NotImplementedError] with a child per context, when this Ruby
    #   cannot fork
    # @raise [Aw::ChildError] with a child per context, when one died or
    #   delivered no result; what is raised outside an expectation is raised
    #   here again, with children or without
    def assert_fix(name, value, fork: false)
      spec = ::Fix[name]
      unmet = spec.run(fork:) { value }.reject(&:passed?)
      assert(unmet.empty?, ["Expected the value to #{spec}:", *unmet].join("\n  "))
    end

    # Fails when the value meets every expectation of the specification.
    #
    # @param (see #assert_fix)
    # @return [true]
    # @raise [Minitest::Assertion] with the expectations met, one line each
    # @raise [KeyError] when no specification has that name
    # @raise [NotImplementedError] with a child per context, when this Ruby
    #   cannot fork
    # @raise [Aw::ChildError] with a child per context, when one died or
    #   delivered no result; what is raised outside an expectation is raised
    #   here again, with children or without
    def refute_fix(name, value, fork: false)
      spec = ::Fix[name]
      results = spec.run(fork:) { value }
      refute(results.all?(&:passed?), ["Expected the value not to #{spec}:", *results].join("\n  "))
    end
  end
end
