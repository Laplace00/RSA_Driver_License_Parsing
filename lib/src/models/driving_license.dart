/// Model representing a South African driver's license.
library;

/// Represents a parsed South African driver's license.
///
/// This class contains all the information extracted from a South African
/// driver's license PDF417 barcode after decryption and parsing.
///
/// Example:
/// ```dart
/// final license = DrivingLicense(
///   surname: 'SMITH',
///   initials: 'JD',
///   idNumber: '8001015009087',
///   licenseNumber: 'A12345678',
///   // ... other fields
/// );
/// 
/// print(license.fullName); // SMITH JD
/// print(license.isExpired); // false
/// ```
class DrivingLicense {
  /// List of vehicle codes the license holder is authorized to drive.
  ///
  /// Examples: 'A', 'B', 'C1', 'EB'
  final List<String> vehicleCodes;

  /// License holder's surname (family name).
  final String surname;

  /// License holder's initials.
  final String initials;

  /// Professional Driving Permit (PrDP) code, if applicable.
  ///
  /// This is only present for professional drivers.
  final String? prdpCode;

  /// Country code where the ID document was issued.
  ///
  /// Typically 'ZA' for South Africa.
  final String idCountryOfIssue;

  /// Country code where the license was issued.
  ///
  /// Typically 'ZA' for South Africa.
  final String licenseCountryOfIssue;

  /// List of vehicle-specific restrictions.
  ///
  /// Examples: restrictions on vehicle types, driving conditions, etc.
  final List<String> vehicleRestrictions;

  /// Unique license number.
  final String licenseNumber;

  /// South African ID number or passport number.
  final String idNumber;

  /// Type of ID number.
  ///
  /// Typically '01' for South African ID, '02' for passport.
  final String idNumberType;

  /// Issue dates for each vehicle code.
  ///
  /// Format: 'YYYY/MM/DD'
  final List<String> licenseCodeIssueDates;

  /// Driver-specific restriction codes.
  ///
  /// Examples: codes indicating glasses required, automatic transmission only, etc.
  final List<String> driverRestrictionCodes;

  /// Expiry date of Professional Driving Permit (PrDP), if applicable.
  ///
  /// Format: 'YYYY/MM/DD'
  final String? prdpPermitExpiryDate;

  /// License issue number.
  ///
  /// Increments each time a new card is issued.
  final String licenseIssueNumber;

  /// License holder's date of birth.
  ///
  /// Format: 'YYYY/MM/DD'
  final String birthdate;

  /// Date when the license was issued.
  ///
  /// Format: 'YYYY/MM/DD'
  final String licenseIssueDate;

  /// Date when the license expires.
  ///
  /// Format: 'YYYY/MM/DD'
  final String licenseExpiryDate;

  /// License holder's gender.
  ///
  /// Either 'male' or 'female'.
  final String gender;

  // /// Width of the embedded photo image in pixels.
  // final int imageWidth;

  // /// Height of the embedded photo image in pixels.
  // final int imageHeight;

  // /// Raw image data (if available).
  // ///
  // /// Note: Image extraction is currently not fully implemented.
  // final List<int>? imageData;

  /// Creates a new [DrivingLicense] instance.
  ///
  /// All fields except [prdpCode] and [prdpPermitExpiryDate] are required.
  const DrivingLicense({
    required this.vehicleCodes,
    required this.surname,
    required this.initials,
    this.prdpCode,
    required this.idCountryOfIssue,
    required this.licenseCountryOfIssue,
    required this.vehicleRestrictions,
    required this.licenseNumber,
    required this.idNumber,
    required this.idNumberType,
    required this.licenseCodeIssueDates,
    required this.driverRestrictionCodes,
    this.prdpPermitExpiryDate,
    required this.licenseIssueNumber,
    required this.birthdate,
    required this.licenseIssueDate,
    required this.licenseExpiryDate,
    required this.gender,
    // required this.imageWidth,
    // required this.imageHeight,
    // this.imageData,
  });

  /// Returns the full name (surname and initials combined).
  String get fullName => '$initials $surname';

  /// Checks if the license is expired based on the expiry date.
  ///
  /// Returns `true` if the license expiry date is in the past, `false` otherwise.
  /// Returns `false` if the expiry date cannot be parsed.
  bool get isExpired {
    try {
      final parts = licenseExpiryDate.split('/');
      if (parts.length != 3) return false;
      
      final expiryDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return false;
    }
  }

  /// Checks if the license holder has a Professional Driving Permit.
  bool get hasPrdpPermit => prdpCode != null && prdpCode!.isNotEmpty;

  /// Converts the license data to a JSON map.
  ///
  /// This is useful for serialization, storage, or API communication.
  Map<String, dynamic> toJson() {
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
      'idNumberType': idNumberType,
      'licenseCodeIssueDates': licenseCodeIssueDates,
      'driverRestrictionCodes': driverRestrictionCodes,
      'prdpPermitExpiryDate': prdpPermitExpiryDate,
      'licenseIssueNumber': licenseIssueNumber,
      'birthdate': birthdate,
      'licenseIssueDate': licenseIssueDate,
      'licenseExpiryDate': licenseExpiryDate,
      'gender': gender,
      // 'imageWidth': imageWidth,
      // 'imageHeight': imageHeight,
      // 'imageData': imageData,
    };
  }

  /// Creates a [DrivingLicense] instance from a JSON map.
  ///
  /// Throws [ArgumentError] if required fields are missing.
  factory DrivingLicense.fromJson(Map<String, dynamic> json) {
    return DrivingLicense(
      vehicleCodes: (json['vehicleCodes'] as List<dynamic>).cast<String>(),
      surname: json['surname'] as String,
      initials: json['initials'] as String,
      prdpCode: json['prdpCode'] as String?,
      idCountryOfIssue: json['idCountryOfIssue'] as String,
      licenseCountryOfIssue: json['licenseCountryOfIssue'] as String,
      vehicleRestrictions: (json['vehicleRestrictions'] as List<dynamic>).cast<String>(),
      licenseNumber: json['licenseNumber'] as String,
      idNumber: json['idNumber'] as String,
      idNumberType: json['idNumberType'] as String,
      licenseCodeIssueDates: (json['licenseCodeIssueDates'] as List<dynamic>).cast<String>(),
      driverRestrictionCodes: (json['driverRestrictionCodes'] as List<dynamic>).cast<String>(),
      prdpPermitExpiryDate: json['prdpPermitExpiryDate'] as String?,
      licenseIssueNumber: json['licenseIssueNumber'] as String,
      birthdate: json['birthdate'] as String,
      licenseIssueDate: json['licenseIssueDate'] as String,
      licenseExpiryDate: json['licenseExpiryDate'] as String,
      gender: json['gender'] as String,
      // imageWidth: json['imageWidth'] as int,
      // imageHeight: json['imageHeight'] as int,
      // imageData: json['imageData'] != null 
      //     ? (json['imageData'] as List<dynamic>).cast<int>()
      //     : null,
    );
  }

  @override
  String toString() {
    return 'DrivingLicense('
        'name: $fullName, '
        'licenseNumber: $licenseNumber, '
        'idNumber: $idNumber, '
        'vehicleCodes: ${vehicleCodes.join(", ")}, '
        'expiryDate: $licenseExpiryDate, '
        'isExpired: $isExpired'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DrivingLicense &&
        other.licenseNumber == licenseNumber &&
        other.idNumber == idNumber;
  }

  @override
  int get hashCode => licenseNumber.hashCode ^ idNumber.hashCode;
}
