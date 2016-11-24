shared_context 'client setup' do
  let(:client) { create(:client) }
  let(:accountless_client) { create(:accountless_client) }

  before(:each) do
    stub_request(:any, /#{Mondo::Client::DEFAULT_API_URL}/).to_rack(::FakeMondo)
  end
end
