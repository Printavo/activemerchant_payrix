# frozen_string_literal: true

require "activemerchant_payrix"
require "vcr"

def ci?
  ENV["CIRCLE_ARTIFACTS"].nil?
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = true
  config.ignore_localhost = true
  config.cassette_library_dir = "spec/support/vcr_cassettes"
  config.hook_into :webmock

  config.configure_rspec_metadata!

  config.default_cassette_options = {
    record: ci? ? :none : :once,
    persister_options: {downcase_cassette_names: true}
  }

  # Save human-readable response bodies, if `tag: :readable_response` passed to VCR
  config.before_record(:readable_response) do |interaction|
    interaction.response.body.force_encoding("UTF-8")
  end
end

ENV["PAYRIX_PRIVATE_TOKEN"] ||= "respec-test-token-will-not-work-in-production"
