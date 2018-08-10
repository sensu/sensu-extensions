# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "sensu-extensions"
  spec.version       = "1.9.1"
  spec.authors       = ["Sean Porter"]
  spec.email         = ["portertech@gmail.com", "engineering@sensu.io"]
  spec.summary       = "The Sensu extension loader library"
  spec.description   = "The Sensu extension loader library"
  spec.homepage      = "https://github.com/sensu/sensu-extensions"
  spec.license       = "MIT"

  spec.files         = Dir.glob("lib/**/*") + %w[sensu-extensions.gemspec README.md LICENSE.txt]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sensu-json", ">= 1.1.0"
  spec.add_dependency "sensu-logger"
  spec.add_dependency "sensu-settings"
  spec.add_dependency "sensu-extension"
  spec.add_dependency "sensu-extensions-occurrences", "1.2.0"
  spec.add_dependency "sensu-extensions-check-dependencies", "1.1.0"
  spec.add_dependency "sensu-extensions-json", "1.0.0"
  spec.add_dependency "sensu-extensions-ruby-hash", "1.0.0"
  spec.add_dependency "sensu-extensions-only-check-output", "1.0.0"
  spec.add_dependency "sensu-extensions-debug", "1.0.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sensu-extensions-system-profile", "1.0.0"
  spec.add_development_dependency "bouncy-castle-java" if RUBY_PLATFORM =~ /java/

  spec.cert_chain    = ["certs/sensu.pem"]
  spec.signing_key   = File.expand_path("~/.ssh/gem-sensu-private_key.pem") if $0 =~ /gem\z/
end
