import 'package:flutter/material.dart';
import '../models/request.dart';

class RequestProvider with ChangeNotifier {
  final List<Request> _requests = [];

  List<Request> get requests => _requests;

  List<Request> get pendingRequests =>
      _requests.where((r) => r.status == 'Pending').toList();

  void addRequest(Request request) {
    _requests.add(request);
    notifyListeners();
  }

  void updateRequestStatus(String id, String newStatus) {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index != -1) {
      _requests[index].status = newStatus;
      notifyListeners();
    }
  }

  Request? getRequestById(String id) {
    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
}
