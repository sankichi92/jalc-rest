# frozen_string_literal: true

require 'faraday'

require_relative '../error'

module JaLC
  module REST
    class Response
      class RaiseError < Faraday::Middleware
        def on_complete(env)
          case env[:status]
          when 400
            raise BadRequestError.new(response: response_values(env))
          when 404
            raise ResourceNotFound.new(response: response_values(env))
          when 400...500
            raise ClientError.new(response: response_values(env))
          when 500...600
            raise ServerError.new(response: response_values(env))
          when nil
            raise NilStatusError.new(
              'http status could not be derived from the server response',
              response: response_values(env),
            )
          end
        end

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
  end
end
