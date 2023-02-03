# frozen_string_literal: true

D = Steep::Diagnostic

target :lib do
  signature 'sig', 'sig-private'
  repo_path 'gem_rbs_collection/gems'

  check 'lib'

  library 'forwardable', 'logger', 'uri'
  library 'faraday'

  configure_code_diagnostics do |hash|
    hash[D::Ruby::NoMethod] = :information
    hash[D::Ruby::UnknownConstant] = :information

    hash[D::Ruby::MethodDefinitionMissing] = nil # To supress noisy VS Code extension message.
  end
end
