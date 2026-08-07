import 'package:flutter/material.dart';
import 'package:truerealtycrm/screen/leads_screen.dart';

/// Telecaller leads tab — same list UI as field executive with pipeline tabs.
class MyLeadsScreen extends StatelessWidget {
  const MyLeadsScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  static const List<String> pipelineTabs = [
    'All',
    'New Lead',
    'Interested',
    'Hot Lead',
    'Site Visit Schedule',
    'Re-Visit Done',
    'Follow Up',
    'OBM Done',
    'Not Interested',
    'Booking Done',
  ];

  @override
  Widget build(BuildContext context) {
    return LeadListWidget(
      isInsideScrollView: onMenuTap != null,
      onMenuTap: onMenuTap,
      statusTabs: pipelineTabs,
    );
  }
}
