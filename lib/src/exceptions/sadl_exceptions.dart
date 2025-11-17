/// Custom exceptions for South African driver's license parsing.
library;

/// Base exception for all SADL (South African Driver's License) parsing errors.
///
/// All specific exceptions in this library extend from this base class.
class SadlException implements Exception {
  /// The error message describing what went wrong.
  final String message;

  /// Optional cause of the exception.
  final Object? cause;

  /// Creates a new SADL exception with the given [message] and optional [cause].
  const SadlException(this.message, [this.cause]);

  @override
  String toString() =>
      'SadlException: $message${cause != null ? '\nCause: $cause' : ''}';
}

/// Exception thrown when license data decryption fails.
///
/// This can occur when:
/// - The data format is invalid or corrupted
/// - The license version is not recognized
/// - Cryptographic operations fail
class SadlDecryptionException extends SadlException {
  /// Creates a new decryption exception with the given [message] and optional [cause].
  const SadlDecryptionException(super.message, [super.cause]);

  @override
  String toString() =>
      'SadlDecryptionException: $message${cause != null ? '\nCause: $cause' : ''}';
}

/// Exception thrown when license data parsing fails.
///
/// This can occur when:
/// - The decrypted data structure is unexpected
/// - Required fields are missing
/// - Data format doesn't match expected layout
class SadlParsingException extends SadlException {
  /// Creates a new parsing exception with the given [message] and optional [cause].
  const SadlParsingException(super.message, [super.cause]);

  @override
  String toString() =>
      'SadlParsingException: $message${cause != null ? '\nCause: $cause' : ''}';
}

/// Exception thrown when the license version is not supported.
///
/// South African driver's licenses come in different versions (v1, v2, etc.),
/// each with different encryption and format specifications.
class UnsupportedLicenseVersionException extends SadlDecryptionException {
  /// The header bytes that were found in the data.
  final List<int> foundHeader;

  /// Creates a new unsupported version exception with the [foundHeader].
  UnsupportedLicenseVersionException(this.foundHeader)
      : super(
          'Unsupported license version. Header bytes: ${foundHeader.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(', ')}',
        );

  @override
  String toString() =>
      'UnsupportedLicenseVersionException: Unsupported license version. '
      'Header bytes: ${foundHeader.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(', ')}';
}

/// Exception thrown when input data validation fails.
///
/// This occurs before processing begins, when the input data doesn't meet
/// basic requirements (e.g., too short, null, etc.).
class InvalidInputDataException extends SadlException {
  /// Creates a new invalid input exception with the given [message].
  const InvalidInputDataException(super.message);

  @override
  String toString() => 'InvalidInputDataException: $message';
}
