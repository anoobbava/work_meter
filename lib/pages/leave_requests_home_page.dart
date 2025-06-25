import 'package:flutter/material.dart';

import '../services/app_theme.dart';

class LeaveRequestsHomePage extends StatefulWidget {
  final String? _leaves;
  final String? _casualLeave;
  final String? _medicalLeave;
  final String? _earnedLeave;
  
  const LeaveRequestsHomePage(
    this._leaves, 
    this._casualLeave, 
    this._medicalLeave, 
    this._earnedLeave, {
    Key? key,
  }) : super(key: key);

  @override
  State<LeaveRequestsHomePage> createState() => _LeaveRequestsHomePageState();
}

class _LeaveRequestsHomePageState extends State<LeaveRequestsHomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _parseLeaveBalance(String? leave) {
    return double.tryParse(leave ?? '0') ?? 0.0;
  }

  int _getTotalRemainingLeaves() {
    final casual = _parseLeaveBalance(widget._casualLeave);
    final medical = _parseLeaveBalance(widget._medicalLeave);
    final earned = _parseLeaveBalance(widget._earnedLeave);
    return (casual + medical + earned).toInt();
  }

  List<String> _parsePendingLeaves() {
    if (widget._leaves == null || widget._leaves!.isEmpty) {
      return [];
    }
    return widget._leaves!.split(',').where((leave) => leave.isNotEmpty).toList();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App Bar
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Leave Requests',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'OpenSans',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 32),
            
            // Total Leaves Summary Card
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Total Remaining Leaves',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_getTotalRemainingLeaves()}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'days available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveBalanceCards() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leave Balance',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Leave Balance Cards
            Row(
              children: [
                Expanded(
                  child: _buildLeaveCard(
                    'Casual Leave',
                    widget._casualLeave ?? '0',
                    AppTheme.primaryColor,
                    Icons.beach_access,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLeaveCard(
                    'Medical Leave',
                    widget._medicalLeave ?? '0',
                    AppTheme.errorColor,
                    Icons.local_hospital,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Earned Leave Card (Full Width)
            _buildLeaveCard(
              'Earned Leave',
              widget._earnedLeave ?? '0',
              AppTheme.successColor,
              Icons.star,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveCard(
    String title,
    String balance,
    Color color,
    IconData icon, {
    bool isFullWidth = false,
  }) {
    final balanceValue = _parseLeaveBalance(balance);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isFullWidth 
        ? Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          balanceValue.toString(),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'days',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  balanceValue > 15 ? 'High' : balanceValue > 5 ? 'Medium' : 'Low',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    balanceValue.toString(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'days',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  Widget _buildPendingLeaves() {
    final pendingLeaves = _parsePendingLeaves();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pending Requests',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          if (pendingLeaves.isEmpty)
            _buildEmptyPendingState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingLeaves.length,
              itemBuilder: (context, index) {
                return _buildPendingLeaveCard(pendingLeaves[index], index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPendingLeaveCard(String leaveInfo, int index) {
    // Parse leave info: "14Aug(08:00)-H"
    final parts = leaveInfo.split('-');
    final dateTime = parts.isNotEmpty ? parts[0] : leaveInfo;
    final status = parts.length > 1 ? parts[1] : 'P';
    
    Color statusColor;
    String statusText;
    switch (status.toUpperCase()) {
      case 'H':
        statusColor = AppTheme.warningColor;
        statusText = 'Holiday';
        break;
      case 'R':
        statusColor = AppTheme.errorColor;
        statusText = 'Rejected';
        break;
      case 'A':
        statusColor = AppTheme.successColor;
        statusText = 'Approved';
        break;
      default:
        statusColor = AppTheme.primaryColor;
        statusText = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.event,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateTime,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Leave Request #${index + 1}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPendingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 40,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'All Clear!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No pending leave requests',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildLeaveBalanceCards(),
            const SizedBox(height: 16),
            _buildPendingLeaves(),
            const SizedBox(height: 80), // Bottom padding
          ],
        ),
      ),
    );
  }
}
