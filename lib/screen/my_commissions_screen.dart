import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/data/models/commission_model.dart';
import 'package:truerealtycrm/provider/commission_provider.dart';

class MyCommissionsScreen extends StatefulWidget {
  const MyCommissionsScreen({super.key});

  @override
  State<MyCommissionsScreen> createState() => _MyCommissionsScreenState();
}

class _MyCommissionsScreenState extends State<MyCommissionsScreen> {
  static const _blue = Color(0xFF075BFF);
  static const _navy = Color(0xFF071B3E);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CommissionProvider>();
      if (provider.report == null) provider.fetch();
    });
  }

  Future<void> _choosePeriod() async {
    final provider = context.read<CommissionProvider>();
    final value = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _PeriodTile('This month', 'this_month'),
            _PeriodTile('Last month', 'last_month'),
            _PeriodTile('This quarter', 'this_quarter'),
            _PeriodTile('This year', 'this_year'),
          ],
        ),
      ),
    );
    if (value != null && value != provider.preset) {
      await provider.fetch(preset: value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommissionProvider>();
    final report = provider.report;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FD),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.fetch,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 30.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _Header(onPeriodTap: _choosePeriod),
                    SizedBox(height: 20.h),
                    if (provider.isLoading && report == null)
                      SizedBox(
                        height: 560.h,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else if (provider.error != null && report == null)
                      _ErrorState(
                        message: provider.error!,
                        onRetry: provider.fetch,
                      )
                    else if (report != null) ...[
                      if (report.rows.isNotEmpty)
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text:
                                    'You are viewing commission entries assigned to ',
                              ),
                              TextSpan(
                                text: '${report.rows.first.recipientName}.',
                                style: const TextStyle(
                                  color: _blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: const Color(0xFF506181),
                            height: 1.45,
                          ),
                        ),
                      SizedBox(height: 16.h),
                      _SummaryGrid(summary: report.summary),
                      SizedBox(height: 16.h),
                      _ProgressCard(target: report.target),
                      SizedBox(height: 16.h),
                      _History(report: report),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodTile extends StatelessWidget {
  const _PeriodTile(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.calendar_month_outlined),
    title: Text(label),
    onTap: () => Navigator.pop(context, value),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.onPeriodTap});
  final VoidCallback onPeriodTap;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(
          Icons.arrow_back,
          color: _MyCommissionsScreenState._navy,
        ),
      ),
      SizedBox(width: 8.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Commissions',
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: _MyCommissionsScreenState._navy,
              ),
            ),
            Text(
              'Commission workspace',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: const Color(0xFF596A88),
              ),
            ),
          ],
        ),
      ),
      Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(color: Color(0xFFDDE4EF)),
        ),
        child: IconButton(
          tooltip: 'Select period',
          onPressed: onPeriodTap,
          icon: const Icon(
            Icons.calendar_month_outlined,
            color: _MyCommissionsScreenState._blue,
          ),
        ),
      ),
    ],
  );
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});
  final CommissionSummary summary;
  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        Icons.currency_rupee,
        'Achieved brokerage',
        summary.achievedBrokerage,
        'Confirmed booking brokerage',
      ),
      (
        Icons.track_changes,
        'Justification target',
        summary.justificationTarget,
        'Multiplier or manual target',
      ),
      (
        Icons.calculate_outlined,
        'Commissionable brokerage',
        summary.commissionableBrokerage,
        'Brokerage above target',
      ),
      (
        Icons.currency_rupee,
        'Incentive earned',
        summary.totalCommission,
        'Commissionable brokerage × rate',
      ),
      (
        Icons.account_balance_wallet_outlined,
        'Paid commission',
        summary.paidCommission,
        'Settled through payroll',
      ),
      (
        Icons.schedule,
        'Pending commission',
        summary.pendingCommission,
        'Awaiting payout',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 680
            ? 3
            : constraints.maxWidth >= 390
            ? 2
            : 1;
        final gap = 10.w;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: 10.h,
          children: cards
              .map(
                (card) => SizedBox(
                  width: width,
                  height: 142.h,
                  child: _SummaryCard(
                    icon: card.$1,
                    title: card.$2,
                    value: card.$3,
                    caption: card.$4,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.caption,
  });
  final IconData icon;
  final String title;
  final double value;
  final String caption;
  @override
  Widget build(BuildContext context) => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _IconCircle(icon),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12.5.sp,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF52617D),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _money(value),
              style: GoogleFonts.inter(
                fontSize: 21.sp,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: _MyCommissionsScreenState._navy,
              ),
            ),
          ),
        ),
        SizedBox(height: 5.h),
        Expanded(
          child: Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              height: 1.3,
              color: const Color(0xFF596A88),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.target});
  final CommissionTarget target;
  @override
  Widget build(BuildContext context) {
    final ratio = target.targetValue <= 0
        ? 0.0
        : (target.achievedTarget / target.targetValue).clamp(0.0, 1.0);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Justification progress',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: _MyCommissionsScreenState._navy,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Incentive starts after achieved brokerage crosses the salary justification target.',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: const Color(0xFF596A88),
              height: 1.45,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8.h,
                    backgroundColor: const Color(0xFFE5EAF1),
                    color: const Color(0xFF169650),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                '${(ratio * 100).round()}%',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF169650),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              _TargetValue('Target', _money(target.targetValue)),
              _divider(),
              _TargetValue(
                'Achieved',
                _money(target.achievedTarget),
                color: const Color(0xFF169650),
              ),
              _divider(),
              _TargetValue(
                'Shortfall',
                _money(target.pendingTarget),
                color: const Color(0xFFF05A13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(height: 42.h, width: 1, color: const Color(0xFFDCE2EB));
}

class _TargetValue extends StatelessWidget {
  const _TargetValue(this.label, this.value, {this.color});
  final String label;
  final String value;
  final Color? color;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5.sp,
            color: const Color(0xFF596A88),
          ),
        ),
        SizedBox(height: 5.h),
        FittedBox(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: color ?? _MyCommissionsScreenState._navy,
            ),
          ),
        ),
      ],
    ),
  );
}

class _History extends StatelessWidget {
  const _History({required this.report});
  final CommissionReport report;
  @override
  Widget build(BuildContext context) => _Card(
    padding: EdgeInsets.all(10.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Commission history',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: _MyCommissionsScreenState._navy,
                    ),
                  ),
                  Text(
                    'Customer names identify the booking. The owner receives the commission.',
                    style: GoogleFonts.inter(
                      fontSize: 10.5.sp,
                      height: 1.4,
                      color: const Color(0xFF596A88),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Text(
                'My entries',
                style: GoogleFonts.inter(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                  color: _MyCommissionsScreenState._blue,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        if (report.rows.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 35.h),
            child: const Center(
              child: Text('No commission entries for this period.'),
            ),
          )
        else
          ...report.rows.map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: 9.h),
              child: _EntryCard(entry: entry),
            ),
          ),
      ],
    ),
  );
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});
  final CommissionEntry entry;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(11.w),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE1E7F0)),
      borderRadius: BorderRadius.circular(11.r),
    ),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _IconCircle(Icons.apartment),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.customerName,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _MyCommissionsScreenState._navy,
                    ),
                  ),
                  Text(
                    entry.projectName,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: const Color(0xFF596A88),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '▣  ${_date(entry.bookingDate)}',
                    style: GoogleFonts.inter(
                      fontSize: 10.5.sp,
                      color: const Color(0xFF596A88),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusChip(label: entry.paymentStatus, paid: entry.isPaid),
                if (entry.paymentDate != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      _date(entry.paymentDate),
                      style: GoogleFonts.inter(
                        fontSize: 9.5.sp,
                        color: const Color(0xFF71809B),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        SizedBox(height: 11.h),
        Row(
          children: [
            Expanded(
              child: _LabeledValue(
                'Owner',
                entry.recipientName,
                caption: 'Receives this commission',
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _LabeledValue(
                'Role',
                entry.isExtra ? 'Extra incentive' : _titleCase(entry.roleType),
                chip: true,
                purple: entry.isExtra,
              ),
            ),
          ],
        ),
        Divider(height: 20.h, color: const Color(0xFFDCE2EB)),
        Row(
          children: [
            _MiniValue(
              'Brokerage',
              entry.isExtra ? '—' : _money(entry.brokerageAmount),
            ),
            _MiniValue(
              'Commissionable',
              entry.isExtra ? '—' : _money(entry.commissionableBrokerage),
            ),
            _MiniValue(
              'Rate',
              entry.isExtra ? '—' : '${_trim(entry.percentage)}%',
            ),
            _MiniValue('Incentive', _money(entry.amount), blue: true),
          ],
        ),
      ],
    ),
  );
}

class _LabeledValue extends StatelessWidget {
  const _LabeledValue(
    this.label,
    this.value, {
    this.caption,
    this.chip = false,
    this.purple = false,
  });
  final String label;
  final String value;
  final String? caption;
  final bool chip;
  final bool purple;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9.5.sp,
          color: const Color(0xFF596A88),
        ),
      ),
      SizedBox(height: 2.h),
      if (chip)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: purple ? const Color(0xFFF0E7FF) : const Color(0xFFE8F0FF),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: purple
                  ? const Color(0xFF7C2CE0)
                  : _MyCommissionsScreenState._blue,
            ),
          ),
        )
      else
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w700,
            color: _MyCommissionsScreenState._navy,
          ),
        ),
      if (caption != null)
        Text(
          caption!,
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            color: const Color(0xFF71809B),
          ),
        ),
    ],
  );
}

class _MiniValue extends StatelessWidget {
  const _MiniValue(this.label, this.value, {this.blue = false});
  final String label;
  final String value;
  final bool blue;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFDCE2EB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 8.5.sp,
                color: const Color(0xFF596A88),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          FittedBox(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w700,
                color: blue
                    ? _MyCommissionsScreenState._blue
                    : _MyCommissionsScreenState._navy,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.paid});
  final String label;
  final bool paid;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: paid ? const Color(0xFFE1F4E8) : const Color(0xFFFFEADC),
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
        color: paid ? const Color(0xFF168842) : const Color(0xFFF05A13),
      ),
    ),
  );
}

class _IconCircle extends StatelessWidget {
  const _IconCircle(this.icon);
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    width: 38.w,
    height: 38.w,
    decoration: const BoxDecoration(
      color: Color(0xFFEAF1FF),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: _MyCommissionsScreenState._blue, size: 20.sp),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding ?? EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: const Color(0xFFE0E6EF)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A0A2A60),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 450.h,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: Color(0xFF71809B),
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}

String _money(double value) {
  final digits = value.round().toString();
  if (digits.length <= 3) return '₹$digits';
  final last = digits.substring(digits.length - 3);
  var first = digits.substring(0, digits.length - 3);
  final parts = <String>[];
  while (first.length > 2) {
    parts.insert(0, first.substring(first.length - 2));
    first = first.substring(0, first.length - 2);
  }
  if (first.isNotEmpty) parts.insert(0, first);
  return '₹${parts.join(',')},$last';
}

String _date(DateTime? date) => date == null
    ? '—'
    : '${date.day.toString().padLeft(2, '0')} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1]} ${date.year}';
String _trim(double value) => value == value.roundToDouble()
    ? value.round().toString()
    : value.toStringAsFixed(1);
String _titleCase(String value) => value.isEmpty
    ? value
    : '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
