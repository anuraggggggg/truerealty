import 'package:flutter/material.dart';

class SiteVisitModel {
  final String leadName;
  final String project;
  final String date;
  final String time;
  final String status;
  final String type;

  SiteVisitModel({
    required this.leadName,
    required this.project,
    required this.date,
    required this.time,
    required this.status,
    required this.type,
  });
}

class SiteVisitProvider extends ChangeNotifier {
  final List<SiteVisitModel> _siteVisits = [
    SiteVisitModel(
      leadName: "Rahul Sharma",
      project: "Green Valley",
      date: "15 June, 2026",
      time: "10:30 AM",
      status: "Scheduled",
      type: "Initial",
    ),
    SiteVisitModel(
      leadName: "Priya Mehta",
      project: "Skyline Residency",
      date: "16 June, 2026",
      time: "02:00 PM",
      status: "Completed",
      type: "Follow-up",
    ),
    SiteVisitModel(
      leadName: "Amit Singh",
      project: "Emerald Heights",
      date: "17 June, 2026",
      time: "11:00 AM",
      status: "Cancelled",
      type: "Initial",
    ),
    SiteVisitModel(
      leadName: "Sanjay Gupta",
      project: "Green Valley",
      date: "18 June, 2026",
      time: "04:30 PM",
      status: "Scheduled",
      type: "Initial",
    ),
  ];

  List<SiteVisitModel> get siteVisits => _siteVisits;

  int get totalVisits => _siteVisits.length;
  int get scheduledVisits => _siteVisits.where((v) => v.status == "Scheduled").length;
  int get completedVisits => _siteVisits.where((v) => v.status == "Completed").length;
  int get cancelledVisits => _siteVisits.where((v) => v.status == "Cancelled").length;
}
