/// State of the bluetooth error
enum BluetoothServiceError {
  unknown,
  scanTimeout,
  connectionTimeout,
  connectionError,
  scanError,
  permissionError,
  readError,
  subscribeError,
  writeError
}