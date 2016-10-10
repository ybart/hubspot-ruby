require 'uri'

module Hubspot
  class OAuth2
    OAUTH2_PATH = "/oauth/v1/token"
    DEFAULT_SCOPES = %w(contacts content social automation timeline).freeze
    
    attr_reader :access_token
    attr_reader :refresh_token
    
    def initialize(response_hash)
      @access_token = response_hash['access_token']
      @refresh_token = response_hash['refresh_token']
    end
    
    class << self
      def authorize_url(client_id:, redirect_uri:, scopes: DEFAULT_SCOPES)
        encoded_scopes = scopes.join(' ')
        params = { client_id: client_id, redirect_uri: redirect_uri, scopes: encoded_scopes }
        "https://app.hubspot.com/oauth/authorize?#{URI.encode_www_form(params)}"
      end
      
      def create(client_id:, client_secret:, redirect_uri:, code:)
        post_data = { 'grant_type' => 'authorization_code', 'client_id' => client_id, 
                      'client_secret' => client_secret, 'redirect_uri' => redirect_uri,
                      'code' => code }

        new(Hubspot::OAuthConnection.submit(OAUTH2_PATH, params: {}, body: post_data))
      end
      
      def refresh(client_id:, client_secret:, redirect_uri:, refresh_token:)
        post_data = { 'grant_type' => 'authorization_code', 'client_id' => client_id, 
                      'client_secret' => client_secret, 'redirect_uri' => redirect_uri,
                      'refresh_token' => refresh_token }

        new(Hubspot::OAuthConnection.submit(OAUTH2_PATH, params: {}, body: post_data))
      end
    end
  end
end