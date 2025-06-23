import 'dart:async';
import 'package:viam_sdk/viam_sdk.dart';

import '../../consts.dart';

typedef LightStatus = ({bool red, bool green, bool blue, bool yellow});

class RobotRepository {
  RobotClient? _robot;
  Timer? _refreshTimer;
  LightStatus? _lightStatus;
  bool _isConnected = false;
  bool _isUpdating = false;

  Camera? camera;
  StreamClient? streamClient;

  bool get isConnected => _isConnected;
  LightStatus? get lightStatus => _lightStatus;

  final _isConnectedController = StreamController<bool>.broadcast();
  Stream<bool> get isConnectedStream => _isConnectedController.stream;

  final _lightStatusController = StreamController<LightStatus>.broadcast();
  Stream<LightStatus> get lightStatusStream => _lightStatusController.stream;

  Future<void> connect({
    required String host,
    required String apiKeyID,
    required String apiKey,
  }) async {
    try {
      final options = RobotClientOptions.withApiKey(apiKeyID, apiKey);
      _robot = await RobotClient.atAddress(host, options);
      _isConnected = true;
      camera = Camera.fromRobot(_robot!, 'camera-1');
      streamClient = _robot?.getStream('camera-1');
      await _fetchAndEmitLightStatus();
      _isConnectedController.add(_isConnected);
      _startPolling();
    } catch (e) {
      _isConnected = false;
      _isConnectedController.add(_isConnected);
    }
  }

  void dispose() {
    _isConnectedController.close();
    _lightStatusController.close();
    _refreshTimer?.cancel();
    disconnect();
  }

  Future<void> disconnect() async {
    await _robot?.close();
    _robot = null;
    _isConnected = false;
    _isConnectedController.add(_isConnected);
    _refreshTimer?.cancel();
  }

  void _startPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) async {
      await _fetchAndEmitLightStatus();
    });
  }

  Future<void> _fetchAndEmitLightStatus() async {
    if (_robot == null || _isUpdating) return;
    final board = Board.fromRobot(_robot!, 'local');

    try {
      final statuses = await Future.wait([
        board.gpio(redPin),
        board.gpio(greenPin),
        board.gpio(bluePin),
        board.gpio(yellowPin),
      ]);

      if (_isUpdating) return;

      _lightStatus = (
        red: statuses[0],
        green: statuses[1],
        blue: statuses[2],
        yellow: statuses[3],
      );

      _lightStatusController.add(_lightStatus!);
    } catch (e, st) {
      _lightStatusController.addError(e, st);
    }
  }

  Future<void> updatePin(String pin, bool value) async {
    if (_robot == null) return;
    _isUpdating = true;
    _refreshTimer?.cancel();
    try {
      _lightStatus = (
        red: pin == redPin ? value : _lightStatus!.red,
        green: pin == greenPin ? value : _lightStatus!.green,
        blue: pin == bluePin ? value : _lightStatus!.blue,
        yellow: pin == yellowPin ? value : _lightStatus!.yellow,
      );

      _lightStatusController.add(_lightStatus!);
      final board = Board.fromRobot(_robot!, 'local');
      await board.setGpioState(pin, value);
    } catch (e, st) {
      _lightStatusController.addError(e, st);
    } finally {
      _isUpdating = false;
      // await _fetchAndEmitLightStatus();
      _startPolling();
    }
  }
}
