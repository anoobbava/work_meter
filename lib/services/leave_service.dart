import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class LeaveService {
  static const String _pendingLeavesKey = 'pending_leaves';
  static const String _leaveHistoryKey = 'leave_history';
  static const String _leaveTypesKey = 'leave_types';
  
  /// Initialize default leave types
  static Future<void> initializeLeaveTypes() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_leaveTypesKey)) {
      List<LeaveType> defaultTypes = [
        LeaveType(
          id: 'casual',
          name: 'Casual Leave',
          maxDays: 12,
          color: '#4CAF50',
          requiresApproval: true,
          canBeHalfDay: true,
        ),
        LeaveType(
          id: 'sick',
          name: 'Sick Leave',
          maxDays: 10,
          color: '#FF9800',
          requiresApproval: false,
          canBeHalfDay: true,
        ),
        LeaveType(
          id: 'earned',
          name: 'Earned Leave',
          maxDays: 21,
          color: '#2196F3',
          requiresApproval: true,
          canBeHalfDay: false,
        ),
        LeaveType(
          id: 'maternity',
          name: 'Maternity Leave',
          maxDays: 180,
          color: '#E91E63',
          requiresApproval: true,
          canBeHalfDay: false,
        ),
        LeaveType(
          id: 'emergency',
          name: 'Emergency Leave',
          maxDays: 5,
          color: '#F44336',
          requiresApproval: false,
          canBeHalfDay: true,
        ),
      ];
      
      String typesJson = json.encode(defaultTypes.map((e) => e.toJson()).toList());
      await prefs.setString(_leaveTypesKey, typesJson);
    }
  }
  
  /// Get available leave types
  static Future<List<LeaveType>> getLeaveTypes() async {
    await initializeLeaveTypes();
    final prefs = await SharedPreferences.getInstance();
    String? typesJson = prefs.getString(_leaveTypesKey);
    
    if (typesJson != null) {
      List<dynamic> decoded = json.decode(typesJson);
      return decoded.map((item) => LeaveType.fromJson(item)).toList();
    }
    
    return [];
  }
  
  /// Apply for leave
  static Future<LeaveApplicationResult> applyForLeave(LeaveApplication application) async {
    try {
      // Validate leave application
      ValidationResult validation = await validateLeaveApplication(application);
      if (!validation.isValid) {
        return LeaveApplicationResult(
          success: false,
          message: validation.message,
          application: null,
        );
      }
      
      application.id = DateTime.now().millisecondsSinceEpoch.toString();
      application.status = LeaveStatus.pending;
      application.appliedDate = DateTime.now();
      
      // Save to pending leaves
      await savePendingLeave(application);
      
      // For emergency leaves and sick leaves, auto-approve if configured
      if (application.leaveType.id == 'emergency' || 
          (application.leaveType.id == 'sick' && !application.leaveType.requiresApproval)) {
        await approveLeave(application.id, 'System Auto-Approved');
      }
      
      return LeaveApplicationResult(
        success: true,
        message: 'Leave application submitted successfully',
        application: application,
      );
    } catch (e) {
      return LeaveApplicationResult(
        success: false,
        message: 'Failed to apply for leave: $e',
        application: null,
      );
    }
  }
  
  /// Validate leave application
  static Future<ValidationResult> validateLeaveApplication(LeaveApplication application) async {
    // Check if dates are valid
    if (application.endDate.isBefore(application.startDate)) {
      return ValidationResult(false, 'End date cannot be before start date');
    }
    
    // Check for overlapping leaves
    List<LeaveApplication> existingLeaves = await getPendingLeaves();
    existingLeaves.addAll(await getApprovedLeaves());
    
    for (LeaveApplication existing in existingLeaves) {
      if (existing.id != application.id && 
          _datesOverlap(application.startDate, application.endDate, 
                       existing.startDate, existing.endDate)) {
        return ValidationResult(false, 'Leave dates overlap with existing application');
      }
    }
    
    // Check leave balance
    double remainingBalance = await getLeaveBalance(application.leaveType.id);
    if (application.totalDays > remainingBalance) {
      return ValidationResult(false, 'Insufficient leave balance');
    }
    
    // Check minimum notice period (except for emergency/sick leaves)
    if (application.leaveType.id != 'emergency' && application.leaveType.id != 'sick') {
      int daysDifference = application.startDate.difference(DateTime.now()).inDays;
      if (daysDifference < 2) {
        return ValidationResult(false, 'Minimum 2 days notice required');
      }
    }
    
    return ValidationResult(true, 'Valid application');
  }
  
  /// Check if two date ranges overlap
  static bool _datesOverlap(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return start1.isBefore(end2.add(Duration(days: 1))) && 
           end1.isAfter(start2.subtract(Duration(days: 1)));
  }
  
  /// Save pending leave
  static Future<void> savePendingLeave(LeaveApplication application) async {
    final prefs = await SharedPreferences.getInstance();
    List<LeaveApplication> pendingLeaves = await getPendingLeaves();
    
    // Remove if already exists (for updates)
    pendingLeaves.removeWhere((leave) => leave.id == application.id);
    pendingLeaves.add(application);
    
    String leavesJson = json.encode(pendingLeaves.map((e) => e.toJson()).toList());
    await prefs.setString(_pendingLeavesKey, leavesJson);
  }
  
  /// Get pending leaves
  static Future<List<LeaveApplication>> getPendingLeaves() async {
    final prefs = await SharedPreferences.getInstance();
    String? leavesJson = prefs.getString(_pendingLeavesKey);
    
    if (leavesJson != null) {
      List<dynamic> decoded = json.decode(leavesJson);
      return decoded.map((item) => LeaveApplication.fromJson(item)).toList();
    }
    
    return [];
  }
  
  /// Get approved leaves
  static Future<List<LeaveApplication>> getApprovedLeaves() async {
    List<LeaveApplication> history = await getLeaveHistory();
    return history.where((leave) => leave.status == LeaveStatus.approved).toList();
  }
  
  /// Get leave history
  static Future<List<LeaveApplication>> getLeaveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String? historyJson = prefs.getString(_leaveHistoryKey);
    
    if (historyJson != null) {
      List<dynamic> decoded = json.decode(historyJson);
      return decoded.map((item) => LeaveApplication.fromJson(item)).toList();
    }
    
    return [];
  }
  
  /// Approve leave
  static Future<void> approveLeave(String leaveId, String approverComment) async {
    List<LeaveApplication> pendingLeaves = await getPendingLeaves();
    LeaveApplication? leave = pendingLeaves.firstWhere(
      (l) => l.id == leaveId,
      orElse: () => throw Exception('Leave not found'),
    );
    
    leave.status = LeaveStatus.approved;
    leave.approverComment = approverComment;
    leave.approvedDate = DateTime.now();
    
    // Move to history
    await _moveToHistory(leave);
    
    // Remove from pending
    pendingLeaves.removeWhere((l) => l.id == leaveId);
    await _savePendingLeaves(pendingLeaves);
  }
  
  /// Reject leave
  static Future<void> rejectLeave(String leaveId, String rejectionReason) async {
    List<LeaveApplication> pendingLeaves = await getPendingLeaves();
    LeaveApplication? leave = pendingLeaves.firstWhere(
      (l) => l.id == leaveId,
      orElse: () => throw Exception('Leave not found'),
    );
    
    leave.status = LeaveStatus.rejected;
    leave.approverComment = rejectionReason;
    leave.approvedDate = DateTime.now();
    
    // Move to history
    await _moveToHistory(leave);
    
    // Remove from pending
    pendingLeaves.removeWhere((l) => l.id == leaveId);
    await _savePendingLeaves(pendingLeaves);
  }
  
  /// Move leave to history
  static Future<void> _moveToHistory(LeaveApplication leave) async {
    final prefs = await SharedPreferences.getInstance();
    List<LeaveApplication> history = await getLeaveHistory();
    
    // Remove if already exists
    history.removeWhere((l) => l.id == leave.id);
    history.add(leave);
    
    String historyJson = json.encode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_leaveHistoryKey, historyJson);
  }
  
  /// Save pending leaves
  static Future<void> _savePendingLeaves(List<LeaveApplication> leaves) async {
    final prefs = await SharedPreferences.getInstance();
    String leavesJson = json.encode(leaves.map((e) => e.toJson()).toList());
    await prefs.setString(_pendingLeavesKey, leavesJson);
  }
  
  /// Get leave balance for a specific type
  static Future<double> getLeaveBalance(String leaveTypeId) async {
    // This would typically come from API, for now using mock data
    Map<String, double> balances = {
      'casual': 12.0,
      'sick': 10.0,
      'earned': 21.0,
      'maternity': 180.0,
      'emergency': 5.0,
    };
    
    return balances[leaveTypeId] ?? 0.0;
  }
  
  /// Get leave statistics
  static Future<LeaveStatistics> getLeaveStatistics() async {
    List<LeaveApplication> history = await getLeaveHistory();
    List<LeaveApplication> pending = await getPendingLeaves();
    
    int totalApplications = history.length + pending.length;
    int approvedApplications = history.where((l) => l.status == LeaveStatus.approved).length;
    int rejectedApplications = history.where((l) => l.status == LeaveStatus.rejected).length;
    int pendingApplications = pending.length;
    
    double totalDaysUsed = history
        .where((l) => l.status == LeaveStatus.approved)
        .fold(0.0, (sum, leave) => sum + leave.totalDays);
    
    return LeaveStatistics(
      totalApplications: totalApplications,
      approvedApplications: approvedApplications,
      rejectedApplications: rejectedApplications,
      pendingApplications: pendingApplications,
      totalDaysUsed: totalDaysUsed,
    );
  }
}

class LeaveType {
  final String id;
  final String name;
  final int maxDays;
  final String color;
  final bool requiresApproval;
  final bool canBeHalfDay;
  
  LeaveType({
    required this.id,
    required this.name,
    required this.maxDays,
    required this.color,
    required this.requiresApproval,
    required this.canBeHalfDay,
  });
  
  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: json['id'],
      name: json['name'],
      maxDays: json['maxDays'],
      color: json['color'],
      requiresApproval: json['requiresApproval'],
      canBeHalfDay: json['canBeHalfDay'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'maxDays': maxDays,
      'color': color,
      'requiresApproval': requiresApproval,
      'canBeHalfDay': canBeHalfDay,
    };
  }
}

class LeaveApplication {
  String id;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final double totalDays;
  final String reason;
  final bool isHalfDay;
  final String? halfDayType; // 'morning' or 'afternoon'
  LeaveStatus status;
  DateTime appliedDate;
  DateTime? approvedDate;
  String? approverComment;
  
  LeaveApplication({
    this.id = '',
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    this.isHalfDay = false,
    this.halfDayType,
    this.status = LeaveStatus.pending,
    required this.appliedDate,
    this.approvedDate,
    this.approverComment,
  });
  
  factory LeaveApplication.fromJson(Map<String, dynamic> json) {
    return LeaveApplication(
      id: json['id'],
      leaveType: LeaveType.fromJson(json['leaveType']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalDays: json['totalDays'].toDouble(),
      reason: json['reason'],
      isHalfDay: json['isHalfDay'],
      halfDayType: json['halfDayType'],
      status: LeaveStatus.values.firstWhere((e) => e.toString() == json['status']),
      appliedDate: DateTime.parse(json['appliedDate']),
      approvedDate: json['approvedDate'] != null ? DateTime.parse(json['approvedDate']) : null,
      approverComment: json['approverComment'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leaveType': leaveType.toJson(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'reason': reason,
      'isHalfDay': isHalfDay,
      'halfDayType': halfDayType,
      'status': status.toString(),
      'appliedDate': appliedDate.toIso8601String(),
      'approvedDate': approvedDate?.toIso8601String(),
      'approverComment': approverComment,
    };
  }
}

enum LeaveStatus {
  pending,
  approved,
  rejected,
  cancelled,
}

class LeaveApplicationResult {
  final bool success;
  final String message;
  final LeaveApplication? application;
  
  LeaveApplicationResult({
    required this.success,
    required this.message,
    this.application,
  });
}

class ValidationResult {
  final bool isValid;
  final String message;
  
  ValidationResult(this.isValid, this.message);
}

class LeaveStatistics {
  final int totalApplications;
  final int approvedApplications;
  final int rejectedApplications;
  final int pendingApplications;
  final double totalDaysUsed;
  
  LeaveStatistics({
    required this.totalApplications,
    required this.approvedApplications,
    required this.rejectedApplications,
    required this.pendingApplications,
    required this.totalDaysUsed,
  });
} 