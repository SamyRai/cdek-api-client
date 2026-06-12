# frozen_string_literal: true

require_relative '../../lib/cdek_api_client'

# EntityFactory creates entity objects from schema-generated JSON data
# Maps raw JSON structures to the appropriate entity classes
class EntityFactory
  class << self
    # Create a TariffData entity from schema-generated JSON
    def create_tariff_data(data)
      return nil unless data.is_a?(Hash)

      # Convert nested objects to entities
      from_location = create_location(data['from_location'])
      to_location = create_location(data['to_location'])
      packages = Array(data['packages']).map { |pkg| create_package(pkg) }

      CDEKApiClient::Entities::TariffData.new(
        type: data['type'] || 1,
        currency: data['currency'] || 1,
        tariff_code: data['tariff_code'] || 139,
        from_location: from_location,
        to_location: to_location,
        packages: packages
      )
    end

    # Create a Location entity from JSON data
    def create_location(data)
      return nil unless data.is_a?(Hash)

      # Provide defaults for required fields
      code = data['code'] || 16_584
      city = data['city'] || 'Test City'
      address = data['address'] || 'Test Address'

      CDEKApiClient::Entities::Location.new(
        code: code,
        city: city,
        address: address
      )
    rescue StandardError
      nil # Return nil if creation fails
    end

    # Create a Package entity from JSON data
    def create_package(data)
      return nil unless data.is_a?(Hash)

      # Provide defaults and ensure required fields
      number = data['number'] || 'pkg001'
      weight = data['weight'] || 1000
      length = data['length'] || 10
      width = data['width'] || 10
      height = data['height'] || 10
      items = Array(data['items']).map { |item| create_item(item) }
      items = [create_default_item] if items.empty?
      comment = data['comment'] || 'Test package'

      CDEKApiClient::Entities::Package.new(
        number: number,
        weight: weight,
        length: length,
        width: width,
        height: height,
        items: items,
        comment: comment
      )
    rescue StandardError
      nil # Return nil if creation fails
    end

    # Create an Item entity from JSON data
    def create_item(data)
      return nil unless data.is_a?(Hash)

      # Provide defaults and ensure correct types
      name = data['name'] || 'Test Item'
      ware_key = data['ware_key'] || 'test123'
      payment = create_payment(data['payment']) || create_default_payment
      cost = data['cost'] || 100
      weight = data['weight'] || 1000
      amount = data['amount'] || 1

      CDEKApiClient::Entities::Item.new(
        name: name,
        ware_key: ware_key,
        payment: payment,
        cost: cost,
        weight: weight,
        amount: amount
      )
    rescue StandardError
      nil # Return nil if creation fails
    end

    # Create a Payment entity from JSON data
    def create_payment(data)
      return nil unless data.is_a?(Hash)

      # Ensure value is an integer
      value = data['value']
      value = value.to_i if value.is_a?(Numeric)
      value = 100 unless value.is_a?(Integer)

      CDEKApiClient::Entities::Payment.new(
        value: value,
        currency: data['currency'] || 'RUB'
      )
    rescue StandardError
      nil # Return nil if creation fails
    end

    # Create a default payment for testing
    def create_default_payment
      CDEKApiClient::Entities::Payment.new(
        value: 100
      )
    end

    # Create an OrderData entity from schema-generated JSON
    def create_order_data(data)
      return nil unless data.is_a?(Hash)

      # Extract and create nested entities with fallbacks
      from_location = create_location(data['from_location']) || create_default_location('from')
      to_location = create_location(data['to_location']) || create_default_location('to')
      recipient = create_recipient(data['recipient']) || create_default_recipient
      sender = create_sender(data['sender']) || create_default_sender
      packages = Array(data['packages']).map { |pkg| create_package(pkg) }
      packages = [create_default_package] if packages.empty?
      services = Array(data['services']).map { |svc| create_service(svc) }

      CDEKApiClient::Entities::OrderData.new(
        type: data['type'] || 1,
        number: data['number'] || 'test-order-123',
        tariff_code: data['tariff_code'] || 139,
        from_location: from_location,
        to_location: to_location,
        recipient: recipient,
        sender: sender,
        packages: packages,
        comment: data['comment']&.to_s || 'Test order',
        shipment_point: data['shipment_point'],
        delivery_point: data['delivery_point'],
        services: services
      )
    end

    # Create a Recipient entity from JSON data
    def create_recipient(data)
      return nil unless data.is_a?(Hash)

      # Provide defaults for required fields
      name = data['name'] || 'Test Recipient'
      phones = Array(data['phones'])
      phones = [{ 'number' => '+79001234567' }] if phones.empty?
      email = data['email'] || 'test@example.com'

      CDEKApiClient::Entities::Recipient.new(
        name: name,
        phones: phones,
        email: email
      )
    rescue StandardError
      nil # Return nil if creation fails
    end

    # Create a Sender entity from JSON data
    def create_sender(data)
      return nil unless data.is_a?(Hash)

      # Provide defaults for required fields
      name = data['name'] || 'Test Sender'
      phones = Array(data['phones'])
      phones = [{ 'number' => '+79001234567' }] if phones.empty?
      email = data['email'] || 'sender@example.com'

      CDEKApiClient::Entities::Sender.new(
        name: name,
        phones: phones,
        email: email
      )
    rescue StandardError
      nil # Return nil if creation fails
    end

    # Create a Service entity from JSON data
    def create_service(data)
      return nil unless data.is_a?(Hash)

      # Provide defaults for required fields
      code = data['code'] || 'INSURANCE'
      price = data['price'] || 100
      name = data['name'] || 'Test Service'

      CDEKApiClient::Entities::Service.new(
        code: code,
        price: price,
        name: name
      )
    rescue StandardError
      nil # Return nil if creation fails
    end

    # Create a default location for testing
    def create_default_location(type = 'default')
      CDEKApiClient::Entities::Location.new(
        code: 16_584,
        city: "#{type} city",
        address: "#{type} address"
      )
    end

    # Create a default recipient for testing
    def create_default_recipient
      CDEKApiClient::Entities::Recipient.new(
        name: 'Test Recipient',
        phones: [{ number: '+79001234567' }],
        email: 'test@example.com'
      )
    end

    # Create a default sender for testing
    def create_default_sender
      CDEKApiClient::Entities::Sender.new(
        name: 'Test Sender',
        phones: [{ number: '+79001234567' }],
        email: 'sender@example.com'
      )
    end

    # Create a default item for testing
    def create_default_item
      CDEKApiClient::Entities::Item.new(
        name: 'Test Item',
        ware_key: 'test123',
        payment: create_default_payment,
        cost: 100,
        weight: 1000,
        amount: 1
      )
    end

    # Create a default package for testing
    def create_default_package
      CDEKApiClient::Entities::Package.new(
        number: 'pkg001',
        weight: 1000,
        length: 10,
        width: 10,
        height: 10,
        items: [create_default_item],
        comment: 'Test package'
      )
    end

    # Create a Webhook entity from schema-generated JSON
    def create_webhook(data)
      return nil unless data.is_a?(Hash)

      # Provide defaults for required fields
      url = data['url'] || 'https://example.com/webhook'
      type = data['type'] || 'ORDER_STATUS'
      event_types = Array(data['event_types'])
      event_types = ['ORDER_STATUS'] if event_types.empty?

      CDEKApiClient::Entities::Webhook.new(
        url: url,
        type: type,
        event_types: event_types
      )
    rescue StandardError
      nil # Return nil if creation fails
    end

    # Create a Check entity from schema-generated JSON
    def create_check(data)
      return nil unless data.is_a?(Hash)

      CDEKApiClient::Entities::Check.new(
        cdek_number: data['cdek_number'],
        date: data['date']
      )
    rescue StandardError
      nil # Return nil if creation fails
    end

    # Create an Agreement entity from schema-generated JSON
    def create_agreement(data)
      return nil unless data.is_a?(Hash)

      # Provide defaults for required fields
      cdek_number = data['cdek_number'] || '123456789'
      date = data['date'] || '2024-01-17'
      time_from = data['time_from'] || '10:00'
      time_to = data['time_to'] || '18:00'

      CDEKApiClient::Entities::Agreement.new(
        cdek_number: cdek_number,
        date: date,
        time_from: time_from,
        time_to: time_to,
        comment: data['comment'],
        delivery_point: data['delivery_point'],
        to_location: data['to_location']
      )
    rescue StandardError
      nil # Return nil if creation fails
    end

    # Create an Intakes entity from schema-generated JSON
    def create_intakes(data)
      return nil unless data.is_a?(Hash)

      # Provide defaults for required fields
      cdek_number = data['cdek_number'] || '123456789'
      intake_date = data['intake_date'] || '2024-01-17'
      intake_time_from = data['intake_time_from'] || '10:00'
      intake_time_to = data['intake_time_to'] || '18:00'
      name = data['name'] || 'Test cargo'

      # Handle nested objects with defaults
      sender = data['sender'] || { 'name' => 'Test Sender', 'phones' => [{ 'number' => '+79001234567' }] }
      from_location = data['from_location'] || { 'code' => 44, 'address' => 'Test Address' }

      CDEKApiClient::Entities::Intakes.new(
        cdek_number: cdek_number,
        intake_date: intake_date,
        intake_time_from: intake_time_from,
        intake_time_to: intake_time_to,
        lunch_time_from: data['lunch_time_from'],
        lunch_time_to: data['lunch_time_to'],
        name: name,
        need_call: data['need_call'],
        comment: data['comment'],
        sender: sender,
        from_location: from_location,
        weight: data['weight'],
        length: data['length'],
        width: data['width'],
        height: data['height']
      )
    rescue StandardError
      nil # Return nil if creation fails
    end

    # Create an IntakeAvailableDaysRequest entity from schema-generated JSON
    def create_intake_available_days_request(data)
      return nil unless data.is_a?(Hash)

      # Provide defaults for required fields
      from_location = data['from_location'] || { 'code' => 44, 'address' => 'Test Address' }

      CDEKApiClient::Entities::IntakeAvailableDaysRequest.new(
        from_location: from_location,
        date: data['date']
      )
    rescue StandardError
      nil # Return nil if creation fails
    end

    # Create an IntakeAvailableDaysResponse entity from JSON data
    def create_intake_available_days_response(data)
      return nil unless data.is_a?(Hash)

      CDEKApiClient::Entities::IntakeAvailableDaysResponse.new(
        date: data['date'],
        all_days: data['all_days'],
        errors: data['errors'],
        warnings: data['warnings']
      )
    rescue StandardError
      nil # Return nil if creation fails
    end

    # Create a Barcode entity from schema-generated JSON
    def create_barcode(data)
      return nil unless data.is_a?(Hash)

      # Provide defaults for required fields
      orders = data['orders'] || [{ 'order_uuid' => 'test-uuid' }]

      CDEKApiClient::Entities::Barcode.new(
        orders: orders,
        copy_count: data['copy_count'],
        type: data['type'],
        format: data['format'] || 'A4',
        lang: data['lang']
      )
    rescue StandardError
      nil # Return nil if creation fails
    end

    # Create an Invoice entity from schema-generated JSON
    def create_invoice(data)
      return nil unless data.is_a?(Hash)

      # Provide defaults for required fields
      orders = data['orders'] || [{ 'order_uuid' => 'test-uuid' }]

      CDEKApiClient::Entities::Invoice.new(
        orders: orders,
        copy_count: data['copy_count'],
        type: data['type']
      )
    rescue StandardError
      nil # Return nil if creation fails
    end

    # Generic entity creation method
    def create_entity(entity_class, data)
      return nil unless data.is_a?(Hash)

      # Convert snake_case keys to symbols for entity initialization
      entity_params = data.transform_keys(&:to_sym)

      entity_class.new(**entity_params)
    rescue ArgumentError
      # If direct initialization fails, try to handle nested objects
      handle_nested_entities(entity_class, data)
    end

    private

    def handle_nested_entities(entity_class, data)
      # This is a simplified version - in a real implementation,
      # you'd need to handle each entity's specific nested requirements
      case entity_class.name
      when /TariffData/
        create_tariff_data(data)
      else
        # Fallback: try direct initialization with symbolized keys
        entity_class.new(**data.transform_keys(&:to_sym))
      end
    end
  end
end
