part of 'ble_service_bloc.dart';

@immutable
sealed class BleServiceState extends Equatable {}

final class BleServiceInitial extends BleServiceState {
  @override
  List<Object?> get props => [];
}

final class BLEAdapterStateChangedState extends BleServiceState {
  final bool isBlueToothON;

  BLEAdapterStateChangedState({required this.isBlueToothON});

  @override
  List<Object?> get props => [isBlueToothON];
}

final class DeviceScanSuccessState extends BleServiceState {
  final ScanResult deviceScanResult;
  DeviceScanSuccessState({required this.deviceScanResult});

  @override
  List<Object?> get props => [deviceScanResult];
}

final class DeviceScanProgressState extends BleServiceState {
  DeviceScanProgressState();

  @override
  List<Object?> get props => [];
}

final class DeviceConnectedState extends BleServiceState {
  final BluetoothDevice device;

  DeviceConnectedState({ required this.device});

  @override
  List<Object?> get props => [device];
}

final class BLESendCommandSuccessState extends BleServiceState {
  final String response;

  BLESendCommandSuccessState({required this.response});

  @override
  List<Object?> get props => [response];
}


final class BleServiceErrorState extends BleServiceState {
  final BluetoothServiceError bluetoothServiceError;

  BleServiceErrorState({required this.bluetoothServiceError});

  @override
  List<Object?> get props => [bluetoothServiceError];
}


