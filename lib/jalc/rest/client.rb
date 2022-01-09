# frozen_string_literal: true

require 'faraday'
begin
  require 'faraday_middleware'
rescue LoadError
  # do nothing
end

require_relative 'response/raise_error'
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

      private

      def conn
        @conn ||= Faraday.new(
          url: @base_url,
          headers: { 'User-Agent' => "jalc-rest v#{VERSION}" },
        ) do |f|
          f.use Response::RaiseError
          f.response :json
          f.response :logger, @logger, { headers: false }
        end
      end
    end
  end
end
