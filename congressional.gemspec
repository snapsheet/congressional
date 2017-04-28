# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'congressional/version'

Gem::Specification.new do |spec|
  spec.name          = "congressional"
  spec.version       = Congressional::VERSION
  spec.email         = "tech@snapsheet.me"
  spec.homepage      = "https://github.com/snapsheet/congressional"
  spec.summary       = "Congressional: States as first-class citizens"
  spec.description   = "A gem for managing complex state behavior."
  spec.authors       = ['dtittle@gmail.com']

  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "bundler"
  spec.add_runtime_dependency "rake"
  spec.add_runtime_dependency "statesman"
  spec.add_runtime_dependency "descendants_tracker"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "pry-stack_explorer"
end
