FactoryGirl.define do
  factory :client, class: 'Mondo::Client' do
    skip_create

    parameters do
      {
        access_token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjaSI6Im9hdXRoY2'\
        'xpZW50XzAwMDA5NFB2SU5ER3pUM2s2dHo4anAiLCJleHAiOjE0ODAxMDM3ODUsImlhdCI'\
        '6MTQ4MDAxNzM4NSwianRpIjoiYXV0aGNvZGVfMDAwMDlFZ2x0TktnSEFCMjNvRHJGcCIs'\
        'InVpIjoidXNlcl8wMDAwOUVhcUVqbGRJRWJ6RE02UFlIIiwidiI6IjIifQ.Q5Z7hqGyI_'\
        'lgOeybqTdCJtz5H6EdBCHlKmubZKRMAwU',
        account_id: 'acc_000091yf79yMwNaZHhHGzp'
      }
    end

    initialize_with do
      new(parameters)
    end

    factory :accountless_client do
      initialize_with do
        new(parameters.except(:account_id))
      end
    end
  end
end
