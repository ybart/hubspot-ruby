module Hubspot
  class EventProperty
    PROPERTIES_PATH = "/integrations/v1/:application_id/timeline/event-types/"\
                      ":event_type_id/properties?userId=:user_id"
    PROPERTY_PATH = "/integrations/v1/:application_id/timeline/event-types/"\
                      ":event_type_id/properties/:property_id?userId=:user_id"

    attr_reader :id
    attr_reader :name
    attr_reader :label
    attr_reader :property_type
    attr_reader :options
    attr_reader :event_type_id
    attr_reader :object_property

    def initialize(response_hash)
      self.class.check_property_type!(response_hash['propertyType'])

      @id = response_hash['id']
      @name = response_hash['name']
      @label = response_hash['label']
      @event_type_id = response_hash['eventTypeId']
      @property_type = response_hash['propertyType']
      @object_property = response_hash['objectProperty']
      @options = response_hash['options']
    end

    class << self
      def create!(application_id:, user_id:, event_type_id:, name:, label:,
                  property_type: 'String', object_property: nil, options: [])
        check_property_type!(property_type)
        
        post_data = { 'name' => name, 'label' => label, 'propertyType' => property_type,
                      'objectProperty' => object_property, options: options }
        params =  { application_id: application_id, user_id: user_id,  event_type_id: event_type_id }

        response = Hubspot::Connection.post_json(PROPERTIES_PATH, params: params, body: post_data)
        new(response)
      end
      
      def all(application_id:, user_id:, event_type_id:)
        params = { application_id: application_id, user_id: user_id, event_type_id: event_type_id }
        response = Hubspot::Connection.get_json(PROPERTIES_PATH, params)
        response.map { |attributes| new(attributes) }
      end
      
      def delete(application_id:, user_id:, event_type_id:, property_id:)
        params = { application_id: application_id, user_id: user_id, event_type_id: event_type_id, 
                   property_id: property_id }
        Hubspot::Connection.delete_json(PROPERTY_PATH, params)
      end
    end
    
    private
    
    def self.check_property_type!(object_type)
      allowed_properties = %w(Date Enumeration Numeric String)
      return if allowed_properties.include?(object_type)
      raise ArgumentError.new( "property_type can be either #{allowed_properties.join(', ')} but not #{object_type}")
    end
  end
end
