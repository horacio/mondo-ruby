require 'sinatra/base'

class FakeMondo < Sinatra::Base
  get '/accounts' do
    json_response 200, 'accounts.json'
  end

  get '/balance' do
    json_response 200, 'balance.json'
  end

  # TODO: Support expand[] parameter.
  get '/transactions/:id' do
    if params['id'] !~ /^tx/
      json_response 404, 'transaction_not_found.json'
    else
      json_response 200, 'transaction.json'
    end
  end

  get '/transactions' do
    json_response 200, 'transactions.json'
  end

  # TODO: SOON.
  get '/cards/list' do
    status 200
  end

  post '/feed' do
    status 200
  end

  get '/webhooks' do
    json_response 200, 'webhooks.json'
  end

  post '/webhooks' do
    json_response 200, 'webhook.json'
  end

  delete '/webhooks/:id' do
    status 200
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(json_file(file_name)).read
  end

  def json_path
    File.join(Mondo.root, 'spec/support/fake_json_responses')
  end

  def json_file(file)
    File.new(json_path + '/' + file)
  end
end
