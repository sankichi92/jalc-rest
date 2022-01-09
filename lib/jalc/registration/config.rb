# frozen_string_literal: true

require 'logger'

module JaLC
  module Registration
    class Config
      attr_accessor :id, :password, :logger

      def initialize
        @id = nil
        @password = nil
        @logger = ::Logger.new($stdout)
      end
    end
  end
end
