import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/data/models/booking_model.dart';
import 'package:truerealtycrm/provider/booking_provider.dart';
import 'package:truerealtycrm/widget/app_loading.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key, this.initialFinanceTab = false});
  final bool initialFinanceTab;

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _pipelineSearch = TextEditingController();
  final _financeSearch = TextEditingController();
  String _bookingStatus = 'all';
  String _bookingProject = 'all';
  String _preset = 'this_month';
  String _financeStatus = 'all';
  String _paymentStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialFinanceTab ? 1 : 0,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  @override
  void dispose() {
    _tabs.dispose();
    _pipelineSearch.dispose();
    _financeSearch.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final provider = context.read<BookingProvider>();
    await provider.fetchBookings();
    if (!mounted) return;
    await _loadFinance();
  }

  Future<void> _loadFinance({int page = 1}) =>
      context.read<BookingProvider>().fetchFinance(
        preset: _preset,
        search: _financeSearch.text.trim(),
        status: _financeStatus,
        paymentStatus: _paymentStatus,
        page: page,
      );

  List<BookingModel> _visibleBookings(BookingProvider provider) {
    final search = _pipelineSearch.text.trim().toLowerCase();
    return provider.bookings.where((item) {
      final statusMatches = switch (_bookingStatus) {
        'scheduled' => item.isScheduled,
        'confirmed' => item.isConfirmed,
        'cancelled' => item.isCancelled,
        _ => true,
      };
      final projectMatches =
          _bookingProject == 'all' || item.projectId == _bookingProject;
      final haystack = [
        item.leadName,
        item.leadDisplayId,
        item.leadPhone,
        item.projectName,
      ].join(' ').toLowerCase();
      return statusMatches && projectMatches && haystack.contains(search);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF082D57),
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Text(
          'Bookings',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: const Color(0xFFFF650D),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFFBFD0E3),
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Bookings Pipeline'),
            Tab(text: 'Brokerage & Incentives'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [_pipeline(), _finance()],
      ),
    );
  }

  Widget _pipeline() {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        final items = _visibleBookings(provider);
        return RefreshIndicator(
          onRefresh: () => provider.fetchBookings(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 10.h),
                sliver: SliverList.list(
                  children: [
                    _Heading(
                      icon: Icons.business_center_outlined,
                      title: 'Bookings Pipeline',
                      subtitle:
                          'Track reservations, confirmed bookings, and inventory handoff.',
                      onRefresh: provider.isLoading
                          ? null
                          : () => provider.fetchBookings(),
                    ),
                    SizedBox(height: 16.h),
                    _PipelineStats(stats: provider.stats),
                    SizedBox(height: 16.h),
                    _FilterCard(
                      children: [
                        TextField(
                          controller: _pipelineSearch,
                          onChanged: (_) => setState(() {}),
                          decoration: _inputDecoration(
                            'Filter bookings...',
                            Icons.search_rounded,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(
                              child: _Select(
                                value: _bookingStatus,
                                items: const {
                                  'all': 'All bookings',
                                  'scheduled': 'Scheduled',
                                  'confirmed': 'Confirmed',
                                  'cancelled': 'Cancelled',
                                },
                                onChanged: (value) =>
                                    setState(() => _bookingStatus = value),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(child: _projectSelect(provider.bookings)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    if (provider.isLoading && provider.bookings.isEmpty)
                      const AppListSkeleton(itemCount: 4, itemHeight: 220)
                    else if (provider.error != null &&
                        provider.bookings.isEmpty)
                      _StateCard(
                        icon: Icons.cloud_off_outlined,
                        title: 'Could not load bookings',
                        message: provider.error!,
                        onRetry: provider.fetchBookings,
                      )
                    else if (items.isEmpty)
                      const _StateCard(
                        icon: Icons.event_busy_outlined,
                        title: 'No bookings found',
                        message: 'Try changing the current filters.',
                      ),
                  ],
                ),
              ),
              if (!(provider.isLoading && provider.bookings.isEmpty) &&
                  items.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 28.h),
                  sliver: SliverList.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => SizedBox(height: 12.h),
                    itemBuilder: (_, index) => _BookingCard(items[index]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _projectSelect(List<BookingModel> bookings) {
    final projects = <String, String>{'all': 'All projects'};
    for (final item in bookings) {
      if (item.projectId.isNotEmpty) projects[item.projectId] = item.projectName;
    }
    if (!projects.containsKey(_bookingProject)) _bookingProject = 'all';
    return _Select(
      value: _bookingProject,
      items: projects,
      onChanged: (value) => setState(() => _bookingProject = value),
    );
  }

  Widget _finance() {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) => RefreshIndicator(
        onRefresh: _loadFinance,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 28.h),
              sliver: SliverList.list(
                children: [
                  _Heading(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Brokerage & Incentives',
                    subtitle:
                        'Track agreement value, brokerage receivables, incentives, and commission status.',
                    onRefresh: provider.isLoading ? null : _loadFinance,
                  ),
                  SizedBox(height: 16.h),
                  _FilterCard(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _Select(
                              value: _preset,
                              items: const {
                                'this_month': 'This month',
                                'last_month': 'Last month',
                                'this_quarter': 'This quarter',
                                'this_year': 'This year',
                              },
                              onChanged: (value) {
                                setState(() => _preset = value);
                                _loadFinance();
                              },
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _Select(
                              value: _financeStatus,
                              items: const {
                                'all': 'All statuses',
                                'Booked': 'Booked',
                                'Cancelled': 'Cancelled',
                              },
                              onChanged: (value) {
                                setState(() => _financeStatus = value);
                                _loadFinance();
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _financeSearch,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _loadFinance(),
                              decoration: _inputDecoration(
                                'Search report...',
                                Icons.search_rounded,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          SizedBox(
                            width: 128.w,
                            child: _Select(
                              value: _paymentStatus,
                              items: const {
                                'all': 'All payments',
                                'Paid': 'Paid',
                                'Pending': 'Pending',
                              },
                              onChanged: (value) {
                                setState(() => _paymentStatus = value);
                                _loadFinance();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  if (provider.isLoading && provider.financeRows.isEmpty)
                    const AppListSkeleton(itemCount: 5, itemHeight: 120)
                  else if (provider.error != null &&
                      provider.financeRows.isEmpty)
                    _StateCard(
                      icon: Icons.cloud_off_outlined,
                      title: 'Could not load finance report',
                      message: provider.error!,
                      onRetry: _loadFinance,
                    )
                  else ...[
                    _FinanceMetrics(provider.financeSummary),
                    SizedBox(height: 16.h),
                    Text(
                      'Finance report',
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF082D57),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    if (provider.financeRows.isEmpty)
                      const _StateCard(
                        icon: Icons.receipt_long_outlined,
                        title: 'No finance records',
                        message: 'No rows match the selected filters.',
                      )
                    else
                      ...provider.financeRows.map(_FinanceRowCard.new),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRefresh,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRefresh;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: EdgeInsets.all(9.r),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBDD),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: const Color(0xFFFF650D), size: 22.sp),
      ),
      SizedBox(width: 10.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF082D57),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                height: 1.4,
                color: const Color(0xFF5D708A),
              ),
            ),
          ],
        ),
      ),
      IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh_rounded)),
    ],
  );
}

class _PipelineStats extends StatelessWidget {
  const _PipelineStats({required this.stats});
  final BookingStats stats;
  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 10.w,
    mainAxisSpacing: 10.h,
    childAspectRatio: 1.55,
    children: [
      _Metric('Scheduled', '${stats.scheduled}', Icons.event_outlined, Colors.blue),
      _Metric('Confirmed', '${stats.confirmed}', Icons.check_circle_outline, Colors.green),
      _Metric('Cancelled', '${stats.cancelled}', Icons.cancel_outlined, Colors.red),
      _Metric('Confirmed Value', _money(stats.value), Icons.currency_rupee, const Color(0xFFFF650D)),
      _Metric('Total Brokerage', _money(stats.totalBrokerage), Icons.account_balance_wallet_outlined, Colors.teal),
      _Metric('Pending Brokerage', _money(stats.pendingBrokerage), Icons.schedule_rounded, const Color(0xFFFF650D)),
    ],
  );
}

class _FinanceMetrics extends StatelessWidget {
  const _FinanceMetrics(this.summary);
  final FinanceSummary summary;
  @override
  Widget build(BuildContext context) {
    final data = [
      ('Total Bookings', '${summary.bookings}'),
      ('Agreement Value', _money(summary.agreementValue)),
      ('Total Brokerage', _money(summary.totalBrokerage)),
      ('Pending Brokerage', _money(summary.pendingBrokerage)),
      ('Received Brokerage', _money(summary.receivedBrokerage)),
      ('Base Incentive', _money(summary.baseIncentive)),
      ('Extra Incentive', _money(summary.extraIncentive)),
      ('Total Commission', _money(summary.totalCommission)),
      ('Paid Commission', _money(summary.paidCommission)),
      ('Pending Commission', _money(summary.pendingCommission)),
    ];
    return GridView.builder(
      itemCount: data.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (_, i) => _Metric(
        data[i].$1,
        data[i].$2,
        i == 0 ? Icons.business_center_outlined : Icons.currency_rupee,
        Colors.blue,
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(13.r),
    decoration: _cardDecoration(),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(width: 9.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, maxLines: 2, style: _smallStyle()),
              const Spacer(),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF082D57),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _BookingCard extends StatelessWidget {
  const _BookingCard(this.item);
  final BookingModel item;
  @override
  Widget build(BuildContext context) {
    final color = item.isCancelled ? Colors.red : item.isScheduled ? Colors.blue : Colors.green;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.leadName, style: _titleStyle()),
              ),
              _Badge(label: item.isConfirmed ? 'Confirmed' : item.status, color: color),
            ],
          ),
          Text(item.leadDisplayId, style: _smallStyle()),
          SizedBox(height: 12.h),
          _Info(Icons.calendar_today_outlined, 'Booking date', _date(item.bookingDate)),
          _Info(Icons.phone_outlined, 'Mobile', item.leadPhone),
          _Info(Icons.apartment_outlined, 'Project', item.projectName),
          if (item.unitLabel.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 28.w, bottom: 8.h),
              child: Text(item.unitLabel, style: _smallStyle()),
            ),
          const Divider(),
          Row(
            children: [
              Expanded(child: _Amount('Agreement value', item.agreementValue)),
              Expanded(child: _Amount('Total brokerage', item.totalBrokerage)),
            ],
          ),
          if (item.remarks.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text('Remarks', style: _smallStyle()),
            SizedBox(height: 2.h),
            Text(item.remarks, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }
}

class _FinanceRowCard extends StatelessWidget {
  const _FinanceRowCard(this.row);
  final FinanceRow row;
  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 10.h),
    padding: EdgeInsets.all(14.r),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(row.text('name'), style: _titleStyle())),
            _Badge(label: '${row.bookings} booking', color: Colors.blue),
          ],
        ),
        Text(row.text('detail'), style: _smallStyle()),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 18.w,
          runSpacing: 12.h,
          children: [
            _ReportValue('Agreement value', row.number('agreementValue')),
            _ReportValue('Total brokerage', row.number('totalBrokerage')),
            _ReportValue('Received', row.number('receivedBrokerage')),
            _ReportValue('Pending', row.number('pendingBrokerage')),
            _ReportValue('Total commission', row.number('totalCommission')),
            _ReportValue('Paid commission', row.number('paidCommission')),
            _ReportValue('Pending commission', row.number('pendingCommission')),
            _ReportValue('In justification', row.number('commissionInJustification')),
          ],
        ),
        SizedBox(height: 10.h),
        Text('Latest booking: ${_date(row.latestBookingDate)}', style: _smallStyle()),
      ],
    ),
  );
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(12.r),
    decoration: _cardDecoration(),
    child: Column(children: children),
  );
}

class _Select extends StatelessWidget {
  const _Select({required this.value, required this.items, required this.onChanged});
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    decoration: _inputDecoration('', null),
    items: items.entries
        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis)))
        .toList(),
    onChanged: (value) { if (value != null) onChanged(value); },
  );
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.icon, required this.title, required this.message, this.onRetry});
  final IconData icon;
  final String title;
  final String message;
  final Future<void> Function()? onRetry;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(28.r),
    decoration: _cardDecoration(),
    child: Column(children: [
      Icon(icon, size: 38.sp, color: const Color(0xFF8FA2BA)),
      SizedBox(height: 10.h),
      Text(title, style: _titleStyle()),
      SizedBox(height: 5.h),
      Text(message, textAlign: TextAlign.center, style: _smallStyle()),
      if (onRetry != null) ...[
        SizedBox(height: 12.h),
        OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    ]),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
    decoration: BoxDecoration(color: color.withValues(alpha: .09), borderRadius: BorderRadius.circular(20.r), border: Border.all(color: color.withValues(alpha: .3))),
    child: Text(label, style: GoogleFonts.inter(fontSize: 10.5.sp, fontWeight: FontWeight.w700, color: color)),
  );
}

class _Info extends StatelessWidget {
  const _Info(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Row(children: [
      Icon(icon, size: 17.sp, color: const Color(0xFF8FA2BA)),
      SizedBox(width: 10.w),
      SizedBox(width: 90.w, child: Text(label, style: _smallStyle())),
      Expanded(child: Text(value.isEmpty ? '—' : value, style: GoogleFonts.inter(fontSize: 12.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF082D57)))),
    ]),
  );
}

class _Amount extends StatelessWidget {
  const _Amount(this.label, this.value);
  final String label;
  final double value;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: _smallStyle()), SizedBox(height: 3.h), Text(_money(value), style: _titleStyle())]);
}

class _ReportValue extends StatelessWidget {
  const _ReportValue(this.label, this.value);
  final String label;
  final double value;
  @override
  Widget build(BuildContext context) => SizedBox(width: 145.w, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: _smallStyle()), SizedBox(height: 2.h), Text(_money(value), style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF082D57)))]));
}

InputDecoration _inputDecoration(String hint, IconData? icon) => InputDecoration(
  hintText: hint.isEmpty ? null : hint,
  prefixIcon: icon == null ? null : Icon(icon, size: 19),
  filled: true,
  fillColor: Colors.white,
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFD8E2EF))),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFD8E2EF))),
);
BoxDecoration _cardDecoration() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDDE5EF)), boxShadow: const [BoxShadow(color: Color(0x08082D57), blurRadius: 8, offset: Offset(0, 2))]);
TextStyle _titleStyle() => GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF082D57));
TextStyle _smallStyle() => GoogleFonts.inter(fontSize: 10.5.sp, height: 1.35, color: const Color(0xFF5D708A));
String _date(DateTime? date) => date == null ? '—' : '${date.day.toString().padLeft(2, '0')} ${const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][date.month - 1]} ${date.year}';
String _money(double value) {
  final rounded = value.round().toString();
  final out = StringBuffer();
  for (var i = 0; i < rounded.length; i++) {
    final remaining = rounded.length - i;
    out.write(rounded[i]);
    if (remaining > 1 && (remaining == 4 || (remaining > 4 && (remaining - 4) % 2 == 0))) out.write(',');
  }
  return '₹$out';
}
