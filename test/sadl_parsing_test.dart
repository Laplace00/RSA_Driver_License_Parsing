/// Tests for sadl_parsing library.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:rsa_driver_license_parsing/sadl_parsing.dart';
import 'dart:typed_data';

void main() {
  group('SadlParser', () {
    test('parseLicense throws InvalidInputDataException for empty data', () {
      final emptyData = Uint8List(0);
      
      expect(
        () => SadlParser.parseLicense(emptyData),
        throwsA(isA<InvalidInputDataException>()),
      );
    });

    test('parseLicense throws InvalidInputDataException for short data', () {
      final shortData = Uint8List.fromList([1, 2, 3]);
      
      expect(
        () => SadlParser.parseLicense(shortData),
        throwsA(isA<InvalidInputDataException>()),
      );
    });

    test('parseLicense throws UnsupportedLicenseVersionException for unknown version', () {
      // Create data with unknown version header but correct length
      final unknownVersionData = Uint8List(1000);
      unknownVersionData[0] = 0xFF; // Unknown version bytes
      unknownVersionData[1] = 0xFF;
      unknownVersionData[2] = 0xFF;
      unknownVersionData[3] = 0xFF;
      
      expect(
        () => SadlParser.parseLicense(unknownVersionData),
        throwsA(isA<UnsupportedLicenseVersionException>()),
      );
    });

    test('decrypt throws InvalidInputDataException for empty data', () {
      final emptyData = Uint8List(0);
      
      expect(
        () => SadlParser.decrypt(emptyData),
        throwsA(isA<InvalidInputDataException>()),
      );
    });

    // TODO: Add tests with real license data
    // Note: Real license data cannot be included in public tests for privacy reasons
    // In production, you would test with anonymized/synthetic test data
  });

  group('DrivingLicense', () {
    test('creates a valid DrivingLicense instance', () {
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

      expect(license.surname, equals('SMITH'));
      expect(license.initials, equals('JD'));
      expect(license.fullName, equals('SMITH JD'));
      expect(license.licenseNumber, equals('A12345678'));
      expect(license.vehicleCodes, contains('B'));
      expect(license.vehicleCodes, contains('EB'));
    });

    test('fullName getter combines surname and initials', () {
      final license = DrivingLicense(
        vehicleCodes: ['B'],
        surname: 'DOE',
        initials: 'J',
        idCountryOfIssue: 'ZA',
        licenseCountryOfIssue: 'ZA',
        vehicleRestrictions: [],
        licenseNumber: 'A12345678',
        idNumber: '8001015009087',
        idNumberType: '01',
        licenseCodeIssueDates: ['2020/01/15'],
        driverRestrictionCodes: ['00'],
        licenseIssueNumber: '01',
        birthdate: '1980/01/01',
        licenseIssueDate: '2020/01/15',
        licenseExpiryDate: '2025/01/15',
        gender: 'male',
        // imageWidth: 150,
        // imageHeight: 180,
      );

      expect(license.fullName, equals('DOE J'));
    });

    test('isExpired returns false for future date', () {
      final license = DrivingLicense(
        vehicleCodes: ['B'],
        surname: 'SMITH',
        initials: 'J',
        idCountryOfIssue: 'ZA',
        licenseCountryOfIssue: 'ZA',
        vehicleRestrictions: [],
        licenseNumber: 'A12345678',
        idNumber: '8001015009087',
        idNumberType: '01',
        licenseCodeIssueDates: ['2020/01/15'],
        driverRestrictionCodes: ['00'],
        licenseIssueNumber: '01',
        birthdate: '1980/01/01',
        licenseIssueDate: '2020/01/15',
        licenseExpiryDate: '2099/12/31', // Far future
        gender: 'male',
        // imageWidth: 150,
        // imageHeight: 180,
      );

      expect(license.isExpired, isFalse);
    });

    test('isExpired returns true for past date', () {
      final license = DrivingLicense(
        vehicleCodes: ['B'],
        surname: 'SMITH',
        initials: 'J',
        idCountryOfIssue: 'ZA',
        licenseCountryOfIssue: 'ZA',
        vehicleRestrictions: [],
        licenseNumber: 'A12345678',
        idNumber: '8001015009087',
        idNumberType: '01',
        licenseCodeIssueDates: ['2020/01/15'],
        driverRestrictionCodes: ['00'],
        licenseIssueNumber: '01',
        birthdate: '1980/01/01',
        licenseIssueDate: '2020/01/15',
        licenseExpiryDate: '2020/01/01', // Past date
        gender: 'male',
        // imageWidth: 150,
        // imageHeight: 180,
      );

      expect(license.isExpired, isTrue);
    });

    test('hasPrdpPermit returns true when prdpCode is set', () {
      final license = DrivingLicense(
        vehicleCodes: ['B'],
        surname: 'SMITH',
        initials: 'J',
        prdpCode: 'ABC123',
        idCountryOfIssue: 'ZA',
        licenseCountryOfIssue: 'ZA',
        vehicleRestrictions: [],
        licenseNumber: 'A12345678',
        idNumber: '8001015009087',
        idNumberType: '01',
        licenseCodeIssueDates: ['2020/01/15'],
        driverRestrictionCodes: ['00'],
        prdpPermitExpiryDate: '2025/01/15',
        licenseIssueNumber: '01',
        birthdate: '1980/01/01',
        licenseIssueDate: '2020/01/15',
        licenseExpiryDate: '2025/01/15',
        gender: 'male',
        // imageWidth: 150,
        // imageHeight: 180,
      );

      expect(license.hasPrdpPermit, isTrue);
    });

    test('hasPrdpPermit returns false when prdpCode is null', () {
      final license = DrivingLicense(
        vehicleCodes: ['B'],
        surname: 'SMITH',
        initials: 'J',
        prdpCode: null,
        idCountryOfIssue: 'ZA',
        licenseCountryOfIssue: 'ZA',
        vehicleRestrictions: [],
        licenseNumber: 'A12345678',
        idNumber: '8001015009087',
        idNumberType: '01',
        licenseCodeIssueDates: ['2020/01/15'],
        driverRestrictionCodes: ['00'],
        licenseIssueNumber: '01',
        birthdate: '1980/01/01',
        licenseIssueDate: '2020/01/15',
        licenseExpiryDate: '2025/01/15',
        gender: 'male',
        // imageWidth: 150,
        // imageHeight: 180,
      );

      expect(license.hasPrdpPermit, isFalse);
    });

    test('toJson and fromJson work correctly', () {
      final originalLicense = DrivingLicense(
        vehicleCodes: ['B', 'EB'],
        surname: 'SMITH',
        initials: 'JD',
        prdpCode: 'ABC123',
        idCountryOfIssue: 'ZA',
        licenseCountryOfIssue: 'ZA',
        vehicleRestrictions: ['01'],
        licenseNumber: 'A12345678',
        idNumber: '8001015009087',
        idNumberType: '01',
        licenseCodeIssueDates: ['2020/01/15', '2020/01/15'],
        driverRestrictionCodes: ['00'],
        prdpPermitExpiryDate: '2025/01/15',
        licenseIssueNumber: '01',
        birthdate: '1980/01/01',
        licenseIssueDate: '2020/01/15',
        licenseExpiryDate: '2025/01/15',
        gender: 'male',
        // imageWidth: 150,
        // imageHeight: 180,
      );

      final json = originalLicense.toJson();
      final recreatedLicense = DrivingLicense.fromJson(json);

      expect(recreatedLicense.surname, equals(originalLicense.surname));
      expect(recreatedLicense.initials, equals(originalLicense.initials));
      expect(recreatedLicense.licenseNumber, equals(originalLicense.licenseNumber));
      expect(recreatedLicense.idNumber, equals(originalLicense.idNumber));
      expect(recreatedLicense.prdpCode, equals(originalLicense.prdpCode));
      expect(recreatedLicense.vehicleCodes, equals(originalLicense.vehicleCodes));
    });

    test('equality works correctly', () {
      final license1 = DrivingLicense(
        vehicleCodes: ['B'],
        surname: 'SMITH',
        initials: 'J',
        idCountryOfIssue: 'ZA',
        licenseCountryOfIssue: 'ZA',
        vehicleRestrictions: [],
        licenseNumber: 'A12345678',
        idNumber: '8001015009087',
        idNumberType: '01',
        licenseCodeIssueDates: ['2020/01/15'],
        driverRestrictionCodes: ['00'],
        licenseIssueNumber: '01',
        birthdate: '1980/01/01',
        licenseIssueDate: '2020/01/15',
        licenseExpiryDate: '2025/01/15',
        gender: 'male',
        // imageWidth: 150,
        // imageHeight: 180,
      );

      final license2 = DrivingLicense(
        vehicleCodes: ['B'],
        surname: 'SMITH',
        initials: 'J',
        idCountryOfIssue: 'ZA',
        licenseCountryOfIssue: 'ZA',
        vehicleRestrictions: [],
        licenseNumber: 'A12345678',
        idNumber: '8001015009087',
        idNumberType: '01',
        licenseCodeIssueDates: ['2020/01/15'],
        driverRestrictionCodes: ['00'],
        licenseIssueNumber: '01',
        birthdate: '1980/01/01',
        licenseIssueDate: '2020/01/15',
        licenseExpiryDate: '2025/01/15',
        gender: 'male',
        // imageWidth: 150,
        // imageHeight: 180,
      );

      final license3 = DrivingLicense(
        vehicleCodes: ['B'],
        surname: 'DOE',
        initials: 'J',
        idCountryOfIssue: 'ZA',
        licenseCountryOfIssue: 'ZA',
        vehicleRestrictions: [],
        licenseNumber: 'B87654321', // Different
        idNumber: '9001015009087', // Different
        idNumberType: '01',
        licenseCodeIssueDates: ['2020/01/15'],
        driverRestrictionCodes: ['00'],
        licenseIssueNumber: '01',
        birthdate: '1990/01/01',
        licenseIssueDate: '2020/01/15',
        licenseExpiryDate: '2025/01/15',
        gender: 'male',
        // imageWidth: 150,
        // imageHeight: 180,
      );

      expect(license1, equals(license2));
      expect(license1, isNot(equals(license3)));
      expect(license1.hashCode, equals(license2.hashCode));
    });
  });

  group('Exception Types', () {
    test('SadlException has correct properties', () {
      final exception = SadlException('Test message', 'Test cause');
      
      expect(exception.message, equals('Test message'));
      expect(exception.cause, equals('Test cause'));
      expect(exception.toString(), contains('Test message'));
      expect(exception.toString(), contains('Test cause'));
    });

    test('InvalidInputDataException extends SadlException', () {
      final exception = InvalidInputDataException('Invalid data');
      
      expect(exception, isA<SadlException>());
      expect(exception.message, equals('Invalid data'));
    });

    test('UnsupportedLicenseVersionException has header property', () {
      final header = [0xFF, 0xFF, 0xFF, 0xFF];
      final exception = UnsupportedLicenseVersionException(header);
      
      expect(exception, isA<SadlDecryptionException>());
      expect(exception.foundHeader, equals(header));
      expect(exception.toString(), contains('0xff'));
    });
  });

  // TODO: Add integration tests with sample license data
  // TODO: Add performance tests for large datasets
  // TODO: Add tests for binary utility functions
}
