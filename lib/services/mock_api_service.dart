import 'dart:convert';

class MockApiService {
  static Map<String, dynamic> getMockResponse() {
    return {
      "workedTime": "08:30",
      "workedAsInt": "0830",
      "emp_key": "test_user_123",
      "work_hour": "08",
      "week_hour": "40",
      "updated_at": DateTime.now().toIso8601String(),
      "week_minute": "00",
      "work_minute": "30",
      "leave_status": "CL-2,ML-3,EL-5",
      "emp_name": "John Doe",
      "attendance": [
        {
          "date": "2024-01-15",
          "in_time": "09:00",
          "out_time": "17:30",
          "status": "present"
        }
      ],
      "cl": "2",
      "ml": "3",
      "el": "5",
      "in_out": "IN"
    };
  }

  static Map<String, dynamic> getNoDataResponse() {
    return {
      "workedTime": "NDF",
      "workedAsInt": "0000"
    };
  }
} 