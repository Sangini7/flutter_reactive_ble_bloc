import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:meta/meta.dart';

import '../utils/debug_mode_print.dart';
import '../utils/enums.dart';

part 'ble_service_event.dart';

part 'ble_service_state.dart';

class BleServiceBloc extends Bloc<BleServiceEvent, BleServiceState> {
  final Duration scanTimeout = const Duration(seconds: 30);
  final Duration connectionTimeout = const Duration(seconds: 30);
  final int mtu = 512;

  ///Stream of State of the bluetooth adapter.
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  ///Stream of Scan results
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;

  ///Stream of is device is currently scanning
  late StreamSubscription<bool> _isScanningSubscription;

  ///Last value from the characteristic
  late StreamSubscription<List<int>> _lastValueSubscription;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  bool _isScanning = false;
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  BleServiceBloc() : super(BleServiceInitial()) {
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      add(BLEAdapterStateChangedEvent(adapterState: state));
    });
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
    });

    on<TurnONBlueToothEvent>((event, emit) async {
      try {
        await FlutterBluePlus.turnOn();
      } catch (e) {
        emit(BleServiceErrorState(
            bluetoothServiceError: BluetoothServiceError.permissionError));
      }
    });

    on<BLEAdapterStateChangedEvent>((event, emit) {
      BluetoothAdapterState adapterState = event.adapterState;
      if (adapterState == BluetoothAdapterState.on ||
          adapterState == BluetoothAdapterState.off) {
        emit(BLEAdapterStateChangedState(
            isBlueToothON: (adapterState == BluetoothAdapterState.on)));
      }
    });

    on<BLESendCommandToConnectedDeviceEvent>((event, emit) async {
      if (event.device.isConnected) {
        List<BluetoothService> services = await event.device.discoverServices();
        BluetoothService service = services
            .firstWhere((service) => service.uuid.str == event.serviceID);
        BluetoothCharacteristic? characteristic;
        try {
          characteristic = service.characteristics.firstWhere(
              (characteristic) =>
                  characteristic.uuid.str == event.characteristicID);
        } catch (e) {
          logPrint(e.toString());
        }
        if (characteristic == null) return;
        await characteristic.setNotifyValue(true);
        _lastValueSubscription = characteristic.lastValueStream.listen((value) {
          logPrint('reading: ${getNiceHexString(value)}');
          if (value.isNotEmpty &&
              getNiceHexString(value) != event.hexCommand.toLowerCase()) {
            emit(BLESendCommandSuccessState(response: getNiceHexString(value)));

            ///Cancel stream subscription on getting response.
            _lastValueSubscription.cancel();
          }
        });
        logPrint('writing: ${parseNiceHexString(event.hexCommand)}');
        await characteristic.write(parseNiceHexString(event.hexCommand),
            withoutResponse: characteristic.properties.writeWithoutResponse);
      }
    });

    on<StartScanAndConnectToDeviceEvent>((event, emit) async {
      emit(DeviceScanProgressState());

      if (_adapterState == BluetoothAdapterState.on) {
        ScanResult? scanResultDevice;
        scanResultDevice = await startBLEScanForDevice(
            scanTimeout: event.scanTimeout ?? scanTimeout,
            deviceID: event.deviceID,
            onScanError: () {
              emit(BleServiceErrorState(
                  bluetoothServiceError: BluetoothServiceError.scanError));
            },
            onScanTimeout: () {
              emit(BleServiceErrorState(
                  bluetoothServiceError: BluetoothServiceError.scanTimeout));
            });
        await FlutterBluePlus.stopScan();

        /// Case when the with deviceID is found
        if (scanResultDevice != null) {
          BluetoothDevice device = scanResultDevice.device;
          emit(DeviceScanSuccessState(deviceScanResult: scanResultDevice));
          try {
            if (!scanResultDevice.advertisementData.connectable) {
              throw (Exception());
            }
            bool isConnected = await connectToDevice(device,
                event.connectionTimeout ?? connectionTimeout, event.mtu ?? mtu);
            if (isConnected) {
              emit(DeviceConnectedState(
                device: device,
              ));
            } else {
              emit(BleServiceErrorState(
                  bluetoothServiceError:
                      BluetoothServiceError.connectionTimeout));
            }
          } catch (e) {
            emit(BleServiceErrorState(
                bluetoothServiceError: BluetoothServiceError.connectionError));
          }
        }
      }
    });
  }

  Future<bool> connectToDevice(
      BluetoothDevice device, Duration connectionTimeout, int mtu) async {
    Completer<bool> completer = Completer();
    try {
      await device.connect(timeout: connectionTimeout, mtu: mtu);
    } catch (e) {
      completer.complete(false);
    }
    _connectionStateSubscription = device.connectionState.listen((state) {
      _connectionState = state;
      if (_connectionState == BluetoothConnectionState.connected) {
        completer.complete(true);
      }
    });
    return completer.future;
  }

  Future<ScanResult?> startBLEScanForDevice(
      {required Duration scanTimeout,
      required String deviceID,
      Function? onScanError,
      Function? onScanTimeout}) async {
    Completer<ScanResult?> completer = Completer();
    ScanResult? scanResult;
    if (_isScanning == false) {
      await FlutterBluePlus.startScan(
          timeout: scanTimeout, withRemoteIds: [deviceID]);
      //TODO: adv convert to stream transformer (enhancement)
      _scanResultsSubscription =
          FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult result in results) {
          if (result.device.remoteId.str == deviceID) {
            scanResult = result;
            completer.complete(scanResult);
            _scanResultsSubscription.cancel();
            return;
          }
        }
      }, onError: (e) {
        onScanError?.call();
      });

      completer.future.timeout(scanTimeout, onTimeout: () {
        if (scanResult == null) {
          onScanTimeout?.call();

          /// Cancel subscription if timeout occurs
          _scanResultsSubscription.cancel();
        }

        /// Return null after timeout
        return null;
      });
    }

    return completer.future;
  }

  List<int> parseNiceHexString(String hexString) {
    List<int> bytes = [];
    for (int i = 0; i < hexString.length; i += 2) {
      String hexSubstring = hexString.substring(i, i + 2);
      bytes.add(int.parse(hexSubstring, radix: 16));
    }
    return bytes;
  }

  String getNiceHexString(List<int> bytes) {
    return bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join('');
  }

  dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    _adapterStateStateSubscription.cancel();
    _lastValueSubscription.cancel();
    _connectionStateSubscription.cancel();
  }
}
