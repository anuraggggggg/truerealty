class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.imageUrl,
    required this.phone,
    required this.address,
    required this.employeeCode,
    required this.joinDate,
    required this.department,
    required this.employmentType,
    required this.basicSalary,
    required this.reportingManager,
    required this.officeLocation,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? imageUrl;
  final String? phone;
  final String? address;
  final String? employeeCode;
  final DateTime? joinDate;
  final String? department;
  final String? employmentType;
  final num? basicSalary;
  final String? reportingManager;
  final String? officeLocation;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final user = _map(json['user']);
    final department = _map(json['department']);
    final reporting = _map(
      json['reportingManager'] ?? json['reportingTo'] ?? json['manager'],
    );

    String? text(List<String> keys) {
      for (final key in keys) {
        final value = json[key] ?? user[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return null;
    }

    return UserProfileModel(
      id: text(const ['id', 'employeeId']) ?? '',
      name: text(const ['fullName', 'name']) ?? 'Employee',
      email: text(const ['email', 'workEmail']) ?? '',
      role: text(const ['role', 'designation']) ?? 'Employee',
      imageUrl: text(const ['image', 'imageUrl', 'avatar']),
      phone: text(const ['phone', 'mobile', 'phoneNumber']),
      address: text(const ['address']),
      employeeCode: text(const ['employeeCode', 'code']),
      joinDate: _date(
        json['joinDate'] ??
            json['dateOfJoining'] ??
            json['joiningDate'] ??
            json['createdAt'],
      ),
      department:
          _value(department, const ['name', 'departmentName']) ??
          text(const ['departmentName']),
      employmentType: text(const ['employmentType', 'status']),
      basicSalary: _number(json['basicSalary'] ?? json['salary']),
      reportingManager:
          _value(reporting, const ['fullName', 'name']) ??
          text(const ['reportingManagerName']),
      officeLocation: text(const [
        'officeLocation',
        'location',
        'workLocation',
      ]),
    );
  }
}

class ProfileAttendanceRecord {
  const ProfileAttendanceRecord({
    required this.date,
    required this.status,
    required this.checkInAt,
    required this.checkOutAt,
    required this.note,
    required this.shiftName,
    required this.shiftStartMinutes,
    required this.shiftEndMinutes,
  });

  final DateTime date;
  final String status;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final String? note;
  final String? shiftName;
  final int? shiftStartMinutes;
  final int? shiftEndMinutes;

  factory ProfileAttendanceRecord.fromJson(Map<String, dynamic> json) {
    final shift = _map(json['shift']);
    return ProfileAttendanceRecord(
      date: _date(json['attendanceDate']) ?? DateTime.now(),
      status: json['status']?.toString() ?? 'Not Checked In',
      checkInAt: _date(json['checkInAt']),
      checkOutAt: _date(json['checkOutAt']),
      note: json['note']?.toString(),
      shiftName: shift['name']?.toString(),
      shiftStartMinutes: _integer(shift['startTimeMinutes']),
      shiftEndMinutes: _integer(shift['endTimeMinutes']),
    );
  }

  static List<ProfileAttendanceRecord> listFrom(Object? data) {
    Object? source = data;
    if (source is Map) {
      source =
          source['data'] ??
          source['items'] ??
          source['attendance'] ??
          source['records'];
    }
    if (source is! List) return const [];
    return source
        .whereType<Map>()
        .map(
          (item) =>
              ProfileAttendanceRecord.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}

Map<String, dynamic> _map(Object? value) {
  return value is Map ? Map<String, dynamic>.from(value) : const {};
}

String? _value(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return null;
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

num? _number(Object? value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '');
}

int? _integer(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}
