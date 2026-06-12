# CDEK API Client

[![Gem Version](https://badge.fury.io/rb/cdek_api_client.svg)](https://badge.fury.io/rb/cdek_api_client)

### Other Languages

- [Русский](README_RUS.md)
- [Татарча](README_TAT.md)
- [English](README.md)

> [!WARNING] >**Important:** This gem is in the early stages of development and it is shared as it is. Any support for development or feedback is welcome; please check the [Contributing](#contributing) section for more information.

## Overview

CDEK ([СДЭК](https://www.cdek.ru/)) is a big logistics company in Russia, that provides a wide range of delivery services for businesses and individuals. The [CDEK API](https://www.cdek.ru/ru/integration/api) allows developers to integrate CDEK's services into their applications, enabling functionalities such as order creation, tracking, tariff calculation, location data retrieval, and webhook management.

The `cdek_api_client` gem provides a Ruby interface for the CDEK API.

Features:

- **Order Management**: Create, track, update, cancel, and delete orders.
- **Tariff Calculation**: Calculate single tariffs and tariff lists.
- **Location Services**: Retrieve cities, regions, postal codes, and delivery offices.
- **Print/Documents**: Generate barcodes and invoices (PDF).
- **Courier Services**: Manage delivery agreements and courier intake requests.
- **Payment Services**: Retrieve payment and check data.
- **Webhook Management**: Register and manage webhooks.
- **Testing & Mocking**: Zero-configuration dynamic test stubbing (`AutoMocker`) and auto-generated API specs.
- **Resilience**: Built-in 5xx retry logic and automatic rate-limit backoff handling.
- **Schema Sync**: Fully automated OpenAPI schema synchronization and code generation pipelines.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Initialization](#initialization)
  - [Creating an Order](#creating-an-order)
  - [Tracking an Order](#tracking-an-order)
  - [Order Management](#order-management)
  - [Calculating Tariff](#calculating-tariff)
  - [Enhanced Tariff Calculation](#enhanced-tariff-calculation)
  - [Getting Location Data](#getting-location-data)
  - [Print and Documents](#print-and-documents)
  - [Courier Services](#courier-services)
  - [Payment Services](#payment-services)
  - [Setting Up Webhooks](#setting-up-webhooks)
  - [Enhanced Webhook Management](#enhanced-webhook-management)
  - [Fetching and Saving Location Data](#fetching-and-saving-location-data)
- [Entities](#entities)
  - [OrderData](#orderdata)
  - [Recipient](#recipient)
  - [Sender](#sender)
  - [Package](#package)
  - [Item](#item)
  - [Barcode](#barcode)
  - [Invoice](#invoice)
  - [Agreement](#agreement)
  - [Intakes](#intakes)
  - [Check](#check)
- [Schema Management](#schema-management)
- [TODO List](#todo-list)
- [Changelog](#changelog)
- [Contributing](#contributing)
- [License](#license)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cdek_api_client'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install cdek_api_client
```

## Usage

### Initialization

To use the CDEK API Client, you need to initialize it with your CDEK API credentials (client ID and client secret):

```ruby
require 'cdek_api_client'

client_id = 'your_client_id'
client_secret = 'your_client_secret'

client = CDEKApiClient::Client.new(client_id, client_secret)
```

### Creating an Order

To create an order, you need to create the necessary entities (`OrderData`, `Recipient`, `Sender`, `Package`, and `Item`) and then pass them to the `create_order` method of the `Order` class:

```ruby
recipient = CDEKApiClient::Entities::Recipient.new(
  name: 'John Doe',
  phones: [{ number: '+79000000000' }],
  email: 'johndoe@example.com'
)

sender = CDEKApiClient::Entities::Sender.new(
  name: 'Sender Name',
  phones: [{ number: '+79000000001' }],
  email: 'sender@example.com'
)

item = CDEKApiClient::Entities::Item.new(
  name: 'Item 1',
  ware_key: '00055',
  payment: 1000,
  cost: 1000,
  weight: 500,
  amount: 1
)

package = CDEKApiClient::Entities::Package.new(
  number: '1',
  weight: 500,
  length: 10,
  width: 10,
  height: 10,
  comment: 'Package 1',
  items: [item]
)

order_data = CDEKApiClient::Entities::OrderData.new(
  type: 1,
  number: 'TEST123',
  tariff_code: 1,
  comment: 'Test order',
  recipient: recipient,
  sender: sender,
  from_location: { code: 44 },
  to_location: { code: 270 },
  packages: [package]
)

order_client = CDEKApiClient::Order.new(client)

begin
  order_response = order_client.create(order_data)
  puts "Order created successfully: #{order_response}"
rescue => e
  puts "Error creating order: #{e.message}"
end
```

### Tracking an Order

To track an order, use the `track` method of the `Order` class with the order UUID:

```ruby
order_uuid = 'order_uuid_from_created_order_response'

begin
  tracking_info = order_client.track(order_uuid)
  puts "Tracking info: #{tracking_info}"
rescue => e
  puts "Error tracking order: #{e.message}"
end
```

### Calculating Tariff

To calculate the tariff, use the `calculate` method of the `Tariff` class with the necessary tariff data:

```ruby
tariff_data = CDEKApiClient::Entities::TariffData.new(
  type: 1,
  currency: 'RUB',
  from_location: { code: 44 },
  to_location: { code: 137 },
  packages: [{ weight: 500, length: 10, width: 10, height: 10 }]
)

tariff_client = CDEKApiClient::Tariff.new(client)

begin
  tariff_response = tariff_client.calculate(tariff_data)
  puts "Tariff calculated: #{tariff_response}"
rescue => e
  puts "Error calculating tariff: #{e.message}"
end
```

### Getting Location Data

To retrieve location data such as cities and regions supported by CDEK, use the `cities` and `regions` methods of the `Location` class:

```ruby
location_client = CDEKApiClient::Location.new(client)

# Fetching cities
begin
  cities = location_client.cities
  puts "Cities: #{cities}"
rescue => e
  puts "Error fetching cities: #{e.message}"
end

# Fetching regions
begin
  regions = location_client.regions
  puts "Regions: #{regions}"
rescue => e
  puts "Error fetching regions: #{e.message}"
end
```

### Setting Up Webhooks

Webhooks allow your application to receive real-time notifications about various events related to your shipments. To set up a webhook, register a URL where CDEK will send HTTP POST requests with event data:

```ruby
webhook_client = CDEKApiClient::Webhook.new(client)

webhook_url = 'https://yourapp.com/webhooks/cdek'
begin
  response = webhook_client.register(webhook_url, event_types: ['ORDER_STATUS', 'DELIVERY_STATUS'])
  puts "Webhook registered: #{response}"
rescue => e
  puts "Error registering webhook: #{e.message}"
end
```

To retrieve and delete registered webhooks:

```ruby
# Fetching webhooks
begin
  webhooks = webhook_client.get_webhooks
  puts "Webhooks: #{webhooks}"
rescue => e
  puts "Error fetching webhooks: #{e.message}"
end

# Deleting a webhook
webhook_id = 'webhook_id_to_delete'
begin
  response = webhook_client.delete(webhook_id)
  puts "Webhook deleted: #{response}"
rescue => e
  puts "Error deleting webhook: #{e.message}"
end
```

### Fetching Location Data

The gem has pre-cached values and uses them by default. Users can override this behavior by fetching live data.

You can fetch cities, regions, offices, and postal code data directly from CDEK API.

```ruby

# Fetching cities
begin
  cities = location_client.cities(use_live_data: true)
rescue => e
  puts "Error fetching cities: #{e.message}"
end

# Fetching regions
begin
  regions = location_client.regions(use_live_data: true)
rescue => e
  puts "Error fetching regions: #{e.message}"
end

# Fetching  offices
begin
  offices = location_client.offices(use_live_data: true)
rescue => e
  puts "Error fetching offices: #{e.message}"
end

# Fetching postal codes for each city
begin
  cities = location_client.cities(use_live_data: true)
rescue => e
  puts "Error fetching postal codes: #{e.message}"
end
```

### Order Management

Order management examples:

```ruby
# Delete an order
begin
  response = client.order.delete('order-uuid')
  puts "Order deleted: #{response}"
rescue => e
  puts "Error deleting order: #{e.message}"
end

# Cancel an order (refusal)
begin
  response = client.order.cancel('order-uuid')
  puts "Order canceled: #{response}"
rescue => e
  puts "Error canceling order: #{e.message}"
end

# Update an order
updated_order_data = # ... create updated order data
begin
  response = client.order.update(updated_order_data)
  puts "Order updated: #{response}"
rescue => e
  puts "Error updating order: #{e.message}"
end

# Get order by UUID
begin
  order_info = client.order.get('order-uuid')
  puts "Order info: #{order_info}"
rescue => e
  puts "Error getting order: #{e.message}"
end

# Get order by CDEK number
begin
  order_info = client.order.get_by_cdek_number('123456789')
  puts "Order info: #{order_info}"
rescue => e
  puts "Error getting order: #{e.message}"
end

# Get order by IM number
begin
  order_info = client.order.get_by_im_number('ORDER123')
  puts "Order info: #{order_info}"
rescue => e
  puts "Error getting order: #{e.message}"
end

# Create client return order
client_return_data = CDEKApiClient::Entities::OrderData.new(
  type: 1,
  tariff_code: 1,
  packages: [package]
)
begin
  response = client.order.create_client_return('original-order-uuid', client_return_data)
  puts "Client return created: #{response}"
rescue => e
  puts "Error creating client return: #{e.message}"
end

# Get intakes for an order
begin
  intakes = client.order.get_intakes('order-uuid')
  puts "Order intakes: #{intakes}"
rescue => e
  puts "Error getting intakes: #{e.message}"
end
```

### Print and Documents

Generate and retrieve printable documents like barcodes and invoices:

```ruby
# Create barcode
barcode_data = CDEKApiClient::Entities::Barcode.with_orders_uuid('order-uuid')
begin
  response = client.print.create_barcode(barcode_data)
  puts "Barcode created: #{response}"
rescue => e
  puts "Error creating barcode: #{e.message}"
end

# Get barcode PDF
begin
  pdf_content = client.print.get_barcode_pdf('barcode-uuid')
  File.write('barcode.pdf', pdf_content)
rescue => e
  puts "Error getting barcode PDF: #{e.message}"
end

# Create invoice
invoice_data = CDEKApiClient::Entities::Invoice.with_orders_uuid('order-uuid')
begin
  response = client.print.create_invoice(invoice_data)
  puts "Invoice created: #{response}"
rescue => e
  puts "Error creating invoice: #{e.message}"
end

# Get invoice PDF
begin
  pdf_content = client.print.get_invoice_pdf('invoice-uuid')
  File.write('invoice.pdf', pdf_content)
rescue => e
  puts "Error getting invoice PDF: #{e.message}"
end
```

### Courier Services

Manage delivery agreements and courier intake requests:

```ruby
# Create delivery agreement
agreement_data = CDEKApiClient::Entities::Agreement.new(
  cdek_number: '123456789',
  date: '2024-01-17',
  time_from: '10:00',
  time_to: '18:00',
  comment: 'Delivery agreement'
)
begin
  response = client.courier.create_agreement(agreement_data)
  puts "Agreement created: #{response}"
rescue => e
  puts "Error creating agreement: #{e.message}"
end

# Create courier intake request
intake_data = CDEKApiClient::Entities::Intakes.new(
  cdek_number: '123456789',
  intake_date: '2024-01-17',
  intake_time_from: '10:00',
  intake_time_to: '18:00',
  name: 'Cargo description',
  sender: { name: 'Sender Name', phones: [{ number: '+79001234567' }] },
  from_location: { code: 44, address: 'Pickup Address' }
)
begin
  response = client.courier.create_intake(intake_data)
  puts "Intake created: #{response}"
rescue => e
  puts "Error creating intake: #{e.message}"
end

# Delete intake request
begin
  response = client.courier.delete_intake('intake-uuid')
  puts "Intake deleted: #{response}"
rescue => e
  puts "Error deleting intake: #{e.message}"
end
```

### Payment Services

Retrieve payment and check information:

```ruby
# Get payments for a date
begin
  payments = client.payment.get_payments('2024-01-17')
  puts "Payments: #{payments}"
rescue => e
  puts "Error getting payments: #{e.message}"
end

# Get checks
check_data = CDEKApiClient::Entities::Check.new(
  cdek_number: '123456789',
  date: '2024-01-17'
)
begin
  checks = client.payment.get_checks(check_data.to_query_params)
  puts "Checks: #{checks}"
rescue => e
  puts "Error getting checks: #{e.message}"
end

# Get payment registries
begin
  registries = client.payment.get_registries('2024-01-17')
  puts "Registries: #{registries}"
rescue => e
  puts "Error getting registries: #{e.message}"
end
```

### Enhanced Tariff Calculation

Calculate all available tariffs at once:

```ruby
# Calculate tariff list
begin
  tariffs = client.tariff.calculate_list(tariff_data)
  puts "Available tariffs: #{tariffs}"
rescue => e
  puts "Error calculating tariffs: #{e.message}"
end
```

### Webhook Management

List and manage webhooks:

```ruby
# List all webhooks
begin
  webhooks = client.webhook.list_all
  puts "All webhooks: #{webhooks}"
rescue => e
  puts "Error listing webhooks: #{e.message}"
end

# Get specific webhook
begin
  webhook = client.webhook.get('webhook-uuid')
  puts "Webhook: #{webhook}"
rescue => e
  puts "Error getting webhook: #{e.message}"
end

# Delete webhook by UUID
begin
  response = client.webhook.delete('webhook-uuid')
  puts "Webhook deleted: #{response}"
rescue => e
  puts "Error deleting webhook: #{e.message}"
end
```

### Entities

### OrderData

Represents the order data.

Attributes:

- `type` (Integer, required): The type of the order.
- `number` (String, required): The order number.
- `tariff_code` (Integer, required): The tariff code.
- `comment` (String): The comment for the order.
- `recipient` (Recipient, required): The recipient details.
- `sender` (Sender, required): The sender details.
- `from_location` (Hash, required): The location details from where the order is shipped.
- `to_location` (Hash, required): The location details of where the order is shipped.
- `services` (Array): Additional services.
- `packages` (Array, required): List of packages.

### Recipient

Represents the recipient details.

Attributes:

- `name` (String, required): The recipient's name.
- `phones` (Array, required): List of phone numbers.
- `email` (String, required): The recipient's email address.

### Sender

Represents the sender's details.

Attributes:

- `name` (String, required): The sender's name.
- `phones` (Array, required): List of phone numbers.
- `email` (String, required): The sender's email address.

### Package

Represents the package details.

Attributes:

- `number` (String, required): The package number.
- `weight` (Integer, required): The weight of the package.
- `length` (Integer, required): The length of the package.
- `width` (Integer, required): The width of the package.
- `height` (Integer, required): The height of the package.
- `comment` (String): The comment for the package.
- `items` (Array, required): List of items in the package.

### Item

Represents the item details.

Attributes:

- `name` (String, required): The name of the item.
- `ware_key` (String, required): The ware key of the item.
- `payment` (Integer, required): The payment value of the item.
- `cost` (Integer, required): The cost of the item.
- `weight` (Integer, required): The weight of the item.
- `amount` (Integer, required): The amount of the item.

### Barcode

Represents barcode creation data for printing.

Attributes:

- `orders` (Array, required): List of orders for barcode generation.
- `copy_count` (Integer): Number of copies (default: 1).
- `format` (String): Print format (A4, A5, A6, A7).
- `lang` (String): Language code (RUS, ENG, DEU, ITA, TUR, CES, KOR, LIT, LAT).

### Invoice

Represents invoice creation data for printing.

Attributes:

- `orders` (Array, required): List of orders for invoice generation.
- `copy_count` (Integer): Number of copies (default: 2).
- `type` (String): Invoice type (tpl_russia, tpl_china, tpl_armenia, tpl_english, tpl_italian, tpl_korean, tpl_latvian, tpl_lithuanian, tpl_german, tpl_turkish, tpl_czech, tpl_thailand, tpl_invoice).

### Agreement

Represents delivery agreement data.

Attributes:

- `cdek_number` (String, required): CDEK order number.
- `order_uuid` (String): Order UUID.
- `date` (String, required): Delivery date.
- `time_from` (String, required): Start time.
- `time_to` (String, required): End time.
- `comment` (String): Comment.
- `delivery_point` (String): Delivery point code.
- `to_location` (Hash): Delivery location details.

### Intakes

Represents courier intake request data.

Attributes:

- `cdek_number` (String): CDEK order number.
- `order_uuid` (String): Order UUID.
- `intake_date` (String, required): Intake date.
- `intake_time_from` (String, required): Start time.
- `intake_time_to` (String, required): End time.
- `lunch_time_from` (String): Lunch start time.
- `lunch_time_to` (String): Lunch end time.
- `name` (String, required): Cargo description.
- `need_call` (Boolean): Whether a call is needed.
- `comment` (String): Comment for courier.
- `courier_power_of_attorney` (Boolean): Courier needs power of attorney.
- `courier_identity_card` (Boolean): Courier needs identity card.
- `sender` (Hash, required): Sender contact information.
- `from_location` (Hash, required): Pickup location details.
- `weight` (Integer): Cargo weight in grams.
- `length` (Integer): Cargo length in cm.
- `width` (Integer): Cargo width in cm.
- `height` (Integer): Cargo height in cm.

### Check

Represents check query data.

Attributes:

- `order_uuid` (String): Order UUID.
- `cdek_number` (String): CDEK order number.
- `date` (String): Date for check retrieval.

## Schema Management

The gem includes a schema management system to keep API definitions up-to-date. The `pull_cdek_schemas.rb` script fetches the latest OpenAPI schemas from CDEK's documentation and organizes them.

### Pulling Latest Schemas

```ruby
# Run the schema pull script
ruby pull_cdek_schemas.rb

# This will:
# 1. Fetch API documentation from CDEK
# 2. Parse and organize schemas
# 3. Save to cdek_api_schemas.json
# 4. Display analysis of available endpoints
```

### Schema Analysis

The script analyzes and organizes:
- **5 main API schemas** from CDEK documentation
- **40 unique endpoints** across all schemas
- Complete endpoint mapping with HTTP methods
- Metadata for each schema version

### Automated Updates

Run the schema pull script periodically to stay updated with the latest CDEK API changes:

```bash
# Add to cron or CI/CD pipeline
0 2 * * * cd /path/to/gem && ruby pull_cdek_schemas.rb
```

## TODO List

- [x] Restructure the codebase for better organization.
- [x] Add mappings for CDEK internal codes.
- [x] Add more API endpoints and data entities (Order management, Print/Documents, Courier services, Payment services).
- [x] Implement schema management system.
- [x] Add comprehensive documentation in English, Russian, and Tatar.
- [ ] Check all attributes for required and optional fields.
- [x] Add documentation for all classes and methods.
- [ ] Refine entity validations.
- [ ] Add more comprehensive error handling.
- [ ] Add rate limiting support.

## Changelog

(See [CHANGELOG.md](CHANGELOG.md))

## Contributing

Bug reports and pull requests are welcome on GitHub. This gem is used in a couple of projects and fulfills the requirements of those projects. If you have any suggestions or improvements, feel free to open an issue or a pull request.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
