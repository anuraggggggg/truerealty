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
          text(const ['departmentName', 'teamName']),
      employmentType: text(const [
        'employmentType',
        'employmentStatus',
        'status',
      ]),
      basicSalary: _number(
        json['basicSalary'] ?? json['monthlyBasic'] ?? json['salary'],
      ),
      reportingManager:
          _value(reporting, const ['fullName', 'name']) ??
          text(const ['reportingManagerName', 'teamLeaderName']),
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
    required this.isGenerated,
    required this.isLate,
    required this.lateMinutes,
    required this.derivedStatusReason,
  });

  final DateTime date;
  final String status;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final String? note;
  final String? shiftName;
  final int? shiftStartMinutes;
  final int? shiftEndMinutes;
  final bool isGenerated;
  final bool isLate;
  final int lateMinutes;
  final String? derivedStatusReason;

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
      isGenerated: json['isGenerated'] == true,
      isLate: json['isLate'] == true,
      lateMinutes: _integer(json['lateMinutes']) ?? 0,
      derivedStatusReason: json['derivedStatusReason']?.toString(),
    );
  }

  static List<ProfileAttendanceRecord> listFrom(Object? data) {
    Object? source = data;
    for (var depth = 0; depth < 4 && source is Map; depth++) {
      final map = Map<String, dynamic>.from(source);
      final nested =
          map['data'] ?? map['items'] ?? map['attendance'] ?? map['records'];
      if (nested == null || identical(nested, source)) break;
      source = nested;
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
