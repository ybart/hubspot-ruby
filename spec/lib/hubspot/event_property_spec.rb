describe Hubspot::EventProperty do
  # This test needs manual configuration on Hubspot.
  # You might do this before to obtain the required information :
  #   1. Login to Hubspot with the demo account and select developper panel
  #   2. Create an application and a hapikey
  #   3. Replace the hapikey, application_id, user_id
  
  let(:hapikey) { '7e0e9eb0-6f90-4471-b769-864f8dfa486d' }
  let(:application_id) { 34597 }
  let(:user_id) { 215482 }
  let(:event_type_id) { example_event_type_hash['id'] }

  before { Hubspot.configure hapikey: hapikey }
  
  let(:example_event_type_hash) do
    VCR.use_cassette('event_type_example') do
      HTTParty.get("https://api.hubapi.com/integrations/v1/#{application_id}"\
                   "/timeline/event-types?hapikey=#{hapikey}&userId=#{user_id}"
                  ).parsed_response.last
    end
  end

  let(:example_event_property_hash) do
    VCR.use_cassette('event_properties_example') do
      HTTParty.get("https://api.hubapi.com/integrations/v1/#{application_id}"\
                   "/timeline/event-types/#{event_type_id}/properties?hapikey=#{hapikey}&userId=#{user_id}"
                  ).parsed_response.last
    end
  end
  
  let(:common_params) do
    { application_id: application_id, user_id: user_id, event_type_id: event_type_id }
  end

  before { Hubspot.configure(hapikey: hapikey) }

  describe '#initialize' do
    subject { Hubspot::EventProperty.new(example_event_property_hash) }
    it  { should be_an_instance_of Hubspot::EventProperty }

    its(:id)              { should_not be_nil }
    its(:name)            { should eql 'MyEventProperty' }
    its(:label)           { should eql 'My Event Property' }
    its(:options)         { should eql [] }
    its(:property_type)   { should eql 'String' }
    its(:event_type_id)   { should eql event_type_id }
    
    it 'rejects invalid property type' do
      expect do
        Hubspot::EventProperty.new(name: 'Invalid property type', 
                                   property_type: 'INVALID',
                                   label: 'Invalid',
                                   event_type_id: event_type_id)
      end.to raise_error(ArgumentError)
    end
  end

  describe '.create!' do
    cassette 'event_property_create'
    subject do
      Hubspot::EventProperty.all(common_params).each do |property|
        Hubspot::EventProperty.delete(common_params.merge(property_id: property.id))
      end
      Hubspot::EventProperty.create!(common_params.merge(
        name: "MyEventProperty", label: 'My Event Property', property_type: 'String'))
    end
    its(:id)              { should_not be_nil }
    its(:name)            { should eql 'MyEventProperty' }
    its(:label)           { should eql 'My Event Property' }
    its(:options)         { should eql [] }
    its(:property_type)   { should eql 'String' }
    its(:event_type_id)   { should eql event_type_id }
  end
  
  describe '.all' do
    cassette 'event_property_all'
    subject { Hubspot::EventProperty.all(common_params) }
  end
end
