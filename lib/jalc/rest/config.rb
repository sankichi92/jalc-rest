# frozen_string_literal: true

require 'logger'

module JaLC
  module REST
    class Config
      attr_accessor :logger

      def initilaize
        @logger = ::Logger.new($stdout)
      end
    end
  end
end
