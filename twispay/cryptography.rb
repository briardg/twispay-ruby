# frozen_string_literal: true

require "base64"
require "openssl"
require "json"

module Twispay
  class Cryptography
    class << self
      def get_base64_json_request(order_data)
        Base64.strict_encode64(order_data.to_json)
      end

      def get_base64_checksum(order_data, secret_key)
        Base64.strict_encode64(
          OpenSSL::HMAC.digest(
            OpenSSL::Digest.new("sha512"),
            secret_key,
            order_data.to_json
          )
        )
      end

      def decrypt_ipn_response(encrypted_ipn_esponse, secret_key)
        # get the IV and the encrypted data
        encrypted_parts = encrypted_ipn_esponse.split(",")
        iv = Base64.strict_decode64(encrypted_parts[0])
        encrypted_data = Base64.strict_decode64(encrypted_parts[1])

        # decrypt the encrypted data
        cipher = OpenSSL::Cipher::AES256.new(:CBC).decrypt
        cipher.iv = iv
        cipher.key = secret_key

        # JSON decode the decrypted data
        decrypted_ipn_response = cipher.update(encrypted_data) + cipher.final
        JSON.parse(decrypted_ipn_response)
      end
    end
  end
end
