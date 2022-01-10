# frozen_string_literal: true

require_relative 'lib/jalc/version'

Gem::Specification.new do |spec|
  spec.name = 'jalc'
  spec.version = JaLC::VERSION
  spec.authors = ['Takahiro Miyoshi']
  spec.email = ['takahiro-miyoshi@sankichi.net']

  spec.summary = 'JaLC (Japan Link Center) API Client'
  spec.homepage = 'https://github.com/sankichi92/jalc-ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/sankichi92/jalc-ruby'
  spec.metadata['changelog_uri'] = 'https://github.com/sankichi92/jalc-ruby/blob/main/CHANGELOG.md'
  spec.metadata['github_repo'] = 'https://github.com/sankichi92/jalc-ruby.git'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:spec|gemfiles)/|\.(?:git|vscode))})
    end
  end
  # spec.bindir = "exe"
  # spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'faraday', '>= 1.0', '< 3.0'
  spec.add_dependency 'faraday-multipart', '~> 1.0'
  spec.add_dependency 'rexml', '~> 3.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
