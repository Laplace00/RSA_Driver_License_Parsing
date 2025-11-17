# RSA Driver License Parsing

A Flutter library for decrypting and parsing South African driver's license data from PDF417 barcodes.

[![pub package](https://img.shields.io/pub/v/rsa_driver_license_parsing.svg)](https://pub.dev/packages/rsa_driver_license_parsing)

## Features

- Decrypt South African driver's license data from PDF417 barcodes
- Parse all license information into a structured format
- Support for both version 1 and version 2 license formats
- Comprehensive error handling with custom exceptions
- Full type safety with null-safety support
- JSON serialization/deserialization
- Well-documented API with examples

## What You'll Need

This package decrypts and parses the encrypted data from South African driver's licenses. You'll need:

1. **A barcode scanning library** to capture the PDF417 barcode (e.g., `mobile_scanner`, `barcode_scan2`)
2. **This package** to decrypt and parse the scanned data

## Usage

### Basic Example

```dart
import 'package:rsa_driver_license_parsing/sadl_parsing.dart';
import 'dart:typed_data';

// Get raw data from barcode scanner
final Uint8List rawData = // ... from your barcode scanner

try {
  // Parse the license (handles decryption and parsing)
  final license = SadlParser.parseLicense(rawData);
  
  // Access the data
  print('Name: ${license.fullName}');
  print('License Number: ${license.licenseNumber}');
  print('ID Number: ${license.idNumber}');
  print('Vehicle Codes: ${license.vehicleCodes.join(", ")}');
  print('Expiry Date: ${license.licenseExpiryDate}');
  print('Is Expired: ${license.isExpired}');
} catch (e) {
  print('Failed to parse license: $e');
}
```

### Error Handling

The library provides specific exception types for different error scenarios:

```dart
try {
  final license = SadlParser.parseLicense(rawData);
  // Use license data...
} on InvalidInputDataException catch (e) {
  print('Invalid data: $e');
} on UnsupportedLicenseVersionException catch (e) {
  print('Unsupported license version: $e');
} on SadlDecryptionException catch (e) {
  print('Decryption failed: $e');
} on SadlParsingException catch (e) {
  print('Parsing failed: $e');
} catch (e) {
  print('Unexpected error: $e');
}
```

### Two-Step Process (Decrypt + Parse)

If you need to decrypt and parse separately:

```dart
// Step 1: Decrypt
final decryptedData = SadlParser.decrypt(rawData);

// Step 2: Parse
final parser = SadlParser._();
final license = parser.parse(decryptedData);
```

### Working with License Data

The `DrivingLicense` class provides easy access to all license information:

```dart
final license = SadlParser.parseLicense(rawData);

// Personal information
print('Full Name: ${license.fullName}');
print('Surname: ${license.surname}');
print('Initials: ${license.initials}');
print('Gender: ${license.gender}');
print('Date of Birth: ${license.birthdate}');

// License information
print('License Number: ${license.licenseNumber}');
print('Issue Date: ${license.licenseIssueDate}');
print('Expiry Date: ${license.licenseExpiryDate}');
print('Vehicle Codes: ${license.vehicleCodes}');

// Check expiry
if (license.isExpired) {
  print('License has expired!');
}

// Professional permit
if (license.hasPrdpPermit) {
  print('PrDP Code: ${license.prdpCode}');
  print('PrDP Expiry: ${license.prdpPermitExpiryDate}');
}
```

### JSON Serialization

```dart
// Convert to JSON
final json = license.toJson();
print(json);

// Convert from JSON
final recreatedLicense = DrivingLicense.fromJson(json);
```

### Integration with Barcode Scanner

Here's a complete example using `mobile_scanner`:

```dart
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rsa_driver_license_parsing/sadl_parsing.dart';
import 'package:flutter/material.dart';

class LicenseScannerPage extends StatefulWidget {
  @override
  State<LicenseScannerPage> createState() => _LicenseScannerPageState();
}

class _LicenseScannerPageState extends State<LicenseScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.pdf417],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan License')),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          if (barcode.rawBytes != null) {
            _parseLicense(barcode.rawBytes!);
          }
        },
      ),
    );
  }

  void _parseLicense(Uint8List rawData) async {
    try {
      final license = SadlParser.parseLicense(rawData);
      
      // Stop scanning and show results
      await controller.stop();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('License Scanned'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${license.fullName}'),
                Text('License: ${license.licenseNumber}'),
                Text('Codes: ${license.vehicleCodes.join(", ")}'),
                Text('Expires: ${license.licenseExpiryDate}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error parsing license: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to parse license: $e')),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

## API Reference

### Main Classes

#### `SadlParser`
Main class for parsing licenses.
- `static DrivingLicense parseLicense(Uint8List rawData)` - Parse license in one step
- `static Uint8List decrypt(Uint8List rawData)` - Decrypt data only

#### `DrivingLicense`
Model class containing all license information.

**Properties:**
- `fullName` - Combined surname and initials
- `surname` - License holder's surname
- `initials` - License holder's initials
- `idNumber` - South African ID number
- `licenseNumber` - Unique license number
- `vehicleCodes` - List of authorized vehicle codes
- `birthdate` - Date of birth (YYYY/MM/DD)
- `gender` - 'male' or 'female'
- `licenseIssueDate` - When license was issued
- `licenseExpiryDate` - When license expires
- `isExpired` - Boolean check if license is expired
- `hasPrdpPermit` - Whether holder has professional permit

**Methods:**
- `toJson()` - Convert to JSON map
- `DrivingLicense.fromJson(Map)` - Create from JSON map

### Exceptions

All exceptions extend from `SadlException`:

- `InvalidInputDataException` - Input data is invalid or too short
- `UnsupportedLicenseVersionException` - License version is not supported
- `SadlDecryptionException` - Decryption failed
- `SadlParsingException` - Parsing failed

## Supported License Versions

- Version 1 (v1) licenses
- Version 2 (v2) licenses

The library automatically detects the version from the data header.

## Known Limitations

- **Image extraction not implemented**: While the library extracts image dimensions, the actual photo data extraction is not yet implemented.
- **Date format**: Dates are returned as strings in 'YYYY/MM/DD' format, not as DateTime objects.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

```bash
# Clone the repository
git clone https://github.com/Laplace00/RSA_Driver_License_Parsing.git

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run example
cd example
flutter run
```

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Original implementation by [Jusha Dann](https://github.com/JushaDann) - [sadl_parsing](https://github.com/JushaDann/sadl_parsing)
- Based on the South African driver's license format specification
- RSA cryptography implemented using the `pointycastle` package

## Support

For issues, questions, or contributions, please visit:
- [GitHub Issues](https://github.com/Laplace00/RSA_Driver_License_Parsing/issues)
- [GitHub Repository](https://github.com/Laplace00/RSA_Driver_License_Parsing)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes in each version.

