import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/constant/screen_utils.dart';

class AssignLeadsScreen extends StatelessWidget {
  const AssignLeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AssignHeaderArt(),
              Transform.translate(
                offset: Offset(0, -48.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 28.h),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _AssignHeader(),
                      SizedBox(height: 18.h),
                      const _MetricStrip(),
                      SizedBox(height: 18.h),
                      const _AssignmentTabs(),
                      SizedBox(height: 16.h),
                      const _SelectLeadsCard(),
                      SizedBox(height: 16.h),
                      const _AssignToCard(),
                      SizedBox(height: 16.h),
                      const _AssignmentOptionsCard(),
                      SizedBox(height: 16.h),
                      const _AiRecommendationCard(),
                      SizedBox(height: 18.h),
                      const _BottomActions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignHeaderArt extends StatelessWidget {
  const _AssignHeaderArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340.h,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Image.asset(
              'assets/top_heades.png',
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),
          Positioned(
            left: 16.w,
            top: 22.h,
            child: CommonWidgets.backButton(context),
          ),
        ],
      ),
    );
  }
}

class _AssignHeader extends StatelessWidget {
  const _AssignHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assign Leads',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 27,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Assign leads manually or use AI auto-assignment.',
          style: TextStyle(
            color: AppColors.mutedNavy,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const [
          _MetricTile(
            icon: Icons.assignment_outlined,
            label: 'Unassigned',
            value: '156',
            detail: 'Requires assignment',
            color: AppColors.vividBlue,
            bg: AppColors.windowBlue,
          ),
          _MetricTile(
            icon: Icons.support_agent,
            label: 'Telecallers',
            value: '24',
            detail: 'Available now',
            color: AppColors.green,
            bg: AppColors.greenBg,
          ),
          _MetricTile(
            icon: Icons.badge_outlined,
            label: 'Executives',
            value: '18',
            detail: 'Active users',
            color: AppColors.purple,
            bg: AppColors.purpleBg,
          ),
          _MetricTile(
            icon: Icons.assignment_turned_in_outlined,
            label: 'Today',
            value: '84',
            detail: 'Assigned leads',
            color: AppColors.orange,
            bg: AppColors.orangeBg,
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
    required this.bg,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 154,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: bg,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: _detailStyle()),
                const SizedBox(height: 4),
                Text(value, style: _valueStyle()),
                const SizedBox(height: 2),
                Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: _smallStyle()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentTabs extends StatelessWidget {
  const _AssignmentTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: const [
          Expanded(child: _TabButton(label: 'Manual', active: true)),
          Expanded(child: _TabButton(label: 'Bulk')),
          Expanded(child: _TabButton(label: 'AI Auto')),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({super.key, required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: active ? AppColors.orangeBg : AppColors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active ? AppColors.orange : AppColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SelectLeadsCard extends StatelessWidget {
  const _SelectLeadsCard();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      number: '1',
      title: 'Select Leads',
      action: '156 Unassigned',
      child: Column(
        children: const [
          _CompactSearch(hint: 'Search leads...'),
          SizedBox(height: 12),
          _LeadAssignRow(name: 'Rahul Sharma', source: 'MagicBricks', score: '92', selected: true),
          _LeadAssignRow(name: 'Neha Kapoor', source: '99Acres', score: '89', selected: true),
          _LeadAssignRow(name: 'Vikram Singh', source: 'Google Ads', score: '86'),
          _LeadAssignRow(name: 'Anjali Mehta', source: 'Referral', score: '83'),
        ],
      ),
    );
  }
}

class _AssignToCard extends StatelessWidget {
  const _AssignToCard();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      number: '2',
      title: 'Assign To',
      action: 'Telecaller',
      child: Column(
        children: const [
          _CompactSearch(hint: 'Search telecallers...'),
          SizedBox(height: 12),
          _AssigneeRow(name: 'Aditya Patil', load: '22 / 30', performance: '88%', selected: true),
          _AssigneeRow(name: 'Sneha Iyer', load: '18 / 30', performance: '92%'),
          _AssigneeRow(name: 'Pooja Sharma', load: '25 / 30', performance: '85%'),
          _AssigneeRow(name: 'Neha Joshi', load: '15 / 30', performance: '90%'),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.number,
    required this.title,
    required this.action,
    required this.child,
  });

  final String number;
  final String title;
  final String action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.navy,
                child: Text(
                  number,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: _sectionTitleStyle())),
              _SoftBadge(label: action),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CompactSearch extends StatelessWidget {
  const _CompactSearch({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: _detailStyle(),
        prefixIcon: const Icon(Icons.search, color: AppColors.navy, size: 20),
        filled: true,
        fillColor: AppColors.scaffoldBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.navy),
        ),
      ),
    );
  }
}

class _LeadAssignRow extends StatelessWidget {
  const _LeadAssignRow({
    required this.name,
    required this.source,
    required this.score,
    this.selected = false,
  });

  final String name;
  final String source;
  final String score;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return _ListRow(
      leading: Checkbox(
        value: selected,
        onChanged: (_) {},
        activeColor: AppColors.navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      title: name,
      subtitle: source,
      trailing: _ScorePill(score),
    );
  }
}

class _AssigneeRow extends StatelessWidget {
  const _AssigneeRow({
    required this.name,
    required this.load,
    required this.performance,
    this.selected = false,
  });

  final String name;
  final String load;
  final String performance;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return _ListRow(
      leading: Radio<bool>(
        value: true,
        groupValue: selected,
        onChanged: (_) {},
        activeColor: AppColors.navy,
      ),
      title: name,
      subtitle: 'Current load $load',
      trailing: _SoftBadge(label: performance),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(width: 38, child: leading),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: _rowTitleStyle()),
                const SizedBox(height: 4),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: _smallStyle()),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

class _AssignmentOptionsCard extends StatelessWidget {
  const _AssignmentOptionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Assignment Options', style: TextStyle(color: AppColors.navy, fontSize: 17, fontWeight: FontWeight.w900)),
          SizedBox(height: 12),
          _OptionRow(label: 'Round Robin', detail: 'Distribute selected leads equally', selected: true),
          _OptionRow(label: 'Based on Capacity', detail: 'Assign based on workload'),
          _OptionRow(label: 'AI Based Assignment', detail: 'Use score, capacity and expert match', recommended: true),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.detail,
    this.selected = false,
    this.recommended = false,
  });

  final String label;
  final String detail;
  final bool selected;
  final bool recommended;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Radio<bool>(
            value: true,
            groupValue: selected,
            onChanged: (_) {},
            activeColor: AppColors.navy,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: _rowTitleStyle())),
                    if (recommended) ...[
                      const SizedBox(width: 8),
                      const _SoftBadge(label: 'Recommended'),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: _smallStyle()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiRecommendationCard extends StatelessWidget {
  const _AiRecommendationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greenBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.white,
                child: Icon(Icons.auto_awesome, color: AppColors.green),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Recommendation', style: TextStyle(color: AppColors.navy, fontSize: 17, fontWeight: FontWeight.w900)),
                    SizedBox(height: 4),
                    Text('Aditya Patil is the best match', style: TextStyle(color: AppColors.mutedNavy, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              _SoftBadge(label: 'Best Match'),
            ],
          ),
          SizedBox(height: 14),
          _AiPoint('High performance telecaller'),
          _AiPoint('Expert in Mumbai and Navi Mumbai'),
          _AiPoint('Available capacity for selected leads'),
        ],
      ),
    );
  }
}

class _AiPoint extends StatelessWidget {
  const _AiPoint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: _rowTitleStyle())),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancel', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: AppColors.orange,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.send_outlined, size: 18),
            label: const Text('Assign Leads', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    );
  }
}

class _SoftBadge extends StatelessWidget {
  const _SoftBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.orangeBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.orange,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill(this.score, {super.key});

  final String score;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.greenBg,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.green),
      ),
      child: Center(
        child: Text(
          score,
          style: const TextStyle(
            color: AppColors.green,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
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

TextStyle _sectionTitleStyle() {
  return const TextStyle(
    color: AppColors.navy,
    fontSize: 17,
    fontWeight: FontWeight.w900,
  );
}

TextStyle _rowTitleStyle() {
  return const TextStyle(
    color: AppColors.navy,
    fontSize: 13,
    fontWeight: FontWeight.w900,
  );
}

TextStyle _detailStyle() {
  return const TextStyle(
    color: AppColors.mutedNavy,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
}

TextStyle _smallStyle() {
  return const TextStyle(
    color: AppColors.mutedNavy,
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );
}

TextStyle _valueStyle() {
  return const TextStyle(
    color: AppColors.navy,
    fontSize: 21,
    fontWeight: FontWeight.w900,
  );
}
