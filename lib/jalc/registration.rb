# frozen_string_literal: true

require 'forwardable'

require_relative 'registration/client'
require_relative 'registration/config'

module JaLC
  module Registration
    class << self
      extend Forwardable

      def_delegators :client, :post, :get_result

      def configure
        yield config
      end

      def config
        @config ||= Config.new
      end

      private

      def client
        @client ||= Client.new(
          id: config.id,
          password: config.password,
          logger: config.logger,
        )
      end
    end
  end
end
