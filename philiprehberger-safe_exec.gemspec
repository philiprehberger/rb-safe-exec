# frozen_string_literal: true

require_relative 'lib/philiprehberger/safe_exec/version'

Gem::Specification.new do |spec|
  spec.name          = 'philiprehberger-safe_exec'
  spec.version       = Philiprehberger::SafeExec::VERSION
  spec.authors       = ['Philip Rehberger']
  spec.email         = ['me@philiprehberger.com']

  spec.summary       = 'Sandboxed expression evaluator with whitelisted operations'
  spec.description   = 'Safely evaluate arithmetic, comparison, and boolean expressions from untrusted input. ' \
                       'Uses a custom parser with no eval, send, or method_missing. Includes timeout support.'
  spec.homepage      = 'https://github.com/philiprehberger/rb-safe-exec'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = spec.homepage
  spec.metadata['changelog_uri']         = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']       = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
