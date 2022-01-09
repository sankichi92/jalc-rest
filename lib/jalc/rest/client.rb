# frozen_string_literal: true

require 'uri'

require 'faraday'

require_relative 'response/raise_error'
require_relative '../version'

module JaLC
  module REST
    BASE_URL = 'https://api.japanlinkcenter.org'

    class Client
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
      end

      def doilist(prefix, from: nil, to: nil, rows: nil, page: nil, sort: nil, order: nil)
        conn.get(
          "/doilist/#{prefix}",
          {
            from: from,
            until: to, # since `until` is Ruby's keyword
            rows: rows,
            page: page,
            sort: sort,
            order: order,
          }.compact,
        )
      end

      def doi(doi)
        conn.get("/dois/#{URI.encode_www_form_component(doi)}")
      end

      private

      def conn
        @conn ||= Faraday.new(
          url: @base_url,
          headers: { 'User-Agent' => "jalc-ruby v#{VERSION}" },
        ) do |f|
          f.use Response::RaiseError
          f.response :json
          f.response :logger, @logger, { headers: false } if @logger
        end
      rescue Faraday::Error => e
        raise e unless e.message.match?(/is not registered/)

        begin
          require 'faraday_middleware'
        rescue LoadError
          raise LoadError, 'faraday_middleware gem is required when using Faraday v1.' \
                           " Please add `gem 'faraday_middleware'` to your Gemfile."
        end

        retry
      end
    end
  end
end
