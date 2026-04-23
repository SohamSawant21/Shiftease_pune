class Request {
  final String id;
  final String name;
  final String phone;
  final String location;
  final DateTime dateTime;
  final int duration;
  final int helpers;
  final double payment;
  String status; 

  Request({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
    required this.dateTime,
    required this.duration,
    required this.helpers,
    required this.payment,
    this.status = 'Pending',
  });
}
