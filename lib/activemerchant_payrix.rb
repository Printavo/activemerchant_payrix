# frozen_string_literal: true

require "activemerchant_payrix/version"
require "activemerchant_payrix/active_merchant/billing/payrix_gateway"

module ActivemerchantPayrix
  class Error < StandardError; end

  def self.test?
    env != "production"
  end

  def self.env
    presence(ENV["PAYRIX_ENV"]) || presence(ENV["RAILS_ENV"]) || presence(ENV["RACK_ENV"]) || "development"
  end

  private_class_method def self.presence(obj)
    obj unless obj.blank?
  end
end
