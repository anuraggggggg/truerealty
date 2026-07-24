import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<_NotificationItem> _notifications = const [];
  bool _isLoading = true;
  bool _isMarkingAllRead = false;
  bool _showUnreadOnly = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadNotifications();
      }
    });
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final provider = context.read<NotificationProvider>();
    final response = await provider.fetchNotifications(limit: 100);

    if (!mounted) {
      return;
    }

    setState(() {
      _notifications = response?.data == null
          ? _notifications
          : _extractApiList(
              response?.data,
            ).map(_NotificationItem.fromJson).toList();
      _error = response == null ? provider.error : null;
      _isLoading = false;
    });
  }

  Future<void> _markAllRead() async {
    setState(() => _isMarkingAllRead = true);

    final provider = context.read<NotificationProvider>();
    final response = await provider.markAllNotificationsRead();

    if (!mounted) {
      return;
    }

    if (response == null) {
      setState(() {
        _error = provider.error ?? 'Unable to mark notifications as read.';
        _isMarkingAllRead = false;
      });
      return;
    }

    setState(() {
      _notifications = _notifications.map((item) => item.copyAsRead()).toList();
      _isMarkingAllRead = false;
      _error = null;
    });
  }

  Future<void> _markRead(_NotificationItem notification) async {
    if (notification.id == null || notification.isRead) {
      return;
    }

    await context.read<NotificationProvider>().markNotificationRead(
      notification.id!,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _notifications = _notifications
          .map((item) => item.id == notification.id ? item.copyAsRead() : item)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleNotifications = _showUnreadOnly
        ? _notifications.where((item) => !item.isRead).toList()
        : _notifications;
    final unreadCount = _notifications.where((item) => !item.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.orangeDeep,
          onRefresh: _loadNotifications,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              width: 40.w,
                              height: 40.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFFD9E3EF),
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18.sp,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Notifications',
                                  style: GoogleFonts.inter(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.navy,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Stay updated with important alerts and activities.',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _MarkAllReadButton(
                            isLoading: _isMarkingAllRead,
                            onTap: unreadCount == 0 || _isMarkingAllRead
                                ? null
                                : _markAllRead,
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      _NotificationTabs(
                        unreadCount: unreadCount,
                        showUnreadOnly: _showUnreadOnly,
                        onChanged: (value) {
                          setState(() => _showUnreadOnly = value);
                        },
                      ),
                      if (_error != null) ...[
                        SizedBox(height: 14.h),
                        _NotificationErrorCard(
                          message: _error!,
                          onRetry: _loadNotifications,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                const SliverToBoxAdapter(child: LinearProgressIndicator())
              else if (visibleNotifications.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyNotificationsState(
                    showUnreadOnly: _showUnreadOnly,
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 24.h),
                  sliver: SliverList.separated(
                    itemCount: visibleNotifications.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final item = visibleNotifications[index];
                      return _NotificationCard(
                        item: item,
                        onTap: () => _markRead(item),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkAllReadButton extends StatelessWidget {
  const _MarkAllReadButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: isLoading
          ? SizedBox(
              width: 14.w,
              height: 14.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.done_rounded, size: 16.sp),
      label: Text(
        'Mark all read',
        style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w700),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navy,
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFD9E3EF)),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}

class _NotificationTabs extends StatelessWidget {
  const _NotificationTabs({
    required this.unreadCount,
    required this.showUnreadOnly,
    required this.onChanged,
  });

  final int unreadCount;
  final bool showUnreadOnly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabButton(
          label: 'All',
          active: !showUnreadOnly,
          onTap: () => onChanged(false),
        ),
        SizedBox(width: 22.w),
        _TabButton(
          label: unreadCount == 0 ? 'Unread' : 'Unread ($unreadCount)',
          active: showUnreadOnly,
          onTap: () => onChanged(true),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: active ? AppColors.orangeDeep : const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: 24.w,
              height: 2.h,
              decoration: BoxDecoration(
                color: active ? AppColors.orangeDeep : Colors.transparent,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationErrorCard extends StatelessWidget {
  const _NotificationErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD9E3EF)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: const Color(0xFFB91C1C),
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final _NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = item.isRead
        ? const Color(0xFF64748B)
        : AppColors.orangeDeep;
    final iconBg = item.isRead
        ? const Color(0xFFF1F5F9)
        : const Color(0xFFFFECE8);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFD9E3EF)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 19.r,
              backgroundColor: iconBg,
              child: Icon(Icons.link_rounded, color: iconColor, size: 19.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: const Color(0xFF53657D),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (item.badge != null)
                        _NotificationBadge(label: item.badge!),
                      if (item.leadDisplayId != null)
                        _NotificationBadge(label: item.leadDisplayId!),
                      if (!item.isRead)
                        const _NotificationBadge(
                          label: 'Unread',
                          highlighted: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              _relativeTime(item.createdAt),
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.label, this.highlighted = false});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.orangeSoft : const Color(0xFFEFF4FA),
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(
          color: highlighted
              ? const Color(0xFFFFC9AA)
              : const Color(0xFFD9E3EF),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: highlighted ? AppColors.orangeDeep : const Color(0xFF53657D),
        ),
      ),
    );
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState({required this.showUnreadOnly});

  final bool showUnreadOnly;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28.r,
              backgroundColor: const Color(0xFFEFF4FA),
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.navy,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              showUnreadOnly
                  ? 'No unread notifications.'
                  : 'No notifications yet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Pull down to refresh.',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.message,
    required this.badge,
    required this.leadDisplayId,
    required this.createdAt,
    required this.readAt,
  });

  final String? id;
  final String title;
  final String description;
  final String message;
  final String? badge;
  final String? leadDisplayId;
  final DateTime? createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  _NotificationItem copyAsRead() {
    return _NotificationItem(
      id: id,
      title: title,
      description: description,
      message: message,
      badge: badge,
      leadDisplayId: leadDisplayId,
      createdAt: createdAt,
      readAt: DateTime.now(),
    );
  }

  factory _NotificationItem.fromJson(Object? source) {
    final map = source is Map
        ? Map<String, dynamic>.from(source)
        : <String, dynamic>{};
    final detailsValue = map['details'];
    final details = detailsValue is Map
        ? Map<String, dynamic>.from(detailsValue)
        : const <String, dynamic>{};
    final description =
        _readString(map, const ['description']) ??
        _readString(map, const ['message']) ??
        'Notification update';

    return _NotificationItem(
      id: _readString(map, const ['id', '_id', 'notificationId']),
      title: _readString(map, const ['title']) ?? 'Notification',
      description: description,
      message: _readString(map, const ['message']) ?? '',
      badge: _readString(map, const ['badge', 'type']),
      leadDisplayId: _readString(details, const ['leadDisplayId', 'displayId']),
      createdAt: _readDate(map, const ['createdAt', 'created_at']),
      readAt: _readDate(map, const ['readAt', 'read_at']),
    );
  }
}

List<dynamic> _extractApiList(Object? source) {
  if (source is List) {
    return source;
  }

  if (source is Map) {
    for (final key in const [
      'data',
      'items',
      'results',
      'rows',
      'records',
      'docs',
      'notifications',
    ]) {
      final value = source[key];
      if (value is List) {
        return value;
      }
      if (value is Map) {
        final nested = _extractApiList(value);
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    }
  }

  return const [];
}

String? _readString(Map<String, dynamic>? map, List<String> keys) {
  if (map == null) {
    return null;
  }

  for (final key in keys) {
    final value = _readValue(map, key);
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return null;
}

DateTime? _readDate(Map<String, dynamic> map, List<String> keys) {
  final text = _readString(map, keys);
  if (text == null) {
    return null;
  }
  return DateTime.tryParse(text)?.toLocal();
}

Object? _readValue(Map<String, dynamic> map, String key) {
  if (map.containsKey(key)) {
    return map[key];
  }
  final normalizedKey = key.toLowerCase();
  for (final entry in map.entries) {
    if (entry.key.toString().toLowerCase() == normalizedKey) {
      return entry.value;
    }
  }
  return null;
}

String _relativeTime(DateTime? date) {
  if (date == null) {
    return 'Recently';
  }
  final now = DateTime.now();
  final difference = now.difference(date);
  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes} mins ago';
  if (difference.inHours < 24) return '${difference.inHours} hours ago';
  if (difference.inDays == 1) return 'Yesterday';
  return '${difference.inDays} days ago';
}
