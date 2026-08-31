# CDEK API Reference

This document provides a reference of all available API endpoints supported by this client, automatically generated from the official OpenAPI schemas.


## auth


### Get o auth token

**HTTP Method:** `POST`  
**Path:** `/v2/oauth/token`  

**Operation ID:** `getOAuthToken`




**Success Response:** `AuthResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `access_token` | `string` |  |
| `token_type` | `string` |  |
| `expires_in` | `integer` |  |
| `scope` | `string` |  |
| `jti` | `string` |  |






---


## calculator


### Available tariffs

**HTTP Method:** `GET`  
**Path:** `/v2/calculator/alltariffs`  

**Operation ID:** `availableTariffs`




**Success Response:** `CalculatorAvailableTariffsResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `tariff_codes` | `array[]` |  |






---

### Tariff

**HTTP Method:** `POST`  
**Path:** `/v2/calculator/tariff`  

**Operation ID:** `tariff`


**Request Body:** `CalculatorRequestDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `date` | `string` |  |
| `type` | `integer` |  |
| `currency` | `integer` |  |
| `lang` | `string` |  |
| `tariff_code` | `integer` |  |
| `from_location` | `object` |  |
| `to_location` | `object` |  |
| `services` | `array[]` |  |
| `packages` | `array[]` |  |
| `additional_order_types` | `array[]` |  |
| `shipment_point` | `string` |  |
| `delivery_point` | `string` |  |





**Success Response:** `CalculatorResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `delivery_sum` | `number` |  |
| `period_min` | `integer` |  |
| `period_max` | `integer` |  |
| `calendar_min` | `integer` |  |
| `calendar_max` | `integer` |  |
| `weight_calc` | `integer` |  |
| `services` | `array[]` |  |
| `total_sum` | `number` |  |
| `currency` | `string` |  |
| `errors` | `array[]` |  |
| `warnings` | `array[]` |  |
| `delivery_date_range` | `object` |  |






---

### Tariff with services

**HTTP Method:** `POST`  
**Path:** `/v2/calculator/tariffAndService`  

**Operation ID:** `tariffWithServices`


**Request Body:** `CalculatorTariffWithServicesRequestDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `date` | `string` |  |
| `type` | `integer` |  |
| `currency` | `integer` |  |
| `lang` | `string` |  |
| `from_location` | `object` |  |
| `to_location` | `object` |  |
| `services` | `array[]` |  |
| `packages` | `array[]` |  |
| `additional_order_types` | `array[]` |  |
| `shipment_point` | `string` |  |
| `delivery_point` | `string` |  |





**Success Response:** `CalculatorTariffWithServicesListResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `tariff_codes` | `array[]` |  |
| `errors` | `array[]` |  |
| `warnings` | `array[]` |  |






---

### Tariff list

**HTTP Method:** `POST`  
**Path:** `/v2/calculator/tarifflist`  

**Operation ID:** `tariffList`


**Request Body:** `CalculatorTariffListRequestDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `date` | `string` |  |
| `type` | `integer` |  |
| `additional_order_types` | `array[]` |  |
| `currency` | `integer` |  |
| `lang` | `string` |  |
| `shipment_point` | `string` |  |
| `delivery_point` | `string` |  |
| `from_location` | `object` |  |
| `to_location` | `object` |  |
| `packages` | `array[]` |  |





**Success Response:** `CalculatorTariffListResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `tariff_codes` | `array[]` |  |
| `errors` | `array[]` |  |
| `warnings` | `array[]` |  |






---


## delivery_point


### Search

**HTTP Method:** `GET`  
**Path:** `/v2/deliverypoints`  

**Operation ID:** `search`




**Success Response:** `OfficeDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `code` | `string` |  |
| `uuid` | `string` |  |
| `address_comment` | `string` |  |
| `nearest_station` | `string` |  |
| `nearest_metro_station` | `string` |  |
| `work_time` | `string` |  |
| `phones` | `array[]` |  |
| `email` | `string` |  |
| `note` | `string` |  |
| `type` | `string` |  |
| `owner_code` | `string` |  |
| `take_only` | `boolean` |  |
| `is_handout` | `boolean` |  |
| `is_reception` | `boolean` |  |
| `is_dressing_room` | `boolean` |  |
| `is_marketplace` | `boolean` |  |
| `is_ltl` | `boolean` |  |
| `have_cashless` | `boolean` |  |
| `have_cash` | `boolean` |  |
| `have_fast_payment_system` | `boolean` |  |
| `allowed_cod` | `boolean` |  |
| `site` | `string` |  |
| `office_image_list` | `array[]` |  |
| `work_time_list` | `array[]` |  |
| `work_time_exception_list` | `array[]` |  |
| `weight_min` | `number` |  |
| `weight_max` | `number` |  |
| `dimensions` | `array[]` |  |
| `status` | `string` |  |
| `errors` | `array[]` |  |
| `warnings` | `array[]` |  |
| `location` | `object` |  |
| `distance` | `integer` |  |
| `ltl_acceptance_partners` | `boolean` |  |
| `ltl_issuance_partners` | `boolean` |  |
| `fulfillment` | `boolean` |  |
| `length_max` | `integer` |  |
| `width_max` | `integer` |  |
| `height_max` | `integer` |  |






---


## intake


### Create

**HTTP Method:** `POST`  
**Path:** `/v2/intakes`  

**Operation ID:** `create`


**Request Body:** `IntakeDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `cdek_number` | `string` |  |
| `order_uuid` | `string` |  |
| `intake_date` | `string` |  |
| `intake_time_from` | `string` |  |
| `intake_time_to` | `string` |  |
| `lunch_time_from` | `string` |  |
| `lunch_time_to` | `string` |  |
| `name` | `string` |  |
| `weight` | `integer` |  |
| `length` | `integer` |  |
| `width` | `integer` |  |
| `height` | `integer` |  |
| `comment` | `string` |  |
| `courier_power_of_attorney` | `boolean` |  |
| `courier_identity_card` | `boolean` |  |
| `sender` | `object` |  |
| `from_location` | `object` |  |
| `need_call` | `boolean` |  |





**Success Response:** `ResponseDtoRootEntityDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---

### Change status

**HTTP Method:** `PATCH`  
**Path:** `/v2/intakes`  

**Operation ID:** `changeStatus`


**Request Body:** `IntakeChangeStatusDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `uuid` | `string` |  |
| `status` | `object` |  |





**Success Response:** `IntakeChangeStatusResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---

### Get available days

**HTTP Method:** `POST`  
**Path:** `/v2/intakes/availableDays`  

**Operation ID:** `getAvailableDays`


**Request Body:** `IntakeAvailableDaysRequestDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `from_location` | `object` |  |
| `date` | `string` |  |





**Success Response:** `IntakeAvailableDaysResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `date` | `array[]` |  |
| `all_days` | `boolean` |  |
| `errors` | `array[]` |  |
| `warnings` | `array[]` |  |






---

### Get by uuid

**HTTP Method:** `GET`  
**Path:** `/v2/intakes/{uuid}`  

**Operation ID:** `getByUuid`




**Success Response:** `IntakeInfoDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |






---

### Delete by uuid

**HTTP Method:** `DELETE`  
**Path:** `/v2/intakes/{uuid}`  

**Operation ID:** `deleteByUuid`




**Success Response:** `ResponseDtoRootEntityDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---


## location


### Cities

**HTTP Method:** `GET`  
**Path:** `/v2/location/cities`  

**Operation ID:** `cities`




**Success Response:** `V2LocationCityDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `code` | `integer` |  |
| `city_uuid` | `string` |  |
| `city` | `string` |  |
| `fias_guid` | `string` |  |
| `country_code` | `string` |  |
| `country` | `string` |  |
| `region` | `string` |  |
| `region_code` | `integer` |  |
| `fias_region_guid` | `string` |  |
| `sub_region` | `string` |  |
| `longitude` | `number` |  |
| `latitude` | `number` |  |
| `time_zone` | `string` |  |
| `payment_limit` | `number` |  |






---

### Get city by coordinates

**HTTP Method:** `GET`  
**Path:** `/v2/location/coordinates`  

**Operation ID:** `getCityByCoordinates`




**Success Response:** `V2LocationCityByCoordinatesDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `code` | `integer` |  |
| `city_uuid` | `string` |  |
| `city` | `string` |  |
| `fias_guid` | `string` |  |






---

### Postalcodes

**HTTP Method:** `GET`  
**Path:** `/v2/location/postalcodes`  

**Operation ID:** `postalcodes`




**Success Response:** `PostcodesResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `code` | `integer` |  |
| `postal_codes` | `array[]` |  |






---

### Regions

**HTTP Method:** `GET`  
**Path:** `/v2/location/regions`  

**Operation ID:** `regions`




**Success Response:** `RegionsResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `country_code` | `string` |  |
| `country` | `string` |  |
| `region` | `string` |  |
| `region_code` | `integer` |  |
| `fias_region_guid` | `string` |  |
| `kladr_region_code` | `string` |  |






---

### Suggest cities

**HTTP Method:** `GET`  
**Path:** `/v2/location/suggest/cities`  

**Operation ID:** `suggestCities`




**Success Response:** `SuggestCityResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `city_uuid` | `string` |  |
| `code` | `integer` |  |
| `full_name` | `string` |  |
| `country_code` | `string` |  |






---


## order


### Get

**HTTP Method:** `GET`  
**Path:** `/v2/orders`  

**Operation ID:** `get`




**Success Response:** `ResponseDtoOrderResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---

### Register_1

**HTTP Method:** `POST`  
**Path:** `/v2/orders`  

**Operation ID:** `register_1`


**Request Body:** `OrderCreateRequestDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `type` | `integer` |  |
| `additional_order_types` | `array[]` |  |
| `number` | `string` |  |
| `accompanying_number` | `string` |  |
| `tariff_code` | `integer` |  |
| `comment` | `string` |  |
| `shipment_point` | `string` |  |
| `delivery_point` | `string` |  |
| `date_invoice` | `string` |  |
| `shipper_name` | `string` |  |
| `shipper_address` | `string` |  |
| `delivery_recipient_cost` | `object` |  |
| `delivery_recipient_cost_adv` | `array[]` |  |
| `sender` | `object` |  |
| `seller` | `object` |  |
| `recipient` | `object` |  |
| `from_location` | `object` |  |
| `to_location` | `object` |  |
| `services` | `array[]` |  |
| `packages` | `array[]` |  |
| `delivery_types` | `array[]` |  |
| `print` | `string` |  |
| `widgetToken` | `string` |  |
| `is_client_return` | `boolean` |  |
| `has_reverse_order` | `boolean` |  |
| `developer_key` | `string` |  |





**Success Response:** `ResponseDtoRootEntityDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---

### Update

**HTTP Method:** `PATCH`  
**Path:** `/v2/orders`  

**Operation ID:** `update`


**Request Body:** `OrderUpdateRequestDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `uuid` | `string` |  |
| `type` | `integer` |  |
| `cdek_number` | `string` |  |
| `number` | `string` |  |
| `accompanying_number` | `string` |  |
| `tariff_code` | `integer` |  |
| `comment` | `string` |  |
| `shipment_point` | `string` |  |
| `delivery_point` | `string` |  |
| `delivery_recipient_cost` | `object` |  |
| `delivery_recipient_cost_adv` | `array[]` |  |
| `sender` | `object` |  |
| `seller` | `object` |  |
| `recipient` | `object` |  |
| `from_location` | `object` |  |
| `to_location` | `object` |  |
| `services` | `array[]` |  |
| `packages` | `array[]` |  |
| `has_reverse_order` | `boolean` |  |
| `delivery_types` | `array[]` |  |





**Success Response:** `ResponseDtoRootEntityDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---

### Get intakes

**HTTP Method:** `GET`  
**Path:** `/v2/orders/{orderUuid}/intakes`  

**Operation ID:** `getIntakes`







---

### Get_2

**HTTP Method:** `GET`  
**Path:** `/v2/orders/{uuid}`  

**Operation ID:** `get_2`




**Success Response:** `ResponseDtoOrderResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---

### Delete

**HTTP Method:** `DELETE`  
**Path:** `/v2/orders/{uuid}`  

**Operation ID:** `delete`




**Success Response:** `ResponseDtoRootEntityDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---

### Client return

**HTTP Method:** `POST`  
**Path:** `/v2/orders/{uuid}/clientReturn`  

**Operation ID:** `clientReturn`


**Request Body:** `CreateClientReturnRequestDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `tariff_code` | `integer` |  |





**Success Response:** `ResponseDtoRootEntityDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---

### Refuse

**HTTP Method:** `POST`  
**Path:** `/v2/orders/{uuid}/refusal`  

**Operation ID:** `refuse`




**Success Response:** `ResponseDtoRootEntityDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---


## passport


### Get_5

**HTTP Method:** `GET`  
**Path:** `/v2/passport`  

**Operation ID:** `get_5`




**Success Response:** `PassportResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `orders` | `array[]` |  |
| `errors` | `array[]` |  |
| `warnings` | `array[]` |  |






---


## photo


### Get ready orders

**HTTP Method:** `POST`  
**Path:** `/v2/photoDocument`  

**Operation ID:** `getReadyOrders`


**Request Body:** `PhotoRequestDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `period_begin` | `string` |  |
| `period_end` | `string` |  |
| `orders` | `array[]` |  |





**Success Response:** `PhotoResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `errors` | `array[]` |  |
| `warnings` | `array[]` |  |
| `orders` | `array[]` |  |






---

### Get photo document

**HTTP Method:** `GET`  
**Path:** `/v2/photoDocument/{uuid}`  

**Operation ID:** `getPhotoDocument`







---


## prealert


### Register

**HTTP Method:** `POST`  
**Path:** `/v2/prealert`  

**Operation ID:** `register`


**Request Body:** `RegisterPrealertRequestDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `planned_date` | `string` |  |
| `shipment_point` | `string` |  |
| `orders` | `array[]` |  |





**Success Response:** `RegisterPrealertResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---

### Get_1

**HTTP Method:** `GET`  
**Path:** `/v2/prealert/{uuid}`  

**Operation ID:** `get_1`




**Success Response:** `GetPrealertResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---


## print


### Barcode print

**HTTP Method:** `POST`  
**Path:** `/v2/print/barcodes`  

**Operation ID:** `barcodePrint`


**Request Body:** `BarcodeRequestDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `orders` | `array[]` |  |
| `copy_count` | `integer` |  |
| `format` | `string` |  |
| `lang` | `string` |  |





**Success Response:** `BarcodePrintResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---

### Barcode get

**HTTP Method:** `GET`  
**Path:** `/v2/print/barcodes/{uuid}`  

**Operation ID:** `barcodeGet`




**Success Response:** `BarcodeGetResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---

### Barcode download

**HTTP Method:** `GET`  
**Path:** `/v2/print/barcodes/{uuid}.pdf`  

**Operation ID:** `barcodeDownload`







---

### Waybill print

**HTTP Method:** `POST`  
**Path:** `/v2/print/orders`  

**Operation ID:** `waybillPrint`


**Request Body:** `WaybillRequestDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `orders` | `array[]` |  |
| `copy_count` | `integer` |  |
| `type` | `string` |  |





**Success Response:** `WaybillPrintResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---

### Waybill get

**HTTP Method:** `GET`  
**Path:** `/v2/print/orders/{uuid}`  

**Operation ID:** `waybillGet`




**Success Response:** `WaybillGetResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---

### Waybill download

**HTTP Method:** `GET`  
**Path:** `/v2/print/orders/{uuid}.pdf`  

**Operation ID:** `waybillDownload`







---


## receipt


### Get_6

**HTTP Method:** `GET`  
**Path:** `/v2/check`  

**Operation ID:** `get_6`




**Success Response:** `CheckResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `errors` | `array[]` |  |
| `warnings` | `array[]` |  |
| `check_info` | `array[]` |  |






---


## registries


### Get_4

**HTTP Method:** `GET`  
**Path:** `/v2/registries`  

**Operation ID:** `get_4`




**Success Response:** `RegistriesResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `registries` | `array[]` |  |
| `errors` | `array[]` |  |
| `warnings` | `array[]` |  |






---


## restriction_hints


### Check packages restrictions

**HTTP Method:** `POST`  
**Path:** `/v2/international/package/restrictions`  

**Operation ID:** `checkPackagesRestrictions`


**Request Body:** `RestrictionHintsRequestDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `tariff_code` | `integer` |  |
| `from_location` | `object` |  |
| `to_location` | `object` |  |
| `packages` | `array[]` |  |








---


## reverse


### Check availability

**HTTP Method:** `POST`  
**Path:** `/v2/reverse/availability`  

**Operation ID:** `checkAvailability`


**Request Body:** `ReverseValidateRequestDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `from_location` | `object` |  |
| `shipment_point` | `string` |  |
| `to_location` | `object` |  |
| `delivery_point` | `string` |  |
| `tariff_code` | `integer` |  |
| `sender` | `object` |  |
| `recipient` | `object` |  |








---


## schedule


### Register_2

**HTTP Method:** `POST`  
**Path:** `/v2/delivery`  

**Operation ID:** `register_2`


**Request Body:** `ScheduleDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `cdek_number` | `string` |  |
| `order_uuid` | `string` |  |
| `date` | `string` |  |
| `time_from` | `string` |  |
| `time_to` | `string` |  |
| `comment` | `string` |  |
| `delivery_point` | `string` |  |
| `to_location` | `object` |  |





**Success Response:** `ResponseDtoRootEntityDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---

### Get estimated intervals

**HTTP Method:** `POST`  
**Path:** `/v2/delivery/estimatedIntervals`  

**Operation ID:** `getEstimatedIntervals`


**Request Body:** `EstimatedDeliveryIntervalsRequestDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `date_time` | `string` |  |
| `from_location` | `object` |  |
| `shipment_point` | `string` |  |
| `to_location` | `object` |  |
| `tariff_code` | `integer` |  |
| `additional_order_types` | `array[]` |  |





**Success Response:** `EstimatedDeliveryIntervalsResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `date_intervals` | `array[]` |  |






---

### Get intervals

**HTTP Method:** `GET`  
**Path:** `/v2/delivery/intervals`  

**Operation ID:** `getIntervals`




**Success Response:** `AvailableDeliveryIntervalsResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `date_intervals` | `array[]` |  |






---

### Get_3

**HTTP Method:** `GET`  
**Path:** `/v2/delivery/{uuid}`  

**Operation ID:** `get_3`




**Success Response:** `ResponseDtoScheduleInfoDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |
| `related_entities` | `array[]` |  |






---


## webhook


### Get all

**HTTP Method:** `GET`  
**Path:** `/v2/webhooks`  

**Operation ID:** `getAll`







---

### Create webhook

**HTTP Method:** `POST`  
**Path:** `/v2/webhooks`  

**Operation ID:** `createWebhook`


**Request Body:** `WebhookDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `uuid` | `string` |  |
| `type` | `string` |  |
| `url` | `string` |  |





**Success Response:** `ResponseDtoWebhookResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |






---

### Get by id

**HTTP Method:** `GET`  
**Path:** `/v2/webhooks/{uuid}`  

**Operation ID:** `getById`




**Success Response:** `ResponseDtoWebhookDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |






---

### Delete by id

**HTTP Method:** `DELETE`  
**Path:** `/v2/webhooks/{uuid}`  

**Operation ID:** `deleteById`




**Success Response:** `ResponseDtoWebhookResponseDto`

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `entity` | `object` |  |
| `requests` | `array[]` |  |






---


