class Booking {
  final String id;
  final String routeId;
  final String userId;
  final String userName;
  final String userPhone;
  final String pickupLocation;
  final int seatNumber;
  final String status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.routeId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.pickupLocation,
    required this.seatNumber,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      routeId: json['routeId'],
      userId: json['userId'],
      userName: json['userName'],
      userPhone: json['userPhone'],
      pickupLocation: json['pickupLocation'],
      seatNumber: json['seatNumber'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'pickupLocation': pickupLocation,
      'seatNumber': seatNumber,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
