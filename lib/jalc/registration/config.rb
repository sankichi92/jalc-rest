# frozen_string_literal: true

require 'logger'

module JaLC
  module Registration
    class Config
      DEFAULT_BASE_URL = 'https://japanlinkcenter.org'

      attr_accessor :base_url, :id, :password, :logger

      def initialize
        @base_url = DEFAULT_BASE_URL
        @id = nil
        @password = nil
        @logger = ::Logger.new($stdout)
      end
    end
  end
end
