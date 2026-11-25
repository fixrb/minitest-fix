# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "minitest-fix"
  spec.version                = File.read(File.join(__dir__, "VERSION.semver")).chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "Assertions of minitest that test a value against a specification of Fix"
  spec.description            = "Minitest::Fix adds two assertions to the tests of minitest: assert_fix :Name, value " \
                                "passes when the value meets every expectation of that specification of Fix, and " \
                                "its message tells which it does not; refute_fix is its opposite. A specification " \
                                "of Fix, beside the suite a project already has."
  spec.homepage               = "https://fixrb.dev/gems/minitest-fix/"
  spec.license                = "MIT"
  spec.files                  = Dir["LICENSE.md", "README.md", "lib/**/*.rb", base: __dir__]
  spec.required_ruby_version  = ">= 3.3.0"

  spec.metadata["bug_tracker_uri"]       = "https://github.com/fixrb/minitest-fix/issues"
  spec.metadata["documentation_uri"]     = "https://gemdocs.org/gems/#{spec.name}/#{spec.version}/"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["source_code_uri"]       = "https://github.com/fixrb/minitest-fix"

  spec.add_dependency "fix", "~> 1.0"
end
