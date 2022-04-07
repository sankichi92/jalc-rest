# frozen_string_literal: true

require 'logger'

module JaLC
  module REST
    class Config
      DEFAULT_BASE_URL = 'https://api.japanlinkcenter.org'

      attr_accessor :base_url, :logger

      def initialize
        @base_url = DEFAULT_BASE_URL
        @logger = ::Logger.new($stdout)
      end
    end
  end
end
