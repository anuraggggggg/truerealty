class BookingModel {
  const BookingModel({
    required this.id,
    required this.leadId,
    required this.leadDisplayId,
    required this.leadName,
    required this.leadPhone,
    required this.leadSource,
    required this.projectId,
    required this.projectName,
    required this.unitLabel,
    required this.configuration,
    required this.status,
    required this.remarks,
    required this.bookingDate,
    required this.leadCreatedAt,
    required this.agreementValue,
    required this.totalBrokerage,
    required this.receivedBrokerage,
    required this.pendingBrokerage,
  });

  final String id;
  final String leadId;
  final String leadDisplayId;
  final String leadName;
  final String leadPhone;
  final String leadSource;
  final String projectId;
  final String projectName;
  final String unitLabel;
  final String configuration;
  final String status;
  final String remarks;
  final DateTime? bookingDate;
  final DateTime? leadCreatedAt;
  final double agreementValue;
  final double totalBrokerage;
  final double receivedBrokerage;
  final double pendingBrokerage;

  bool get isCancelled => status.toLowerCase().contains('cancel');
  bool get isScheduled => status.toLowerCase().contains('schedule');
  bool get isConfirmed => !isCancelled && !isScheduled;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final brokerage = _map(json['brokerage']);
    return BookingModel(
      id: _text(json['id']),
      leadId: _text(json['leadId']),
      leadDisplayId: _text(json['leadDisplayId']),
      leadName: _text(json['leadName'], 'Unknown customer'),
      leadPhone: _text(json['leadPhone']),
      leadSource: _text(json['leadSource'], 'Unknown'),
      projectId: _text(json['projectId']),
      projectName: _text(json['projectName'], 'Unassigned project'),
      unitLabel: _text(json['unitLabel']),
      configuration: _text(json['configuration']),
      status: _text(json['status'], 'Scheduled'),
      remarks: _text(json['remarks']),
      bookingDate: DateTime.tryParse(_text(json['bookingDate'])),
      leadCreatedAt: DateTime.tryParse(_text(json['leadCreatedAt'])),
      agreementValue: _number(json['agreementValue']),
      totalBrokerage: _number(brokerage['netAmount']),
      receivedBrokerage: _number(brokerage['receivedAmount']),
      pendingBrokerage: _number(brokerage['pendingAmount']),
    );
  }
}

class BookingStats {
  const BookingStats({
    this.total = 0,
    this.scheduled = 0,
    this.confirmed = 0,
    this.cancelled = 0,
    this.value = 0,
    this.totalBrokerage = 0,
    this.receivedBrokerage = 0,
    this.pendingBrokerage = 0,
  });

  final int total;
  final int scheduled;
  final int confirmed;
  final int cancelled;
  final double value;
  final double totalBrokerage;
  final double receivedBrokerage;
  final double pendingBrokerage;

  factory BookingStats.fromJson(Map<String, dynamic> json) => BookingStats(
    total: _integer(json['total']),
    scheduled: _integer(json['scheduled']),
    confirmed: _integer(json['confirmed']),
    cancelled: _integer(json['cancelled']),
    value: _number(json['value']),
    totalBrokerage: _number(json['totalBrokerage']),
    receivedBrokerage: _number(json['receivedBrokerage']),
    pendingBrokerage: _number(json['pendingBrokerage']),
  );
}

class FinanceSummary {
  const FinanceSummary({
    this.bookings = 0,
    this.agreementValue = 0,
    this.totalBrokerage = 0,
    this.receivedBrokerage = 0,
    this.pendingBrokerage = 0,
    this.salesIncentive = 0,
    this.preSalesIncentive = 0,
    this.teamLeaderIncentive = 0,
    this.extraIncentive = 0,
    this.totalCommission = 0,
    this.paidCommission = 0,
    this.pendingCommission = 0,
    this.commissionInJustification = 0,
  });

  final int bookings;
  final double agreementValue;
  final double totalBrokerage;
  final double receivedBrokerage;
  final double pendingBrokerage;
  final double salesIncentive;
  final double preSalesIncentive;
  final double teamLeaderIncentive;
  final double extraIncentive;
  final double totalCommission;
  final double paidCommission;
  final double pendingCommission;
  final double commissionInJustification;

  double get baseIncentive =>
      salesIncentive + preSalesIncentive + teamLeaderIncentive;

  factory FinanceSummary.fromJson(Map<String, dynamic> json) => FinanceSummary(
    bookings: _integer(json['bookings']),
    agreementValue: _number(json['agreementValue']),
    totalBrokerage: _number(json['totalBrokerage']),
    receivedBrokerage: _number(json['receivedBrokerage']),
    pendingBrokerage: _number(json['pendingBrokerage']),
    salesIncentive: _number(json['salesIncentive']),
    preSalesIncentive: _number(json['preSalesIncentive']),
    teamLeaderIncentive: _number(json['teamLeaderIncentive']),
    extraIncentive: _number(json['extraIncentive']),
    totalCommission: _number(json['totalCommission']),
    paidCommission: _number(json['paidCommission']),
    pendingCommission: _number(json['pendingCommission']),
    commissionInJustification: _number(json['commissionInJustification']),
  );
}

class FinanceRow {
  const FinanceRow({required this.raw});
  final Map<String, dynamic> raw;
  String text(String key) => _text(raw[key]);
  double number(String key) => _number(raw[key]);
  int get bookings => _integer(raw['bookings']);
  DateTime? get latestBookingDate =>
      DateTime.tryParse(_text(raw['latestBookingDate']));
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
String _text(Object? value, [String fallback = '']) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty || text == 'null' ? fallback : text;
}
double _number(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
int _integer(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
