import 'dart:async';

import 'package:flutter/cupertino.dart';

class TimerController {
  late Timer _timer;
  final Duration duration;
  final VoidCallback timerCallback;

  TimerController({required this.duration, required this.timerCallback}) {
    initializeTimer();
  }

  void initializeTimer() =>
      _timer = Timer.periodic(duration, (_) => timerCallback());

  void restart() {
    _timer.cancel();
    initializeTimer();
  }

  void stop() => dispose();

  void dispose() {
    _timer.cancel();
  }
}
