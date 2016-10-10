describe "Event Types API Live test", live: true do
  # This test needs manual configuration on Hubspot.
  # You might do this before to obtain the required information :
  #   1. Login to Hubspot with the demo account and select developper panel
  #   2. Create an application and a hapikey
  #   3. Replace the hapikey, application_id, user_id
  
  let(:hapikey) { '7e0e9eb0-6f90-4471-b769-864f8dfa486d' }
  let(:application_id) { 34597 }
  let(:user_id) { 215482 }

  before { Hubspot.configure hapikey: hapikey }

  it 'should create' do
    event_type = Hubspot::EventType.all.first
    event_type ||= Hubspot::EventType.create!(application_id: application_id, user_id: user_id, name: 'My Event Type')

    expect(event_type).to be_present
  end
end
