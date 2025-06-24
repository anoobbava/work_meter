import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AttendanceCard extends StatelessWidget {
  final bool val = false;
  final bool val1 = true;
  final List? _attendance;
  AttendanceCard(this._attendance);
  
  @override
  Widget build(BuildContext context) {
    final TextStyle timeStyle = TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 20,
      color: Theme.of(context).colorScheme.secondary,
      fontWeight: FontWeight.bold,
    );
    
    // Handle null or empty attendance data
    if (_attendance == null || _attendance!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No attendance data available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontFamily: 'OpenSans',
              ),
            ),
          ],
        ),
      );
    }
    
    final List _attendanceReversed = _attendance!.reversed.toList();
    
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _attendanceReversed.length,
      itemBuilder: (context, index) {
        try {
          final attendanceItem = _attendanceReversed[index];
          
          // Use the correct field names from the API
          final String inTime = attendanceItem['in'] ?? 'N/A';
          final String outTime = attendanceItem['out'] ?? '';
          final String workedTime = attendanceItem['worked_time'] ?? '';
          
          // Calculate worked time if not provided
          String displayWorkedTime = '';
          if (workedTime.isNotEmpty) {
            // Convert seconds to HH:MM format
            try {
              final seconds = int.parse(workedTime);
              final hours = seconds ~/ 3600;
              final minutes = (seconds % 3600) ~/ 60;
              displayWorkedTime = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
            } catch (e) {
              displayWorkedTime = workedTime;
            }
          } else if (inTime != 'N/A' && outTime.isNotEmpty) {
            // Calculate time difference if both in and out times are available
            try {
              final inDateTime = _parseTime(inTime);
              final outDateTime = _parseTime(outTime);
              if (inDateTime != null && outDateTime != null) {
                final difference = outDateTime.difference(inDateTime);
                displayWorkedTime = '${difference.inHours}:${(difference.inMinutes % 60).toString().padLeft(2, '0')}';
              }
            } catch (e) {
              print('Error calculating worked time: $e');
            }
          }
          
          // Check if person is currently in (no out time)
          bool switchValue = outTime.isEmpty;
          
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: CupertinoSwitch(
                    value: switchValue, 
                    onChanged: null,
                    activeColor: Colors.green,
                  ),
                  title: Text(
                    "In: $inTime - Out: ${outTime.isEmpty ? 'Still in' : outTime}",
                    style: timeStyle,
                  ),
                  subtitle: Text(
                    switchValue ? 'Currently Working' : 'Completed',
                    style: TextStyle(
                      color: switchValue ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: displayWorkedTime.isNotEmpty 
                    ? Text(
                        displayWorkedTime,
                        style: timeStyle,
                      )
                    : null,
                ),
                if (index < _attendanceReversed.length - 1)
                  Divider(
                    height: 1.0,
                    color: Theme.of(context).dividerColor,
                  ),
              ],
            ),
          );
        } catch (e) {
          print('Error rendering attendance item: $e');
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text(
              'Error loading attendance data',
              style: TextStyle(color: Colors.red[700]),
            ),
          );
        }
      },
    );
  }

  // Helper method to parse time strings
  DateTime? _parseTime(String timeStr) {
    try {
      // Handle time formats like "08:58", "17:30"
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
    } catch (e) {
      print('Error parsing time: $timeStr - $e');
    }
    return null;
  }
}
