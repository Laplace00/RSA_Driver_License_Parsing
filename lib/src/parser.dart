/// Parser for decrypted South African driver's license data.
library;

import 'dart:typed_data';

import 'constants.dart';
import 'exceptions/sadl_exceptions.dart';
import 'models/driving_license.dart';
import 'utils/binary_utils.dart';

/// Parses decrypted South African driver's license data into a structured format.
///
/// After the license data has been decrypted, it must be parsed to extract
/// the individual fields. The data is organized in three sections:
/// 1. String data (names, codes, numbers)
/// 2. Binary encoded data (dates, restrictions)
/// 3. Image data (photo dimensions and pixels)
class SadlParser {
  /// Parses decrypted license data into a [DrivingLicense] object.
  ///
  /// The decrypted data follows a specific binary format with three main sections.
  ///
  /// Example:
  /// ```dart
  /// final parser = SadlParser();
  /// final decryptedData = Uint8List.fromList([...]); // Decrypted bytes
  /// final license = parser.parse(decryptedData);
  /// print(license.surname);
  /// ```
  ///
  /// Throws [SadlParsingException] if the data format is invalid or parsing fails.
  DrivingLicense parse(Uint8List data) {
    try {
      // Find the start of string data section
      final stringDataStart = _findStringDataMarker(data);

      // Section 1: Parse string fields
      final stringData = _parseStringSection(data, stringDataStart);

      // Section 2: Parse binary encoded data (dates, codes)
      final binaryData =
          _parseBinarySection(data, stringData['nextIndex'] as int);

      // Section 3: Parse image metadata
      // final imageData = _parseImageSection(data, binaryData['nextIndex'] as int);

      // Construct and return the DrivingLicense object
      return DrivingLicense(
        vehicleCodes: stringData['vehicleCodes'] as List<String>,
        surname: stringData['surname'] as String,
        initials: stringData['initials'] as String,
        prdpCode: stringData['prdpCode'] as String?,
        idCountryOfIssue: stringData['idCountryOfIssue'] as String,
        licenseCountryOfIssue: stringData['licenseCountryOfIssue'] as String,
        vehicleRestrictions: stringData['vehicleRestrictions'] as List<String>,
        licenseNumber: stringData['licenseNumber'] as String,
        idNumber: stringData['idNumber'] as String,
        idNumberType: binaryData['idNumberType'] as String,
        licenseCodeIssueDates:
            binaryData['licenseCodeIssueDates'] as List<String>,
        driverRestrictionCodes:
            binaryData['driverRestrictionCodes'] as List<String>,
        prdpPermitExpiryDate: binaryData['prdpPermitExpiryDate'] as String?,
        licenseIssueNumber: binaryData['licenseIssueNumber'] as String,
        birthdate: binaryData['birthdate'] as String,
        licenseIssueDate: binaryData['licenseIssueDate'] as String,
        licenseExpiryDate: binaryData['licenseExpiryDate'] as String,
        gender: binaryData['gender'] as String,
        // imageWidth: imageData['width'] as int,
        // imageHeight: imageData['height'] as int,
        // imageData: imageData['imageData'] as List<int>?,
      );
    } catch (e) {
      if (e is SadlException) {
        rethrow;
      }
      throw SadlParsingException('Failed to parse license data', e);
    }
  }

  /// Finds the marker byte that indicates the start of string data.
  int _findStringDataMarker(Uint8List data) {
    for (var i = 0; i < data.length; i++) {
      if (data[i] == kStringDataMarker) {
        return i + 1; // Return position after the marker
      }
    }
    throw const SadlParsingException(
      'Could not find string data marker (0x82) in decrypted data',
    );
  }

  /// Parses the string data section.
  ///
  /// This section contains text fields like names, license numbers, and codes.
  /// Strings are delimited by special bytes (0xe0, 0xe1).
  Map<String, dynamic> _parseStringSection(Uint8List data, int startIndex) {
    var index = startIndex;

    // Read vehicle codes (up to 4)
    final vehicleCodesResult = readStrings(
      data,
      index,
      kInitialVehicleCodesCount,
    );
    final vehicleCodes = vehicleCodesResult[0] as List<String>;
    index = vehicleCodesResult[1] as int;

    // Read surname
    final surnameResult = readString(data, index);
    final surname = surnameResult[0] as String;
    index = surnameResult[1] as int;
    final surnameDelimiter = surnameResult[2] as int;

    // Read initials
    final initialsResult = readString(data, index);
    final initials = initialsResult[0] as String;
    index = initialsResult[1] as int;

    // Read PrDP code (optional - depends on delimiter from surname)
    String? prdpCode;
    if (surnameDelimiter != kDelimiterSection) {
      final prdpResult = readString(data, index);
      prdpCode = prdpResult[0] as String;
      if (prdpCode.isEmpty) prdpCode = null;
      index = prdpResult[1] as int;
    }

    // Read ID country of issue
    final idCountryResult = readString(data, index);
    final idCountryOfIssue = idCountryResult[0] as String;
    index = idCountryResult[1] as int;

    // Read license country of issue
    final licenseCountryResult = readString(data, index);
    final licenseCountryOfIssue = licenseCountryResult[0] as String;
    index = licenseCountryResult[1] as int;

    // Read vehicle restrictions (up to 4)
    final restrictionsResult = readStrings(
      data,
      index,
      kInitialVehicleCodesCount,
    );
    final vehicleRestrictions = restrictionsResult[0] as List<String>;
    index = restrictionsResult[1] as int;

    // Read license number
    final licenseNumberResult = readString(data, index);
    final licenseNumber = licenseNumberResult[0] as String;
    index = licenseNumberResult[1] as int;

    // Read ID number (fixed 13 characters)
    final idNumber = _readFixedLengthString(data, index, kIdNumberLength);
    index += kIdNumberLength;

    return {
      'vehicleCodes': vehicleCodes,
      'surname': surname,
      'initials': initials,
      'prdpCode': prdpCode,
      'idCountryOfIssue': idCountryOfIssue,
      'licenseCountryOfIssue': licenseCountryOfIssue,
      'vehicleRestrictions': vehicleRestrictions,
      'licenseNumber': licenseNumber,
      'idNumber': idNumber,
      'nextIndex': index,
    };
  }

  /// Parses the binary encoded data section.
  ///
  /// This section contains dates and codes encoded in a compact binary format
  /// using nibbles (4-bit values).
  Map<String, dynamic> _parseBinarySection(Uint8List data, int startIndex) {
    var index = startIndex;

    // Read ID number type (1 byte)
    final idNumberType = data[index].toString().padLeft(2, '0');
    index++;

    // Extract nibbles until end marker
    final nibbleQueue = extractNibbles(data, index, kBinaryDataEndMarker);

    // Update index to position after end marker
    while (index < data.length && data[index] != kBinaryDataEndMarker) {
      index++;
    }
    if (index < data.length) {
      index++; // Skip the end marker byte
    }

    // Parse dates and codes from nibbles
    final licenseCodeIssueDates = readNibbleDateList(
      nibbleQueue,
      kVehicleCodeIssueDatesCount,
    );

    final driverRestrictionCodes = nibbleQueue.length >= 2
        ? '${nibbleQueue.removeAt(0)}${nibbleQueue.removeAt(0)}'
        : '00';

    final prdpPermitExpiryDate = readNibbleDateString(nibbleQueue);

    final licenseIssueNumber = nibbleQueue.length >= 2
        ? '${nibbleQueue.removeAt(0)}${nibbleQueue.removeAt(0)}'
        : '00';

    final birthdate = readNibbleDateString(nibbleQueue);
    final licenseIssueDate = readNibbleDateString(nibbleQueue);
    final licenseExpiryDate = readNibbleDateString(nibbleQueue);

    final genderCode = nibbleQueue.length >= 2
        ? '${nibbleQueue.removeAt(0)}${nibbleQueue.removeAt(0)}'
        : '01';

    final gender = _parseGender(genderCode);

    return {
      'idNumberType': idNumberType,
      'licenseCodeIssueDates': licenseCodeIssueDates,
      'driverRestrictionCodes': [driverRestrictionCodes],
      'prdpPermitExpiryDate':
          prdpPermitExpiryDate.isEmpty ? null : prdpPermitExpiryDate,
      'licenseIssueNumber': licenseIssueNumber,
      'birthdate': birthdate,
      'licenseIssueDate': licenseIssueDate,
      'licenseExpiryDate': licenseExpiryDate,
      'gender': gender,
      'nextIndex': index,
    };
  }

  /// Parses the image metadata section.
  ///
  /// This section contains the dimensions of the embedded photo.
  /// Note: Full image data extraction is not yet implemented.
  // Map<String, dynamic> _parseImageSection(Uint8List data, int startIndex) {
  //   var index = startIndex;

  //   // Skip 3 bytes
  //   index += 3;

  //   // Read width (1 byte)
  //   final width = index < data.length ? data[index] : 0;
  //   index += 2; // Skip 1 byte after width

  //   // Read height (1 byte)
  //   final height = index < data.length ? data[index] : 0;
  //   index++;

  //   // TODO: Extract actual image data
  //   // The image data follows after the dimensions but requires additional
  //   // parsing logic to properly extract and decode.

  //   return {
  //     'width': width,
  //     'height': height,
  //     'imageData': null, // Not yet implemented
  //     'nextIndex': index,
  //   };
  // }

  /// Reads a fixed-length string from the data.
  String _readFixedLengthString(Uint8List data, int startIndex, int length) {
    final buffer = StringBuffer();
    for (var i = 0; i < length && (startIndex + i) < data.length; i++) {
      buffer.writeCharCode(data[startIndex + i]);
    }
    return buffer.toString();
  }

  /// Converts a gender code to a readable string.
  String _parseGender(String genderCode) {
    switch (genderCode) {
      case kGenderCodeMale:
        return 'male';
      case kGenderCodeFemale:
        return 'female';
      default:
        return genderCode == '01' ? 'male' : 'female';
    }
  }
}
