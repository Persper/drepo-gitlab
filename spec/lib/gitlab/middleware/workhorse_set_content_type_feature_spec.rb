# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Middleware::WorkhorseSetContentTypeFeature do
  let(:app) { double(:app) }
  let(:middleware) { described_class.new(app) }
  let(:env) { {} }
  let(:response_headers) { {} }

  describe '#call' do
    before do
      expect(app).to receive(:call).and_return([200, response_headers, ""])
    end

    it "does not set #{described_class::FEATURE_HEADER} header" do
      stub_feature_flags(workhorse_set_content_type: true)

      _, headers, _ = middleware.call(env)

      expect(headers.keys).not_to include(described_class::FEATURE_HEADER)
    end

    shared_examples 'feature workhorse_set_content_type' do
      before do
        stub_feature_flags(workhorse_set_content_type: flag_value)
      end

      context 'enabled' do
        let(:flag_value) { true }

        it "sets #{described_class::FEATURE_HEADER} header" do
          _, headers, _ = middleware.call(env)

          expect(headers[described_class::FEATURE_HEADER]).to eq "true"
        end
      end

      context 'disabled' do
        let(:flag_value) { false }

        it "does not set #{described_class::FEATURE_HEADER} header" do
          _, headers, _ = middleware.call(env)

          expect(headers.keys).not_to include(described_class::FEATURE_HEADER)
        end
      end
    end

    context "when #{Gitlab::Workhorse::SEND_DATA_HEADER} header is present"  do
      let(:response_headers) { { "#{Gitlab::Workhorse::SEND_DATA_HEADER}" => "whatever" } }

      it_behaves_like "feature workhorse_set_content_type"
    end

    context "when X-Sendfile header is present"  do
      let(:response_headers) { { "X-Sendfile" => "whatever" } }

      it_behaves_like "feature workhorse_set_content_type"
    end
  end
end
