# frozen_string_literal: true

require 'faraday'
require 'faraday/multipart'

require_relative '../version'
require_relative 'middleware/parse_xml'
require_relative 'middleware/raise_error'

module JaLC
  module Registration
    class Client
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def post(xml_file)
        response = conn.post(
          '/jalc/infoRegistry/registDataReceive/index',
          {
            login_id: Faraday::Multipart::ParamPart.new(config.id, 'text/plain'),
            login_password: Faraday::Multipart::ParamPart.new(config.password, 'text/plain'),
            fname: Faraday::Multipart::FilePart.new(xml_file, 'text/xml'),
          },
        )
        response.body
      end

      def get_result(exec_id)
        response = conn.get(
          '/jalc/infoRegistry/registDataResult/index',
          {
            login_id: config.id,
            login_password: config.password,
            exec_id: exec_id,
          },
        )
        response.body
      end

      private

      def conn
        @conn ||= Faraday.new(
          url: config.base_url,
          headers: { 'User-Agent' => "jalc-ruby v#{VERSION}" },
        ) do |f|
          f.request :multipart
          f.use Middleware::RaiseError
          f.use Middleware::ParseXML
          f.response :raise_error
          if config.logger
            f.response :logger, config.logger, { headers: false } do |logger|
              logger.filter(/(password=)\w+/, '\1[FILTERED]')
            end
          end
        end
      end
    end
  end
end
