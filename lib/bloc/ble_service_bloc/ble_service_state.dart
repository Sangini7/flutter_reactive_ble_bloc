part of 'ble_service_bloc.dart';

/// The base class for all states related to the BLE service BLoC.
/// This class is immutable and extends [Equatable] to allow for value comparison.
@immutable
sealed class BleServiceState extends Equatable {}

/// The initial state of the BLE service.
/// This state indicates that no BLE actions have been performed yet.
final class BleServiceInitial extends BleServiceState {
  @override
  List<Object?> get props => [];
}

/// A state indicating that the state of the Bluetooth adapter has changed.
/// [isBlueToothON] is a boolean indicating whether Bluetooth is currently enabled or not.
final class BLEAdapterStateChangedState extends BleServiceState {
  final bool isBlueToothON;

  BLEAdapterStateChangedState({required this.isBlueToothON});

  @override
  List<Object?> get props => [isBlueToothON];
}

/// A state indicating that a BLE device scan has successfully found a device.
/// [deviceScanResult] contains the result of the scan.
final class DeviceScanSuccessState extends BleServiceState {
  final ScanResult deviceScanResult;

  DeviceScanSuccessState({required this.deviceScanResult});

  @override
  List<Object?> get props => [deviceScanResult];
}

/// A state indicating that a BLE device scan is currently in progress.
final class DeviceScanProgressState extends BleServiceState {
  DeviceScanProgressState();

  @override
  List<Object?> get props => [];
}

/// A state indicating that a BLE device has successfully connected.
/// [device] is the connected Bluetooth device.
final class DeviceConnectedState extends BleServiceState {
  final BluetoothDevice device;

  DeviceConnectedState({ required this.device});

  @override
  List<Object?> get props => [device];
}

/// A state indicating that a command has been successfully sent to a connected BLE device.
/// [response] contains the response from the device.
final class BLESendCommandSuccessState extends BleServiceState {
  final String response;

  BLESendCommandSuccessState({required this.response});

  @override
  List<Object?> get props => [response];
}

/// A state indicating an error occurred in the BLE service.
/// [bluetoothServiceError] provides details about the error.
final class BleServiceErrorState extends BleServiceState {
  final BluetoothServiceError bluetoothServiceError;

  BleServiceErrorState({required this.bluetoothServiceError});

  @override
  List<Object?> get props => [bluetoothServiceError];
}
