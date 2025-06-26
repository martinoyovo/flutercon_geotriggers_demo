import 'package:flutter/material.dart';

class DemoStatusPanel extends StatelessWidget {
  final String statusText;
  final Set<String> activeZones;

  const DemoStatusPanel({
    super.key,
    required this.statusText,
    required this.activeZones,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.blue[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Demo Status:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            statusText,
            style: TextStyle(fontSize: 18, color: Colors.blue[800]),
          ),
          if (activeZones.isNotEmpty) ...[
            SizedBox(height: 12),
            _buildActiveZoneChips(),
          ],
          if (statusText.contains("completed")) ...[
            SizedBox(height: 8),
            _buildCompletionIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveZoneChips() {
    return Wrap(
      spacing: 8,
      children:
          activeZones
              .map(
                (zone) => Chip(
                  label: Text(zone),
                  backgroundColor: _getZoneChipColor(zone),
                  avatar: Icon(
                    Icons.location_on,
                    size: 16,
                    color: _getZoneChipIconColor(zone),
                  ),
                ),
              )
              .toList(),
    );
  }

  // Get chip background color based on zone name
  Color _getZoneChipColor(String zoneName) {
    switch (zoneName.toLowerCase()) {
      case 'union square':
        return Colors.green[100]!;
      case 'flatiron district':
        return Colors.orange[100]!;
      case 'koreatown':
        return Colors.red[100]!;
      case 'theater district':
        return Colors.purple[100]!;
      case 'central park south':
        return Colors.teal[100]!;
      case 'columbus circle':
        return Colors.indigo[100]!;
      case 'times square destination':
        return Colors.blue[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  // Get chip icon color based on zone name
  Color _getZoneChipIconColor(String zoneName) {
    switch (zoneName.toLowerCase()) {
      case 'union square':
        return Colors.green[700]!;
      case 'flatiron district':
        return Colors.orange[700]!;
      case 'koreatown':
        return Colors.red[700]!;
      case 'theater district':
        return Colors.purple[700]!;
      case 'central park south':
        return Colors.teal[700]!;
      case 'columbus circle':
        return Colors.indigo[700]!;
      case 'times square destination':
        return Colors.blue[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  Widget _buildCompletionIndicator() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green[700], size: 20),
          SizedBox(width: 8),
          Text(
            'Tour Completed Successfully!',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
