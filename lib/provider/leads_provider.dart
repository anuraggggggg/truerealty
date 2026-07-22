import 'package:flutter/material.dart';


class LeadProvider extends ChangeNotifier {
  final List<LeadModel> _leads = [
    LeadModel(
      name: "Rahul Sharma",
      email: "rahul.sharma@gmail.com",
      phone: "+919876543210",
      status: "Hot",
    ),
    LeadModel(
      name: "Amit Kumar",
      email: "amit@email.com",
      phone: "+91 98765 00000",
      status: "Qualified",
    ),
    LeadModel(
      name: "Priya Singh",
      email: "priya@email.com",
      phone: "+91 98765 11111",
      status: "Contacted",
    ),
  ];

  List<LeadModel> get leads => _leads;

  int get totalLeads => _leads.length;

  int get hotLeads =>
      _leads.where((e) => e.status == "Hot").length;

  int get qualifiedLeads =>
      _leads.where((e) => e.status == "Qualified").length;

  int get convertedLeads =>
      _leads.where((e) => e.status == "Converted").length;

  void addLead(LeadModel lead) {
    _leads.add(lead);
    notifyListeners();
  }

  void removeLead(int index) {
    _leads.removeAt(index);
    notifyListeners();
  }
}
class LeadModel {
  final String name;
  final String email;
  final String phone;
  final String status;

  LeadModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
  });
}