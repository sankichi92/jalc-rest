# frozen_string_literal: true

require 'faraday'

require_relative '../error'

module JaLC
  module REST
    class Middleware
      class RaiseError < Faraday::Middleware
        def on_complete(env)
          case env[:status]
          when 400
            raise BadRequestError.new(response: response_values(env))
          when 404
            raise ResourceNotFound.new(response: response_values(env))
          when 400...500
            raise ClientError.new(response: response_values(env))
          when 500...600, nil
            raise ServerError.new(response: response_values(env))
          end
        end

        private

        def response_values(env)
          {
            status: env.status,
            headers: env.response_headers,
            body: env.body,
            request: {
              method: env.method,
              url: env.url,
              headers: env.request_headers,
              body: env.request_body,
            },
          }
        end
      end
    end

    class HTTPError < Error
      attr_reader :response

      def initialize(msg = nil, response: nil)
        @response = response
        msg ||= response[:body].dig('message', 'errors', 'message') if response && response[:body].respond_to?(:dig)
        msg ||= "the server responded with status #{response[:status]}" if response

        super(msg)
      end

      def inspect
        if response
          %(#<#{self.class} response=#{response.inspect}>)
        else
          super
        end
      end
    end

    class ClientError < HTTPError; end
    class BadRequestError < ClientError; end
    class ResourceNotFound < ClientError; end
    class ServerError < HTTPError; end
  end
end
