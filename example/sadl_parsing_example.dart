/// Example usage of the sadl_parsing library.
///
/// This example demonstrates how to use the library to parse
/// South African driver's license data from a PDF417 barcode.
library;

import 'dart:typed_data';
import 'package:rsa_driver_license_parsing/sadl_parsing.dart';

void main() {
  // Example 1: Basic usage with sample data
  basicExample();

  // Example 2: Error handling
  errorHandlingExample();

  // Example 3: Accessing license information
  accessingDataExample();

  // Example 4: Working with JSON
  jsonExample();

  // Example 5: Two-step process (decrypt then parse)
  twoStepExample();
}

/// Basic example: Parse a license in one step
void basicExample() {
  print('=== Basic Example ===');
  
  // In a real application, you would get this data from a barcode scanner
  //  final Uint8List rawData = Uint8List.fromList([]); // For demonstration purposes (this won't actually work without real data)
  // try {
  //   final license = SadlParser.parseLicense(rawData);
  //   print("Full Name: ${license.fullName}");
  //   print('Surname: ${license.surname}');
  //   print('Initials: ${license.initials}');
  //   print('License Number: ${license.licenseNumber}');
  //   print('ID Number: ${license.idNumber}');
  //   print('Vehicle Codes: ${license.vehicleCodes}');
  //   print('Birthdate: ${license.birthdate}');
  //   print('Issue Date: ${license.licenseIssueDate}');
  //   print('Expiry Date: ${license.licenseExpiryDate}');
  //   print('Gender: ${license.gender}');
  //   print('Is Expired: ${license.isExpired}');
  // } catch (e) {
  //   print('Error: $e');
  // }
  
  print('');
}

/// Example with proper error handling
void errorHandlingExample() {
  print('=== Error Handling Example ===');
  
  final invalidData = Uint8List.fromList([1, 2, 3]); // Too short
  
  try {
    final license = SadlParser.parseLicense(invalidData);
    print('License: ${license.fullName}');
  } on InvalidInputDataException catch (e) {
    print('Invalid input: $e');
  } on UnsupportedLicenseVersionException catch (e) {
    print('Unsupported version: $e');
  } on SadlDecryptionException catch (e) {
    print('Decryption failed: $e');
  } on SadlParsingException catch (e) {
    print('Parsing failed: $e');
  } catch (e) {
    print('Unexpected error: $e');
  }
  
  print('');
}

/// Example showing how to access various license fields
void accessingDataExample() {
  print('=== Accessing License Data Example ===');
  
  // This example shows what you can access after successful parsing
  // In reality, you need actual barcode data
  
  print('''
  After parsing, you can access:
  
  Personal Information:
    - license.fullName          // Combined surname and initials
    - license.surname           // Surname only
    - license.initials          // Initials only
    - license.birthdate         // Format: YYYY/MM/DD
    - license.gender            // 'male' or 'female'
    - license.idNumber          // SA ID number
    
  License Information:
    - license.licenseNumber     // Unique license number
    - license.vehicleCodes      // List of codes (e.g., ['A', 'B', 'EB'])
    - license.licenseIssueDate  // When license was issued
    - license.licenseExpiryDate // When license expires
    - license.isExpired         // Boolean check
    
  Restrictions & Codes:
    - license.vehicleRestrictions
    - license.driverRestrictionCodes
    - license.prdpCode          // Professional permit code (if applicable)

  ''');
  
  print('');
}

/// Example showing JSON serialization
void jsonExample() {
  print('=== JSON Serialization Example ===');
  
  // Creating a sample license object
  final license = DrivingLicense(
    vehicleCodes: ['B', 'EB'],
    surname: 'SMITH',
    initials: 'JD',
    prdpCode: null,
    idCountryOfIssue: 'ZA',
    licenseCountryOfIssue: 'ZA',
    vehicleRestrictions: [],
    licenseNumber: 'A12345678',
    idNumber: '8001015009087',
    idNumberType: '01',
    licenseCodeIssueDates: ['2020/01/15', '2020/01/15'],
    driverRestrictionCodes: ['00'],
    prdpPermitExpiryDate: null,
    licenseIssueNumber: '01',
    birthdate: '1980/01/01',
    licenseIssueDate: '2020/01/15',
    licenseExpiryDate: '2025/01/15',
    gender: 'male',
    // imageWidth: 150,
    // imageHeight: 180,
  );
  
  // Convert to JSON
  final json = license.toJson();
  print('License as JSON:');
  print(json);
  
  // Convert back from JSON
  final recreatedLicense = DrivingLicense.fromJson(json);
  print('\nRecreated from JSON:');
  print('Name: ${recreatedLicense.fullName}');
  print('License: ${recreatedLicense.licenseNumber}');
  print('Expired: ${recreatedLicense.isExpired}');
  
  print('');
}

/// Example showing the two-step process (decrypt, then parse)
void twoStepExample() {
  print('=== Two-Step Process Example ===');
  
  print('''
  If you want to decrypt and parse separately:
  
  // Step 1: Decrypt the raw barcode data
  final rawData = getDataFromScanner();
  final decryptedData = SadlParser.decrypt(rawData);
  
  // Now you could save or inspect the decrypted data
  
  // Step 2: Parse the decrypted data
  final parser = SadlParser._();
  final license = parser.parse(decryptedData);
  
  This is useful if you want to:
  - Cache the decrypted data
  - Debug the decryption process
  - Separate concerns in your app architecture
  ''');
  
  print('');
}

/// Example of integrating with a barcode scanner
void barcodeScannerIntegrationExample() {
  print('=== Barcode Scanner Integration Example ===');
  
  print('''
  To integrate with a barcode scanner:
  
  1. Add a barcode scanning package to pubspec.yaml:
     dependencies:
       mobile_scanner: ^latest_version
  
  2. Scan the barcode:
     ```dart
     import 'package:mobile_scanner/mobile_scanner.dart';
     import 'package:sadl_parsing/sadl_parsing.dart';
     
     void scanLicense() async {
       // Set up scanner for PDF417 format
       final controller = MobileScannerController(
         formats: [BarcodeFormat.pdf417],
       );
       
       // When barcode is detected:
       controller.barcodes.listen((capture) {
         final barcode = capture.barcodes.first;
         if (barcode.rawBytes != null) {
           try {
             final license = SadlParser.parseLicense(barcode.rawBytes!);
             print('Scanned: \${license.fullName}');
           } catch (e) {
             print('Failed to parse: \$e');
           }
         }
       });
     }
     ```
  ''');
}
