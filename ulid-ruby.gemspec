# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ulid/version'

Gem::Specification.new do |spec|
  spec.name          = "ulid-ruby"
  spec.version       = ULID::VERSION
  spec.authors       = ["Adam Bachman"]
  spec.email         = ["adam.bachman@gmail.com"]

  spec.summary       = %q{Ruby library providing support for Universally unique Lexicographically sortable IDentifiers}
  spec.description   = %q{
    Ruby library providing support for Universally unique Lexicographically
    Sortable Identifiers. ULIDs are helpful in systems where you need to
    generate ID values that are absolutely lexicographically sortable by time,
    regardless of where they were generated.
  }
  spec.homepage      = "https://github.com/abachman/ulid-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| file.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "yard", "~> 0.9"
end
