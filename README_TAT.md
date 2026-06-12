### CDEK API Клиенты

[![Gem Версия](https://badge.fury.io/rb/cdek_api_client.svg)](https://badge.fury.io/rb/cdek_api_client)

### Башка телләрдә

- [Русский](README_RUS.md)
- [English](README.md)
- [Татарча](README_TAT.md)

## Күзәтү

СДЭК ([CDEK](https://www.cdek.ru/)) - Россиядәге зур логистика компаниясе, бизнес һәм шәхси кешеләр өчен төрле хезмәтләр күрсәтә. [CDEK API](https://www.cdek.ru/ru/integration/api) эшләнүчеләргә СДЭК хезмәтләрен үз кушымталарына интеграцияләргә мөмкинлек бирә, заказ ясау, күзәтү, тарифларны исәпләү, урын мәгълүматларын алу һәм вебхуктарны идарә итү кебек функцияләрне тормышка ашырып.

`cdek_api_client` gem CDEK API өчен Ruby-интерфейс тәкъдим итә.

Функцияләр:

- **Заказларны идарә итү**: Заказлар ясау, күзәтү, яңарту, гамәлдән чыгару һәм бетерү.
- **Тарифларны исәпләү**: Аерым тарифларны һәм тарифлар исемлеген исәпләү.
- **Урын хезмәтләре**: Шәһәрләрне, регионнарны, почта индексларын һәм тапшыру офисларын алу.
- **Бастыру/Документлар**: Штрих-кодларны һәм счет-фактураларны генерацияләү (PDF).
- **Курьер хезмәтләре**: Тапшыру килешүләрен һәм йөк алу сорауларын идарә итү.
- **Түләү хезмәтләре**: Түләүләр һәм чеклар турында мәгълүмат алу.
- **Вебхукларны идарә итү**: Вебхукларны теркәү һәм идарә итү.
- **Тестлау**: Динамик мокирование (`AutoMocker`) һәм автогенерацияләнгән API спецификацияләре.
- **Ышанычлылык**: 5xx хаталары өчен автоматик кабатлау логикасы (retry) һәм лимитларны эшкәртү (Rate-limit backoff).
- **Схемалар синхронизациясе**: OpenAPI схемаларын автоматик синхронизацияләү һәм код генерациясе.

## Эчтәлек

- [Урнаштыру](#урнаштыру)
- [Куллану](#куллану)
  - [Инициализация](#инициализация)
  - [Заказ ясау](#заказ-ясау)
  - [Заказны күзәтү](#заказны-күзәтү)
  - [Тарифны исәпләү](#тарифны-исәпләү)
  - [Урын мәгълүматларын алу](#урын-мәгълүматларын-алу)
  - [Веб-хокларны көйләү](#веб-хокларны-көйләү)
  - [Урын мәгълүматларын алу һәм саклау](#урын-мәгълүматларын-алу-һәм-саклау)
  - [Заказларны идарә итү](#заказларны-идарә-итү)
  - [Бастыру һәм документлар](#бастыру-һәм-документлар)
  - [Курьер хезмәтләре](#курьер-хезмәтләре)
  - [Түләү хезмәтләре](#түләү-хезмәтләре)
  - [Киңәйтелгән тариф исәпләве](#киңәйтелгән-тариф-исәпләве)
  - [Киңәйтелгән вебхук идарәсе](#киңәйтелгән-вебхук-идарәсе)
- [Субъектлар](#субъектлар)
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
- [Схема идарәсе](#схема-идарәсе)
- [TODO Лист](#todo-лист)
- [Үзгәрешләр](#үзгәрешләр)
- [Ярдәм итү](#ярдәм-итү)
- [Лицензия](#лицензия)

## Урнаштыру

Бу юлны Gemfile'га өстәрегез:

```ruby
gem 'cdek_api_client', '~> 0.5.1'
```

Аннары башкарырга:

```sh
bundle install
```

Яки gem'ны үзегез урнаштырыгыз:

```sh
gem install cdek_api_client
```

## Куллану

### Инициализация

CDEK API Клиенты белән эшләү өчен, аны сезнең CDEK API учет мәгълүматлары белән инициализацияләргә кирәк (client ID һәм client secret):

```ruby
require 'cdek_api_client'

client_id = 'your_client_id'
client_secret = 'your_client_secret'

client = CDEKApiClient::Client.new(client_id, client_secret)
```

### Заказ ясау

Заказ ясау өчен кирәкле субъектларны (`OrderData`, `Recipient`, `Sender`, `Package`, һәм `Item`) булдырырга һәм аларны `Order` классындагы `create_order` методы белән тапшырырга кирәк:

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

### Заказны күзәтү

Заказны күзәтү өчен, `Order` классындагы `track` методын заказ UUID белән кулланыгыз:

```ruby
order_uuid = 'order_uuid_from_created_order_response'

begin
  tracking_info = order_client.track(order_uuid)
  puts "Tracking info: #{tracking_info}"
rescue => e
  puts "Error tracking order: #{e.message}"
end
```

### Тарифны исәпләү

Тарифны исәпләү өчен, кирәкле тариф мәгълүматлары белән `Tariff` классындагы `calculate` методын кулланыгыз:

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

### Урын мәгълүматларын алу

CDEK'ның ярдәм ителгән шәһәрләре һәм төбәкләре кебек урын мәгълүматларын алу өчен `Location` классындагы `cities` һәм `regions` методларын кулланыгыз:

```ruby
location_client = CDEKApiClient::Location.new(client)

# Шәһәрләрне алу
begin
  cities = location_client.cities
  puts "Cities: #{cities}"
rescue => e
  puts "Error fetching cities: #{e.message}"
end

# Төбәкләрне алу
begin
  regions = location_client.regions
  puts "Regions: #{regions}"
rescue => e
  puts "Error fetching regions: #{e.message}"
end
```

### Веб-хокларны көйләү

Веб-хоклар сезнең кушымтага реаль вакытта төрле вакыйгалар турында хәбәр итәргә мөмкинлек бирә. Веб-хокны көйләү өчен, CDEK HTTP POST сорауларын җибәрәчәк URL'ны теркәгез:

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

Теркәлгән веб-хокларны алу һәм бетерү өчен:

```ruby
# Веб-хокларны алу
begin
  webhooks = webhook_client.get_webhooks
  puts "Webhooks: #{webhooks}"
rescue => e
  puts "Error fetching webhooks: #{e.message}"
end

# Веб-хокны бетерү
webhook_id = 'webhook_id_to_delete'
begin
  response = webhook_client.delete(webhook_id)
  puts "Webhook deleted: #{response}"
rescue => e
  puts "Error deleting webhook: #{e.message}"
end
```

### Урын мәгълүматларын алу һәм саклау

Gem алдан кэшланган кыйммәтләрне эшли һәм аларны төп булып куллана. Кулланучылар бу үзлекне CDEK API'дан турыдан-туры яңа мәгълүматлар алып үзгәртергә мөмкин.

```ruby
# Шәһәрләрне алу
begin
  cities = location_client.cities(use_live_data: true)
rescue => e
  puts "Шәһәрләрне алу хатасы: #{e.message}"
end

# Регионнарны алу
begin
  regions = location_client.regions(use_live_data: true)
rescue => e
  puts "Регионнарны алу хатасы: #{e.message}"
end

# Офисларны алу
begin
  offices = location_client.offices(use_live_data: true)
rescue => e
  puts "Офисларны алу хатасы: #{e.message}"
end

# Һәр шәһәр өчен почта кодларын алу
begin
  cities = location_client.cities(use_live_data: true)
rescue => e
  puts "Почта кодларын алу хатасы: #{e.message}"
end
```

### Заказларны идарә итү

Заказларны идарә итү мисаллары:

```ruby
# Заказны бетерү
begin
  response = client.order.delete('order-uuid')
  puts "Заказ бетерелде: #{response}"
rescue => e
  puts "Заказны бетерү хатасы: #{e.message}"
end

# Заказны гамәлдән чыгару (баш тарту)
begin
  response = client.order.cancel('order-uuid')
  puts "Заказ гамәлдән чыгарылды: #{response}"
rescue => e
  puts "Заказны гамәлдән чыгару хатасы: #{e.message}"
end

# Заказны яңарту
updated_order_data = # ... яңартылган заказ мәгълүматларын булдырырга
begin
  response = client.order.update(updated_order_data)
  puts "Заказ яңартылды: #{response}"
rescue => e
  puts "Заказны яңарту хатасы: #{e.message}"
end

# Заказны UUID буенча алу
begin
  order_info = client.order.get('order-uuid')
  puts "Заказ турында мәгълүмат: #{order_info}"
rescue => e
  puts "Заказны алу хатасы: #{e.message}"
end

# Заказны СДЭК номеры буенча алу
begin
  order_info = client.order.get_by_cdek_number('123456789')
  puts "Заказ турында мәгълүмат: #{order_info}"
rescue => e
  puts "Заказны алу хатасы: #{e.message}"
end

# Заказны ИМ номеры буенча алу
begin
  order_info = client.order.get_by_im_number('ORDER123')
  puts "Заказ турында мәгълүмат: #{order_info}"
rescue => e
  puts "Заказны алу хатасы: #{e.message}"
end

# Клиент кайтару заказы ясау
client_return_data = CDEKApiClient::Entities::OrderData.new(
  type: 1,
  tariff_code: 1,
  packages: [package]
)
begin
  response = client.order.create_client_return('original-order-uuid', client_return_data)
  puts "Клиент кайтаруы ясалды: #{response}"
rescue => e
  puts "Клиент кайтаруын ясау хатасы: #{e.message}"
end

# Заказ өчен алуларны алу
begin
  intakes = client.order.get_intakes('order-uuid')
  puts "Заказ алулары: #{intakes}"
rescue => e
  puts "Алуларны алу хатасы: #{e.message}"
end
```

### Бастыру һәм документлар

Штрих-кодлар һәм счет-фактуралар кебек бастырыла торган документлар генерацияләү һәм алу:

```ruby
# Штрих-код ясау
barcode_data = CDEKApiClient::Entities::Barcode.with_orders_uuid('order-uuid')
begin
  response = client.print.create_barcode(barcode_data)
  puts "Штрих-код ясалды: #{response}"
rescue => e
  puts "Штрих-код ясау хатасы: #{e.message}"
end

# Штрих-кодны PDF рәвешендә алу
begin
  pdf_content = client.print.get_barcode_pdf('barcode-uuid')
  File.write('barcode.pdf', pdf_content)
rescue => e
  puts "PDF штрих-код алу хатасы: #{e.message}"
end

# Счет-фактура ясау
invoice_data = CDEKApiClient::Entities::Invoice.with_orders_uuid('order-uuid')
begin
  response = client.print.create_invoice(invoice_data)
  puts "Счет-фактура ясалды: #{response}"
rescue => e
  puts "Счет-фактура ясау хатасы: #{e.message}"
end

# Счет-фактураны PDF рәвешендә алу
begin
  pdf_content = client.print.get_invoice_pdf('invoice-uuid')
  File.write('invoice.pdf', pdf_content)
rescue => e
  puts "PDF счет-фактура алу хатасы: #{e.message}"
end
```

### Курьер хезмәтләре

Тапшыру килешүләре һәм курьер йөк алу сорауларын идарә итү:

```ruby
# Тапшыру килешүе ясау
agreement_data = CDEKApiClient::Entities::Agreement.new(
  cdek_number: '123456789',
  date: '2024-01-17',
  time_from: '10:00',
  time_to: '18:00',
  comment: 'Тапшыру килешүе'
)
begin
  response = client.courier.create_agreement(agreement_data)
  puts "Килешү ясалды: #{response}"
rescue => e
  puts "Килешү ясау хатасы: #{e.message}"
end

# Курьер йөк алу соравы ясау
intake_data = CDEKApiClient::Entities::Intakes.new(
  cdek_number: '123456789',
  intake_date: '2024-01-17',
  intake_time_from: '10:00',
  intake_time_to: '18:00',
  name: 'Йөк тасвирламасы',
  sender: { name: 'Җибәрүче исеме', phones: [{ number: '+79001234567' }] },
  from_location: { code: 44, address: 'Алу адресы' }
)
begin
  response = client.courier.create_intake(intake_data)
  puts "Алу ясалды: #{response}"
rescue => e
  puts "Алу ясау хатасы: #{e.message}"
end

# Йөк алу соравын бетерү
begin
  response = client.courier.delete_intake('intake-uuid')
  puts "Алу бетерелде: #{response}"
rescue => e
  puts "Алуны бетерү хатасы: #{e.message}"
end
```

### Түләү хезмәтләре

Түләүләр һәм чеклар турында мәгълүмат алу:

```ruby
# Көн өчен түләүләрне алу
begin
  payments = client.payment.get_payments('2024-01-17')
  puts "Түләүләр: #{payments}"
rescue => e
  puts "Түләүләрне алу хатасы: #{e.message}"
end

# Чекларны алу
check_data = CDEKApiClient::Entities::Check.new(
  cdek_number: '123456789',
  date: '2024-01-17'
)
begin
  checks = client.payment.get_checks(check_data.to_query_params)
  puts "Чеклар: #{checks}"
rescue => e
  puts "Чекларны алу хатасы: #{e.message}"
end

# Түләү реестрларын алу
begin
  registries = client.payment.get_registries('2024-01-17')
  puts "Реестрлар: #{registries}"
rescue => e
  puts "Реестрларны алу хатасы: #{e.message}"
end
```

### Киңәйтелгән тариф исәпләве

Барлык мөмкин тарифларны берьюлы исәпләү:

```ruby
# Тарифлар исемлеген исәпләү
begin
  tariffs = client.tariff.calculate_list(tariff_data)
  puts "Мөмкин тарифлар: #{tariffs}"
rescue => e
  puts "Тарифларны исәпләү хатасы: #{e.message}"
end
```

### Вебхукларны идарә итү

Вебхукларны исемләү һәм идарә итү:

```ruby
# Барлык вебхукларны исемләү
begin
  webhooks = client.webhook.list_all
  puts "Барлык вебхуклар: #{webhooks}"
rescue => e
  puts "Вебхукларны исемләү хатасы: #{e.message}"
end

# Конкрет вебхукны алу
begin
  webhook = client.webhook.get('webhook-uuid')
  puts "Вебхук: #{webhook}"
rescue => e
  puts "Вебхукны алу хатасы: #{e.message}"
end

# Вебхукны UUID буенча бетерү
begin
  response = client.webhook.delete('webhook-uuid')
  puts "Вебхук бетерелде: #{response}"
rescue => e
  puts "Вебхукны бетерү хатасы: #{e.message}"
end
```

## Субъектлар

### OrderData

Заказ мәгълүматларын тәкъдим итә.

Атрибутлар:

- `type` (Integer, мәҗбүри): Заказ төре.
- `number` (String, мәҗбүри): Заказ номеры.
- `tariff_code` (Integer, мәҗбүри): Тариф коды.
- `comment` (String): Заказ өчен комментарий.
- `recipient` (Recipient, мәҗбүри): Кабул итүченең мәгълүматлары.
- `sender` (Sender, мәҗбүри): Җибәрүченең мәгълүматлары.
- `from_location` (Hash, мәҗбүри): Заказ җибәрелгән урынның мәгълүматлары.
- `to_location` (Hash, мәҗбүри): Заказ җибәрелгән урынның мәгълүматлары.
- `services` (Array): Өстәмә хезмәтләр.
- `packages` (Array, мәҗбүри): Упаковкалар исемлеге.

### Recipient

Кабул итүченең мәгълүматларын тәкъдим итә.

Атрибутлар:

- `name` (String, мәҗбүри): Кабул итүченең исеме.
- `phones` (Array, мәҗбүри): Телефон номерлары исемлеге.
- `email` (String, мәҗбүри): Кабул итүченең электрон почтасы.

### Sender

Җибәрүченең мәгълүматларын тәкъдим итә.

Атрибутлар:

- `name` (String, мәҗбүри): Җибәрүченең исеме.
- `phones` (Array, мәҗбүри): Телефон номерлары исемлеге.
- `email` (String, мәҗбүри): Җибәрүченең электрон почтасы.

### Package

Упаковка турында мәгълүматны тәкъдим итә.

Атрибутлар:

- `number` (String, мәҗбүри): Упаковка номеры.
- `weight` (Integer, мәҗбүри): Упаковка авырлыгы.
- `length` (Integer, мәҗбүри): Упаковка озынлыгы.
- `width` (Integer, мәҗбүри): Упаковка киңлеге.
- `height` (Integer, мәҗбүри): Упаковка биеклеге.
- `comment` (String): Упаковка өчен комментарий.
- `items` (Array, мәҗбүри): Упаковкадагы товарлар исемлеге.

### Item

Товар турында мәгълүматны тәкъдим итә.

Атрибутлар:

- `name` (String, мәҗбүри): Товар исеме.
- `ware_key` (String, мәҗбүри): Товар коды.
- `payment` (Integer, мәҗбүри): Товарның бәясе.
- `cost` (Integer, мәҗбүри): Товарның кыйммәте.
- `weight` (Integer, мәҗбүри): Товарның авырлыгы.
- `amount` (Integer, мәҗбүри): Товар саны.

### Barcode

Бастыру өчен штрих-код ясау мәгълүматларын тәкъдим итә.

Атрибутлар:

- `orders` (Array, мәҗбүри): Штрих-код генерациясе өчен заказлар исемлеге.
- `copy_count` (Integer): Күчермәләр саны (килешү буенча: 1).
- `format` (String): Бастыру форматы (A4, A5, A6, A7).
- `lang` (String): Тел коды (RUS, ENG, DEU, ITA, TUR, CES, KOR, LIT, LAT).

### Invoice

Бастыру өчен счет-фактура ясау мәгълүматларын тәкъдим итә.

Атрибутлар:

- `orders` (Array, мәҗбүри): Счет-фактура генерациясе өчен заказлар исемлеге.
- `copy_count` (Integer): Күчермәләр саны (килешү буенча: 2).
- `type` (String): Счет-фактура төре (tpl_russia, tpl_china, tpl_armenia, tpl_english, tpl_italian, tpl_korean, tpl_latvian, tpl_lithuanian, tpl_german, tpl_turkish, tpl_czech, tpl_thailand, tpl_invoice).

### Agreement

Тапшыру килешүе мәгълүматларын тәкъдим итә.

Атрибутлар:

- `cdek_number` (String, мәҗбүри): СДЭК заказ номеры.
- `order_uuid` (String): Заказ UUID'ы.
- `date` (String, мәҗбүри): Тапшыру көне.
- `time_from` (String, мәҗбүри): Башлану вакыты.
- `time_to` (String, мәҗбүри): Тәмамлану вакыты.
- `comment` (String): Комментарий.
- `delivery_point` (String): Тапшыру ноктасы коды.
- `to_location` (Hash): Тапшыру урыны мәгълүматлары.

### Intakes

Курьер йөк алу соравы мәгълүматларын тәкъдим итә.

Атрибутлар:

- `cdek_number` (String): СДЭК заказ номеры.
- `order_uuid` (String): Заказ UUID'ы.
- `intake_date` (String, мәҗбүри): Алу көне.
- `intake_time_from` (String, мәҗбүри): Башлану вакыты.
- `intake_time_to` (String, мәҗбүри): Тәмамлану вакыты.
- `lunch_time_from` (String): Төшке аш башлану вакыты.
- `lunch_time_to` (String): Төшке аш тәмамлану вакыты.
- `name` (String, мәҗбүри): Йөк тасвирламасы.
- `need_call` (Boolean): Шалтырату кирәкме.
- `comment` (String): Курьер өчен комментарий.
- `courier_power_of_attorney` (Boolean): Курьерга ышаныч кәгазе кирәкме.
- `courier_identity_card` (Boolean): Курьерга шәхес таныклыгы кирәкме.
- `sender` (Hash, мәҗбүри): Җибәрүче контакт мәгълүматлары.
- `from_location` (Hash, мәҗбүри): Алу урыны мәгълүматлары.
- `weight` (Integer): Йөк авырлыгы граммнарда.
- `length` (Integer): Йөк озынлыгы см'да.
- `width` (Integer): Йөк киңлеге см'да.
- `height` (Integer): Йөк биеклеге см'да.

### Check

Чек соравы мәгълүматларын тәкъдим итә.

Атрибутлар:

- `order_uuid` (String): Заказ UUID'ы.
- `cdek_number` (String): СДЭК заказ номеры.
- `date` (String): Чеклар алу өчен көн.

## Схема идарәсе

Gem API билгеләнешләрен актуаль тоту өчен схема идарәсе системасын эченә ала. `pull_cdek_schemas.rb` скрипты CDEK документациясеннән соңгы OpenAPI схемаларын ала һәм аларны оештыра.

### Соңгы схемаларны алу

```ruby
# Схема алу скриптын эшләтү
ruby pull_cdek_schemas.rb

# Бу эшли:
# 1. CDEK'тан API документациясе алу
# 2. Схемаларны анализлау һәм оештыру
# 3. cdek_api_schemas.json'га саклау
# 4. Мөмкин эндпоинтлар анализын күрсәтү
```

### Схема анализы

Скрипт анализлый һәм оештыра:
- CDEK документациясеннән **5 төп API схемасы**
- Барлык схемаларда **40 уникаль эндпоинт**
- HTTP методлары белән тулы эндпоинт маппинглары
- Һәр схема версиясе өчен метамәгълүматлар

### Автоматик яңартулар

CDEK API соңгы үзгәрешләре белән актуальлекне саклау өчен схема алу скриптын периодик эшләтегез:

```bash
# Cron'га яки CI/CD pipeline'га өстәргә
0 2 * * * cd /path/to/gem && ruby pull_cdek_schemas.rb
```

## TODO Лист

- [x] Код базасын яхшырак оештыру өчен реструктуризацияләү.
- [x] CDEK эчке кодлары өчен маппинглар өстәү.
- [x] Күбрәк API нокталары һәм мәгълүмат субъектлары өстәү (Заказ идарәсе, Бастыру/Документлар, Курьер хезмәтләре, Түләү хезмәтләре).
- [x] Схема идарәсе системасын гамәлгә ашыру.
- [x] Инглиз, рус һәм татар телләрендә тулы документация өстәү.
- [ ] Бөтен атрибутларны мәҗбүри һәм өстәмә кырлар өчен тикшерү.
- [x] Барлык класслар һәм методлар өчен документация өстәү.
- [ ] Субъектлар валидациясен төзәтү.
- [ ] VCR белән интеграцион тестлар өстәү.
- [ ] Күбрәк комплекслы хата эшкәртү өстәү.
- [ ] Сораулар лимиты буенча ярдәм өстәү.

## Үзгәрешләр

([CHANGELOG.md](CHANGELOG.md) файлында күрсәтелгән барлык үзгәрешләрне карарга кирәк.)

## Ярдәм итү

Баг исемлегеләрен һәм pull request'ларны GitHub'да кирәк. Бу gem күп проектларда кулланылырга һәм уларны талапларын тиешләргә кулланылырга. Әгәр сездә күтүләр һәм яхшыртмалар булса, исемлек яки pull request ачырга кирәк.

## Лицензия

Бу gem [MIT Лицензиясе](https://opensource.org/licenses/MIT) шартларында ачык кодлы буларак урнаштырылган.
