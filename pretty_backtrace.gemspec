# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pretty_backtrace/version'

Gem::Specification.new do |spec|
  spec.name          = "pretty_backtrace"
  spec.version       = PrettyBacktrace::VERSION
  spec.authors       = ["Koichi Sasada"]
  spec.email         = ["ko1@atdot.net"]
  spec.summary       = %q{Pretty your exception backtrace.}
  spec.description   = %q{Pretty your exception backtrace.}
  spec.homepage      = "http://github.com/ko1/pretty_backtrace"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "debug_inspector", "~> 0.0.1"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
