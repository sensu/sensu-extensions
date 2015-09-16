# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "sensu-extensions"
  spec.version       = "1.3.0"
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

  spec.add_dependency "sensu-logger"
  spec.add_dependency "sensu-settings"
  spec.add_dependency "sensu-extension"

  spec.add_dependency "multi_json"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "uuidtools"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "bouncy-castle-java" if RUBY_PLATFORM =~ /java/
  spec.add_development_dependency "codeclimate-test-reporter" unless RUBY_VERSION < "1.9"
end
