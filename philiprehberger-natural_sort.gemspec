# frozen_string_literal: true

require_relative 'lib/philiprehberger/natural_sort/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-natural_sort'
  spec.version = Philiprehberger::NaturalSort::VERSION
  spec.authors = ['Philip Rehberger']
  spec.email = ['me@philiprehberger.com']
  spec.summary = 'Human-friendly natural sorting — "file2" before "file10"'
  spec.description = 'Natural sort for strings containing numbers. Splits strings into text and numeric chunks ' \
                     'and compares them the way humans expect: "file2" sorts before "file10".'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-natural_sort'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/philiprehberger/rb-natural-sort'
  spec.metadata['changelog_uri'] = 'https://github.com/philiprehberger/rb-natural-sort/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/philiprehberger/rb-natural-sort/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
