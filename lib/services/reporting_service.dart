import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import './api_service.dart';
import './leave_service.dart';

class ReportingService {
  static const String _reportDataKey = 'report_data';
  static const String _reportCacheKey = 'report_cache';
  
  /// Generate attendance report for a specific period
  static Future<AttendanceReport> generateAttendanceReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get attendance data from API service
      Map<String, dynamic> userData = await ApiService.fetchWorkMeterData();
      List<dynamic> attendanceData = userData['attendance'] ?? [];
      
      // Filter attendance data for the specified period
      List<AttendanceEntry> filteredAttendance = attendanceData
          .map((entry) => AttendanceEntry.fromJson(entry))
          .where((entry) => 
              entry.date.isAfter(startDate.subtract(Duration(days: 1))) &&
              entry.date.isBefore(endDate.add(Duration(days: 1))))
          .toList();
      
      return _calculateAttendanceReport(filteredAttendance, startDate, endDate);
    } catch (e) {
      throw Exception('Failed to generate attendance report: $e');
    }
  }
  
  /// Calculate attendance report metrics
  static AttendanceReport _calculateAttendanceReport(
    List<AttendanceEntry> attendance,
    DateTime startDate,
    DateTime endDate,
  ) {
    int totalWorkingDays = _calculateWorkingDays(startDate, endDate);
    int daysPresent = attendance.map((e) => e.date).toSet().length;
    int daysAbsent = totalWorkingDays - daysPresent;
    
    double totalHoursWorked = 0;
    double totalOvertimeHours = 0;
    int lateArrivals = 0;
    int earlyDepartures = 0;
    
    Map<DateTime, List<AttendanceEntry>> dailyEntries = {};
    
    // Group entries by date
    for (var entry in attendance) {
      if (!dailyEntries.containsKey(entry.date)) {
        dailyEntries[entry.date] = [];
      }
      dailyEntries[entry.date]!.add(entry);
    }
    
    // Calculate daily metrics
    for (var date in dailyEntries.keys) {
      var dayEntries = dailyEntries[date]!;
      dayEntries.sort((a, b) => a.checkIn.compareTo(b.checkIn));
      
      // Calculate total worked hours for the day
      double dayHours = 0;
      for (var entry in dayEntries) {
        if (entry.checkOut != null) {
          double hours = entry.checkOut!.difference(entry.checkIn).inMinutes / 60.0;
          dayHours += hours;
        }
      }
      
      totalHoursWorked += dayHours;
      
      // Check for overtime (assuming 8 hours standard)
      if (dayHours > 8) {
        totalOvertimeHours += (dayHours - 8);
      }
      
      // Check for late arrivals (assuming 9:00 AM standard)
      var firstEntry = dayEntries.first;
      if (firstEntry.checkIn.hour > 9 || 
          (firstEntry.checkIn.hour == 9 && firstEntry.checkIn.minute > 0)) {
        lateArrivals++;
      }
      
      // Check for early departures (assuming 5:00 PM standard)
      var lastEntry = dayEntries.last;
      if (lastEntry.checkOut != null) {
        if (lastEntry.checkOut!.hour < 17) {
          earlyDepartures++;
        }
      }
    }
    
    double averageHoursPerDay = daysPresent > 0 ? totalHoursWorked / daysPresent : 0;
    double attendancePercentage = totalWorkingDays > 0 
        ? (daysPresent / totalWorkingDays) * 100 
        : 0;
    
    return AttendanceReport(
      startDate: startDate,
      endDate: endDate,
      totalWorkingDays: totalWorkingDays,
      daysPresent: daysPresent,
      daysAbsent: daysAbsent,
      attendancePercentage: attendancePercentage,
      totalHoursWorked: totalHoursWorked,
      averageHoursPerDay: averageHoursPerDay,
      totalOvertimeHours: totalOvertimeHours,
      lateArrivals: lateArrivals,
      earlyDepartures: earlyDepartures,
      dailyAttendance: dailyEntries,
    );
  }
  
  /// Generate leave report
  static Future<LeaveReport> generateLeaveReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      List<LeaveApplication> leaveHistory = await LeaveService.getLeaveHistory();
      List<LeaveApplication> pendingLeaves = await LeaveService.getPendingLeaves();
      
      // Filter leaves for the specified period
      List<LeaveApplication> filteredHistory = leaveHistory
          .where((leave) => 
              leave.startDate.isAfter(startDate.subtract(Duration(days: 1))) &&
              leave.startDate.isBefore(endDate.add(Duration(days: 1))))
          .toList();
      
      List<LeaveApplication> filteredPending = pendingLeaves
          .where((leave) => 
              leave.startDate.isAfter(startDate.subtract(Duration(days: 1))) &&
              leave.startDate.isBefore(endDate.add(Duration(days: 1))))
          .toList();
      
      return _calculateLeaveReport(filteredHistory, filteredPending, startDate, endDate);
    } catch (e) {
      throw Exception('Failed to generate leave report: $e');
    }
  }
  
  /// Calculate leave report metrics
  static LeaveReport _calculateLeaveReport(
    List<LeaveApplication> history,
    List<LeaveApplication> pending,
    DateTime startDate,
    DateTime endDate,
  ) {
    int totalApplications = history.length + pending.length;
    int approvedApplications = history.where((l) => l.status == LeaveStatus.approved).length;
    int rejectedApplications = history.where((l) => l.status == LeaveStatus.rejected).length;
    int pendingApplications = pending.length;
    
    Map<String, int> leaveTypeCount = {};
    Map<String, double> leaveTypeDays = {};
    double totalLeaveDays = 0;
    
    // Process approved leaves
    for (var leave in history.where((l) => l.status == LeaveStatus.approved)) {
      String leaveType = leave.leaveType.name;
      leaveTypeCount[leaveType] = (leaveTypeCount[leaveType] ?? 0) + 1;
      leaveTypeDays[leaveType] = (leaveTypeDays[leaveType] ?? 0) + leave.totalDays;
      totalLeaveDays += leave.totalDays;
    }
    
    return LeaveReport(
      startDate: startDate,
      endDate: endDate,
      totalApplications: totalApplications,
      approvedApplications: approvedApplications,
      rejectedApplications: rejectedApplications,
      pendingApplications: pendingApplications,
      totalLeaveDays: totalLeaveDays,
      leaveTypeBreakdown: leaveTypeCount,
      leaveTypeDays: leaveTypeDays,
      approvalRate: totalApplications > 0 
          ? (approvedApplications / totalApplications) * 100 
          : 0,
    );
  }
  
  /// Generate productivity report
  static Future<ProductivityReport> generateProductivityReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      AttendanceReport attendanceReport = await generateAttendanceReport(
        startDate: startDate,
        endDate: endDate,
      );
      
      LeaveReport leaveReport = await generateLeaveReport(
        startDate: startDate,
        endDate: endDate,
      );
      
      return _calculateProductivityReport(attendanceReport, leaveReport);
    } catch (e) {
      throw Exception('Failed to generate productivity report: $e');
    }
  }
  
  /// Calculate productivity metrics
  static ProductivityReport _calculateProductivityReport(
    AttendanceReport attendanceReport,
    LeaveReport leaveReport,
  ) {
    double productivityScore = 0;
    List<String> insights = [];
    
    // Calculate productivity score based on various factors
    double attendanceWeight = 0.4;
    double punctualityWeight = 0.3;
    double overtimeWeight = 0.2;
    double leaveBalanceWeight = 0.1;
    
    // Attendance score
    double attendanceScore = attendanceReport.attendancePercentage;
    
    // Punctuality score (based on late arrivals)
    double punctualityScore = attendanceReport.daysPresent > 0
        ? ((attendanceReport.daysPresent - attendanceReport.lateArrivals) / 
           attendanceReport.daysPresent) * 100
        : 100;
    
    // Overtime score (moderate overtime is good, excessive is concerning)
    double overtimeScore = 100;
    if (attendanceReport.totalOvertimeHours > 0) {
      double avgOvertimePerDay = attendanceReport.totalOvertimeHours / 
          attendanceReport.daysPresent;
      if (avgOvertimePerDay > 2) {
        overtimeScore = 70; // Excessive overtime
      } else if (avgOvertimePerDay > 1) {
        overtimeScore = 85; // Moderate overtime
      } else {
        overtimeScore = 95; // Minimal overtime
      }
    }
    
    // Leave balance score (reasonable leave usage)
    double leaveScore = 90; // Default good score
    if (leaveReport.totalLeaveDays > 10) {
      leaveScore = 75; // High leave usage
    }
    
    productivityScore = (attendanceScore * attendanceWeight) +
                       (punctualityScore * punctualityWeight) +
                       (overtimeScore * overtimeWeight) +
                       (leaveScore * leaveBalanceWeight);
    
    // Generate insights
    if (attendanceReport.attendancePercentage >= 95) {
      insights.add('Excellent attendance record');
    } else if (attendanceReport.attendancePercentage >= 85) {
      insights.add('Good attendance record');
    } else {
      insights.add('Attendance needs improvement');
    }
    
    if (attendanceReport.lateArrivals <= 2) {
      insights.add('Punctual arrival times');
    } else {
      insights.add('Consider improving punctuality');
    }
    
    if (attendanceReport.totalOvertimeHours > 20) {
      insights.add('High overtime hours - consider workload balance');
    }
    
    return ProductivityReport(
      startDate: attendanceReport.startDate,
      endDate: attendanceReport.endDate,
      productivityScore: productivityScore,
      insights: insights,
      attendanceScore: attendanceScore,
      punctualityScore: punctualityScore,
      overtimeEfficiency: overtimeScore,
    );
  }
  
  /// Get dashboard summary
  static Future<DashboardSummary> getDashboardSummary() async {
    try {
      DateTime now = DateTime.now();
      
      // Get current user data
      Map<String, dynamic> userData = await ApiService.fetchWorkMeterData();
      String todayHours = '${userData['work_hour'] ?? '0'}h ${userData['work_minute'] ?? '0'}m';
      String weeklyHours = '${userData['week_hour'] ?? '0'}h ${userData['week_minute'] ?? '0'}m';
      String inOutStatus = userData['in_out'] ?? 'O';
      
      // Get leave statistics
      LeaveStatistics leaveStats = await LeaveService.getLeaveStatistics();
      
      // Calculate monthly attendance rate (mock calculation)
      double monthlyAttendanceRate = 85.5; // This would be calculated from actual data
      
      List<String> insights = [
        'Good work-life balance this week',
        'Consistent attendance pattern',
        'Consider taking planned breaks'
      ];
      
      return DashboardSummary(
        currentDate: now,
        todayWorkHours: todayHours,
        weeklyWorkHours: weeklyHours,
        monthlyAttendanceRate: monthlyAttendanceRate,
        isCheckedIn: inOutStatus == 'I',
        pendingLeaves: leaveStats.pendingApplications,
        productivityScore: _calculateProductivityScore(userData),
        insights: insights,
      );
    } catch (e) {
      throw Exception('Failed to get dashboard summary: $e');
    }
  }
  
  /// Calculate working days between two dates (excluding weekends)
  static int _calculateWorkingDays(DateTime startDate, DateTime endDate) {
    int workingDays = 0;
    DateTime currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      if (currentDate.weekday != DateTime.saturday && 
          currentDate.weekday != DateTime.sunday) {
        workingDays++;
      }
      currentDate = currentDate.add(Duration(days: 1));
    }
    
    return workingDays;
  }
  
  /// Export report to JSON
  static Future<String> exportReportToJson(dynamic report) async {
    try {
      return json.encode(report.toJson());
    } catch (e) {
      throw Exception('Failed to export report: $e');
    }
  }
  
  /// Cache report data
  static Future<void> cacheReportData(String reportKey, dynamic reportData) async {
    final prefs = await SharedPreferences.getInstance();
    String cacheKey = '${_reportCacheKey}_$reportKey';
    await prefs.setString(cacheKey, json.encode({
      'data': reportData.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    }));
  }
  
  /// Get cached report data
  static Future<T?> getCachedReportData<T>(String reportKey, T Function(Map<String, dynamic>) fromJson) async {
    final prefs = await SharedPreferences.getInstance();
    String cacheKey = '${_reportCacheKey}_$reportKey';
    String? cachedData = prefs.getString(cacheKey);
    
    if (cachedData != null) {
      Map<String, dynamic> cache = json.decode(cachedData);
      DateTime timestamp = DateTime.parse(cache['timestamp']);
      
      // Check if cache is still valid (1 hour)
      if (DateTime.now().difference(timestamp).inHours < 1) {
        return fromJson(cache['data']);
      }
    }
    
    return null;
  }
  
  /// Generate weekly summary
  static Future<WeeklySummary> getWeeklySummary() async {
    try {
      Map<String, dynamic> userData = await ApiService.fetchWorkMeterData();
      
      // Mock weekly data - in real implementation, this would come from API
      List<DailyWorkSummary> dailySummaries = [
        DailyWorkSummary(
          date: DateTime.now().subtract(Duration(days: 6)),
          hoursWorked: 8.5,
          isPresent: true,
          checkInTime: '09:00',
          checkOutTime: '17:30',
        ),
        DailyWorkSummary(
          date: DateTime.now().subtract(Duration(days: 5)),
          hoursWorked: 8.0,
          isPresent: true,
          checkInTime: '09:15',
          checkOutTime: '17:15',
        ),
        DailyWorkSummary(
          date: DateTime.now().subtract(Duration(days: 4)),
          hoursWorked: 7.5,
          isPresent: true,
          checkInTime: '09:30',
          checkOutTime: '17:00',
        ),
        DailyWorkSummary(
          date: DateTime.now().subtract(Duration(days: 3)),
          hoursWorked: 8.2,
          isPresent: true,
          checkInTime: '08:45',
          checkOutTime: '17:05',
        ),
        DailyWorkSummary(
          date: DateTime.now().subtract(Duration(days: 2)),
          hoursWorked: 0.0,
          isPresent: false,
          checkInTime: '',
          checkOutTime: '',
        ),
        DailyWorkSummary(
          date: DateTime.now().subtract(Duration(days: 1)),
          hoursWorked: 8.8,
          isPresent: true,
          checkInTime: '08:30',
          checkOutTime: '17:20',
        ),
        DailyWorkSummary(
          date: DateTime.now(),
          hoursWorked: double.tryParse(userData['work_hour']?.toString() ?? '0') ?? 0,
          isPresent: true,
          checkInTime: '09:00',
          checkOutTime: userData['in_out'] == 'O' ? '17:00' : '',
        ),
      ];
      
      double totalHours = dailySummaries.fold(0, (sum, day) => sum + day.hoursWorked);
      int daysPresent = dailySummaries.where((day) => day.isPresent).length;
      
      return WeeklySummary(
        startDate: DateTime.now().subtract(Duration(days: 6)),
        endDate: DateTime.now(),
        dailySummaries: dailySummaries,
        totalHours: totalHours,
        averageHours: daysPresent > 0 ? totalHours / daysPresent : 0,
        daysPresent: daysPresent,
        attendanceRate: (daysPresent / 7) * 100,
      );
    } catch (e) {
      throw Exception('Failed to get weekly summary: $e');
    }
  }
  
  /// Calculate productivity score
  static double _calculateProductivityScore(Map<String, dynamic> userData) {
    try {
      double workHours = double.tryParse(userData['work_hour']?.toString() ?? '0') ?? 0;
      double workMinutes = double.tryParse(userData['work_minute']?.toString() ?? '0') ?? 0;
      
      double totalHours = workHours + (workMinutes / 60);
      
      // Base score calculation (8 hours = 100%)
      double score = (totalHours / 8) * 100;
      
      // Cap at 100 and ensure minimum of 0
      return (score > 100) ? 100 : (score < 0) ? 0 : score;
    } catch (e) {
      return 75.0; // Default score
    }
  }
  
  /// Generate attendance report for chart display
  static Future<AttendanceChartData> getAttendanceChartData({
    required int days,
  }) async {
    try {
      Map<String, dynamic> userData = await ApiService.fetchWorkMeterData();
      List<dynamic> attendanceData = userData['attendance'] ?? [];
      
      List<AttendancePoint> points = [];
      DateTime now = DateTime.now();
      
      for (int i = days - 1; i >= 0; i--) {
        DateTime date = now.subtract(Duration(days: i));
        
        // Find attendance for this date
        var dayAttendance = attendanceData.where((entry) {
          try {
            DateTime entryDate = DateTime.parse(entry['date']);
            return entryDate.day == date.day && 
                   entryDate.month == date.month && 
                   entryDate.year == date.year;
          } catch (e) {
            return false;
          }
        }).toList();
        
        double hoursWorked = 0;
        if (dayAttendance.isNotEmpty) {
          for (var entry in dayAttendance) {
            if (entry['worked_time'] != null && 
                entry['worked_time'].toString().isNotEmpty) {
              double seconds = double.tryParse(entry['worked_time'].toString()) ?? 0;
              hoursWorked += seconds / 3600; // Convert to hours
            }
          }
        }
        
        points.add(AttendancePoint(
          date: date,
          hoursWorked: hoursWorked,
          isPresent: dayAttendance.isNotEmpty,
        ));
      }
      
      return AttendanceChartData(
        points: points,
        averageHours: points.isNotEmpty 
            ? points.map((p) => p.hoursWorked).reduce((a, b) => a + b) / points.length 
            : 0,
        totalDays: days,
        presentDays: points.where((p) => p.isPresent).length,
      );
    } catch (e) {
      throw Exception('Failed to get attendance chart data: $e');
    }
  }
  
  /// Get leave breakdown for chart display
  static Future<LeaveChartData> getLeaveChartData() async {
    try {
      LeaveStatistics stats = await LeaveService.getLeaveStatistics();
      List<LeaveApplication> history = await LeaveService.getLeaveHistory();
      
      Map<String, double> leaveTypeUsage = {};
      Map<String, double> leaveTypeBalance = {
        'Casual Leave': 12.0,
        'Sick Leave': 10.0,
        'Earned Leave': 21.0,
        'Emergency Leave': 5.0,
      };
      
      // Calculate usage by leave type
      for (var leave in history.where((l) => l.status == LeaveStatus.approved)) {
        String leaveType = leave.leaveType.name;
        leaveTypeUsage[leaveType] = (leaveTypeUsage[leaveType] ?? 0) + leave.totalDays;
      }
      
      return LeaveChartData(
        leaveTypeUsage: leaveTypeUsage,
        leaveTypeBalance: leaveTypeBalance,
        totalDaysUsed: stats.totalDaysUsed,
        pendingApplications: stats.pendingApplications,
      );
    } catch (e) {
      throw Exception('Failed to get leave chart data: $e');
    }
  }
}

class AttendanceEntry {
  final DateTime date;
  final DateTime checkIn;
  final DateTime? checkOut;
  final double workedHours;
  
  AttendanceEntry({
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.workedHours,
  });
  
  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    DateTime date = DateTime.parse(json['date']);
    
    // Parse check-in time
    List<String> inTimeParts = json['in'].split(':');
    DateTime checkIn = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(inTimeParts[0]),
      int.parse(inTimeParts[1]),
    );
    
    // Parse check-out time if available
    DateTime? checkOut;
    if (json['out'] != null && json['out'].toString().isNotEmpty) {
      List<String> outTimeParts = json['out'].split(':');
      checkOut = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(outTimeParts[0]),
        int.parse(outTimeParts[1]),
      );
    }
    
    double workedHours = 0;
    if (json['worked_time'] != null && json['worked_time'].toString().isNotEmpty) {
      workedHours = double.parse(json['worked_time']) / 3600; // Convert seconds to hours
    }
    
    return AttendanceEntry(
      date: date,
      checkIn: checkIn,
      checkOut: checkOut,
      workedHours: workedHours,
    );
  }
}

class AttendanceReport {
  final DateTime startDate;
  final DateTime endDate;
  final int totalWorkingDays;
  final int daysPresent;
  final int daysAbsent;
  final double attendancePercentage;
  final double totalHoursWorked;
  final double averageHoursPerDay;
  final double totalOvertimeHours;
  final int lateArrivals;
  final int earlyDepartures;
  final Map<DateTime, List<AttendanceEntry>> dailyAttendance;
  
  AttendanceReport({
    required this.startDate,
    required this.endDate,
    required this.totalWorkingDays,
    required this.daysPresent,
    required this.daysAbsent,
    required this.attendancePercentage,
    required this.totalHoursWorked,
    required this.averageHoursPerDay,
    required this.totalOvertimeHours,
    required this.lateArrivals,
    required this.earlyDepartures,
    required this.dailyAttendance,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalWorkingDays': totalWorkingDays,
      'daysPresent': daysPresent,
      'daysAbsent': daysAbsent,
      'attendancePercentage': attendancePercentage,
      'totalHoursWorked': totalHoursWorked,
      'averageHoursPerDay': averageHoursPerDay,
      'totalOvertimeHours': totalOvertimeHours,
      'lateArrivals': lateArrivals,
      'earlyDepartures': earlyDepartures,
    };
  }
}

class LeaveReport {
  final DateTime startDate;
  final DateTime endDate;
  final int totalApplications;
  final int approvedApplications;
  final int rejectedApplications;
  final int pendingApplications;
  final double totalLeaveDays;
  final Map<String, int> leaveTypeBreakdown;
  final Map<String, double> leaveTypeDays;
  final double approvalRate;
  
  LeaveReport({
    required this.startDate,
    required this.endDate,
    required this.totalApplications,
    required this.approvedApplications,
    required this.rejectedApplications,
    required this.pendingApplications,
    required this.totalLeaveDays,
    required this.leaveTypeBreakdown,
    required this.leaveTypeDays,
    required this.approvalRate,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalApplications': totalApplications,
      'approvedApplications': approvedApplications,
      'rejectedApplications': rejectedApplications,
      'pendingApplications': pendingApplications,
      'totalLeaveDays': totalLeaveDays,
      'leaveTypeBreakdown': leaveTypeBreakdown,
      'leaveTypeDays': leaveTypeDays,
      'approvalRate': approvalRate,
    };
  }
}

class ProductivityReport {
  final DateTime startDate;
  final DateTime endDate;
  final double productivityScore;
  final List<String> insights;
  final double attendanceScore;
  final double punctualityScore;
  final double overtimeEfficiency;
  
  ProductivityReport({
    required this.startDate,
    required this.endDate,
    required this.productivityScore,
    required this.insights,
    required this.attendanceScore,
    required this.punctualityScore,
    required this.overtimeEfficiency,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'productivityScore': productivityScore,
      'insights': insights,
      'attendanceScore': attendanceScore,
      'punctualityScore': punctualityScore,
      'overtimeEfficiency': overtimeEfficiency,
    };
  }
}

class DashboardSummary {
  final DateTime currentDate;
  final String todayWorkHours;
  final String weeklyWorkHours;
  final double monthlyAttendanceRate;
  final bool isCheckedIn;
  final int pendingLeaves;
  final double productivityScore;
  final List<String> insights;
  
  DashboardSummary({
    required this.currentDate,
    required this.todayWorkHours,
    required this.weeklyWorkHours,
    required this.monthlyAttendanceRate,
    required this.isCheckedIn,
    required this.pendingLeaves,
    required this.productivityScore,
    required this.insights,
  });
}

class AttendancePoint {
  final DateTime date;
  final double hoursWorked;
  final bool isPresent;
  
  AttendancePoint({
    required this.date,
    required this.hoursWorked,
    required this.isPresent,
  });
}

class AttendanceChartData {
  final List<AttendancePoint> points;
  final double averageHours;
  final int totalDays;
  final int presentDays;
  
  AttendanceChartData({
    required this.points,
    required this.averageHours,
    required this.totalDays,
    required this.presentDays,
  });
}

class LeaveChartData {
  final Map<String, double> leaveTypeUsage;
  final Map<String, double> leaveTypeBalance;
  final double totalDaysUsed;
  final int pendingApplications;
  
  LeaveChartData({
    required this.leaveTypeUsage,
    required this.leaveTypeBalance,
    required this.totalDaysUsed,
    required this.pendingApplications,
  });
}

class DailyWorkSummary {
  final DateTime date;
  final double hoursWorked;
  final bool isPresent;
  final String checkInTime;
  final String checkOutTime;
  
  DailyWorkSummary({
    required this.date,
    required this.hoursWorked,
    required this.isPresent,
    required this.checkInTime,
    required this.checkOutTime,
  });
}

class WeeklySummary {
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyWorkSummary> dailySummaries;
  final double totalHours;
  final double averageHours;
  final int daysPresent;
  final double attendanceRate;
  
  WeeklySummary({
    required this.startDate,
    required this.endDate,
    required this.dailySummaries,
    required this.totalHours,
    required this.averageHours,
    required this.daysPresent,
    required this.attendanceRate,
  });
} 