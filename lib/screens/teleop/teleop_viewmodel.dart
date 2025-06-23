import 'package:flutter/foundation.dart';
import 'package:viam_sdk/viam_sdk.dart';
import '../../data/repositories/robot_repository.dart';

class TeleopViewModel extends ChangeNotifier {
  final RobotRepository _robotRepository;

  TeleopViewModel(this._robotRepository)
    : isConnected = _robotRepository.isConnected,
      lightStatus = _robotRepository.lightStatus {
    _robotRepository.isConnectedStream.listen((isConnected) {
      this.isConnected = isConnected;
      notifyListeners();
    });
    _robotRepository.lightStatusStream.listen((lightStatus) {
      this.lightStatus = lightStatus;
      notifyListeners();
    });
  }

  bool isConnected;
  LightStatus? lightStatus;

  Camera? get camera => _robotRepository.camera;
  StreamClient? get streamClient => _robotRepository.streamClient;

  Future<void> updatePin(String pin, bool value) async {
    await _robotRepository.updatePin(pin, value);
  }

  Future<void> disconnect() async {
    await _robotRepository.disconnect();
  }
}
