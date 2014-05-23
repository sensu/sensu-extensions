# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "sensu-extensions"
  spec.version       = "0.0.2"
  spec.authors       = ["Sean Porter"]
  spec.email         = ["portertech@gmail.com"]
  spec.summary       = "The Sensu extension loader library"
  spec.description   = "The Sensu extension loader library"
  spec.homepage      = "https://github.com/sensu/sensu-extensions"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sensu-em"
  spec.add_dependency "sensu-extension"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "codeclimate-test-reporter"
end
