import 'package:flutter/material.dart';
import '../services/game_timer_service.dart';

class GameTimerWidget extends StatefulWidget {
  final GameTimerService timerService;
  final double screenWidth;

  const GameTimerWidget({
    Key? key,
    required this.timerService,
    required this.screenWidth,
  }) : super(key: key);

  @override
  State<GameTimerWidget> createState() => _GameTimerWidgetState();
}

class _GameTimerWidgetState extends State<GameTimerWidget> {
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _elapsedSeconds = widget.timerService.currentTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: widget.screenWidth * 0.02),
      padding: EdgeInsets.symmetric(
        horizontal: widget.screenWidth * 0.02, 
        vertical: 4
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: Colors.amber, size: widget.screenWidth * 0.012),
          SizedBox(width: widget.screenWidth * 0.003),
          Text(
            widget.timerService.formatTime(widget.timerService.currentTime),
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.screenWidth * 0.008,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 