## 1.0.0

* Initial stable release for pub.dev
* Decrypt and parse South African driver's license data from PDF417 barcodes
* Support for both version 1 and version 2 license formats
* Simple API: `SadlParser.parseLicense()` handles both decryption and parsing
* Comprehensive error handling with custom exception types:
  * `InvalidInputDataException`
  * `UnsupportedLicenseVersionException`
  * `SadlDecryptionException`
  * `SadlParsingException`
* Full null-safety support
* JSON serialization with `toJson()` and `fromJson()`
* Enhanced `DrivingLicense` model with useful getters:
  * `fullName` - Combined surname and initials
  * `isExpired` - Check if license has expired
  * `hasPrdpPermit` - Check for professional driving permit
* Well-documented API with comprehensive examples
* Legacy `SadlTool` class maintained for backward compatibility (deprecated)

## 1.0.1

* fix: Update repository link in acknowledgments section of README

