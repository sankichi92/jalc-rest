# frozen_string_literal: true

require 'faraday'

require_relative '../error'

module JaLC
  module Registration
    module Middleware
      class RaiseError < Faraday::Middleware
        def on_complete(env)
          case env.body.root.elements['head/errcd']&.text
          when '*'
            raise AuthenticationError,
                  'Wrong login_id/login_password or non-registered IP address request (errcd=*)'
          when '#'
            raise InvalidXMLError, 'XML format is invalid or any required params are blank (errcd=#)'
          when '+'
            raise RegistrationError, 'Non-XML file, non UTF-8 encoding or other error (errcd=+)'
          end
        end
      end
    end

    class RegistrationError < Error; end
    class AuthenticationError < RegistrationError; end
    class InvalidXMLError < RegistrationError; end
  end
end
