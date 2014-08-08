# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

require 'kraken-io/version'

Gem::Specification.new do |s|
  s.name        = 'kraken-io'
  s.version     = Kraken::API::VERSION.dup
  s.author      = ['Przemek Matylla']
  s.email       = ['przemek@matylla.pl']
  s.homepage    = 'http://github.com/kraken-io/kraken-ruby'
  s.summary     = %q{Ruby gem for interacting with Kraken.io API}
  s.description = %q{With this gem you can plug into the power and speed of Kraken.io Image Optimizer. https://kraken.io/}
  s.files       = Dir["lib/**/*.rb"]
  s.license     = 'MIT'
  s.add_dependency('json')
  s.add_dependency('httparty')
  s.add_dependency('multipart-post')
  s.add_dependency('activesupport')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rspec-its')
  s.add_development_dependency('webmock', '~> 1.17')
  s.add_development_dependency('pry')
  s.add_development_dependency('pry-byebug')
end
