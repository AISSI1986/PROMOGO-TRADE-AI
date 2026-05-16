import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'dart:async';

class LiveBroadcasterViewModel extends BaseViewModel {
  bool _isLive = false;
  bool get isLive => _isLive;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  bool _isFrontCamera = false;
  bool get isFrontCamera => _isFrontCamera;

  int _viewerCount = 0;
  int get viewerCount => _viewerCount;

  Duration _liveDuration = Duration.zero;
  String get formattedDuration => _liveDuration.toString().split('.').first.padLeft(8, "0");

  Timer? _liveTimer;

  void toggleLive() {
    _isLive = !_isLive;
    if (_isLive) {
      _startTimer();
      _viewerCount = 1; // Le vendeur compte pour 1 au début
    } else {
      _stopTimer();
      _viewerCount = 0;
    }
    notifyListeners();
  }

  void _startTimer() {
    _liveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _liveDuration += const Duration(seconds: 1);
      // Simulation d'arrivée de viewers
      if (_liveDuration.inSeconds % 10 == 0) {
        _viewerCount += (1 + (timer.tick % 5));
      }
      notifyListeners();
    });
  }

  void _stopTimer() {
    _liveTimer?.cancel();
    _liveDuration = Duration.zero;
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void switchCamera() {
    _isFrontCamera = !_isFrontCamera;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
