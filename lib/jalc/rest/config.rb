# frozen_string_literal: true

require 'logger'

module JaLC
  module REST
    class Config
      attr_accessor :logger

      def initialize
        @logger = ::Logger.new($stdout)
      end
    end
  end
end
