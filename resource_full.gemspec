require 'rake'

Gem::Specification.new do |s|
  s.name = 'resource_full'
  s.summary = 'A library for building controllers that correctly interact with ActiveResource.'
  s.version = '0.7.6'

  s.author = 'Brian Guthrie'
  s.email = 'btguthrie@gmail.com'
  s.homepage = 'http://github.com/bguthrie/resource_full'
  s.has_rdoc = false

  s.files = FileList['lib/**/*.rb', '[A-Z]*', 'spec/**/*'].to_a
  s.test_files = FileList['spec/resource_full/**/*.rb']
  
  s.add_dependency 'action_controller', '>= 2.1.0'
  s.add_dependency 'active_record', '>= 2.1.0'
  
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'mocha'
end