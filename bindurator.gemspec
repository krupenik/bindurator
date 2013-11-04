lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bindurator/version'

Gem::Specification.new do |spec|
  spec.name          = "bindurator"
  spec.version       = Bindurator::VERSION
  spec.authors       = ["Dennis Krupenik"]
  spec.email         = ["dennis@krupenik.com"]
  spec.description   = %q{ISC BINDv9 config generator}
  spec.summary       = %q{ISC BINDv9 config generator}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
