### Клиент CDEK API

[![Версия Gem](https://badge.fury.io/rb/cdek_api_client.svg)](https://badge.fury.io/rb/cdek_api_client)

### Другие языки

- [English](README.md)
- [Татарча](README_TAT.md)
- [Русский](README_RUS.md)

> [!WARNING] >**Важно:** Этот gem находится на ранней стадии разработки и распространяется как есть. Любая поддержка разработки или обратная связь приветствуется; пожалуйста, ознакомьтесь с разделом [Contributing](#contributing) для получения дополнительной информации.

## Обзор

СДЭК ([CDEK](https://www.cdek.ru/)) - крупная логистическая компания в России, предоставляющая широкий спектр услуг доставки для бизнеса и частных лиц. [API СДЭК](https://www.cdek.ru/ru/integration/api) позволяет разработчикам интегрировать услуги СДЭК в свои приложения, обеспечивая такие функции, как создание заказов, отслеживание, расчет тарифов, получение данных о местоположении и управление вебхуками.

Gem `cdek_api_client` предоставляет Ruby-интерфейс для API СДЭК.

Функции:

- **Управление заказами**: Создание, отслеживание, обновление, отмена и удаление заказов.
- **Расчет тарифов**: Расчет отдельных тарифов и списков тарифов.
- **Сервисы местоположения**: Получение городов, регионов, почтовых индексов и офисов доставки.
- **Печать/Документы**: Генерация штрих-кодов и счетов-фактур (PDF).
- **Курьерские услуги**: Управление договоренностями о доставке и запросами на забор груза.
- **Платежные услуги**: Получение информации о платежах и чеках.
- **Управление вебхуками**: Регистрация и управление вебхуками.
- **Тестирование**: Динамическое мокирование тестов без конфигурации (`AutoMocker`) и автогенерация API спецификаций.
- **Отказоустойчивость**: Встроенная логика повторных попыток для 5xx ошибок и автоматическая обработка лимитов запросов (Rate-limit backoff).
- **Синхронизация схем**: Полностью автоматизированная синхронизация OpenAPI схем и кодогенерация.

## Содержание

- [Установка](#установка)
- [Использование](#использование)
  - [Инициализация](#инициализация)
  - [Создание заказа](#создание-заказа)
  - [Отслеживание заказа](#отслеживание-заказа)
  - [Управление заказами](#управление-заказами)
  - [Расчет тарифа](#расчет-тарифа)
  - [Расширенный расчет тарифов](#расширенный-расчет-тарифов)
  - [Получение данных о местоположении](#получение-данных-о-местоположении)
  - [Печать и документы](#печать-и-документы)
  - [Курьерские услуги](#курьерские-услуги)
  - [Платежные услуги](#платежные-услуги)
  - [Настройка вебхуков](#настройка-вебхуков)
  - [Расширенное управление вебхуками](#расширенное-управление-вебхуками)
  - [Получение и сохранение данных о местоположении](#получение-и-сохранение-данных-о-местоположении)
- [Сущности](#сущности)
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
- [Управление схемами](#управление-схемами)
- [TODO List](#todo-list)
- [Изменения](#изменения)
- [Содействие](#содействие)
- [Лицензия](#лицензия)

## Установка

Добавьте эту строку в ваш Gemfile:

```ruby
gem 'cdek_api_client'
```

Затем выполните:

```sh
bundle install
```

Или установите gem самостоятельно:

```sh
gem install cdek_api_client
```

## Использование

### Инициализация

Чтобы использовать клиент CDEK API, необходимо инициализировать его с вашими учетными данными CDEK API (client ID и client secret):

```ruby
require 'cdek_api_client'

client_id = 'your_client_id'
client_secret = 'your_client_secret'

client = CDEKApiClient::Client.new(client_id, client_secret)
```

### Создание заказа

Для создания заказа нужно создать необходимые сущности (`OrderData`, `Recipient`, `Sender`, `Package` и `Item`) и передать их в метод `create_order` класса `Order`:

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

### Отслеживание заказа

Чтобы отслеживать заказ, используйте метод `track` класса `Order` с UUID заказа:

```ruby
order_uuid = 'order_uuid_from_created_order_response'

begin
  tracking_info = order_client.track(order_uuid)
  puts "Tracking info: #{tracking_info}"
rescue => e
  puts "Error tracking order: #{e.message}"
end
```

### Расчет тарифа

Для расчета тарифа используйте метод `calculate` класса `Tariff` с необходимыми данными тарифа:

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

### Получение данных о местоположении

Чтобы получить данные о местоположении, такие как города и регионы, поддерживаемые CDEK, используйте методы `cities` и `regions` класса `Location`:

```ruby
location_client = CDEKApiClient::Location.new(client)

# Получение городов
begin
  cities = location_client.cities
  puts "Cities: #{cities}"
rescue => e
  puts "Error fetching cities: #{e.message}"
end

# Получение регионов
begin
  regions = location_client.regions
  puts "Regions: #{regions}"
rescue => e
  puts "Error fetching regions: #{e.message}"
end
```

### Управление заказами

Примеры управления заказами:

```ruby
# Удаление заказа
begin
  response = client.order.delete('order-uuid')
  puts "Заказ удален: #{response}"
rescue => e
  puts "Ошибка удаления заказа: #{e.message}"
end

# Отмена заказа (отказ)
begin
  response = client.order.cancel('order-uuid')
  puts "Заказ отменен: #{response}"
rescue => e
  puts "Ошибка отмены заказа: #{e.message}"
end

# Обновление заказа
updated_order_data = # ... создать обновленные данные заказа
begin
  response = client.order.update(updated_order_data)
  puts "Заказ обновлен: #{response}"
rescue => e
  puts "Ошибка обновления заказа: #{e.message}"
end

# Получение заказа по UUID
begin
  order_info = client.order.get('order-uuid')
  puts "Информация о заказе: #{order_info}"
rescue => e
  puts "Ошибка получения заказа: #{e.message}"
end

# Получение заказа по номеру СДЭК
begin
  order_info = client.order.get_by_cdek_number('123456789')
  puts "Информация о заказе: #{order_info}"
rescue => e
  puts "Ошибка получения заказа: #{e.message}"
end

# Получение заказа по номеру ИМ
begin
  order_info = client.order.get_by_im_number('ORDER123')
  puts "Информация о заказе: #{order_info}"
rescue => e
  puts "Ошибка получения заказа: #{e.message}"
end

# Создание клиентского возврата
client_return_data = CDEKApiClient::Entities::OrderData.new(
  type: 1,
  tariff_code: 1,
  packages: [package]
)
begin
  response = client.order.create_client_return('original-order-uuid', client_return_data)
  puts "Клиентский возврат создан: #{response}"
rescue => e
  puts "Ошибка создания клиентского возврата: #{e.message}"
end

# Получение заборов для заказа
begin
  intakes = client.order.get_intakes('order-uuid')
  puts "Заборы заказа: #{intakes}"
rescue => e
  puts "Ошибка получения заборов: #{e.message}"
end
```

### Расширенный расчет тарифов

Расчет всех доступных тарифов за один раз:

```ruby
# Расчет списка тарифов
begin
  tariffs = client.tariff.calculate_list(tariff_data)
  puts "Доступные тарифы: #{tariffs}"
rescue => e
  puts "Ошибка расчета тарифов: #{e.message}"
end
```

### Печать и документы

Генерация и получение печатных документов вроде штрих-кодов и счетов-фактур:

```ruby
# Создание штрих-кода
barcode_data = CDEKApiClient::Entities::Barcode.with_orders_uuid('order-uuid')
begin
  response = client.print.create_barcode(barcode_data)
  puts "Штрих-код создан: #{response}"
rescue => e
  puts "Ошибка создания штрих-кода: #{e.message}"
end

# Получение штрих-кода в PDF
begin
  pdf_content = client.print.get_barcode_pdf('barcode-uuid')
  File.write('barcode.pdf', pdf_content)
rescue => e
  puts "Ошибка получения PDF штрих-кода: #{e.message}"
end

# Создание счета-фактуры
invoice_data = CDEKApiClient::Entities::Invoice.with_orders_uuid('order-uuid')
begin
  response = client.print.create_invoice(invoice_data)
  puts "Счет-фактура создан: #{response}"
rescue => e
  puts "Ошибка создания счета-фактуры: #{e.message}"
end

# Получение счета-фактуры в PDF
begin
  pdf_content = client.print.get_invoice_pdf('invoice-uuid')
  File.write('invoice.pdf', pdf_content)
rescue => e
  puts "Ошибка получения PDF счета-фактуры: #{e.message}"
end
```

### Курьерские услуги

Управление договоренностями о доставке и запросами на забор груза:

```ruby
# Создание договоренности о доставке
agreement_data = CDEKApiClient::Entities::Agreement.new(
  cdek_number: '123456789',
  date: '2024-01-17',
  time_from: '10:00',
  time_to: '18:00',
  comment: 'Договоренность о доставке'
)
begin
  response = client.courier.create_agreement(agreement_data)
  puts "Договоренность создана: #{response}"
rescue => e
  puts "Ошибка создания договоренности: #{e.message}"
end

# Создание запроса на забор курьером
intake_data = CDEKApiClient::Entities::Intakes.new(
  cdek_number: '123456789',
  intake_date: '2024-01-17',
  intake_time_from: '10:00',
  intake_time_to: '18:00',
  name: 'Описание груза',
  sender: { name: 'Отправитель', phones: [{ number: '+79001234567' }] },
  from_location: { code: 44, address: 'Адрес забора' }
)
begin
  response = client.courier.create_intake(intake_data)
  puts "Забор создан: #{response}"
rescue => e
  puts "Ошибка создания забора: #{e.message}"
end

# Удаление запроса на забор
begin
  response = client.courier.delete_intake('intake-uuid')
  puts "Забор удален: #{response}"
rescue => e
  puts "Ошибка удаления забора: #{e.message}"
end
```

### Платежные услуги

Получение информации о платежах и чеках:

```ruby
# Получение платежей за дату
begin
  payments = client.payment.get_payments('2024-01-17')
  puts "Платежи: #{payments}"
rescue => e
  puts "Ошибка получения платежей: #{e.message}"
end

# Получение чеков
check_data = CDEKApiClient::Entities::Check.new(
  cdek_number: '123456789',
  date: '2024-01-17'
)
begin
  checks = client.payment.get_checks(check_data.to_query_params)
  puts "Чеки: #{checks}"
rescue => e
  puts "Ошибка получения чеков: #{e.message}"
end

# Получение реестров платежей
begin
  registries = client.payment.get_registries('2024-01-17')
  puts "Реестры: #{registries}"
rescue => e
  puts "Ошибка получения реестров: #{e.message}"
end
```

### Управление вебхуками

Перечисление и управление вебхуками:

```ruby
# Перечисление всех вебхуков
begin
  webhooks = client.webhook.list_all
  puts "Все вебхуки: #{webhooks}"
rescue => e
  puts "Ошибка перечисления вебхуков: #{e.message}"
end

# Получение конкретного вебхука
begin
  webhook = client.webhook.get('webhook-uuid')
  puts "Вебхук: #{webhook}"
rescue => e
  puts "Ошибка получения вебхука: #{e.message}"
end

# Удаление вебхука по UUID
begin
  response = client.webhook.delete('webhook-uuid')
  puts "Вебхук удален: #{response}"
rescue => e
  puts "Ошибка удаления вебхука: #{e.message}"
end
```

### Получение и сохранение данных о местоположении

Gem имеет предварительно кэшированные значения и использует их по умолчанию. Пользователи могут переопределить это поведение, получая живые данные напрямую из API CDEK.

```ruby
# Получение городов
begin
  cities = location_client.cities(use_live_data: true)
rescue => e
  puts "Ошибка получения городов: #{e.message}"
end

# Получение регионов
begin
  regions = location_client.regions(use_live_data: true)
rescue => e
  puts "Ошибка получения регионов: #{e.message}"
end

# Получение офисов
begin
  offices = location_client.offices(use_live_data: true)
rescue => e
  puts "Ошибка получения офисов: #{e.message}"
end

# Получение почтовых кодов для каждого города
begin
  cities = location_client.cities(use_live_data: true)
rescue => e
  puts "Ошибка получения почтовых кодов: #{e.message}"
end
```

### Настройка вебхуков

Вебхуки позволяют вашему приложению получать уведомления в реальном времени о различных событиях, связанных с вашими отправлениями. Чтобы настроить вебхук, зарегистрируйте URL, на который CDEK будет отправлять HTTP POST запросы с данными о событиях:

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

Чтобы получить и удалить зарегистрированные вебхуки:

```ruby
# Получение вебхуков
begin
  webhooks = webhook_client.get_webhooks
  puts "Webhooks: #{webhooks}"
rescue => e
  puts "Error fetching webhooks: #{e.message}"
end

# Удаление вебхука
webhook_id = 'webhook_id_to_delete'
begin
  response = webhook_client.delete(webhook_id)
  puts "Webhook deleted: #{response}"
rescue => e
  puts "Error deleting webhook: #{e.message}"
end
```

### Сущности

### OrderData

Представляет данные заказа.

Атрибуты:

- `type` (Integer, обязательный): Тип заказа.
- `number` (String, обязательный): Номер заказа.
- `tariff_code` (Integer, обязательный): Код тарифа.
- `comment` (String): Комментарий к заказу.
- `recipient` (Recipient, обязательный): Детали получателя.
- `sender` (Sender, обязательный): Детали отправителя.
- `from_location` (Hash, обязательный): Детали места отправления заказа.
- `to_location` (Hash, обязательный): Детали места назначения заказа.
- `services` (Array): Дополнительные услуги.
- `packages` (Array, обязательный): Список упаковок.

### Recipient

Представляет данные получателя.

Атрибуты:

- `name` (String, обязательный): Имя получателя.
- `phones` (Array, обязательный): Список телефонных номеров.
- `email` (String, обязательный): Электронная почта получателя.

### Sender

Представляет данные отправителя.

Атрибуты:

- `name` (String, обязательный): Имя отправителя.
- `phones` (Array, обязательный): Список телефонных номеров.
- `email` (String, обязательный): Электронная почта отправителя.

### Package

Представляет данные об упаковке.

Атрибуты:

- `number` (String, обязательный): Номер упаковки.
- `weight` (Integer, обязательный): Вес упаковки.
- `length` (Integer, обязательный): Длина упаковки.
- `width` (Integer, обязательный): Ширина упаковки.
- `height` (Integer, обязательный): Высота упаковки.
- `comment` (String): Комментарий к упаковке.
- `items` (Array, обязательный): Список товаров в упаковке.

### Item

Представляет данные о товаре.

Атрибуты:

- `name` (String, обязательный): Наименование товара.
- `ware_key` (String, обязательный): Код товара.
- `payment` (Integer, обязательный): Сумма оплаты за товар.
- `cost` (Integer, обязательный): Стоимость товара.
- `weight` (Integer, обязательный): Вес товара.
- `amount` (Integer, обязательный): Количество товара.

### Barcode

Представляет данные создания штрих-кода для печати.

Атрибуты:

- `orders` (Array, обязательный): Список заказов для генерации штрих-кода.
- `copy_count` (Integer): Количество копий (по умолчанию: 1).
- `format` (String): Формат печати (A4, A5, A6, A7).
- `lang` (String): Код языка (RUS, ENG, DEU, ITA, TUR, CES, KOR, LIT, LAT).

### Invoice

Представляет данные создания счета-фактуры для печати.

Атрибуты:

- `orders` (Array, обязательный): Список заказов для генерации счета-фактуры.
- `copy_count` (Integer): Количество копий (по умолчанию: 2).
- `type` (String): Тип счета-фактуры (tpl_russia, tpl_china, tpl_armenia, tpl_english, tpl_italian, tpl_korean, tpl_latvian, tpl_lithuanian, tpl_german, tpl_turkish, tpl_czech, tpl_thailand, tpl_invoice).

### Agreement

Представляет данные договоренности о доставке.

Атрибуты:

- `cdek_number` (String, обязательный): Номер заказа СДЭК.
- `order_uuid` (String): UUID заказа.
- `date` (String, обязательный): Дата доставки.
- `time_from` (String, обязательный): Время начала.
- `time_to` (String, обязательный): Время окончания.
- `comment` (String): Комментарий.
- `delivery_point` (String): Код пункта доставки.
- `to_location` (Hash): Детали места доставки.

### Intakes

Представляет данные запроса на забор груза курьером.

Атрибуты:

- `cdek_number` (String): Номер заказа СДЭК.
- `order_uuid` (String): UUID заказа.
- `intake_date` (String, обязательный): Дата забора.
- `intake_time_from` (String, обязательный): Время начала.
- `intake_time_to` (String, обязательный): Время окончания.
- `lunch_time_from` (String): Время начала обеда.
- `lunch_time_to` (String): Время окончания обеда.
- `name` (String, обязательный): Описание груза.
- `need_call` (Boolean): Необходим ли звонок.
- `comment` (String): Комментарий для курьера.
- `courier_power_of_attorney` (Boolean): Курьеру нужна доверенность.
- `courier_identity_card` (Boolean): Курьеру нужно удостоверение личности.
- `sender` (Hash, обязательный): Контактная информация отправителя.
- `from_location` (Hash, обязательный): Детали места забора.
- `weight` (Integer): Вес груза в граммах.
- `length` (Integer): Длина груза в см.
- `width` (Integer): Ширина груза в см.
- `height` (Integer): Высота груза в см.

### Check

Представляет данные запроса чеков.

Атрибуты:

- `order_uuid` (String): UUID заказа.
- `cdek_number` (String): Номер заказа СДЭК.
- `date` (String): Дата для получения чеков.

## Управление схемами

Gem включает систему управления схемами для поддержания актуальности определений API. Скрипт `pull_cdek_schemas.rb` получает последние схемы OpenAPI из документации CDEK и организует их.

### Получение последних схем

```ruby
# Запуск скрипта получения схем
ruby pull_cdek_schemas.rb

# Это выполнит:
# 1. Получение документации API от CDEK
# 2. Разбор и организация схем
# 3. Сохранение в cdek_api_schemas.json
# 4. Отображение анализа доступных эндпоинтов
```

### Анализ схем

Скрипт анализирует и организует:
- **5 основных схем API** из документации CDEK
- **40 уникальных эндпоинтов** во всех схемах
- Полное сопоставление эндпоинтов с HTTP методами
- Метаданные для каждой версии схемы

### Автоматические обновления

Запускайте скрипт получения схем периодически для поддержания актуальности с последними изменениями API CDEK:

```bash
# Добавить в cron или CI/CD pipeline
0 2 * * * cd /path/to/gem && ruby pull_cdek_schemas.rb
```

## TODO List

- [x] Реструктурировать код для лучшей организации.
- [x] Добавить сопоставления внутренних кодов CDEK.
- [x] Добавить больше точек API и сущностей данных (Управление заказами, Печать/Документы, Курьерские услуги, Платежные услуги).
- [x] Реализовать систему управления схемами.
- [x] Добавить всестороннюю документацию на английском, русском и татарском языках.
- [ ] Проверить все атрибуты на обязательные и необязательные поля.
- [x] Добавить документацию для всех классов и методов.
- [ ] Уточнить валидации сущностей.
- [ ] Добавить интеграционные тесты с VCR.
- [ ] Добавить более всестороннюю обработку ошибок.
- [ ] Добавить поддержку ограничения скорости запросов.

## Изменения

(Смотрите [CHANGELOG](CHANGELOG.md))

## Содействие

Этот gem используется в реальных проектах и на данный момент находится в стадии активной разработки. Если у вас есть идеи, предложения или проблемы, пожалуйста, создайте issue или pull request.

## Лицензия

Этот gem доступен как открытый исходный код под условиями MIT License.
