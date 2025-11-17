/// Binary utility functions for data conversion and manipulation.
library;

import 'dart:typed_data';

/// Converts a hexadecimal string to a [Uint8List].
///
/// The hex string should contain an even number of characters.
/// Each pair of hex characters is converted to a single byte.
///
/// Example:
/// ```dart
/// final bytes = hexToUint8List('48656c6c6f');
/// print(String.fromCharCodes(bytes)); // 'Hello'
/// ```
///
/// Throws [FormatException] if the hex string is invalid.
Uint8List hexToUint8List(String hex) {
  if (hex.length.isOdd) {
    throw FormatException(
        'Hex string must have an even number of characters: $hex');
  }

  final bytes = <int>[];
  for (var i = 0; i < hex.length; i += 2) {
    final hexByte = hex.substring(i, i + 2);
    try {
      final byte = int.parse(hexByte, radix: 16);
      bytes.add(byte);
    } catch (e) {
      throw FormatException(
          'Invalid hex string at position $i: $hexByte', hex, i);
    }
  }
  return Uint8List.fromList(bytes);
}

/// Converts a [Uint8List] to a hexadecimal string.
///
/// Each byte is represented as two hex characters (lowercase).
///
/// Example:
/// ```dart
/// final bytes = Uint8List.fromList([72, 101, 108, 108, 111]);
/// print(uint8ListToHex(bytes)); // '48656c6c6f'
/// ```
String uint8ListToHex(Uint8List data) {
  return data.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
}

/// Converts a [BigInt] to a [Uint8List].
///
/// The BigInt is converted to its hexadecimal representation, then to bytes.
/// Leading zero bytes are removed.
///
/// Example:
/// ```dart
/// final bigInt = BigInt.from(256);
/// final bytes = bigIntToUint8List(bigInt);
/// print(bytes); // [1, 0]
/// ```
Uint8List bigIntToUint8List(BigInt number) {
  if (number == BigInt.zero) {
    return Uint8List.fromList([0]);
  }

  // Convert to hex string with even length
  var hexString = number.toRadixString(16);
  if (hexString.length.isOdd) {
    hexString = '0$hexString';
  }

  // Convert hex string to bytes
  final bytes = <int>[];
  for (var i = 0; i < hexString.length; i += 2) {
    bytes.add(int.parse(hexString.substring(i, i + 2), radix: 16));
  }

  // Remove leading zeros
  var skip = 0;
  while (skip < bytes.length - 1 && bytes[skip] == 0) {
    skip++;
  }

  return Uint8List.fromList(bytes.sublist(skip));
}

/// Converts a [Uint8List] to a [BigInt].
///
/// Each byte is treated as a digit in base 256.
///
/// Example:
/// ```dart
/// final bytes = Uint8List.fromList([1, 0]);
/// final bigInt = uint8ListToBigInt(bytes);
/// print(bigInt); // 256
/// ```
BigInt uint8ListToBigInt(Uint8List data) {
  if (data.isEmpty) {
    return BigInt.zero;
  }

  final hexString =
      data.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');

  return BigInt.parse(hexString, radix: 16);
}

/// Reads a null-terminated string from binary data starting at [index].
///
/// Reads bytes until a delimiter byte is encountered.
/// Returns the string value, the new index position, and the delimiter found.
///
/// [data] - The binary data to read from
/// [index] - The starting position
/// [delimiters] - List of byte values that terminate the string
///
/// Returns a list: [String value, int newIndex, int delimiter]
List<dynamic> readString(
  Uint8List data,
  int index, {
  List<int> delimiters = const [0xe0, 0xe1],
}) {
  final buffer = StringBuffer();
  int delimiter = delimiters[0];

  while (index < data.length) {
    final currentByte = data[index];
    index++;

    if (delimiters.contains(currentByte)) {
      delimiter = currentByte;
      break;
    }

    buffer.writeCharCode(currentByte);
  }

  return [buffer.toString(), index, delimiter];
}

/// Reads multiple strings from binary data.
///
/// Reads up to [length] string fields from the data.
/// Stops early if a 0xe1 delimiter is encountered (section end marker).
/// Only non-empty strings are added to the returned list.
///
/// [data] - The binary data to read from
/// [index] - The starting position
/// [length] - Maximum number of string fields to read
/// [delimiters] - List of byte values that terminate strings
///
/// Returns a list: [List<String> strings, int newIndex]
List<dynamic> readStrings(
  Uint8List data,
  int index,
  int length, {
  List<int> delimiters = const [0xe0, 0xe1],
}) {
  final strings = <String>[];
  var i = 0;

  while (i < length && index < data.length) {
    final result = readString(data, index, delimiters: delimiters);
    final value = result[0] as String;
    index = result[1] as int;
    final delimiter = result[2] as int;

    // Add non-empty strings to the list
    if (value.isNotEmpty) {
      strings.add(value);
    }

    i++;

    // If we hit a 0xe1 delimiter, this marks the end of this section
    // Continue reading until we've consumed all 0xe1 delimiters
    if (delimiter == 0xe1) {
      // Keep consuming consecutive 0xe1 delimiters
      while (i < length && index < data.length && data[index] == 0xe1) {
        index++;
        i++;
      }
      break; // Stop reading this section
    }
  }

  return [strings, index];
}

/// Reads a date string from a nibble queue.
///
/// A nibble is a 4-bit value (half a byte). The date is encoded as:
/// - 8 nibbles representing: m, c, d, y, m1, m2, d1, d2
/// - Format: MCDY/M1M2/D1D2 (e.g., 1989/12/25)
///
/// If the first nibble is 10 (0xA), the date is considered empty.
///
/// [nibbleQueue] - Queue of nibbles to read from (modified in place)
///
/// Returns a date string in format 'YYYY/MM/DD' or empty string if null date.
String readNibbleDateString(List<int> nibbleQueue) {
  if (nibbleQueue.isEmpty) {
    return '';
  }

  final m = nibbleQueue.removeAt(0);

  // Empty date indicator
  if (m == 10) {
    return '';
  }

  if (nibbleQueue.length < 7) {
    return '';
  }

  final c = nibbleQueue.removeAt(0);
  final d = nibbleQueue.removeAt(0);
  final y = nibbleQueue.removeAt(0);
  final m1 = nibbleQueue.removeAt(0);
  final m2 = nibbleQueue.removeAt(0);
  final d1 = nibbleQueue.removeAt(0);
  final d2 = nibbleQueue.removeAt(0);

  return '$m$c$d$y/$m1$m2/$d1$d2';
}

/// Reads multiple date strings from a nibble queue.
///
/// [nibbleQueue] - Queue of nibbles to read from (modified in place)
/// [length] - Number of dates to attempt to read
///
/// Returns a list of date strings (empty dates are excluded).
List<String> readNibbleDateList(List<int> nibbleQueue, int length) {
  final dateList = <String>[];

  for (var i = 0; i < length && nibbleQueue.isNotEmpty; i++) {
    final dateString = readNibbleDateString(nibbleQueue);
    if (dateString.isNotEmpty) {
      dateList.add(dateString);
    }
  }

  return dateList;
}

/// Extracts nibbles (4-bit values) from bytes.
///
/// Each byte is split into two nibbles: high nibble (bits 4-7) and low nibble (bits 0-3).
///
/// [data] - The binary data
/// [startIndex] - Starting position in the data
/// [endMarker] - Byte value that marks the end of nibble data
///
/// Returns a list of nibbles.
List<int> extractNibbles(Uint8List data, int startIndex, int endMarker) {
  final nibbles = <int>[];
  var index = startIndex;

  while (index < data.length) {
    final currentByte = data[index];
    index++;

    if (currentByte == endMarker) {
      break;
    }

    // High nibble (bits 4-7)
    nibbles.add(currentByte >> 4);
    // Low nibble (bits 0-3)
    nibbles.add(currentByte & 0x0F);
  }

  return nibbles;
}
