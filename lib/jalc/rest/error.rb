# frozen_string_literal: true

require 'faraday'

module JaLC
  module REST
    class Error < Faraday::Error
      def initialize(exc)
        default_message = if exc.respond_to?(:response)
                            exc_msg_and_response!(exc, exc.response)
                          else
                            exc_msg_and_response!(exc)
                          end
        response_message = (response_body.dig('message', 'errors', 'message') if response_body.respond_to?(:dig))
        super(response_message || default_message)
      end
    end

    class ClientError < Error; end
    class BadRequestError < ClientError; end
    class ServerError < Error; end
  end
end
