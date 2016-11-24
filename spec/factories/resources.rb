FactoryGirl.define do
  factory :resource, class: 'Mondo::Resource' do
    client { create(:client) }

    initialize_with do
      new({}, client)
    end
  end
end
