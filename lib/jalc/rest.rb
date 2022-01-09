# frozen_string_literal: true

require 'forwardable'

require_relative 'rest/client'
require_relative 'rest/config'
require_relative 'rest/version'

module JaLC
  module REST
    class << self
      extend Forwardable

      def_delegators :client, :prefixes, :doilist, :doi

      def configure
        yield config
      end

      def config
        @config ||= Config.new
      end

      private

      def client
        @client ||= Client.new(logger: config.logger)
      end
    end
  end
end
