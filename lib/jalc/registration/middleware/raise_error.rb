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
                  'IDとパスワードの組合せが間違っているか、アクセス元のIPアドレスがJaLCに登録されているIPアドレスと異なっている可能性があります (errcd=*)'
          when '#'
            raise InvalidXMLError, 'XMLファイルの構造に誤りがあるか、login_id、login_passwd、fnameのパラメータに未設定のものがある可能性があります (errcd=#)'
          when '+'
            raise RegistrationError, 'fnameで指定したファイルがXMLファイルでないか、XMLファイルの文字コードがUTF-8でない可能性があります (errcd=+)'
          end
        end
      end
    end

    class RegistrationError < Error; end
    class AuthenticationError < RegistrationError; end
    class InvalidXMLError < RegistrationError; end
  end
end
