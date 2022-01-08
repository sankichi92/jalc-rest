# frozen_string_literal: true

require 'faraday'
begin
  require 'faraday_middleware'
rescue LoadError
  # do nothing
end

require_relative 'error'
require_relative 'version'

module JaLC
  module REST
    class Client
      BASE_URL = 'https://api.japanlinkcenter.org'

      def initialize(logger: nil, base_url: BASE_URL)
        @logger = logger
        @base_url = base_url
      end

      def prefixes(ra: nil, sort: nil, order: nil)
        conn.get(
          '/prefixes',
          {
            ra: ra,
            sort: sort,
            order: order,
          }.compact,
        )
      rescue Faraday::Error => e
        handle_error(e)
      end

      private

      def conn
        @conn ||= Faraday.new(
          url: @base_url,
          headers: { 'User-Agent' => "jalc-rest v#{VERSION}" },
        ) do |f|
          f.response :raise_error
          f.response :json
          f.response :logger, @logger, { headers: false }
        end
      end

      def handle_error(error)
        case error.response_status
        when 400
          raise BadRequestError, error
        when 400...500
          raise ClientError, error
        when 500...600
          raise ServerError, error
        else
          raise error
        end
      end
    end
  end
end
