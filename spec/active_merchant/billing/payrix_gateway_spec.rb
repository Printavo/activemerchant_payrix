# frozen_string_literal: true

RSpec.describe ActiveMerchant::Billing::PayrixGateway, :vcr do
  let(:private_token) { ENV["PAYRIX_PRIVATE_TOKEN"] }
  let(:gateway) { described_class.new(private_token:, test: true) }

  shared_examples "failed object lookup requests" do
    context "when the ID is not valid" do
      let(:id) { "t_failed_id" }

      it { is_expected.to eq(nil) }
    end

    context "when the ID is nil" do
      let(:id) { nil }

      it { is_expected.to eq(nil) }
    end
  end

  describe "#merchant_valid?" do
    subject { gateway.merchant_valid?(merchant_id) }

    context "when the merchant ID is valid" do
      let(:merchant_id) { "t1_mer_6227be75a75b292bde6dbe2" }

      it { is_expected.to eq(true) }
    end

    context "when the merchant ID is not valid" do
      let(:merchant_id) { "t1_mer_NOT-VALID" }

      it { is_expected.to eq(false) }
    end
  end

  describe "#token_purchase" do
    subject { gateway.token_purchase(token, currency, amount, origin, type, options) }

    let(:currency) { "USD" }
    let(:amount) { 400 }
    let(:origin) { ActiveMerchant::Billing::PayrixGateway::ORIGIN_PAYFRAME }
    let(:type) { ActiveMerchant::Billing::PayrixGateway::TXN_TYPE_CREDIT_CARD_SALE }
    let(:options) { {order: "1234567", description: "Payment for Invoice #10", tax: 1} }

    context "when a transaction can be made" do
      let(:token) { "4da838f0da85bdcd0c906c68c8ab7995" }

      it "returns a successful response" do
        expect(subject.success?).to eq(true)
      end
    end

    context "when a transaction can not be made" do
      let(:token) { "NOT-A-VALID-TOKEN" }

      it "returns an unsuccessful response" do
        expect(subject.success?).to eq(false)
      end
    end
  end

  describe "#token" do
    subject { gateway.token(id) }

    context "when the token ID is valid" do
      let(:id) { "t1_tok_6244d08bb29de1c181432bc" }

      it { is_expected.to include({id:}) }
    end

    include_examples "failed object lookup requests"
  end

  describe "#customer" do
    subject { gateway.customer(id) }

    context "when the customer ID is valid" do
      let(:id) { "t1_cus_62433a716b885716b07066d" }

      it { is_expected.to include({id:}) }
    end

    include_examples "failed object lookup requests"
  end

  describe "#credit" do
    subject { gateway.credit(transaction_id, ActiveMerchant::Billing::PayrixGateway::ORIGIN_ECOMMERCE, nil, {}) }

    context "when the transaction ID is valid" do
      let(:transaction_id) { "t1_txn_626aaa5e6a0749d6d715419" }

      it "returns a successful response" do
        expect(subject.success?).to eq(true)
        expect(subject.params.dig(:data, 0)).to include({fortxn: transaction_id, type: ActiveMerchant::Billing::PayrixGateway::TXN_TYPE_CREDIT_CARD_REFUND})
      end
    end

    context "when the transaction ID is not valid" do
      let(:transaction_id) { "t1_trx_NOT-VALID" }

      it "returns an unsuccessful response" do
        expect(subject.success?).to eq(false)
      end
    end
  end

  describe "#void" do
    subject { gateway.void(transaction_id, ActiveMerchant::Billing::PayrixGateway::ORIGIN_ECOMMERCE, {}) }

    context "when the transaction ID is valid and can be voided" do
      let(:transaction_id) { "t1_txn_62a384a224b7d6d03864126" }

      it "returns a successful response" do
        expect(subject.success?).to eq(true)
        expect(subject.params.dig(:data, 0)).to include({fortxn: transaction_id, type: ActiveMerchant::Billing::PayrixGateway::TXN_TYPE_CREDIT_CARD_REVERSED})
      end
    end

    context "when the transaction ID is not valid" do
      let(:transaction_id) { "t1_trx_NOT-VALID" }

      it "returns an unsuccessful response" do
        expect(subject.success?).to eq(false)
      end
    end
  end

  describe "#transaction" do
    subject { gateway.transaction(id) }

    context "when the ID is valid" do
      let(:id) { "t1_txn_627ac6be1da3ad2e0858d91" }

      it { is_expected.to include({merchant: "t1_mer_6261d8dd066e9d49f047b3e"}) }
    end

    include_examples "failed object lookup requests"
  end

  describe "#merchant" do
    subject { gateway.merchant(id) }

    context "when the ID is valid" do
      let(:id) { "t1_mer_6261d8dd066e9d49f047b3e" }

      it { is_expected.to include({entity: "t1_ent_6261d8dcf0c10a0f9d43523"}) }
    end

    include_examples "failed object lookup requests"
  end

  describe "#entity" do
    subject { gateway.entity(id) }

    context "when the ID is valid" do
      let(:id) { "t1_ent_6261d8dcf0c10a0f9d43523" }

      it { is_expected.to include({login: "t1_log_6261d8dcef3c02296a23ac4"}) }
    end

    include_examples "failed object lookup requests"
  end

  describe "#entries" do
    subject { gateway.entries(search) }

    context "when the ID is valid" do
      let(:id) { "t1_chb_627ad341b3226992c967215" }
      let(:search) { ["eventId[equals]=#{id}", "isFee[equals]=1"] }

      it "returns a list searched for entries" do
        expect(subject.map { |entity| entity[:eventId] }.uniq).to eq([id])
        expect(subject.map { |entity| entity[:isFee] }.uniq).to eq([1])
      end
    end
  end

  describe "#merchants" do
    subject { gateway.merchants(search) }

    context "when the search criterion is valid" do
      let(:entity_id) { "t1_ent_6227be759e683008bed22a7" }
      let(:search) { ["entity[equals]=#{entity_id}"] }

      it "returns a list of merchants matching the search criteria" do
        expect(subject.map { |merchant| merchant[:entity] }.uniq).to eq([entity_id])
      end
    end
  end

  describe "#entity_update" do
    subject { gateway.entity_update(entity_id, update_fields) }

    let(:custom) { "custom-100" }
    let(:entity_id) { "t1_ent_626afdc71c90d0b8a1388ce" }
    let(:update_fields) { {custom:} }

    it "updates the custom field" do
      expect(subject.success?).to eq(true)
      expect(subject.params.dig(:data, 0)[:custom]).to eq(custom)
    end
  end

  describe "#transaction_update" do
    subject { gateway.transaction_update(id, update_fields) }

    let(:channel) { "channel-101" }
    let(:id) { "t1_txn_62b1e93fc2aaac49b149f75" }
    let(:update_fields) { {channel:} }

    it "updates the channel field" do
      expect(subject.success?).to eq(true)
      expect(subject.params.dig(:data, 0)[:channel]).to eq(channel)
    end
  end

  describe "#disbursement" do
    subject { gateway.disbursement(id) }

    context "when the ID is valid" do
      let(:id) { "t1_dbm_630550ab2747cc033d0ecc8" }

      it { is_expected.to include({entity: "t1_ent_62bc7a5235ddbe87f6fa04f"}) }
    end

    context "when the ID is not valid" do
      let(:id) { "t_failed_id" }

      it { is_expected.to eq(nil) }
    end
  end

  describe "#disbursements" do
    subject { gateway.disbursements(["entity[equals]=#{entity_id}"], ["page[limit]=1"]) }

    context "when the entity_id is for a valid merchant with at least 1 disbursement" do
      let(:entity_id) { "t1_ent_62bc7a5235ddbe87f6fa04f" }

      it "shows disbursement data" do
        expect(subject[:data].count).to eq(1)
        expect(subject[:data][0]).to include(id: "t1_dbm_630550ab2747cc033d0ecc8")
      end

      it "contains pagination details" do
        expect(subject[:details][:page]).to include(current: 1, hasMore: true)
      end
    end
  end
end
