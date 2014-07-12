# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "attribute_pair_generator"
  gem.version       = "1.1.0"
  gem.authors       = ["Andrew Thal", "Jeff Whitmire"]
  gem.email         = "andrew.thal@livingsocial.com"
  gem.description   = %q{Easily generate form fields and object information fields with labels.}
  gem.summary       = %q{Easily generate form fields and object information fields with labels.}
  gem.homepage      = "https://github.com/livingsocial/attribute-pair-generator"

  gem.license = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rake'
  gem.add_development_dependency "faker"
  gem.add_development_dependency "rspec", '~> 2.0'
  gem.add_development_dependency "nokogiri", '~> 1.6'
  gem.add_dependency "actionpack", '>= 3.0.0'
end
