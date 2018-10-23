# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::LfsToken do
  describe '#token' do
    shared_examples 'an LFS token generator' do
      it 'returns a computed token' do
        expect(Settings).to receive(:attr_encrypted_db_key_base).and_return('fbnbv6hdjweo53qka7kza8v8swxc413c05pb51qgtfte0bygh1p2e508468hfsn5ntmjcyiz7h1d92ashpet5pkdyejg7g8or3yryhuso4h8o5c73h429d9c3r6bjnet').twice

        token = handler.token

        expect(token).not_to be_nil
        expect(token).to be_a String
        expect(described_class.new(actor).token_valid?(token)).to be_truthy
      end
    end

    context 'when the actor is a user' do
      let(:actor) { create(:user, username: 'test_user_lfs_1') }
      let(:handler) { described_class.new(actor) }

      before do
        allow(actor).to receive(:encrypted_password).and_return('$2a$04$ETfzVS5spE9Hexn9wh6NUenCHG1LyZ2YdciOYxieV1WLSa8DHqOFO')
      end

      it_behaves_like 'an LFS token generator'

      it 'returns the correct username' do
        expect(handler.actor_name).to eq(actor.username)
      end

      it 'returns the correct token type' do
        expect(handler.type).to eq(:lfs_token)
      end
    end

    context 'when the actor is a key' do
      let(:user) { create(:user, username: 'test_user_lfs_2') }
      let(:actor) { create(:key, user: user) }
      let(:handler) { described_class.new(actor) }

      before do
        allow(user).to receive(:encrypted_password).and_return('$2a$04$C1GAMKsOKouEbhKy2JQoe./3LwOfQAZc.hC8zW2u/wt8xgukvnlV.')
      end

      it_behaves_like 'an LFS token generator'

      it 'returns the correct username' do
        expect(handler.actor_name).to eq(user.username)
      end

      it 'returns the correct token type' do
        expect(handler.type).to eq(:lfs_token)
      end
    end

    context 'when the actor is a deploy key' do
      let(:actor_id) { 1 }
      let(:actor) { create(:deploy_key) }
      let(:project) { create(:project) }
      let(:handler) { described_class.new(actor) }

      before do
        allow(actor).to receive(:id).and_return(actor_id)
        allow(actor).to receive(:fingerprint).and_return('0d:0d:cd:de:3d:b2:b9:67:db:db:34:99:e5:23:2a:2e')
      end

      it_behaves_like 'an LFS token generator'

      it 'returns the correct username' do
        expect(handler.actor_name).to eq("lfs+deploy-key-#{actor_id}")
      end

      it 'returns the correct token type' do
        expect(handler.type).to eq(:lfs_deploy_token)
      end
    end

    context 'when the actor is invalid' do
      it 'raises an exception' do
        expect { described_class.new('invalid') }.to raise_error('Bad Actor')
      end
    end
  end

  describe '#token_valid?' do
    let(:actor) { create(:user, username: 'test_user_lfs_1') }
    let(:handler) { described_class.new(actor) }

    before do
      allow(actor).to receive(:encrypted_password).and_return('$2a$04$ETfzVS5spE9Hexn9wh6NUenCHG1LyZ2YdciOYxieV1WLSa8DHqOFO')
    end

    context 'and the token is invalid' do
      context "because it's junk" do
        it 'returns false' do
          expect(handler.token_valid?('junk')).to be_falsey
        end
      end

      context "because it's been fiddled with" do
        it 'returns false' do
          fiddled_token = handler.token.tap { |token| token[0] = 'E' }
          expect(handler.token_valid?(fiddled_token)).to be_falsey
        end
      end

      context "because it was generated with a different secret" do
        it 'returns false' do
          different_actor = create(:user, username: 'test_user_lfs_2')
          different_secret_token = described_class.new(different_actor).token
          expect(handler.token_valid?(different_secret_token)).to be_falsey
        end
      end

      context "because it's expired" do
        it 'returns false' do
          expired_token = handler.token
          # Needs to be 120 seconds, because the default expiry is 60 seconds
          # with an additional 60 second leeway.
          Timecop.freeze(Time.now + 120) do
            expect(handler.token_valid?(expired_token)).to be_falsey
          end
        end
      end
    end
  end
end
