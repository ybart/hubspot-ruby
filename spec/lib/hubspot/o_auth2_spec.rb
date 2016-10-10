describe Hubspot::OAuth2 do
  let(:client_id) { '2d966b5e-5bd9-4056-8ee8-19e17674e227' }
  let(:client_secret) { '9b13795b-5e1c-4fc5-b33c-ce33b2c73fa6' }
  let(:code) { '43781707-308b-470a-be1d-06985199d760' }
  let(:redirect_uri) { 'http://httpbin.org/get' }

  describe '.authorize_url' do
    subject { Hubspot::OAuth2.authorize_url(client_id: client_id, redirect_uri: redirect_uri) }
    
    it 'returns authorization URI' do
      expect(p subject).to eq 'https://app.hubspot.com/oauth/authorize?'\
                            'client_id=2d966b5e-5bd9-4056-8ee8-19e17674e227'\
                            '&redirect_uri=http%3A%2F%2Fhttpbin.org%2Fget&'\
                            'scopes=contacts+content+social+automation'\
                            '+timeline'
    end
  end

  describe '.create' do
    cassette 'oauth2_tokens'

    subject do
      Hubspot::OAuth2.create(client_id: client_id, redirect_uri: redirect_uri, 
                             client_secret: client_secret, code: code)
    end
    
    it { should be_an_instance_of Hubspot::OAuth2 }
    
    it 'returns OAuth2 tokens' do
      expect(subject.access_token).not_to be_nil
      expect(subject.refresh_token).not_to be_nil
    end
  end
end