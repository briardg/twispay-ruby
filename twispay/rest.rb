# frozen_string_literal: true
require 'httparty'

module Twispay
  class Rest
    include HTTParty
    base_uri ENV['TWISPAY_API_URL'] || "https://api-stage.twispay.com"

    def initialize(token: ENV["TWISPAY_TOKEN"])
      @token = token
    end

    def get_order(id)
      self.class.get("#{order_url}/#{id}", base_options)
    end

    def cancel_recurring_order(id:, reason: nil, message: nil, terminate_order: nil )
      options = base_options.merge({
        headers: {"Content-Type": "application/x-www-form-urlencoded"}.merge(base_options[:headers]),
        body: URI.encode_www_form({
          reason: reason,
          message: message,
          terminateOrder: terminate_order
        }.delete_if { |k, v| v.nil? })
      })
      self.class.delete("#{order_url}/#{id}", options)
    end

    private

    DELETE_ORDER_REASONS_LIST = %w[
      fraud-confirm
      highly-suspicious
      duplicated-transaction
      customer-demand
      test-transaction
    ].freeze

    def base_options
      {
        headers: {
          "Authorization" => "Bearer #{token}"
        }
      }
    end

    def token
      @token
    end

    def order_url
      "/order"
    end

    def reason_correct?(reason)
      DELETE_ORDER_REASONS_LIST.include?(reason)
    end
  end
end
