# frozen_string_literal: true

require 'faraday'
begin
  require 'faraday_middleware'
rescue LoadError
  # do nothing
end

require_relative 'version'

module JaLC
  module REST
    class Client
      BASE_URL = 'https://api.japanlinkcenter.org'

      def initialize(base_url: BASE_URL, user_agent: "jalc-rest v#{VERSION}")
        @base_url = base_url
        @user_agent = user_agent
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

      private

      def conn
        @conn ||= Faraday.new(
          url: @base_url,
          headers: { 'User-Agent' => @user_agent },
        ) do |f|
          f.response :json
        end
      end
    end
  end
end
