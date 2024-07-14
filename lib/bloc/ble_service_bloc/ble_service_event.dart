part of 'ble_service_bloc.dart';

@immutable
sealed class BleServiceEvent extends Equatable {}

class StartScanAndConnectToDeviceEvent extends BleServiceEvent {
  final String deviceID;
  final Duration? scanTimeout;
  final Duration? connectionTimeout;
  final int? mtu;

  StartScanAndConnectToDeviceEvent(
      {this.mtu,
      required this.deviceID,
      this.scanTimeout,
      this.connectionTimeout});

  @override
  List<Object?> get props => [];
}

class BLEAdapterStateChangedEvent extends BleServiceEvent {
  final BluetoothAdapterState adapterState;

  BLEAdapterStateChangedEvent({required this.adapterState});

  @override
  List<Object?> get props => [adapterState];
}

class BLESendCommandToConnectedDeviceEvent extends BleServiceEvent {
  final BluetoothDevice device;
  final String characteristicID;
  final String serviceID;
  final String hexCommand;

  BLESendCommandToConnectedDeviceEvent(
      {required this.device,
      required this.characteristicID,
      required this.serviceID,
      required this.hexCommand});

  @override
  List<Object?> get props => [characteristicID, serviceID, hexCommand, device];
}

class TurnONBlueToothEvent extends BleServiceEvent {
  TurnONBlueToothEvent();

  @override
  List<Object?> get props => [];
}
