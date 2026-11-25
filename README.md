# Minitest::Fix

[![Version](https://img.shields.io/github/v/tag/fixrb/minitest-fix?label=Version&logo=github)](https://github.com/fixrb/minitest-fix/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://gemdocs.org/gems/minitest-fix/latest/)
[![License](https://img.shields.io/github/license/fixrb/minitest-fix?label=License&logo=github)](https://github.com/fixrb/minitest-fix/raw/main/LICENSE.md)

Minitest::Fix brings the specifications of [Fix](https://github.com/fixrb/fix) to [minitest](https://github.com/minitest/minitest), as two assertions: `assert_fix :Name, value` passes when the value meets every expectation of the specification, and its message tells which it does not; `refute_fix` is its opposite. It is the way to add a specification of Fix to a minitest suite, and to keep the suite.

[fixrb.dev](https://fixrb.dev/gems/minitest-fix/) presents the gem.

## Installation

```ruby
# Gemfile
gem "minitest-fix"
```

Minitest::Fix requires Ruby 3.3 or later, and depends on [Fix](https://github.com/fixrb/fix). It asks nothing of minitest but the `assert` and the `refute` of the test class that includes it.

## Usage

```ruby
# duck_test.rb
require "minitest/autorun"
require "minitest/fix"

Fix :Duck do
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

class Duck
  def walk = "Klop klop!"
  def swim = "Swoosh..."
  def speak = "Quaaack!"
end

class Robot
  def walk = "Klop klop!"
  def swim = "Glug glug..."
end

class RubberDuck
  def swim = "Swoosh..."
  def speak = "Squeak!"
end

class DuckTest < Minitest::Test
  include Minitest::Fix

  def test_duck
    assert_fix :Duck, Duck.new
  end

  def test_robot
    assert_fix :Duck, Robot.new
  end

  def test_rubber_duck
    assert_fix :Duck, RubberDuck.new
  end
end
```

`ruby duck_test.rb` runs three tests, and one fails:

```text
  1) Failure:
DuckTest#test_rubber_duck [duck_test.rb:47]:
Expected the value to fix Duck:
  duck_test.rb:7: Error: NoMethodError: undefined method 'walk' for an instance of RubberDuck
  duck_test.rb:15: Failure: expected "Squeak!" to eq "Quaaack!"
```

`require "minitest/fix"` requires Fix, and `include Minitest::Fix` gives the two assertions to a test class, or to all of them when it is included in `Minitest::Test` itself, or in `ActiveSupport::TestCase` in a Rails application. The name is the one of a specification registered by `Fix :Name do … end`, and `KeyError` is raised when there is none. The specification is written where the suite can require it once: in the test file as above, or in a file of its own, which a test of Fix can require too.

`assert_fix` passes when every expectation passes, a warning or an info included: the robot above passes, though it swims its own way and does not speak, and minitest says nothing of it. `Fix[:Duck].test { Robot.new }` writes every line, the warning and the info among them. Failed, the assertion gives the lines of the failures and of the errors, each pointing at its expectation. `refute_fix :Name, value` passes when one expectation is not met. Each of them counts as one assertion.

The methods of the specification are sent to the value itself, in the process of the test, where its transaction, its mocks and its coverage tool are. A method that changes the value changes it for the contexts that follow, and for the rest of the test.

`assert_fix :Name, value, fork: true` runs each context in a child process, as Fix does it, on a system with `fork`: the methods are sent to a copy of the value, and the one the test holds is left as it was. It is for a value whose state is all in the process, since what lives outside is not copied. In a Rails application with transactional tests, a child does not see a row the test has created, and a row it writes is not rolled back; a mock does not see what a child received.

The assertions take a value, not a block. Since the value is given once, the contexts cannot build it anew with their lets: a specification meant for an assertion is written without `with`. What is not an outcome of an expectation is raised: an `Interrupt`, and with `fork: true` a child that died or a Ruby without `fork`.

## Versioning

Minitest::Fix follows [Semantic Versioning 2.0](https://semver.org/).

## License

The [gem](https://rubygems.org/gems/minitest-fix) is available as open source under the terms of the [MIT License](https://github.com/fixrb/minitest-fix/raw/main/LICENSE.md).

## Sponsors

This project is sponsored by [Sashité](https://sashite.com/)
