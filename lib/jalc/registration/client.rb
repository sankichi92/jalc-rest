# frozen_string_literal: true

require 'faraday'
require 'faraday/multipart'

require_relative '../version'

module JaLC
  module Registration
    BASE_URL = 'https://japanlinkcenter.org/jalc/infoRegistry/registDataReceive/index'

    class Client
      def initialize(id:, password:, logger: nil, base_url: BASE_URL)
        @id = id
        @password = password
        @logger = logger
        @base_url = base_url
      end

      def post(xml_file)
        conn.post(
          nil,
          {
            login_id: Faraday::Multipart::ParamPart.new(@id, 'text/plain'),
            login_password: Faraday::Multipart::ParamPart.new(@password, 'text/plain'),
            fname: Faraday::Multipart::FilePart.new(xml_file, 'text/xml'),
          },
        )
      end

      private

      def conn
        @conn ||= Faraday.new(
          url: @base_url,
          headers: { 'User-Agent' => "jalc-ruby v#{VERSION}" },
        ) do |f|
          f.request :multipart
          f.response :logger, @logger, { headers: false } if @logger
        end
      end
    end
  end
end
