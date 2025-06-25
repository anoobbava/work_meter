import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/leave_service.dart';
import '../services/notification_service.dart';
import '../services/app_theme.dart';

class EnhancedLeaveApplicationPage extends StatefulWidget {
  @override
  _EnhancedLeaveApplicationPageState createState() => _EnhancedLeaveApplicationPageState();
}

class _EnhancedLeaveApplicationPageState extends State<EnhancedLeaveApplicationPage> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  List<LeaveType> _leaveTypes = [];
  LeaveType? _selectedLeaveType;
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  bool _isHalfDay = false;
  String _halfDayType = 'morning';
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadLeaveTypes();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
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
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaveTypes() async {
    try {
      List<LeaveType> types = await LeaveService.getLeaveTypes();
      setState(() {
        _leaveTypes = types;
        if (types.isNotEmpty) {
          _selectedLeaveType = types.first;
        }
      });
    } catch (e) {
      _showErrorDialog('Failed to load leave types: $e');
    }
  }

  double _calculateLeaveDays() {
    if (_isHalfDay) {
      return 0.5;
    }
    
    int days = _selectedEndDate.difference(_selectedStartDate).inDays + 1;
    
    // Exclude weekends
    int workingDays = 0;
    DateTime currentDate = _selectedStartDate;
    
    while (currentDate.isBefore(_selectedEndDate.add(Duration(days: 1)))) {
      if (currentDate.weekday != DateTime.saturday && 
          currentDate.weekday != DateTime.sunday) {
        workingDays++;
      }
      currentDate = currentDate.add(Duration(days: 1));
    }
    
    return workingDays.toDouble();
  }

  Future<void> _submitLeaveApplication() async {
    if (!_formKey.currentState!.validate() || _selectedLeaveType == null) {
      _showErrorDialog('Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      LeaveApplication application = LeaveApplication(
        leaveType: _selectedLeaveType!,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        totalDays: _calculateLeaveDays(),
        reason: _reasonController.text.trim(),
        isHalfDay: _isHalfDay,
        halfDayType: _isHalfDay ? _halfDayType : null,
        appliedDate: DateTime.now(),
      );

      LeaveApplicationResult result = await LeaveService.applyForLeave(application);

      if (result.success) {
        await NotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'Leave Application Submitted',
          body: 'Your ${_selectedLeaveType!.name} application has been submitted.',
          importance: NotificationImportance.high,
        );
        _showSuccessDialog(result.message);
      } else {
        _showErrorDialog(result.message);
      }
    } catch (e) {
      _showErrorDialog('Failed to submit: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Apply for Leave',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Leave Type'),
                _buildLeaveTypeSelector(),
                SizedBox(height: 24),
                
                _buildSectionHeader('Date Selection'),
                _buildDateSelectionCard(),
                SizedBox(height: 24),
                
                if (_selectedLeaveType?.canBeHalfDay == true) ...[
                  _buildSectionHeader('Half Day Option'),
                  _buildHalfDaySelector(),
                  SizedBox(height: 24),
                ],
                
                _buildSectionHeader('Reason'),
                _buildReasonField(),
                SizedBox(height: 24),
                
                _buildSummaryCard(),
                SizedBox(height: 32),
                
                _buildSubmitButton(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildLeaveTypeSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Leave Type',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<LeaveType>(
            value: _selectedLeaveType,
            items: _leaveTypes.map((type) => DropdownMenuItem(
              value: type,
              child: Text(type.name),
            )).toList(),
            onChanged: (value) => setState(() => _selectedLeaveType = value),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectionCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  'Start Date',
                  _selectedStartDate,
                  (date) {
                    setState(() {
                      _selectedStartDate = date;
                      if (_selectedEndDate.isBefore(date)) {
                        _selectedEndDate = date;
                      }
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildDateSelector(
                  'End Date',
                  _selectedEndDate,
                  (date) {
                    setState(() {
                      _selectedEndDate = date;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Total Days: ${_calculateLeaveDays()}',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime selectedDate, Function(DateTime) onDateSelected) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365)),
        );
        
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy').format(selectedDate),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHalfDaySelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            title: Text('Apply for half day'),
            value: _isHalfDay,
            onChanged: (value) => setState(() => _isHalfDay = value ?? false),
          ),
          if (_isHalfDay) ...[
            SizedBox(height: 12),
            RadioListTile<String>(
              title: Text('Morning'),
              value: 'morning',
              groupValue: _halfDayType,
              onChanged: (value) => setState(() => _halfDayType = value!),
            ),
            RadioListTile<String>(
              title: Text('Afternoon'),
              value: 'afternoon',
              groupValue: _halfDayType,
              onChanged: (value) => setState(() => _halfDayType = value!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReasonField() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: _reasonController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Please provide a reason for your leave request',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please provide a reason for your leave';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 12),
          _buildSummaryRow('Leave Type', _selectedLeaveType?.name ?? 'Not selected'),
          _buildSummaryRow('Start Date', DateFormat('MMM dd, yyyy').format(_selectedStartDate)),
          _buildSummaryRow('End Date', DateFormat('MMM dd, yyyy').format(_selectedEndDate)),
          _buildSummaryRow('Total Days', '${_calculateLeaveDays()} days'),
          if (_isHalfDay)
            _buildSummaryRow('Half Day', '${_halfDayType.capitalize()} half'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitLeaveApplication,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Text(
                'Submit Application',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
} 