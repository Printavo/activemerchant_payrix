# frozen_string_literal: true

RSpec.describe ActivemerchantPayrix do
  it "has a version number" do
    expect(ActivemerchantPayrix::VERSION).not_to be nil
  end

  describe ".test?" do
    subject { ActivemerchantPayrix.test? }

    context "when env is production" do
      before { allow(ENV).to receive(:[]).with("PAYRIX_ENV").and_return("production") }

      it { is_expected.to eq(false) }
    end

    context "when env is anything other than production" do
      it { is_expected.to eq(true) }
    end
  end

  describe ".env" do
    subject { ActivemerchantPayrix.env }

    before { allow(ENV).to receive(:[]).and_call_original }

    context "when there are no environment variables denoting our environment" do
      it { is_expected.to eq("development") }
    end

    context "when there is a RACK_ENV environment_variable set" do
      let(:rack_env) { "staging" }

      before { allow(ENV).to receive(:[]).with("RACK_ENV").and_return(rack_env) }

      it { is_expected.to eq(rack_env) }
    end

    context "when there is a RAILS_ENV environment_variable set" do
      let(:rails_env) { "staging" }

      before { allow(ENV).to receive(:[]).with("RAILS_ENV").and_return(rails_env) }

      it { is_expected.to eq(rails_env) }

      context "and a RACK_ENV environment variable is also set" do
        let(:rack_env) { "production" }

        before { allow(ENV).to receive(:[]).with("RACK_ENV").and_return(rack_env) }

        it { is_expected.to eq(rails_env) }
      end
    end

    context "when there is a PAYRIX_ENV environment_variable set" do
      let(:payrix_env) { "staging" }

      before { allow(ENV).to receive(:[]).with("PAYRIX_ENV").and_return(payrix_env) }

      it { is_expected.to eq(payrix_env) }

      context "and a RACK_ENV environment variable is also set" do
        let(:rack_env) { "production" }

        before { allow(ENV).to receive(:[]).with("RACK_ENV").and_return(rack_env) }

        it { is_expected.to eq(payrix_env) }
      end

      context "and a RAILS_ENV environment variable is also set" do
        let(:rails_env) { "production" }

        before { allow(ENV).to receive(:[]).with("RAILS_ENV").and_return(rails_env) }

        it { is_expected.to eq(payrix_env) }
      end
    end
  end
end
