import 'driver.dart';

class Route {
  final String id;
  final String driverId;
  final Driver driver;
  final String destination;
  final DateTime departureTime;
  final int availableSeats;
  final int totalSeats;
  final double price;
  final String status;
  final DateTime createdAt;

  Route({
    required this.id,
    required this.driverId,
    required this.driver,
    required this.destination,
    required this.departureTime,
    required this.availableSeats,
    required this.totalSeats,
    required this.price,
    required this.status,
    required this.createdAt,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'],
      driverId: json['driverId'],
      driver: Driver.fromJson(json['driver']),
      destination: json['destination'],
      departureTime: DateTime.parse(json['departureTime']),
      availableSeats: json['availableSeats'],
      totalSeats: json['totalSeats'],
      price: json['price'].toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'driver': driver.toJson(),
      'destination': destination,
      'departureTime': departureTime.toIso8601String(),
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'price': price,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
