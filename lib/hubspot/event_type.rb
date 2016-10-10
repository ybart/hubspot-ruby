require 'hubspot/utils'

module Hubspot
  #
  # HubSpot Event types API
  #
  # {http://developers.hubspot.com/docs/methods/timeline/timeline-overview}
  #
  class EventType
    EVENT_TYPES_PATH = "/integrations/v1/:application_id/timeline/event-types?userId=:user_id"

    attr_reader :id
    attr_reader :name
    attr_reader :application_id
    attr_reader :header_template
    attr_reader :detail_template
    attr_reader :object_type

    def initialize(response_hash)
      self.class.check_object_type!(response_hash['objectType'])

      @id = response_hash['id']
      @name = response_hash['name']
      @application_id = response_hash['applicationId']
      @header_template = response_hash['headerTemplate']
      @detail_template = response_hash['detailTemplate']
      @object_type = response_hash['objectType']
    end

    class << self
      def create!(application_id:, user_id:, name:, header_template: nil, detail_template: nil, object_type: 'CONTACT')
        check_object_type!(object_type)
        
        post_data = { 'name' => name, 'applicationId' => application_id, 
                      'headerTemplate' => header_template, 'detailTemplate' => detail_template,
                      'objectType' => object_type }

        response = Hubspot::Connection.post_json(EVENT_TYPES_PATH,
                                                 params: { application_id: application_id, user_id: user_id }, 
                                                 body: post_data )
        new(response)
      end
      
      def all(application_id:, user_id:)
        response = Hubspot::Connection.get_json(EVENT_TYPES_PATH, application_id: application_id, user_id: user_id)
        response.map { |attributes| new(attributes) }
      end
    end
    
    private
    
    def self.check_object_type!(object_type)
      return if %w(CONTACT COMPANY DEAL).include?(object_type)
      raise ArgumentError.new("object_type can be either CONTACT, COMPANY or DEAL but not #{object_type}")
    end
  end
end
