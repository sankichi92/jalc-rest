# frozen_string_literal: true

require 'faraday'

module JaLC
  module REST
    class Client
      def prefixes
        Faraday.get('https://api.japanlinkcenter.org/prefixes')
      end
    end
  end
end
