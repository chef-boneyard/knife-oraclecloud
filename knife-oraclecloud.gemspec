
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'knife-oraclecloud/version'

Gem::Specification.new do |spec|
  spec.name          = 'knife-oraclecloud'
  spec.version       = KnifeOracleCloud::VERSION
  spec.authors       = ['Chef Partner Engineering']
  spec.email         = ['partnereng@chef.io']
  spec.summary       = 'Knife plugin to interact with Oracle Cloud.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/chef-partners/knife-oraclecloud'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'chef',         '>= 12.0'
  spec.add_dependency 'knife-cloud',  '~> 1.2.0'
  spec.add_dependency 'oraclecloud',  '~> 1.1'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'chefstyle'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.35'
end
