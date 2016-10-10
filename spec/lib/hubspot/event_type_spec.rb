describe Hubspot::EventType do
  # This test needs manual configuration on Hubspot.
  # You might do this before to obtain the required information :
  #   1. Login to Hubspot with the demo account and select developper panel
  #   2. Create an application and a hapikey
  #   3. Replace the hapikey, application_id, user_id
  
  let(:hapikey) { '7e0e9eb0-6f90-4471-b769-864f8dfa486d' }
  let(:application_id) { 34597 }
  let(:user_id) { 215482 }

  before { Hubspot.configure hapikey: hapikey }
  
  let(:example_event_type_hash) do
    VCR.use_cassette('event_type_example') do
      HTTParty.get("https://api.hubapi.com/integrations/v1/#{application_id}"\
                   "/timeline/event-types?hapikey=#{hapikey}&userId=#{user_id}"
                  ).parsed_response.last
    end
  end

  before { Hubspot.configure(hapikey: hapikey) }

  describe '#initialize' do
    subject { Hubspot::EventType.new(example_event_type_hash) }
    it  { should be_an_instance_of Hubspot::EventType }
    its(:id)              { should_not be_nil }
    its(:name)            { should eql 'My Event Type' }
    its(:application_id)  { should eql application_id }
    its(:object_type)     { should eql 'CONTACT' }
    
    it 'rejects invalid object type' do
      expect do
        Hubspot::EventType.new(name: 'Invalid object type', contact_type: 'INVALID')
      end.to raise_error(ArgumentError)
    end
  end

  describe '.create!' do
    cassette 'event_type_create'
    subject do
      Hubspot::EventType.create!(application_id: application_id, user_id: user_id, 
                                 name: 'My Event Type', header_template: 'Header',
                                 detail_template: 'Details')
    end
    its(:id)              { should_not be_nil }
    its(:name)            { should eql 'My Event Type' }
    its(:header_template) { should eql 'Header' }
    its(:detail_template) { should eql 'Details' }
    its(:application_id)  { should eql application_id }
    its(:object_type)     { should eql 'CONTACT' }
  end
  
  describe '.all' do
    cassette 'event_type_all'
    subject { Hubspot::EventType.all(application_id: application_id, user_id: user_id) }
    
    def create_event_type(name, object_type='CONTACT', header=nil, details=nil)
      Hubspot::EventType.create!(application_id: application_id, user_id: user_id, 
                                 name: name, header_template: header,
                                 detail_template: details, object_type: object_type)
    end
    
    before do
      create_event_type('Contact event', 'CONTACT', 'Contact header', 'Contact details')
      create_event_type('Company event', 'COMPANY', 'Company header', 'Company details')
      create_event_type('Deal event', 'DEAL', 'Deal header', 'Deal details')
    end
    
    it 'contains created events' do
      expect(subject.find { |type| type.object_type == 'CONTACT' }).not_to be_nil
      expect(subject.find { |type| type.object_type == 'COMPANY' }).not_to be_nil
      expect(subject.find { |type| type.object_type == 'DEAL' }).not_to be_nil
    end
  end
end
