/// Enum representing various errors that can occur during Bluetooth operations.
enum BluetoothServiceError {
  /// An unknown error occurred.
  unknown,

  /// Timeout occurred during scanning for devices.
  scanTimeout,

  /// Timeout occurred during connecting to a device.
  connectionTimeout,

  /// Error occurred while establishing a connection to a device.
  connectionError,

  /// Error occurred during scanning for devices.
  scanError,

  /// Bluetooth permission was denied by the user.
  permissionError,

  /// Error occurred while reading data from a device.
  readError,

  /// Error occurred while subscribing to a characteristic for notifications.
  subscribeError,

  /// Error occurred while writing data to a device.
  writeError,
}
