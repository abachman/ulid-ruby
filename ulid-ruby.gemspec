# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ulid/version'

Gem::Specification.new do |spec|
  spec.name          = "ulid-ruby"
  spec.version       = ULID::VERSION
  spec.authors       = ["adam bachman"]
  spec.email         = ["adam.bachman@gmail.com"]

  spec.summary       = %q{ruby library providing support for universally unique lexicographically sortable identifiers}
  spec.description   = %q{todo: write a longer description or delete this line.}
  spec.homepage      = "https://github.com/abachman/ulid-ruby"
  spec.license       = "mit"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| file.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "yard", "~> 0.9"
end
