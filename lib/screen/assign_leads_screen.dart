import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/constant/screen_utils.dart';
import 'package:truerealtycrm/provider/employee_provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';

class AssignLeadsScreen extends StatefulWidget {
  const AssignLeadsScreen({super.key});

  @override
  State<AssignLeadsScreen> createState() => _AssignLeadsScreenState();
}

class _AssignLeadsScreenState extends State<AssignLeadsScreen> {
  final Set<String> _selectedLeadIds = {};
  List<_AssignEmployee> _employees = const [];
  String? _selectedEmployeeId;
  String _leadSearch = '';
  String _employeeSearch = '';
  bool _loading = true;
  bool _assigning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final results = await Future.wait([
      context.read<LeadProvider>().fetchLeads(page: 1, limit: 100),
      context.read<EmployeeProvider>().fetchEmployees(
        role: 'all',
        status: 'Active',
        limit: 100,
      ),
    ]);
    if (!mounted) return;
    final employees = _extractAssignList(results[1]?.data)
        .map(_AssignEmployee.fromJson)
        .where((employee) => employee.id.isNotEmpty)
        .toList();
    setState(() {
      _employees = employees;
      _selectedLeadIds.removeWhere(
        (id) =>
            !context.read<LeadProvider>().leads.any((lead) => lead.id == id),
      );
      _loading = false;
      if (results[0] == null || results[1] == null) {
        _error = 'Some assignment data could not be loaded.';
      }
    });
  }

  Future<void> _assign() async {
    if (_selectedLeadIds.isEmpty || _selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select leads and an assignee first.')),
      );
      return;
    }
    setState(() {
      _assigning = true;
      _error = null;
    });
    final provider = context.read<LeadProvider>();
    final response = _selectedLeadIds.length == 1
        ? await provider.assignLead(
            leadId: _selectedLeadIds.first,
            body: {'assignedToId': _selectedEmployeeId},
          )
        : await provider.bulkAssignLeads({
            'leadIds': _selectedLeadIds.toList(),
            'assignedToId': _selectedEmployeeId,
          });
    if (!mounted) return;
    if (response == null) {
      setState(() {
        _assigning = false;
        _error = provider.error ?? 'Unable to assign leads.';
      });
      return;
    }
    setState(() {
      _selectedLeadIds.clear();
      _selectedEmployeeId = null;
      _assigning = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Leads assigned successfully.')),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final leadProvider = context.watch<LeadProvider>();
    final unassignedLeads = leadProvider.leads
        .where(_isLeadUnassigned)
        .toList();
    final leads = unassignedLeads.where((lead) {
      final query = _leadSearch.trim().toLowerCase();
      if (query.isEmpty) return true;
      return '${lead.name} ${lead.displayId ?? ''} ${lead.phone} ${lead.source ?? ''}'
          .toLowerCase()
          .contains(query);
    }).toList();
    final employees = _employees.where((employee) {
      final query = _employeeSearch.trim().toLowerCase();
      return query.isEmpty ||
          '${employee.name} ${employee.email} ${employee.role}'
              .toLowerCase()
              .contains(query);
    }).toList();
    final unassignedCount = unassignedLeads.length;
    final telecallerCount = _employees
        .where((employee) => employee.isTelecaller)
        .length;
    final executiveCount = _employees
        .where((employee) => employee.isExecutive)
        .length;

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
                      _MetricStrip(
                        unassigned: unassignedCount,
                        telecallers: telecallerCount,
                        executives: executiveCount,
                        selected: _selectedLeadIds.length,
                      ),
                      SizedBox(height: 16.h),
                      if (_loading)
                        const Center(child: CircularProgressIndicator())
                      else if (_error != null && leadProvider.leads.isEmpty)
                        _AssignError(message: _error!, onRetry: _load)
                      else ...[
                        _SelectLeadsCard(
                          leads: leads,
                          selectedIds: _selectedLeadIds,
                          unassignedCount: unassignedCount,
                          onSearch: (value) =>
                              setState(() => _leadSearch = value),
                          onSelected: (leadId, selected) {
                            setState(() {
                              selected
                                  ? _selectedLeadIds.add(leadId)
                                  : _selectedLeadIds.remove(leadId);
                            });
                          },
                        ),
                        SizedBox(height: 16.h),
                        _AssignToCard(
                          employees: employees,
                          selectedId: _selectedEmployeeId,
                          onSearch: (value) =>
                              setState(() => _employeeSearch = value),
                          onSelected: (value) =>
                              setState(() => _selectedEmployeeId = value),
                        ),
                        SizedBox(height: 16.h),
                        if (_error != null) ...[
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          SizedBox(height: 12.h),
                        ],
                        _BottomActions(
                          assigning: _assigning,
                          enabled:
                              _selectedLeadIds.isNotEmpty &&
                              _selectedEmployeeId != null,
                          onAssign: _assign,
                        ),
                      ],
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
  const _MetricStrip({
    required this.unassigned,
    required this.telecallers,
    required this.executives,
    required this.selected,
  });

  final int unassigned;
  final int telecallers;
  final int executives;
  final int selected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _MetricTile(
            icon: Icons.assignment_outlined,
            label: 'Unassigned',
            value: '$unassigned',
            detail: 'Requires assignment',
            color: AppColors.vividBlue,
            bg: AppColors.windowBlue,
          ),
          _MetricTile(
            icon: Icons.support_agent,
            label: 'Telecallers',
            value: '$telecallers',
            detail: 'Active users',
            color: AppColors.green,
            bg: AppColors.greenBg,
          ),
          _MetricTile(
            icon: Icons.badge_outlined,
            label: 'Executives',
            value: '$executives',
            detail: 'Active users',
            color: AppColors.purple,
            bg: AppColors.purpleBg,
          ),
          _MetricTile(
            icon: Icons.assignment_turned_in_outlined,
            label: 'Selected',
            value: '$selected',
            detail: 'Ready to assign',
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
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _detailStyle(),
                ),
                const SizedBox(height: 4),
                Text(value, style: _valueStyle()),
                const SizedBox(height: 2),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _smallStyle(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Retained for compatibility with the previous assignment layout.
// ignore: unused_element
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
  const _TabButton({required this.label, this.active = false});

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
  const _SelectLeadsCard({
    required this.leads,
    required this.selectedIds,
    required this.unassignedCount,
    required this.onSearch,
    required this.onSelected,
  });

  final List<LeadModel> leads;
  final Set<String> selectedIds;
  final int unassignedCount;
  final ValueChanged<String> onSearch;
  final void Function(String leadId, bool selected) onSelected;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      number: '1',
      title: 'Select Leads',
      action: '$unassignedCount Unassigned',
      child: Column(
        children: [
          _CompactSearch(hint: 'Search leads...', onChanged: onSearch),
          const SizedBox(height: 12),
          if (leads.isEmpty)
            const _EmptyAssignmentRow(label: 'No leads found')
          else
            ...leads.map(
              (lead) => _LeadAssignRow(
                lead: lead,
                selected: selectedIds.contains(lead.id),
                onChanged: lead.id == null
                    ? null
                    : (selected) => onSelected(lead.id!, selected),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssignToCard extends StatelessWidget {
  const _AssignToCard({
    required this.employees,
    required this.selectedId,
    required this.onSearch,
    required this.onSelected,
  });

  final List<_AssignEmployee> employees;
  final String? selectedId;
  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      number: '2',
      title: 'Assign To',
      action: '${employees.length} Active',
      child: Column(
        children: [
          _CompactSearch(hint: 'Search assignees...', onChanged: onSearch),
          const SizedBox(height: 12),
          if (employees.isEmpty)
            const _EmptyAssignmentRow(label: 'No active employees found')
          else
            ...employees.map(
              (employee) => _AssigneeRow(
                employee: employee,
                selected: selectedId == employee.id,
                onChanged: (_) => onSelected(employee.id),
              ),
            ),
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
  const _CompactSearch({required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
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
    required this.lead,
    required this.selected,
    required this.onChanged,
  });

  final LeadModel lead;
  final bool selected;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return _ListRow(
      leading: Checkbox(
        value: selected,
        onChanged: (value) => onChanged?.call(value ?? false),
        activeColor: AppColors.navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      title: lead.titleWithId,
      subtitle: [
        lead.source,
        lead.status,
      ].whereType<String>().where((value) => value.isNotEmpty).join(' • '),
      trailing: _SoftBadge(label: lead.status),
    );
  }
}

class _AssigneeRow extends StatelessWidget {
  const _AssigneeRow({
    required this.employee,
    required this.selected,
    required this.onChanged,
  });

  final _AssignEmployee employee;
  final bool selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(employee.id),
      borderRadius: BorderRadius.circular(10),
      child: _ListRow(
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? AppColors.navy : AppColors.mutedNavy,
        ),
        title: employee.name,
        subtitle: employee.email,
        trailing: _SoftBadge(label: employee.displayRole),
      ),
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
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _rowTitleStyle(),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _smallStyle(),
                ),
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

// Retained for compatibility with the previous assignment layout.
// ignore: unused_element
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
          Text(
            'Assignment Options',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12),
          _OptionRow(
            label: 'Round Robin',
            detail: 'Distribute selected leads equally',
            selected: true,
          ),
          _OptionRow(
            label: 'Based on Capacity',
            detail: 'Assign based on workload',
          ),
          _OptionRow(
            label: 'AI Based Assignment',
            detail: 'Use score, capacity and expert match',
            recommended: true,
          ),
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
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? AppColors.navy : AppColors.mutedNavy,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _rowTitleStyle(),
                      ),
                    ),
                    if (recommended) ...[
                      const SizedBox(width: 8),
                      const _SoftBadge(label: 'Recommended'),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _smallStyle(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
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
                    Text(
                      'AI Recommendation',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Aditya Patil is the best match',
                      style: TextStyle(
                        color: AppColors.mutedNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
  const _BottomActions({
    required this.assigning,
    required this.enabled,
    required this.onAssign,
  });

  final bool assigning;
  final bool enabled;
  final Future<void> Function() onAssign;

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: enabled && !assigning ? onAssign : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: AppColors.orange,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: assigning
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Icon(Icons.send_outlined, size: 18),
            label: Text(
              assigning ? 'Assigning...' : 'Assign Leads',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}

class _SoftBadge extends StatelessWidget {
  const _SoftBadge({required this.label});

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

class _EmptyAssignmentRow extends StatelessWidget {
  const _EmptyAssignmentRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(label, style: _detailStyle(), textAlign: TextAlign.center),
      ),
    );
  }
}

class _AssignError extends StatelessWidget {
  const _AssignError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFB42318)),
          ),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _AssignEmployee {
  const _AssignEmployee({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final String role;

  factory _AssignEmployee.fromJson(Object? source) {
    if (source is! Map) {
      return const _AssignEmployee(id: '', name: '', email: '', role: '');
    }
    final map = Map<String, dynamic>.from(source);
    var name = _assignText(map, const ['name', 'fullName', 'displayName']);
    if (name.isEmpty) {
      name = [
        _assignText(map, const ['firstName']),
        _assignText(map, const ['lastName']),
      ].where((part) => part.isNotEmpty).join(' ');
    }
    return _AssignEmployee(
      id: _assignText(map, const ['id', '_id', 'employeeId', 'userId']),
      name: name.isEmpty ? 'Unknown employee' : name,
      email: _assignText(map, const ['email', 'phone', 'mobile']),
      role: _assignText(map, const [
        'role',
        'roleName',
        'designation',
        'userRole',
      ]),
    );
  }

  bool get isTelecaller {
    final value = role.toLowerCase().replaceAll(RegExp(r'[_ -]'), '');
    return value.contains('telecaller') || value.contains('caller');
  }

  bool get isExecutive {
    final value = role.toLowerCase().replaceAll(RegExp(r'[_ -]'), '');
    return value.contains('salesagent') ||
        value.contains('fieldexecutive') ||
        value.contains('executive');
  }

  String get displayRole {
    if (role.isEmpty) return 'Active';
    return role
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

List<dynamic> _extractAssignList(Object? source) {
  if (source is List) return source;
  if (source is Map) {
    for (final key in const [
      'data',
      'items',
      'results',
      'rows',
      'records',
      'employees',
      'users',
    ]) {
      final nested = _extractAssignList(source[key]);
      if (nested.isNotEmpty) return nested;
    }
  }
  return const [];
}

String _assignText(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return '';
}

bool _isLeadUnassigned(LeadModel lead) {
  final raw = lead.raw ?? const <String, dynamic>{};
  for (final key in const [
    'assignedToId',
    'assigneeId',
    'assignedEmployeeId',
  ]) {
    if (raw.containsKey(key)) {
      final value = raw[key]?.toString().trim() ?? '';
      return value.isEmpty || value.toLowerCase() == 'null';
    }
  }
  return (lead.assignedTo ?? '').trim().isEmpty;
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
