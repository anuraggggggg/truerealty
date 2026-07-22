import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/dashboard_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue10,
            blurRadius: 18.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: ListView(
        children: [
          const _ReportHeader(),
          SizedBox(height: 24.h),
          const _SummaryMetrics(),
          SizedBox(height: 24.h),
          const _LeadSourceChart(),
          SizedBox(height: 24.h),
          const _RevenueReport(),
          SizedBox(height: 24.h),
          const _AgentPerformance(),
        ],
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Reports Overview',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 12.w),
        PopupMenuButton<String>(
          onSelected: (period) => context.read<DashboardProvider>().setPeriod(period),
          initialValue: context.read<DashboardProvider>().selectedPeriod,
          itemBuilder: (context) => DashboardProvider.periods
              .map((p) => PopupMenuItem(value: p, child: Text(p, style: TextStyle(fontSize: 14.sp))))
              .toList(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_outlined, size: 16.sp, color: AppColors.vividBlue),
                SizedBox(width: 8.w),
                Text(
                  context.watch<DashboardProvider>().selectedPeriod,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, size: 18.sp, color: AppColors.navy),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryMetrics extends StatelessWidget {
  const _SummaryMetrics();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _MetricItem(
            label: 'Avg. Response',
            value: '14 mins',
            icon: Icons.timer_outlined,
            color: AppColors.vividBlue,
            bg: AppColors.white,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _MetricItem(
            label: 'Conversion Rate',
            value: '3.4%',
            icon: Icons.trending_up,
            color: AppColors.green,
            bg: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              const Icon(Icons.info_outline, color: AppColors.border, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.mutedNavy,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadSourceChart extends StatelessWidget {
  const _LeadSourceChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leads by Source',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: CustomPaint(
                  painter: _DonutChartPainter(),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: const [
                    _ChartLegendItem(label: 'Social Media', value: '45%', color: AppColors.vividBlue),
                    _ChartLegendItem(label: 'Referrals', value: '25%', color: AppColors.orange),
                    _ChartLegendItem(label: 'Walk-ins', value: '20%', color: AppColors.green),
                    _ChartLegendItem(label: 'Website', value: '10%', color: AppColors.purple),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartLegendItem extends StatelessWidget {
  const _ChartLegendItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.mutedNavy,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 20.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paints = [
      Paint()
        ..color = AppColors.vividBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
      Paint()
        ..color = AppColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
      Paint()
        ..color = AppColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
      Paint()
        ..color = AppColors.purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    ];

    double startAngle = -1.57; // Start from top
    final angles = [
      6.28 * 0.45, // 45%
      6.28 * 0.25, // 25%
      6.28 * 0.20, // 20%
      6.28 * 0.10, // 10%
    ];

    for (int i = 0; i < angles.length; i++) {
      canvas.drawArc(rect, startAngle, angles[i], false, paints[i]);
      startAngle += angles[i];
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RevenueReport extends StatelessWidget {
  const _RevenueReport();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Revenue Growth',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Icon(Icons.more_horiz, color: AppColors.mutedNavy),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              _BarItem(heightFactor: 0.4, label: 'Jan'),
              _BarItem(heightFactor: 0.6, label: 'Feb'),
              _BarItem(heightFactor: 0.5, label: 'Mar'),
              _BarItem(heightFactor: 0.8, label: 'Apr'),
              _BarItem(heightFactor: 0.7, label: 'May'),
              _BarItem(heightFactor: 0.9, label: 'Jun', isHighlighted: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.heightFactor,
    required this.label,
    this.isHighlighted = false,
  });

  final double heightFactor;
  final String label;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 120 * heightFactor,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: isHighlighted ? AppColors.orange : AppColors.softBlue,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isHighlighted ? AppColors.navy : AppColors.mutedNavy,
              fontSize: 11,
              fontWeight: isHighlighted ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentPerformance extends StatelessWidget {
  const _AgentPerformance();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Performing Agents',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          const _AgentRow(name: 'Sarah Connor', leads: '84', conversion: '12%', color: AppColors.vividBlue),
          const _AgentRow(name: 'James Bond', leads: '72', conversion: '10%', color: AppColors.orange),
          const _AgentRow(name: 'Ethan Hunt', leads: '65', conversion: '8%', color: AppColors.green),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'View All Rankings',
                style: TextStyle(
                  color: AppColors.vividBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentRow extends StatelessWidget {
  const _AgentRow({
    required this.name,
    required this.leads,
    required this.conversion,
    required this.color,
  });

  final String name;
  final String leads;
  final String conversion;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withAlpha(26),
            child: Text(
              name[0],
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$leads Leads Assigned',
                  style: const TextStyle(
                    color: AppColors.mutedNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.greenBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              conversion,
              style: const TextStyle(
                color: AppColors.green,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.border),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadowBlue10,
        blurRadius: 18,
        offset: Offset(0, 8),
      ),
    ],
  );
}
