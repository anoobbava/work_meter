import 'package:flutter/material.dart';

class LeaveRequestsLeaves extends StatelessWidget {
  final String? _leaves;
  LeaveRequestsLeaves(this._leaves);

// this function will return the message as subtitle in the list tile of leaves to be applied
  String leaveStatusMessage(leave) {
    if (leave.contains('R')) {
      // all applied
      return 'All Applied';
    } else if (leave.contains('H')) {
      // partially applied
      return 'Partially Applied';
    } else if (leave.contains('I')) {
      // pending Approved by Manager
      return 'Pending approval by Manager';
    } else {
      return 'Not Applied';
    }
  }

  // return the image path for the leave requests
  String generateLeaveImagePath(leave) {
    if (leave.contains('R')) {
      // all applied
      return 'images/all_applied_leave_icon.png';
    } else if (leave.contains('H')) {
      // partially applied
      return 'images/partially_applied_leave_icon.png';
    } else {
      return 'images/pending_leave_icon.png';
    }
  }

  // Get color based on leave status
  Color getLeaveStatusColor(leave) {
    if (leave.contains('R')) {
      return Colors.green; // All applied - green
    } else if (leave.contains('H')) {
      return Colors.orange; // Partially applied - orange
    } else if (leave.contains('I')) {
      return Colors.blue; // Pending approval - blue
    } else {
      return Colors.grey; // Not applied - grey
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Handle null or empty leaves
    if (_leaves == null || _leaves!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: Colors.green[400],
            ),
            SizedBox(height: 16),
            Text(
              'No pending leaves!',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontFamily: 'OpenSans',
              ),
            ),
          ],
        ),
      );
    }

    // for time to be styled in the pending leaves
    final TextStyle leaveTimeStyle = TextStyle(
        fontFamily: 'OpenSans',
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
        color: Colors.white);

    // for time to be styled in the pending leaves
    final TextStyle leaveStatusStyle = TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: 'OpenSans',
        fontSize: 15.0,
        color: Colors.white70);

    // for date to be styled in the pending leaves
    final TextStyle leaveDateStyle = TextStyle(
        fontFamily: 'OpenSans',
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: Colors.white);
        
    List leavesArray = _leaves!.split(',');
    print('display leaves array');
    print(leavesArray);
    
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              itemCount: leavesArray.length,
              itemBuilder: (context, index) {
                final leave = leavesArray[index];
                final statusColor = getLeaveStatusColor(leave);
                
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          generateLeaveImagePath(leave),
                          width: 24,
                          height: 24,
                        ),
                      ),
                      title: Text(
                        leave.split('-')[0].split('(')[0],
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        leaveStatusMessage(leave),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSans',
                          fontSize: 15.0,
                          color: statusColor,
                        ),
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          leave.split('-')[0].split('(')[1].replaceAll(')', ''),
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
