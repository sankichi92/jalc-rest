# frozen_string_literal: true

require 'faraday'

require_relative '../error'

module JaLC
  module Registration
    module Middleware
      class RaiseError < Faraday::Middleware
        def on_complete(env)
          case env.body.root.elements['head/errcd']&.text
          when '*'
            raise AuthenticationError.new(doc: env.body)
          when '#'
            raise InvalidXMLError.new(doc: env.body)
          when '+'
            raise RegistrationError.new(doc: env.body)
          end
        end
      end
    end

    class RegistrationError < Error
      attr_reader :doc

      def initialize(msg = nil, doc:)
        @doc = doc
        msg ||= "#{doc.root.elements['head/errmsg']&.text} (errcd=#{doc.root.elements['head/errcd']&.text})"
        super(msg)
      end
    end

    class AuthenticationError < RegistrationError; end
    class InvalidXMLError < RegistrationError; end
  end
end
