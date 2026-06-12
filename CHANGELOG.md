# Changelog

All notable changes to this project will be documented in this file.

> [!NOTE]  
> The format is based on [Keep a Changelog],
> and this project adheres to [Semantic Versioning].

## [Unreleased]

/

## [0.5.1] - 2026-06-12

### Changed
- Fixed API Reference generator to deeply parse DTO references and output full attribute properties mapping

## [0.5.0] - 2026-06-12

### Added
- Added `RspecGenerator` to automatically generate spec files for all API endpoints based on the OpenAPI schema
- Added `AutoMocker` module for zero-configuration, dynamic WebMock stubbing using generated fixtures
- Added `.github/workflows/e2e_live_tests.yml` for nightly API drift validation using real CDEK credentials
- Added `SchemaValidator` to rigorously enforce dry-validation contracts on E2E testing

### Changed
- Refactored schema generator with strict type validation (`dry-types`)
- Removed conversational language and actualized documentation (`README.md`, `README_RUS.md`, `README_TAT.md`)

## [0.4.0] - 2026-06-12

### Added
- Added `CDEKApiClient::Client#execute_with_retry` to natively support 5xx and 429 rate-limit backoff mechanisms
- Fleshed out pending `Location` tests

### Changed
- Optimized OpenAPI schema puller, updated API schemas, and added `rake schema:generate_all` task

## [0.3.0] - 2026-01-18

### Added
- Added Courier API for managing delivery agreements, courier intakes, and delivery intervals
- Added Payment API for payment-related operations
- Added Print API for document printing functionality
- Added new entities: `Agreement`, `AuthResponse`, `AuthErrorResponse`, `Barcode`, `Check`, `IntakeAvailableDaysRequest`, `IntakeAvailableDaysResponse`, `Intakes`, `Invoice`

### Changed
- Updated gemspec metadata to follow 2026 RubyGems standards:
  - Fixed all URIs to use HTTPS instead of HTTP
  - Added `bug_tracker_uri` metadata field
  - Added `documentation_uri` metadata field
  - Updated `changelog_uri` to point directly to CHANGELOG.md file
- Updated GitHub repository description and added relevant topics for better discoverability
- Fixed GitHub Actions workflow syntax issue in Ruby setup step

## [0.2.1] - 2024-07-22

### Added
- Added new commands to the `Makefile` for tagging a new version and pushing it to GitHub.

### Changed
- Updated links to Changelog and the Gem homepage in the gemspec.

### Fixed
- Fixed issues with previous release details and documentation.

## [0.2.0] - 2024-07-22

### Added
- Improved error handling and response parsing in the `Client` class.
- Updated `README.md` with detailed usage examples, including fetching and saving location data with optional live data fetching.

### Changed
- Refactored code structure for better organization.
- Updated specs for `Client` and `API` classes.

## [0.1.0] - 2024-07-22
- Initial release

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html

<!-- Versions -->

[unreleased]: https://github.com/SamyRai/cdek_api_client/compare/v0.5.1...HEAD
[0.5.1]: https://github.com/SamyRai/cdek_api_client/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/SamyRai/cdek_api_client/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/SamyRai/cdek_api_client/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/SamyRai/cdek_api_client/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/SamyRai/cdek_api_client/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/SamyRai/cdek_api_client/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/SamyRai/cdek_api_client/releases/tag/v0.1.0
