part of 'ble_service_bloc.dart';

/// The base class for all events related to the BLE service BLoC.
/// This class is immutable and extends [Equatable] to allow for value comparison.
@immutable
sealed class BleServiceEvent extends Equatable {}

/// Event to start scanning for and connecting to a BLE device.
///
/// Parameters:
/// - [deviceID]: The ID of the device to connect to.
/// - [scanTimeout]: Optional timeout duration for the scan operation.
/// - [connectionTimeout]: Optional timeout duration for the connection operation.
/// - [mtu]: Optional Maximum Transmission Unit size.
class StartScanAndConnectToDeviceEvent extends BleServiceEvent {
  final String deviceID;
  final Duration? scanTimeout;
  final Duration? connectionTimeout;
  final int? mtu;

  StartScanAndConnectToDeviceEvent({
    this.mtu,
    required this.deviceID,
    this.scanTimeout,
    this.connectionTimeout,
  });

  @override
  List<Object?> get props => [deviceID, scanTimeout, connectionTimeout, mtu];
}

/// Event to handle changes in the Bluetooth adapter state.
///
/// Parameters:
/// - [adapterState]: The current state of the Bluetooth adapter.
class BLEAdapterStateChangedEvent extends BleServiceEvent {
  final BluetoothAdapterState adapterState;

  BLEAdapterStateChangedEvent({required this.adapterState});

  @override
  List<Object?> get props => [adapterState];
}

/// Event to send a command to a connected BLE device.
///
/// Parameters:
/// - [device]: The connected Bluetooth device.
/// - [characteristicID]: The ID of the characteristic to write to.
/// - [serviceID]: The ID of the service containing the characteristic.
/// - [hexCommand]: The command to send, in hexadecimal format.
class BLESendCommandToConnectedDeviceEvent extends BleServiceEvent {
  final BluetoothDevice device;
  final String characteristicID;
  final String serviceID;
  final String hexCommand;

  BLESendCommandToConnectedDeviceEvent({
    required this.device,
    required this.characteristicID,
    required this.serviceID,
    required this.hexCommand,
  });

  @override
  List<Object?> get props => [characteristicID, serviceID, hexCommand, device];
}

/// Event to turn on Bluetooth.
///
/// This event does not have any parameters.
class TurnONBlueToothEvent extends BleServiceEvent {
  TurnONBlueToothEvent();

  @override
  List<Object?> get props => [];
}
