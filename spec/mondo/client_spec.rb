require 'spec_helper'

describe Mondo::Client do
  include_context 'client setup'

  describe '#accounts' do
    it 'returns a list of accounts owned by the currently authorised user' do
      expect(client.accounts).to be_a(Array)
      expect(client.accounts.first).to be_a(Mondo::Account)
    end
  end

  describe '#balance' do
    it 'returns balance information for a specific account that is required' do
      expect(client.account_id).to be_present
      expect(client.balance).to be_a(Mondo::Balance)
    end

    it 'raises an exception if the account ID is missing' do
      expect { accountless_client.balance }.to \
        raise_error(Mondo::ClientError, /must provide an account ID/)
    end
  end

  describe '#transaction' do
    let(:transaction_id) { "tx_00008zIcpb1TB4yeIFXMzx" }

    it 'returns an individual transaction, fetched by its ID' do
      expect(client.transaction(transaction_id)).to be_a(Mondo::Transaction)
    end

    it 'raises an exception given a unexistant ID' do
      expect { accountless_client.transaction('bogus') }.to \
        raise_error(Mondo::ApiError, /Transaction not found/)
    end
  end

  describe '#transactions' do
    it 'returns a list of transactions on the user’s account' do
      expect(client.transactions).to be_a(Array)

      client.transactions.all? do |transaction|
        expect(transaction).to be_a(Mondo::Transaction)
      end
    end

    it 'raises an exception if the account ID is missing' do
      expect { accountless_client.transactions }.to \
        raise_error(Mondo::ClientError, /must provide an account ID/)
    end
  end

  describe '#create_feed_item' do
    it "creates a new feed item (basic type) on the user's feed" do
      expect {
        client.create_feed_item(attributes_for(:feed_item))
      }.not_to raise_error
    end

    it 'raises an exception if the account ID is missing' do
      expect {
        accountless_client.create_feed_item(attributes_for(:feed_item))
      }.to raise_error(Mondo::ClientError, /must provide an account ID/)
    end
  end

  describe '#web_hooks' do
    let(:webhook_url) { 'http://example.com/callback' }
    let(:webhook_id) { 'webhook_000091yhhzvJSxLYGAceC9' }

    it 'registers a webhook to receive notification of events in an account' do
      webhooks = client.register_web_hook(webhook_url)
      webhook = webhooks.first

      expect(webhook).to be_a(Mondo::WebHook)
      expect(webhook.url).to eq(webhook_url)
    end

    it 'lists the webhooks your application has registered on an account' do
      webhooks = client.web_hooks

      webhooks.all? do |webhook|
        expect(webhook).to be_a(Mondo::WebHook)
      end
    end

    it 'removes a specific webhook from an account' do
      webhooks = client.deregister_web_hook(webhook_id)

      expect(webhooks.size).to eq(1)
    end
  end

  describe '#cards' do
    pending('In progress...')
  end

  describe '#attachments' do
    pending('In progress...')
  end
end
