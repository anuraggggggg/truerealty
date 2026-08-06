class CommissionReport {
  const CommissionReport({
    required this.meta,
    required this.summary,
    required this.target,
    required this.rows,
  });

  final CommissionMeta meta;
  final CommissionSummary summary;
  final CommissionTarget target;
  final List<CommissionEntry> rows;

  factory CommissionReport.fromJson(Map<String, dynamic> json) {
    final rows = json['rows'] is List ? json['rows'] as List : const [];
    return CommissionReport(
      meta: CommissionMeta.fromJson(_map(json['meta'])),
      summary: CommissionSummary.fromJson(_map(json['summary'])),
      target: CommissionTarget.fromJson(_map(json['target'])),
      rows: rows
          .whereType<Map>()
          .map(
            (row) => CommissionEntry.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList(growable: false),
    );
  }
}

class CommissionMeta {
  const CommissionMeta({
    required this.preset,
    required this.scope,
    required this.canViewTeam,
    required this.page,
    required this.limit,
    required this.totalRows,
  });
  final String preset;
  final String scope;
  final bool canViewTeam;
  final int page;
  final int limit;
  final int totalRows;

  factory CommissionMeta.fromJson(Map<String, dynamic> json) => CommissionMeta(
    preset: _string(json['preset'], 'this_month'),
    scope: _string(json['scope'], 'mine'),
    canViewTeam: json['canViewTeam'] == true,
    page: _integer(json['page'], 1),
    limit: _integer(json['limit'], 10),
    totalRows: _integer(json['totalRows']),
  );
}

class CommissionSummary {
  const CommissionSummary({
    required this.totalCommission,
    required this.paidCommission,
    required this.pendingCommission,
    required this.achievedBrokerage,
    required this.justificationTarget,
    required this.commissionableBrokerage,
  });
  final double totalCommission;
  final double paidCommission;
  final double pendingCommission;
  final double achievedBrokerage;
  final double justificationTarget;
  final double commissionableBrokerage;

  factory CommissionSummary.fromJson(Map<String, dynamic> json) =>
      CommissionSummary(
        totalCommission: _number(json['totalCommission']),
        paidCommission: _number(json['paidCommission']),
        pendingCommission: _number(json['pendingCommission']),
        achievedBrokerage: _number(json['achievedBrokerage']),
        justificationTarget: _number(json['justificationTarget']),
        commissionableBrokerage: _number(json['commissionableBrokerage']),
      );
}

class CommissionTarget {
  const CommissionTarget({
    required this.targetValue,
    required this.achievedTarget,
    required this.pendingTarget,
  });
  final double targetValue;
  final double achievedTarget;
  final double pendingTarget;

  factory CommissionTarget.fromJson(Map<String, dynamic> json) =>
      CommissionTarget(
        targetValue: _number(json['targetValue']),
        achievedTarget: _number(json['achievedTarget']),
        pendingTarget: _number(json['pendingTarget']),
      );
}

class CommissionEntry {
  const CommissionEntry({
    required this.id,
    required this.bookingDate,
    required this.customerName,
    required this.projectName,
    required this.recipientName,
    required this.roleType,
    required this.percentage,
    required this.amount,
    required this.brokerageAmount,
    required this.commissionableBrokerage,
    required this.paymentStatus,
    required this.kind,
    this.paymentDate,
  });
  final String id;
  final DateTime? bookingDate;
  final String customerName;
  final String projectName;
  final String recipientName;
  final String roleType;
  final double percentage;
  final double amount;
  final double brokerageAmount;
  final double commissionableBrokerage;
  final String paymentStatus;
  final String kind;
  final DateTime? paymentDate;

  bool get isExtra =>
      kind.toUpperCase() == 'EXTRA' || roleType.toUpperCase() == 'EXTRA';
  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  factory CommissionEntry.fromJson(Map<String, dynamic> json) =>
      CommissionEntry(
        id: _string(json['id']),
        bookingDate: DateTime.tryParse(_string(json['bookingDate'])),
        customerName: _string(json['customerName'], 'Customer'),
        projectName: _string(json['projectName'], 'Project not specified'),
        recipientName: _string(json['recipientName'], '—'),
        roleType: _string(json['roleType'], 'SALES'),
        percentage: _number(json['percentage']),
        amount: _number(json['amount']),
        brokerageAmount: _number(json['brokerageAmount']),
        commissionableBrokerage: _number(json['commissionableBrokerage']),
        paymentStatus: _string(json['paymentStatus'], 'Pending'),
        paymentDate: DateTime.tryParse(_string(json['paymentDate'])),
        kind: _string(json['kind'], 'BASE'),
      );
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};
String _string(dynamic value, [String fallback = '']) =>
    value == null || value.toString() == 'null' ? fallback : value.toString();
double _number(dynamic value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;
int _integer(dynamic value, [int fallback = 0]) => value is num
    ? value.toInt()
    : int.tryParse(value?.toString() ?? '') ?? fallback;
