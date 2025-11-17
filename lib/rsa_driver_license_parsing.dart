/// A library for parsing South African driver's licenses.
///
/// This library provides functionality to decrypt and parse data from
/// South African driver's license PDF417 barcodes. It supports both
/// version 1 and version 2 license formats.
///
/// Example usage:
/// ```dart
/// import 'package:rsa_driver_license_parsing/rsa_driver_license_parsing.dart';
/// import 'dart:typed_data';
///
/// // Get raw data from PDF417 barcode scan
/// final rawData = Uint8List.fromList([...]); // Your scanned data
///
/// // Parse the license (handles both decryption and parsing)
/// try {
///   final license = SadlParser.parseLicense(rawData);
///   print('Name: ${license.fullName}');
///   print('License Number: ${license.licenseNumber}');
///   print('Expiry Date: ${license.licenseExpiryDate}');
///   print('Is Expired: ${license.isExpired}');
/// } catch (e) {
///   print('Failed to parse license: $e');
/// }
/// ```
library rsa_driver_license_parsing;

import 'dart:typed_data';

// Export public API
export 'src/models/driving_license.dart';
export 'src/exceptions/sadl_exceptions.dart';

// Import internal components
import 'src/decryptor.dart';
import 'src/parser.dart' as internal_parser;
import 'src/models/driving_license.dart';

/// Main class for parsing South African driver's licenses.
///
/// This class provides a simple, high-level API for working with
/// South African driver's license data.
class SadlParser {
  /// Parses a South African driver's license from raw barcode data.
  ///
  /// This is a convenience method that handles both decryption and parsing
  /// in a single call. The [rawData] should be the bytes extracted from
  /// a PDF417 barcode scan of a South African driver's license.
  ///
  /// Example:
  /// ```dart
  /// final rawData = Uint8List.fromList([...]); // From barcode scanner
  /// final license = SadlParser.parseLicense(rawData);
  /// print(license.surname);
  /// ```
  ///
  /// Throws [InvalidInputDataException] if the data is invalid.
  /// Throws [UnsupportedLicenseVersionException] if the version is not supported.
  /// Throws [SadlDecryptionException] if decryption fails.
  /// Throws [SadlParsingException] if parsing fails.
  static DrivingLicense parseLicense(Uint8List rawData) {
    // Step 1: Decrypt the data
    final decryptor = SadlDecryptor();
    final decryptedData = decryptor.decrypt(rawData);

    // Step 2: Parse the decrypted data
    final parser = internal_parser.SadlParser();
    return parser.parse(decryptedData);
  }

  /// Decrypts South African driver's license data.
  ///
  /// Use this method if you only need to decrypt the data without parsing it.
  /// The returned [Uint8List] contains the decrypted binary data.
  ///
  /// Example:
  /// ```dart
  /// final rawData = Uint8List.fromList([...]); // From barcode scanner
  /// final decryptedData = SadlParser.decrypt(rawData);
  /// ```
  ///
  /// Throws [InvalidInputDataException] if the data is invalid.
  /// Throws [UnsupportedLicenseVersionException] if the version is not supported.
  /// Throws [SadlDecryptionException] if decryption fails.
  static Uint8List decrypt(Uint8List rawData) {
    final decryptor = SadlDecryptor();
    return decryptor.decrypt(rawData);
  }

  // Private constructor for instance methods
  SadlParser._();

  /// Parses decrypted license data into a [DrivingLicense] object.
  ///
  /// Use this method if you have already decrypted the data and only
  /// need to parse it.
  ///
  /// Example:
  /// ```dart
  /// final decryptedData = SadlParser.decrypt(rawData);
  /// final parser = SadlParser._();
  /// final license = parser.parse(decryptedData);
  /// ```
  ///
  /// Throws [SadlParsingException] if parsing fails.
  DrivingLicense parse(Uint8List decryptedData) {
    final parser = internal_parser.SadlParser();
    return parser.parse(decryptedData);
  }
}

/// Legacy compatibility class.
///
/// This class is kept for backward compatibility with existing code.
/// New code should use [SadlParser] instead.
///
/// @deprecated Use [SadlParser.parseLicense()] instead.
@Deprecated('Use SadlParser.parseLicense() instead')
class SadlTool {
  /// Creates a new SadlTool instance.
  const SadlTool();

  /// Decrypts license data.
  ///
  /// @deprecated Use [SadlParser.decrypt()] instead.
  @Deprecated('Use SadlParser.decrypt() instead')
  Uint8List decryptData(Uint8List data, {String? license}) {
    return SadlParser.decrypt(data);
  }

  /// Parses decrypted license data.
  ///
  /// @deprecated Use [SadlParser] and its parse() method instead.
  @Deprecated('Use SadlParser and its parse() method instead')
  DrivingLicense parseData(Uint8List data) {
    final parser = internal_parser.SadlParser();
    return parser.parse(data);
  }
}
