import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/provider/contact_lead_provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/router/app_router.dart';
import 'package:truerealtycrm/widget/app_loading.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactLeadsScreen extends StatefulWidget {
  const ContactLeadsScreen({super.key});

  @override
  State<ContactLeadsScreen> createState() => _ContactLeadsScreenState();
}

class _ContactLeadsScreenState extends State<ContactLeadsScreen> {
  static const _border = Color(0xFFDCE5F0);
  final _search = TextEditingController();
  final Set<String> _selected = {};
  Timer? _debounce;
  List<Map<String, dynamic>> _items = const [];
  Map<String, dynamic> _filters = const {};
  int _page = 1;
  int _limit = 10;
  int _total = 0;
  bool _loading = true;
  bool _updating = false;
  bool _loggingOut = false;
  bool _requiresReauthentication = false;
  String? _error;
  bool _selectionMode = false;
  String _selectedTab = 'All';
  static const List<String> _statusTabs = [
    'All',
    'Cold',
    'Interested',
    'Not Interested',
    'Converted',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialLoad());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _initialLoad() async {
    await Future.wait([_load(), _loadFilters()]);
  }

  Future<void> _loadFilters() async {
    final response = await context.read<LeadProvider>().fetchLeadPipeline(
      limitPerColumn: 1,
    );
    if (!mounted || response == null) return;
    final root = _map(response.data);
    final nested = _map(root['data']);
    final filters = _map(root['filters']).isNotEmpty
        ? _map(root['filters'])
        : _map(nested['filters']);
    if (filters.isNotEmpty) setState(() => _filters = filters);
  }

  Future<void> _load({int? page}) async {
    final nextPage = page ?? _page;
    setState(() {
      _loading = true;
      _error = null;
      _requiresReauthentication = false;
    });
    final auth = context.read<AuthProvider>();
    final assignedToId = auth.role == UserRole.owner
        ? null
        : _authenticatedEmployeeId(auth);
    if (auth.role != UserRole.owner && assignedToId == null) {
      setState(() {
        _items = const [];
        _total = 0;
        _loading = false;
        _requiresReauthentication = true;
        _error = 'Unable to identify the signed-in employee.';
      });
      return;
    }
    final provider = context.read<ContactLeadProvider>();
    String? apiStatus;
    if (_selectedTab != 'All') {
      apiStatus = switch (_selectedTab) {
        'Cold' => 'COLD',
        'Interested' => 'INTERESTED',
        'Not Interested' => 'NOT_INTERESTED',
        'Converted' => 'CONVERTED',
        _ => _selectedTab.toUpperCase(),
      };
    }
    final response = await provider.fetchContactLeads(
      search: _search.text.trim(),
      page: nextPage,
      limit: _limit,
      assignedToId: assignedToId,
      status: apiStatus,
    );
    if (!mounted) return;
    if (response == null) {
      setState(() {
        _loading = false;
        _error = provider.error ?? 'Unable to load contact leads.';
      });
      return;
    }
    final root = _map(response.data);
    final nested = _map(root['data']);
    final rawItems = root['data'] is List
        ? _list(root['data'])
        : _list(nested['data'] ?? nested['items']);
    final meta = _map(root['meta']).isNotEmpty
        ? _map(root['meta'])
        : _map(nested['meta']);
    setState(() {
      _items = rawItems.map(_map).toList();
      _page = _int(meta['page'], fallback: nextPage);
      _limit = _int(meta['limit'], fallback: _limit);
      _total = _int(meta['total'], fallback: rawItems.length);
      _selected.removeWhere((id) => !_items.any((item) => item['id'] == id));
      _loading = false;
    });
  }

  String? _authenticatedEmployeeId(AuthProvider auth) {
    String? find(Object? value, [int depth = 0]) {
      if (value == null || depth > 4) return null;
      if (value is Map) {
        for (final key in const ['employeeId', 'id', 'userId', '_id']) {
          final candidate = value[key]?.toString().trim() ?? '';
          if (candidate.isNotEmpty) return candidate;
        }
        for (final key in const ['employee', 'user', 'profile', 'data']) {
          final candidate = find(value[key], depth + 1);
          if (candidate != null) return candidate;
        }
      }
      return null;
    }

    return find(auth.session?.user) ?? find(auth.session?.raw);
  }

  void _searchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () => _load(page: 1));
    setState(() {});
  }

  int get _first => _total == 0 ? 0 : ((_page - 1) * _limit) + 1;
  int get _last => (_page * _limit).clamp(0, _total);
  int get _pages => _total == 0 ? 1 : (_total / _limit).ceil();
  bool get _allSelected =>
      _items.isNotEmpty &&
      _items.every((item) => _selected.contains('${item['id']}'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.leadListBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _initialLoad,
          color: AppColors.orangeStrong,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                SizedBox(height: 16.h),
                _toolbar(),
                SizedBox(height: 14.h),
                _buildTabs(),
                SizedBox(height: 14.h),
                if (_error != null) _errorPanel(),
                _table(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.navy,
            side: const BorderSide(color: _border),
            padding: EdgeInsets.all(8.r),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Leads',
                style: GoogleFonts.inter(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              Text(
                'Manage incoming portal and campaign enquiries.',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: _loading ? null : _initialLoad,
          icon: Icon(Icons.refresh_rounded, size: 22.sp),
        ),
      ],
    );
  }

  Widget _toolbar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48.h,
                child: TextField(
                  controller: _search,
                  onChanged: _searchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search name, number, project or source',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _search.clear();
                              _load(page: 1);
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 13.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.orangeStrong,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            SizedBox(
              width: 48.w,
              height: 48.h,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectionMode = !_selectionMode;
                    if (!_selectionMode) _selected.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: _selectionMode
                      ? AppColors.orangeStrong
                      : AppColors.navy,
                  backgroundColor: _selectionMode
                      ? const Color(0xFFFFF4ED)
                      : Colors.white,
                  side: BorderSide(
                    color: _selectionMode
                        ? AppColors.orangeStrong
                        : const Color(0xFFCBD5E1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Icon(
                  _selectionMode
                      ? Icons.close_rounded
                      : Icons.checklist_rounded,
                  size: 21.sp,
                ),
              ),
            ),
          ],
        ),
        if (_selectionMode) ...[
          SizedBox(height: 10.h),
          Row(
            children: [
              Text(
                '${_selected.length} selected',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(width: 14.w),
              PopupMenuButton<_BulkAction>(
                enabled: !_updating,
                onSelected: _runBulkAction,
                offset: const Offset(0, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                color: Colors.white,
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _BulkAction.assign,
                    child: Text('Assign To'),
                  ),
                  PopupMenuItem(
                    value: _BulkAction.source,
                    child: Text('Lead Source'),
                  ),
                  PopupMenuItem(
                    value: _BulkAction.project,
                    child: Text('Project Name'),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: _BulkAction.interested,
                    child: Text('Mark interested'),
                  ),
                  PopupMenuItem(
                    value: _BulkAction.notInterested,
                    child: Text('Mark not interested'),
                  ),
                  PopupMenuItem(
                    value: _BulkAction.convert,
                    child: Text('Convert selected'),
                  ),
                  PopupMenuItem(
                    value: _BulkAction.archive,
                    child: Text('Archive selected'),
                  ),
                ],
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _updating ? 'Updating...' : 'Update',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      SizedBox(width: 7.w),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 19.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _table() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectionMode) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFDCE5F0)),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _allSelected,
                  activeColor: AppColors.orangeStrong,
                  onChanged: _toggleAll,
                ),
                Expanded(
                  child: Text(
                    'Showing $_first to $_last of $_total contact leads',
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                Text(
                  'Select all',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
        ],
        if (_loading && _items.isEmpty)
          const AppListSkeleton(itemCount: 4, itemHeight: 180)
        else ...[
          if (_loading) ...[
            SizedBox(height: 8.h),
            const LinearProgressIndicator(minHeight: 2),
          ],
          SizedBox(height: 12.h),
          for (var i = 0; i < _items.length; i++) ...[
            _contactCard(_items[i]),
            if (i != _items.length - 1) SizedBox(height: 12.h),
          ],
        ],
        if (!_loading && _items.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(28.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFDCE5F0)),
            ),
            child: Center(
              child: Text(
                'No contact leads found.',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xFFDCE5F0)),
          ),
          child: _pagination(),
        ),
      ],
    );
  }

  Widget _contactCard(Map<String, dynamic> item) {
    final id = '${item['id'] ?? ''}';
    final note = _value(item, 'note');
    final selected = _selected.contains(id);
    final name = _value(item, 'customerName', fallback: 'Unknown contact');
    final phone = _contactPhone(item);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 12.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF8F3) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? AppColors.orangeStrong : const Color(0xFFDCE5F0),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectionMode) ...[
                  Checkbox(
                    value: selected,
                    activeColor: AppColors.orangeStrong,
                    visualDensity: VisualDensity.compact,
                    onChanged: (_) => _toggle(id),
                  ),
                  SizedBox(width: 4.w),
                ],
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: const Color(0xFF10213D),
                  child: Text(
                    _initials(name),
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0B1735),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Added on ${_date(item['createdAt'])}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _status(_value(item, 'status', fallback: 'COLD')),
                    SizedBox(height: 5.h),
                    _badge(
                      _value(item, 'sourceName', fallback: 'Unknown'),
                      const Color(0xFF2563EB),
                    ),
                  ],
                ),
                PopupMenuButton<_RowAction>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xFF1D4ED8),
                  ),
                  onSelected: (action) => _runRowAction(action, item),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: _RowAction.edit,
                      child: Text('Edit contact'),
                    ),
                    PopupMenuItem(
                      value: _RowAction.interested,
                      child: Text('Mark interested'),
                    ),
                    PopupMenuItem(
                      value: _RowAction.notInterested,
                      child: Text('Mark not interested'),
                    ),
                    PopupMenuItem(
                      value: _RowAction.convert,
                      child: Text('Convert to lead'),
                    ),
                    PopupMenuItem(
                      value: _RowAction.archive,
                      child: Text('Archive'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _mobileDetail(
                    Icons.phone_rounded,
                    'Mobile Number',
                    '${_value(item, 'mobileCountryCode')} ${_value(item, 'mobile')}'
                        .trim(),
                    iconColor: const Color(0xFF00A63E),
                    iconBackground: const Color(0xFFE8F8EE),
                  ),
                ),
                Container(
                  width: 1,
                  height: 48.h,
                  color: const Color(0xFFE4E7EC),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _mobileDetail(
                    Icons.apartment_rounded,
                    'Project Name',
                    _value(item, 'projectName', fallback: 'Not assigned'),
                    iconColor: const Color(0xFF1468D4),
                    iconBackground: const Color(0xFFEAF2FF),
                  ),
                ),
              ],
            ),
            SizedBox(height: 11.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _mobileDetail(
                      Icons.person_pin_circle_outlined,
                      'Assigned To',
                      _value(item, 'assignedToName', fallback: 'Unassigned'),
                      iconColor: const Color(0xFF4D2DDB),
                      iconBackground: const Color(0xFFEDEAFF),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48.h,
                    color: const Color(0xFFE4E7EC),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _mobileDetail(
                      Icons.update_rounded,
                      'Last Update',
                      _date(item['updatedAt']),
                      iconColor: const Color(0xFF4D2DDB),
                      iconBackground: const Color(0xFFEDEAFF),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 11.h),
            InkWell(
              borderRadius: BorderRadius.circular(8.r),
              onTap: () => _showNoteDialog(item),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 17.sp,
                      color: const Color(0xFF1454D8),
                    ),
                    SizedBox(width: 7.w),
                    Text(
                      'Note: ',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF475467),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        note.isEmpty ? 'Add note' : note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ).copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40.h,
                    child: OutlinedButton.icon(
                      onPressed: phone.isEmpty ? null : () => _call(phone),
                      icon: Icon(Icons.phone_rounded, size: 17.sp),
                      label: Text(
                        'Call',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.orangeDeep,
                        side: const BorderSide(color: Color(0xFFE97842)),
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: SizedBox(
                    height: 40.h,
                    child: OutlinedButton.icon(
                      onPressed: phone.isEmpty ? null : () => _openWhatsApp(phone),
                      icon: Icon(Icons.chat_rounded, size: 17.sp),
                      label: Text(
                        'WhatsApp',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF168553),
                        side: const BorderSide(color: Color(0xFFB7E4C7)),
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _contactPhone(Map<String, dynamic> item) {
    final mobile = _value(item, 'mobile');
    if (mobile.isEmpty || mobile == '-') return '';
    final countryCode = _value(item, 'mobileCountryCode');
    return countryCode.isEmpty ? mobile : '$countryCode $mobile';
  }

  Future<void> _call(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) return;
    try {
      final launched = await launchUrl(
        Uri(scheme: 'tel', path: cleaned),
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } catch (_) {}
    if (mounted) _message('Unable to open the phone dialer.');
  }

  Future<void> _openWhatsApp(String phone) async {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      _message('No valid phone number for WhatsApp.');
      return;
    }
    if (digits.length == 10) digits = '91$digits';
    final candidates = <Uri>[
      Uri.parse('whatsapp://send?phone=$digits'),
      Uri.parse('https://api.whatsapp.com/send?phone=$digits'),
      Uri.parse('https://wa.me/$digits'),
    ];
    for (final uri in candidates) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
      } catch (_) {}
    }
    if (mounted) _message('Unable to open WhatsApp. Please install WhatsApp.');
  }

  Future<void> _showNoteDialog(Map<String, dynamic> item) async {
    final id = '${item['id'] ?? ''}'.trim();
    if (id.isEmpty) {
      _message('Contact lead ID is unavailable.');
      return;
    }
    final changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ContactNoteDialog(item: item),
    );
    if (changed == true && mounted) await _load(page: _page);
  }

  Widget _mobileDetail(
    IconData icon,
    String label,
    String value, {
    Color iconColor = AppColors.navy,
    Color iconBackground = const Color(0xFFF1F5F9),
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: iconBackground == const Color(0xFFF1F5F9) ? 20.w : 34.w,
          height: iconBackground == const Color(0xFFF1F5F9) ? 20.h : 34.h,
          decoration: iconBackground == const Color(0xFFF1F5F9)
              ? null
              : BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(8.r),
                ),
          child: Icon(
            icon,
            size: iconBackground == const Color(0xFFF1F5F9) ? 16.sp : 17.sp,
            color: iconColor,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pagination() {
    final pagination = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _pageArrow(
          Icons.chevron_left,
          onTap: _page <= 1 || _loading ? null : () => _load(page: _page - 1),
        ),
        SizedBox(width: 8.w),
        _pageChip(_page.toString(), isSelected: true),
        SizedBox(width: 8.w),
        Text(
          '...',
          style: GoogleFonts.inter(
            fontSize: 21.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8.w),
        _pageChip(_pages.toString()),
        SizedBox(width: 8.w),
        _pageArrow(
          Icons.chevron_right,
          onTap: _page >= _pages || _loading ? null : () => _load(page: _page + 1),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Showing $_first to $_last of $_total leads',
              style: GoogleFonts.inter(
                fontSize: 12.5.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          pagination,
        ],
      ),
    );
  }

  Widget _pageArrow(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: onTap == null ? const Color(0xFFDFE6EE) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _pageChip(String label, {bool isSelected = false}) {
    return Container(
      width: 30.w,
      height: 30.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF18223B) : Colors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: isSelected ? const Color(0xFF18223B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          color: isSelected ? Colors.white : const Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _toggle(String id) => setState(
    () => _selected.contains(id) ? _selected.remove(id) : _selected.add(id),
  );
  void _toggleAll(bool? checked) => setState(() {
    if (checked == true) {
      _selected.addAll(_items.map((item) => '${item['id']}'));
    } else {
      _selected.clear();
    }
  });

  Future<void> _runBulkAction(_BulkAction action) async {
    if (_selected.isEmpty) {
      _message('Select at least one contact lead.');
      return;
    }
    switch (action) {
      case _BulkAction.assign:
        await _chooseAndUpdate(
          'Assign contact leads',
          'Select employee',
          _options('users'),
          'assignedToId',
        );
      case _BulkAction.source:
        await _chooseAndUpdate(
          'Update lead source',
          'Select source',
          _options('sources'),
          'sourceId',
        );
      case _BulkAction.project:
        await _chooseAndUpdate(
          'Update project',
          'Select project',
          _options('projects'),
          'preferredProjectId',
          searchable: true,
        );
      case _BulkAction.interested:
        await _bulkEndpoint(
          (provider, id) => provider.markInterested(id),
          'Contacts marked interested.',
        );
      case _BulkAction.notInterested:
        await _bulkEndpoint(
          (provider, id) => provider.updateContactLead(
            contactLeadId: id,
            body: const {'status': 'NOT_INTERESTED'},
          ),
          'Contacts marked not interested.',
        );
      case _BulkAction.convert:
        await _bulkEndpoint(
          (provider, id) => provider.convertContactLead(id),
          'Contacts converted successfully.',
        );
      case _BulkAction.archive:
        if (await _confirm('Archive selected contacts?')) {
          await _bulkEndpoint(
            (provider, id) => provider.archiveContactLead(id),
            'Contacts archived.',
          );
        }
    }
  }

  Future<void> _runRowAction(
    _RowAction action,
    Map<String, dynamic> item,
  ) async {
    final id = '${item['id']}';
    switch (action) {
      case _RowAction.edit:
        final changed = await showDialog<bool>(
          context: context,
          builder: (_) => _EditContactDialog(item: item),
        );
        if (changed == true) await _load();
      case _RowAction.interested:
        await _single(
          () => context.read<ContactLeadProvider>().markInterested(id),
          'Contact marked interested.',
        );
      case _RowAction.notInterested:
        await _single(
          () => context.read<ContactLeadProvider>().updateContactLead(
                contactLeadId: id,
                body: const {'status': 'NOT_INTERESTED'},
              ),
          'Contact marked not interested.',
        );
      case _RowAction.convert:
        await _single(
          () => context.read<ContactLeadProvider>().convertContactLead(id),
          'Contact converted successfully.',
        );
      case _RowAction.archive:
        if (await _confirm('Archive this contact lead?')) {
          await _single(
            () => context.read<ContactLeadProvider>().archiveContactLead(id),
            'Contact archived.',
          );
        }
    }
  }

  List<_Option> _options(String key) => _list(_filters[key])
      .map((raw) {
        final map = _map(raw);
        return _Option(
          '${map['id'] ?? ''}',
          _value(map, 'name', fallback: 'Unnamed'),
          subtitle: key == 'projects'
              ? _value(map, 'location')
              : _value(map, 'role'),
        );
      })
      .where((option) => option.id.isNotEmpty)
      .toList();

  Future<void> _chooseAndUpdate(
    String title,
    String hint,
    List<_Option> options,
    String field, {
    bool searchable = false,
  }) async {
    if (options.isEmpty) {
      _message('No options are available. Pull to refresh and try again.');
      return;
    }
    final option = await showDialog<_Option>(
      context: context,
      builder: (_) => _OptionDialog(
        title: title,
        hint: hint,
        options: options,
        searchable: searchable,
      ),
    );
    if (option == null) return;
    await _bulkEndpoint(
      (provider, id) => provider.updateContactLead(
        contactLeadId: id,
        body: {field: option.id},
      ),
      '$title updated successfully.',
    );
  }

  Future<void> _bulkEndpoint(
    Future<Object?> Function(ContactLeadProvider, String) operation,
    String success,
  ) async {
    setState(() => _updating = true);
    final provider = context.read<ContactLeadProvider>();
    var completed = 0;
    String? failureMessage;
    for (final id in _selected.toList()) {
      if (await operation(provider, id) != null) {
        completed++;
      } else {
        failureMessage = _contactLeadError(provider);
      }
    }
    if (!mounted) return;
    setState(() => _updating = false);
    if (completed == _selected.length) {
      _message(success);
      _selected.clear();
      await _load();
    } else if (completed == 0) {
      _message(failureMessage ?? 'Unable to update contact leads.');
    } else {
      _message(
        'Updated $completed of ${_selected.length} contacts. '
        '${failureMessage ?? 'Some contacts could not be updated.'}',
      );
    }
  }

  Future<void> _single(
    Future<Object?> Function() operation,
    String success,
  ) async {
    final provider = context.read<ContactLeadProvider>();
    final result = await operation();
    if (!mounted) return;
    _message(result == null ? _contactLeadError(provider) : success);
    if (result != null) await _load();
  }

  String _contactLeadError(ContactLeadProvider provider) {
    final body = _map(provider.errorBody);
    final existingLead = _map(body['existingLead']);
    if (existingLead.isNotEmpty) {
      final displayId = _value(existingLead, 'displayId');
      final name = _value(existingLead, 'name');
      final mobile = _value(existingLead, 'mobile');
      final details = [
        displayId,
        name,
        mobile,
      ].where((value) => value.isNotEmpty).join(' — ');
      return details.isEmpty
          ? 'A lead with this mobile number already exists.'
          : 'Lead already exists: $details.';
    }
    return provider.error ?? 'Unable to update contact lead.';
  }

  Future<bool> _confirm(String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Please confirm'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ) ??
      false;

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), duration: const Duration(seconds: 5)),
  );

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRouter.login, (_) => false);
  }

  Widget _errorPanel() => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1F2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFFECACA)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _requiresReauthentication
                    ? 'Session needs attention'
                    : 'Unable to load contact leads',
                style: _style(13, FontWeight.w800, const Color(0xFF991B1B)),
              ),
              const SizedBox(height: 3),
              Text(
                _requiresReauthentication
                    ? 'Please log out and sign in again to refresh your employee account.'
                    : _error!,
                style: _style(11, FontWeight.w500, const Color(0xFF7F1D1D)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        if (_requiresReauthentication)
          FilledButton.icon(
            onPressed: _loggingOut ? null : _logout,
            icon: _loggingOut
                ? const SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded, size: 16),
            label: Text(_loggingOut ? 'Logging out' : 'Log out'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
            ),
          )
        else
          TextButton.icon(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Retry'),
          ),
      ],
    ),
  );

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'CL';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static Widget _badge(String text, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6.r),
      border: Border.all(color: color.withValues(alpha: 0.24)),
    ),
    child: Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
  static Widget _status(String status) {
    final label = _leadStatusLabel(status);
    final colors = _leadStatusColors(label);
    return _CompactLeadBadge(
      text: label,
      foreground: colors.$1,
      background: colors.$2,
      borderColor: colors.$3,
    );
  }

  static (Color, Color, Color) _leadStatusColors(String status) {
    final value = status.toLowerCase();
    if (value.contains('hot') || value.contains('overdue')) {
      return (
        const Color(0xFFFF641A),
        const Color(0xFFFFF1E8),
        const Color(0xFFFFC8AA),
      );
    }
    if (value.contains('not interest')) {
      return (
        const Color(0xFF7C3AED),
        const Color(0xFFF3E8FF),
        const Color(0xFFE9D5FF),
      );
    }
    if (value.contains('book') || value.contains('convert')) {
      return (
        const Color(0xFF168553),
        const Color(0xFFE8F8EF),
        const Color(0xFFB7EAD4),
      );
    }
    if (value.contains('warm')) {
      return (
        const Color(0xFFB45309),
        const Color(0xFFFFF7E8),
        const Color(0xFFFDE68A),
      );
    }
    if (value.contains('cold')) {
      return (
        const Color(0xFF2563EB),
        const Color(0xFFEAF2FF),
        const Color(0xFFBFDBFE),
      );
    }
    return (
      const Color(0xFF475569),
      const Color(0xFFF1F5F9),
      const Color(0xFFCBD5E1),
    );
  }

  static String _leadStatusLabel(String status) {
    final normalized = status.trim().toUpperCase().replaceAll(' ', '_');
    final label = switch (normalized) {
      'COLD' => 'Cold Lead',
      'WARM' => 'Warm Lead',
      'HOT' => 'Hot Lead',
      'INTERESTED' => 'Interested Lead',
      'NOT_INTERESTED' => 'Not Interested Lead',
      'NEW' => 'New Lead',
      'CONVERTED' => 'Converted',
      'ARCHIVED' => 'Archived',
      _ => _title(status.isEmpty ? 'COLD' : status),
    };
    return label;
  }


  static TextStyle _style(
    double size,
    FontWeight weight, [
    Color color = AppColors.navy,
  ]) => GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);
  static Map<String, dynamic> _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  static List<dynamic> _list(Object? value) => value is List ? value : const [];
  static int _int(Object? value, {int fallback = 0}) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
  static String _value(
    Map<String, dynamic> map,
    String key, {
    String fallback = '',
  }) {
    final value = map[key]?.toString().trim() ?? '';
    return value.isEmpty ? fallback : value;
  }

  static String _title(String value) => value
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(' ')
      .where((e) => e.isNotEmpty)
      .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
      .join(' ');
  static String _date(Object? value) {
    final date = DateTime.tryParse('$value')?.toLocal();
    if (date == null) return '—';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}, ${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'pm' : 'am'}';
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _statusTabs.length; i++) ...[
            if (i > 0) SizedBox(width: 8.w),
            _tabChip(
              _statusTabs[i],
              isSelected: _selectedTab == _statusTabs[i],
              onTap: () {
                setState(() {
                  _selectedTab = _statusTabs[i];
                });
                _load(page: 1);
              },
            ),
          ],
        ],
      ),
    );
  }

  Color _tabTextColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('cold')) return const Color(0xFF2563EB);
    if (lower.contains('not interest')) return const Color(0xFF7C3AED);
    if (lower.contains('interest')) return const Color(0xFF9333EA);
    if (lower.contains('convert')) return const Color(0xFF16A34A);
    return const Color(0xFF475569);
  }

  Color _tabBackgroundColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('cold')) return const Color(0xFFEAF2FF);
    if (lower.contains('not interest')) return const Color(0xFFF3E8FF);
    if (lower.contains('interest')) return const Color(0xFFF3E8FF);
    if (lower.contains('convert')) return const Color(0xFFE8F8EC);
    return Colors.white;
  }

  Widget _tabChip(
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    final bg = isSelected ? const Color(0xFF18223B) : _tabBackgroundColor(label);
    final fg = isSelected ? Colors.white : _tabTextColor(label);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          constraints: BoxConstraints(minHeight: 32.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? const Color(0xFF18223B) : const Color(0xFFE2E8F0),
              width: 1.w,
            ),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.5.sp,
                height: 1.1,
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactNoteDialog extends StatefulWidget {
  const _ContactNoteDialog({required this.item});

  final Map<String, dynamic> item;

  @override
  State<_ContactNoteDialog> createState() => _ContactNoteDialogState();
}

class _ContactNoteDialogState extends State<_ContactNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.item['note'] ?? ''}',
  );
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final response = await context
        .read<ContactLeadProvider>()
        .updateContactLead(
          contactLeadId: '${widget.item['id']}',
          body: {'note': _controller.text.trim()},
        );
    if (!mounted) return;
    if (response != null) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _saving = false;
      _error =
          context.read<ContactLeadProvider>().error ??
          'Unable to save the note.';
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add note'),
    content: SizedBox(
      width: 520,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _controller,
              autofocus: true,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a note.'
                  : null,
              decoration: InputDecoration(
                hintText: 'Write a note about this contact lead',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'Saving...' : 'Save note'),
      ),
    ],
  );
}

class _OptionDialog extends StatefulWidget {
  const _OptionDialog({
    required this.title,
    required this.hint,
    required this.options,
    required this.searchable,
  });
  final String title;
  final String hint;
  final List<_Option> options;
  final bool searchable;
  @override
  State<_OptionDialog> createState() => _OptionDialogState();
}

class _OptionDialogState extends State<_OptionDialog> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final visible = widget.options
        .where(
          (o) => '${o.label} ${o.subtitle}'.toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.searchable) ...[
              TextField(
                onChanged: (v) => setState(() => query = v),
                decoration: InputDecoration(
                  hintText: 'Search by project or location',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: visible.length,
                itemBuilder: (_, i) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFFF0E5),
                    child: Icon(
                      widget.searchable
                          ? Icons.apartment
                          : Icons.person_outline,
                      color: AppColors.orangeDeep,
                    ),
                  ),
                  title: Text(visible[i].label),
                  subtitle: visible[i].subtitle.isEmpty
                      ? null
                      : Text(visible[i].subtitle),
                  onTap: () => Navigator.pop(context, visible[i]),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _EditContactDialog extends StatefulWidget {
  const _EditContactDialog({required this.item});
  final Map<String, dynamic> item;
  @override
  State<_EditContactDialog> createState() => _EditContactDialogState();
}

class _EditContactDialogState extends State<_EditContactDialog> {
  final key = GlobalKey<FormState>();
  late final TextEditingController name = TextEditingController(
    text: '${widget.item['customerName'] ?? ''}',
  );
  late final TextEditingController mobile = TextEditingController(
    text: '${widget.item['mobile'] ?? ''}',
  );
  late final TextEditingController email = TextEditingController(
    text: '${widget.item['email'] ?? ''}',
  );
  late final TextEditingController note = TextEditingController(
    text: '${widget.item['note'] ?? ''}',
  );
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    mobile.dispose();
    email.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit contact lead'),
    content: SizedBox(
      width: 520,
      child: Form(
        key: key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(name, 'Customer name', Icons.person_outline, required: true),
            const SizedBox(height: 12),
            _field(
              mobile,
              'Mobile number',
              Icons.phone_outlined,
              required: true,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _field(
              email,
              'Email address',
              Icons.mail_outline,
              keyboard: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _field(note, 'Note', Icons.note_alt_outlined, lines: 3),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: saving ? null : _save,
        child: Text(saving ? 'Saving...' : 'Save changes'),
      ),
    ],
  );
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    int lines = 1,
    TextInputType? keyboard,
  }) => TextFormField(
    controller: controller,
    maxLines: lines,
    keyboardType: keyboard,
    validator: required
        ? (v) => v == null || v.trim().isEmpty ? '$label is required' : null
        : null,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
    ),
  );
  Future<void> _save() async {
    if (!key.currentState!.validate()) return;
    setState(() => saving = true);
    final response = await context
        .read<ContactLeadProvider>()
        .updateContactLead(
          contactLeadId: '${widget.item['id']}',
          body: {
            'customerName': name.text.trim(),
            'mobile': mobile.text.trim(),
            'email': email.text.trim(),
            'note': note.text.trim(),
          },
        );
    if (!mounted) return;
    if (response != null) {
      Navigator.pop(context, true);
    } else {
      setState(() => saving = false);
    }
  }
}

class _Option {
  const _Option(this.id, this.label, {this.subtitle = ''});
  final String id;
  final String label;
  final String subtitle;
}

enum _BulkAction {
  assign,
  source,
  project,
  interested,
  notInterested,
  convert,
  archive,
}

enum _RowAction { edit, interested, notInterested, convert, archive }

class _CompactLeadBadge extends StatelessWidget {
  const _CompactLeadBadge({
    required this.text,
    required this.foreground,
    required this.background,
    required this.borderColor,
  });

  final String text;
  final Color foreground;
  final Color background;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}
