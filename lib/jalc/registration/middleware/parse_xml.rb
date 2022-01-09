# frozen_string_literal: true

require 'rexml'

module JaLC
  module Registration
    module Middleware
      class ParseXML < Faraday::Middleware
        def on_complete(env)
          env.body = REXML::Document.new(env.body.to_s)
        end
      end
    end
  end
end
