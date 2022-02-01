# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'synvert/version'

Gem::Specification.new do |spec|
  spec.name          = 'synvert'
  spec.version       = Synvert::VERSION
  spec.authors       = ['Richard Huang']
  spec.email         = ['flyerhzm@gmail.com']
  spec.description   = 'synvert is used to convert ruby code to better syntax.'
  spec.summary       = 'synvert = syntax + convert.'
  spec.homepage      = 'https://github.com/xinminlabs/synvert-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.post_install_message = 'Please run `synvert-ruby --sync` first to sync snippets remotely.'

  spec.add_runtime_dependency 'synvert-core', '>= 0.61.2'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
spec.metadata['rubygems_mfa_required'] = 'true'
end
