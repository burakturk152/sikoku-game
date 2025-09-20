import 'dart:async';
import 'package:flutter/material.dart';

class GameTimerService {
  Timer? _timer;
  int elapsedSeconds = 0;
  bool isTimerRunning = false;
  bool isPuzzleCompleted = false;
  
  // Timer durumunu dinlemek için callback
  final Function(int)? onTimeUpdate;
  final Function()? onTimerStart;
  final Function()? onTimerStop;

  GameTimerService({
    this.onTimeUpdate,
    this.onTimerStart,
    this.onTimerStop,
  });

  void startTimer() {
    if (!isTimerRunning && !isPuzzleCompleted) {
      isTimerRunning = true;
      onTimerStart?.call();
      
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        elapsedSeconds++;
        onTimeUpdate?.call(elapsedSeconds);
      });
    }
  }

  void stopTimer() {
    _timer?.cancel();
    isTimerRunning = false;
    onTimerStop?.call();
  }

  void resetTimer() {
    stopTimer();
    elapsedSeconds = 0;
  }

  void setPuzzleCompleted(bool completed) {
    isPuzzleCompleted = completed;
    if (completed) {
      stopTimer();
    }
  }


  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  int get currentTime => elapsedSeconds;
  bool get isRunning => isTimerRunning;

  void dispose() {
    _timer?.cancel();
  }
} 