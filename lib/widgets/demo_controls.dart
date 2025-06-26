import 'package:flutter/material.dart';

class DemoControls extends StatelessWidget {
  const DemoControls({
    super.key,
    required this.isReady,
    required this.demoRunning,
    required this.locationDisplayStarted,
    required this.onStart,
    required this.onReset,
    required this.onSpeedChanged,
    required this.currentSpeed,
  });

  final bool isReady;
  final bool demoRunning;
  final bool locationDisplayStarted;
  final VoidCallback? onStart;
  final VoidCallback? onReset;
  final ValueChanged<double> onSpeedChanged;
  final double currentSpeed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 25, top: 15),
      child: Column(
        children: [
          if (!demoRunning)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.speed, color: Colors.blue, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Speed: ${(currentSpeed * 2.237).toStringAsFixed(0)} mph',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Slow',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '2 mph',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      Expanded(
                        child: Slider(
                          value: currentSpeed,
                          min: 0.894, // 2 mph
                          max: 22.35, // 50 mph
                          divisions: 24,
                          onChanged: isReady ? onSpeedChanged : null,
                          activeColor: Colors.blue,
                          inactiveColor: Colors.grey[300],
                        ),
                      ),
                      Text(
                        '50 mph',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: isReady ? onStart : null,
                icon: Icon(_getStartButtonIcon()),
                label: Text(_getStartButtonText()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getStartButtonColor(),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 15),
              ElevatedButton.icon(
                onPressed: isReady ? onReset : null,
                icon: Icon(Icons.refresh),
                label: Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getStartButtonIcon() {
    if (!demoRunning) {
      return Icons
          .play_arrow; // Start - always show play when demo is not running
    } else if (locationDisplayStarted) {
      return Icons.pause; // Pause
    } else {
      return Icons.play_arrow; // Resume
    }
  }

  String _getStartButtonText() {
    if (!demoRunning) {
      return 'Start'; // Always show "Start" when demo is not running
    } else if (locationDisplayStarted) {
      return 'Pause';
    } else {
      return 'Resume';
    }
  }

  Color _getStartButtonColor() {
    if (!demoRunning) {
      return Colors.green; // Start - always green when demo is not running
    } else if (locationDisplayStarted) {
      return Colors.orange; // Pause
    } else {
      return Colors.blue; // Resume
    }
  }
}
