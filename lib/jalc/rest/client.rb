# frozen_string_literal: true

require 'uri'

require 'faraday'

require_relative 'middleware/raise_error'
require_relative '../version'

module JaLC
  module REST
    class Client
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def prefixes(ra: nil, sort: nil, order: nil)
        response = conn.get(
          '/prefixes',
          {
            ra: ra,
            sort: sort,
            order: order,
          }.compact,
        )
        response.body
      end

      def doilist(prefix, from: nil, to: nil, rows: nil, page: nil, sort: nil, order: nil)
        response = conn.get(
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
        response.body
      end

      def doi(doi)
        encoded_doi = URI.encode_www_form_component(URI.encode_www_form_component(doi))
        response = conn.get("/dois/#{encoded_doi}")
        response.body
      end

      private

      def conn
        @conn ||= Faraday.new(
          url: config.base_url,
          headers: { 'User-Agent' => "jalc-ruby v#{VERSION}" },
        ) do |f|
          f.use Middleware::RaiseError
          f.response :json
          f.response :logger, config.logger, { headers: false } if config.logger
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
