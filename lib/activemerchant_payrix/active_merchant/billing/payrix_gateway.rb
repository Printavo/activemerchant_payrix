require "activemerchant"

# API Documentation: https://portal.payrix.com/docs/api

module ActiveMerchant
  module Billing
    class PayrixGateway < ActiveMerchant::Billing::Gateway
      LIVE_URL = "https://api.payrix.com".freeze
      LIVE_URL_V2 = "https://apiv2.payrix.com".freeze
      TEST_URL = "https://test-api.payrix.com".freeze

      PRIVATE_TOKEN = ENV["PAYRIX_PRIVATE_TOKEN"]

      ORIGIN_ECOMMERCE = 2
      ORIGIN_PAYFRAME = 8

      TXN_TYPE_CREDIT_CARD_SALE = 1
      TXN_TYPE_CREDIT_CARD_AUTH = 2
      TXN_TYPE_CREDIT_CARD_CAPTURE = 3
      TXN_TYPE_CREDIT_CARD_REVERSED = 4
      TXN_TYPE_CREDIT_CARD_REFUND = 5
      TXN_TYPE_ECHECK_SALE = 7
      TXN_TYPE_ECHECK_REFUND = 8
      TXN_TYPE_ECHECK_REDEPOSIT = 11
      TXN_TYPE_ECHECK_VERIFICATION = 12

      TXN_TYPES_ECHECK = [TXN_TYPE_ECHECK_SALE, TXN_TYPE_ECHECK_REFUND, TXN_TYPE_ECHECK_REDEPOSIT, TXN_TYPE_ECHECK_VERIFICATION].freeze
      TXN_TYPES_REFUND = [TXN_TYPE_CREDIT_CARD_REVERSED, TXN_TYPE_CREDIT_CARD_REFUND, TXN_TYPE_ECHECK_REFUND, TXN_TYPE_ECHECK_REDEPOSIT].freeze

      TXN_STATUS_PENDING = 0
      TXN_STATUS_APPROVED = 1
      TXN_STATUS_FAILED = 2
      TXN_STATUS_CAPTURED = 3
      TXN_STATUS_SETTLED = 4
      TXN_STATUS_RETURNED = 5

      MERCHANT_STATUS_NOT_READY = 0
      MERCHANT_STATUS_READY = 1
      MERCHANT_STATUS_BOARDED = 2
      MERCHANT_STATUS_MANUAL = 3
      MERCHANT_STATUS_CLOSED = 4
      MERCHANT_STATUS_INCOMPLETE = 5
      MERCHANT_STATUS_DENIED = 6

      DISPUTE_CYCLE_RETRIEVAL = "retrieval".freeze
      DISPUTE_CYCLE_FIRST = "first".freeze
      DISPUTE_CYCLE_ARBITRATION = "arbitration".freeze
      DISPUTE_CYCLE_REVERSAL = "reversal".freeze
      DISPUTE_CYCLE_REPRESENTMENT = "representment".freeze
      DISPUTE_CYCLE_PRE_ARBITRATION = "preArbitration".freeze
      DISPUTE_CYCLE_ARBITRATION_LOST = "arbitrationLost".freeze
      DISPUTE_CYCLE_ARBITRATION_SPLIT = "arbitrationSplit".freeze
      DISPUTE_CYCLE_ARBITRATION_WON = "arbitrationWon".freeze
      DISPUTE_CYCLE_ISSUER_ACCEPT_PRE_ARBITRATION = "issuerAcceptPreArbitration".freeze
      DISPUTE_CYCLE_ISSUER_DECLINED_PRE_ARBITRATION = "issuerDeclinedPreArbitration".freeze
      DISPUTE_CYCLE_RESPONSE_TO_ISSUER_PRE_ARBITRATION = "responseToIssuerPreArbitration".freeze

      DISPUTE_STATUS_OPEN = "open".freeze
      DISPUTE_STATUS_CLOSED = "closed".freeze
      DISPUTE_STATUS_WON = "won".freeze
      DISPUTE_STATUS_LOST = "lost".freeze

      DISBURSEMENT_STATUS_REQUESTED = 1
      DISBURSEMENT_STATUS_PROCESSING = 2
      DISBURSEMENT_STATUS_PROCESSED = 3
      DISBURSEMENT_STATUS_FAILED = 4
      DISBURSEMENT_STATUS_DENIED = 5
      DISBURSEMENT_STATUS_RETURNED = 6

      DISBURSEMENT_ENTRIES_STATUS_PENDING = "pending".freeze
      DISBURSEMENT_ENTRIES_STATUS_PROCESSING = "processing".freeze
      DISBURSEMENT_ENTRIES_STATUS_PROCESSED = "processed".freeze

      DISBURSEMENT_EVENT_DAYS = 1
      DISBURSEMENT_EVENT_WEEKS = 2
      DISBURSEMENT_EVENT_CC_CAPTURE = 7
      DISBURSEMENT_EVENT_CC_REFUND = 8
      DISBURSEMENT_EVENT_PAYOUT = 10
      DISBURSEMENT_EVENT_CHARGEBACK = 11
      DISBURSEMENT_EVENT_INTERCHANGE = 13
      DISBURSEMENT_EVENT_ACH_FAIL = 15
      DISBURSEMENT_EVENT_ARBITRATION = 20
      DISBURSEMENT_EVENT_ECHECK_SALE = 21
      DISBURSEMENT_EVENT_ECHECK_REFUND = 22
      DISBURSEMENT_EVENT_ECHECK_RETURN = 23
      DISBURSEMENT_EVENT_SETTLEMENT = 24
      DISBURSEMENT_EVENT_RESERVE_ENTRY = 36
      DISBURSEMENT_EVENT_RESERVE_ENTRY_RELEASE = 37
      DISBURSEMENT_EVENT_REMAINDER = 40
      DISBURSEMENT_EVENT_REMAINDER_USED = 41

      # Unused disbursement events
      DISBURSEMENT_EVENT_MONTHS = 3
      DISBURSEMENT_EVENT_YEARS = 4
      DISBURSEMENT_EVENT_SINGLE = 5
      DISBURSEMENT_EVENT_AUTH = 6
      DISBURSEMENT_EVENT_BOARD = 9
      DISBURSEMENT_EVENT_OVERDRAFT = 12
      DISBURSEMENT_EVENT_PROCESSOR = 14
      DISBURSEMENT_EVENT_ACCOUNT = 16
      DISBURSEMENT_EVENT_SIFT = 17
      DISBURSEMENT_EVENT_ADJUSTMENT = 18
      DISBURSEMENT_EVENT_RETRIEVAL = 19
      DISBURSEMENT_EVENT_MIS_USE = 25
      DISBURSEMENT_EVENT_PROFITSHARE = 26
      DISBURSEMENT_EVENT_UNAUTH = 27
      DISBURSEMENT_EVENT_ACHNOC = 28
      DISBURSEMENT_EVENT_ECNOC = 29
      DISBURSEMENT_EVENT_ECFAIL = 30
      DISBURSEMENT_EVENT_ECNSF = 31
      DISBURSEMENT_EVENT_CURRENCY = 32
      DISBURSEMENT_EVENT_TERMINAL_TXN = 33
      DISBURSEMENT_EVENT_REVERSE_PAYOUT = 34
      DISBURSEMENT_EVENT_PARTIAL_REVERSE_PAYOUT = 35
      DISBURSEMENT_EVENT_PENDING_ENTRY = 38
      DISBURSEMENT_EVENT_PENDING_PAID = 39
      DISBURSEMENT_EVENT_PENDING_REFUND_CANCELLED = 42

      PAYMENT_METHODS = {
        1 => "American Express",
        2 => "Visa",
        3 => "MasterCard",
        4 => "Diners Club",
        5 => "Discover",
        7 => "Debit card",
        8 => "Checking account",
        9 => "Savings account",
        10 => "Corporate checking account",
        11 => "Corporate savings account"
      }.freeze

      ITEM_UM_EACH = "EACH".freeze

      def initialize(options = {private_token: PRIVATE_TOKEN, test: !::Rails.env.production?})
        requires!(options, :private_token)

        super
      end

      def merchant_valid?(merchant_id)
        return false if merchant_id.blank?

        response = get(endpoint: :merchants, id: merchant_id)

        response.dig(:id) == merchant_id
      rescue
        false
      end

      def token_purchase(token, currency, amount, origin, type, options = {})
        payload = new_transaction_payload(token, currency, amount, origin, type).merge(options)

        post(:transactions, payload)
      end

      def void(id, type, origin, options = {})
        payload = {fortxn: id, type:, origin:}.merge(options)

        post(:transactions, payload)
      end

      def credit(id, type, origin, amount = nil, options = {})
        payload = {fortxn: id, type:, origin:, total: amount}.merge(options)

        post(:transactions, payload)
      end

      def token(id, url_params = nil)
        return if id.blank?

        get(endpoint: :tokens, id:, url_params:)
      end

      def token_update(id, payload = {})
        put(:tokens, id, payload)
      end

      def customer(id)
        return if id.blank?

        get(endpoint: :customers, id:)
      end

      def merchant(id, url_params = nil)
        return if id.blank?

        get(endpoint: :merchants, id:, url_params:)
      end

      def merchants(search, url_params = nil)
        get_some(endpoint: :merchants, url_params:, headers: token_header.merge(search: search.join("&")))
      end

      def entity(id, url_params = nil)
        return if id.blank?

        get(endpoint: :entities, id:, url_params:)
      end

      def entity_update(id, fields)
        return if id.blank? || fields.blank?

        put(:entities, id, fields.to_json)
      end

      def transaction(id, url_params = nil)
        return if id.blank?

        get(endpoint: :transactions, id:, url_params:)
      end

      def transactions(search, url_params = nil)
        get_some(endpoint: :transactions, url_params:, headers: token_header.merge(search: search.join("&")))
      end

      def transaction_update(id, fields)
        return if id.blank? || fields.blank?

        put(:transactions, id, fields.to_json)
      end

      def entries(search, url_params = nil)
        get_some(endpoint: :entries, url_params:, headers: token_header.merge(search: search.join("&")))
      end

      def chargeback(id, url_params = nil)
        return if id.blank?

        get(endpoint: :chargebacks, id:, url_params:)
      end

      def chargebacks(search, url_params = nil)
        get_some(endpoint: :chargebacks, url_params:, headers: token_header.merge(search: search.join("&")))
      end

      def decision(id)
        return if test? || id.blank?

        HTTP.headers(v2_token_header).get(risk_summary_url(id:))
      end

      def disbursement(id, url_params = nil)
        return if id.blank?

        get(endpoint: :disbursements, id:, url_params:)
      end

      def disbursements(search, url_params = nil, all: false)
        headers = token_header.merge(search: search.join("&"))
        return make_request(endpoint: :disbursements, url_params:) { |url| ssl_get(url, headers) }.with_indifferent_access.dig(:response) unless all

        get_all(:disbursements, url_params, headers)
      end

      def funds(search, url_params = nil)
        get_some(endpoint: :funds, url_params:, headers: token_header.merge(search: search.join("&")))
      end

      def disbursement_entries(search, url_params = nil)
        headers = token_header.merge(search: search.join("&"))

        get_all(:disbursementEntries, url_params, headers)
      end

      private

      def new_transaction_payload(token, currency, amount, origin, type)
        {
          token:,
          currency:,
          total: amount.to_i,
          origin:,
          type:
        }
      end

      def get(endpoint:, id:, url_params: [])
        make_request(endpoint:, id:, url_params:) { |url| ssl_get(url, token_header) }.with_indifferent_access.dig(:response, :data, 0)
      end

      def get_some(endpoint:, headers:, url_params: [])
        make_request(endpoint:, url_params:) { |url| ssl_get(url, headers) }.with_indifferent_access.dig(:response, :data)
      end

      def get_all(endpoint, url_params, headers)
        all_data = []
        url_params ||= []
        url_params << "page[limit]=100"
        page = 0
        loop do
          paged_url_params = url_params + ["page[number]=#{page += 1}"]
          response = make_request(endpoint:, url_params: paged_url_params) { |url| ssl_get(url, headers) }.with_indifferent_access.dig(:response)
          all_data.concat(response[:data])

          break unless response.dig(:details, :page, :hasMore)
        end

        all_data
      end

      def post(action, payload = nil)
        commit(make_request(endpoint: action) { |url| ssl_post(url, payload&.to_json, token_header) }.with_indifferent_access[:response])
      end

      def put(action, id, payload = nil)
        commit(make_request(endpoint: action, id:) { |url| ssl_put(url, payload&.to_json, token_header) }.with_indifferent_access[:response])
      end

      def commit(response)
        errors = response[:errors] || response.dig(:data, :errors) || []

        Response.new(
          errors.blank?,
          error_message(response),
          response,
          test: test?,
          error_code: errors.dig(0, :errorCode),
          authorization: response.dig(:data, 0, :id)
        )
      end

      def error_message(response)
        errors = response[:errors] || response.dig(:data, :errors)
        msg = errors&.dig(0, :msg) || ""

        error_field = errors&.dig(0, :field)
        msg += " (field: #{error_field})" if error_field.present?

        msg.strip
      end

      def url(endpoint: nil, id: nil, url_params: [])
        base_url = test? ? TEST_URL : LIVE_URL
        case endpoint
        when :transactions
          base_url += "/txns"
        else
          base_url += "/#{endpoint}" if endpoint.present?
        end

        base_url += "/#{id}" if id.present?
        base_url += "?#{url_params.join("&")}" if url_params.present?

        base_url
      end

      def risk_summary_url(id: nil)
        URI.parse("#{LIVE_URL_V2}/risk/v2/decision/policy-run-summary?stage=auth&transactionId=#{id}")
      end

      def v2_token_header
        {
          "Authorization" => "Bearer #{@options[:private_token]}",
          "login" => "required-but-not-used",
          "legacy-auth-header-name" => "APIKEY"
        }
      end

      def token_header
        {
          "Content-Type": "application/json",
          APIKEY: @options[:private_token]
        }
      end

      def ssl_put(endpoint, data, headers = {})
        ssl_request(:put, endpoint, data.to_json, headers)
      end

      def make_request(endpoint:, id: nil, url_params: [])
        url = url(endpoint:, id:, url_params:)
        JSON.parse(yield(url))
      end
    end
  end
end
