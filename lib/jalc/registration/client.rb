# frozen_string_literal: true

require 'faraday'
require 'faraday/multipart'

require_relative '../version'
require_relative 'middleware/parse_xml'
require_relative 'middleware/raise_error'

module JaLC
  module Registration
    BASE_URL = 'https://japanlinkcenter.org'

    class Client
      def initialize(id:, password:, logger: nil, base_url: BASE_URL)
        @id = id
        @password = password
        @logger = logger
        @base_url = base_url
      end

      def post(xml_file)
        conn.post(
          '/jalc/infoRegistry/registDataReceive/index',
          {
            login_id: Faraday::Multipart::ParamPart.new(@id, 'text/plain'),
            login_password: Faraday::Multipart::ParamPart.new(@password, 'text/plain'),
            fname: Faraday::Multipart::FilePart.new(xml_file, 'text/xml'),
          },
        )
      end

      def get_result(exec_id)
        conn.get(
          '/jalc/infoRegistry/registDataResult/index',
          {
            login_id: @id,
            login_password: @password,
            exec_id: exec_id,
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
          f.use Middleware::RaiseError
          f.use Middleware::ParseXML
          f.response :raise_error
          f.response :logger, @logger, { headers: false } if @logger
        end
      end
    end
  end
end
