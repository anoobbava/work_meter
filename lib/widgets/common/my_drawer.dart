import 'package:flutter/material.dart';

import '../../pages/attendance_home_page.dart';
import '../../pages/leave_requests_home_page.dart';
import '../../pages/user_profile.dart';
import '../../pages/about.dart';
import '../../services/app_theme.dart';

class MyDrawer extends StatelessWidget {
  final String? _leaveStatus;
  final String? _casualLeave;
  final String? _medicalLeave;
  final String? _earnedLeave;
  final List? _attendance;
  final String? _workHour;
  final String? _workMinute;
  final String? _weeklyHour;
  final String? _weeklyMinute;
  final String? _profileName;
  final String? _inOutStatus;

  const MyDrawer(
    this._leaveStatus,
    this._casualLeave,
    this._medicalLeave,
    this._earnedLeave,
    this._attendance,
    this._workHour,
    this._workMinute,
    this._weeklyHour,
    this._weeklyMinute,
    this._profileName,
    this._inOutStatus, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Drawer Header
              Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Avatar
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'images/profile_icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 32,
                              color: AppTheme.primaryColor,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Profile Name
                    Text(
                      _profileName ?? 'User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _inOutStatus == 'IN' 
                          ? AppTheme.successColor 
                          : AppTheme.warningColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _inOutStatus == 'IN' ? Icons.login : Icons.logout,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _inOutStatus == 'IN' ? 'Checked In' : 'Checked Out',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    // Attendance
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.access_time_rounded,
                      title: 'Attendance',
                      subtitle: 'View work hours & history',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttendanceHomePage(
                              _attendance,
                              _workHour,
                              _workMinute,
                              _inOutStatus,
                              _weeklyHour,
                              _weeklyMinute,
                            ),
                          ),
                        );
                      },
                      badge: _workHour != null ? '${_workHour}h' : null,
                      badgeColor: AppTheme.successColor,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Leave Requests
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.event_available_rounded,
                      title: 'Leave Requests',
                      subtitle: 'Manage your leaves',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeaveRequestsHomePage(
                              _leaveStatus,
                              _casualLeave,
                              _medicalLeave,
                              _earnedLeave,
                            ),
                          ),
                        );
                      },
                      badge: _getTotalLeaves(),
                      badgeColor: AppTheme.warningColor,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Profile
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.person_rounded,
                      title: 'Profile',
                      subtitle: 'View your profile',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfile(_profileName),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // About
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.info_outline_rounded,
                      title: 'About',
                      subtitle: 'App information',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => About(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Divider
                    Divider(
                      color: Theme.of(context).dividerColor,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // App Version
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Workmeter v1.0.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  String? _getTotalLeaves() {
    int total = 0;
    
    if (_casualLeave != null) {
      total += int.tryParse(_casualLeave!) ?? 0;
    }
    if (_medicalLeave != null) {
      total += int.tryParse(_medicalLeave!) ?? 0;
    }
    if (_earnedLeave != null) {
      total += int.tryParse(_earnedLeave!) ?? 0;
    }
    
    return total > 0 ? total.toString() : null;
  }
}

// Todo:
// 1. change the colour of drawer
// 2. check the SafeArea in the drawer
