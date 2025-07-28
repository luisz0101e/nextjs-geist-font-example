import 'package:flutter/material.dart';
import 'package:kalilu/models/driver.dart';
import 'package:kalilu/models/route.dart';
import 'package:kalilu/models/booking.dart';
import 'package:kalilu/services/mock_data_service.dart';

class AppProvider extends ChangeNotifier {
  List<Driver> _drivers = [];
  List<Route> _routes = [];
  List<Booking> _bookings = [];
  List<Booking> _userBookings = [];
  Route? _activeRoute;
  Driver? _currentDriver;

  List<Driver> get drivers => _drivers;
  List<Route> get routes => _routes;
  List<Booking> get bookings => _bookings;
  List<Booking> get userBookings => _userBookings;
  Route? get activeRoute => _activeRoute;
  Driver? get currentDriver => _currentDriver;

  AppProvider() {
    _loadInitialData();
  }

  void _loadInitialData() {
    _drivers = MockDataService.getMockDrivers();
    _routes = MockDataService.getMockRoutes();
    _bookings = MockDataService.getMockBookings();
    _currentDriver = _drivers.first;
  }

  List<Route> getAvailableRoutes() {
    return _routes.where((route) => 
      route.status == 'active' && route.availableSeats > 0
    ).toList();
  }

  List<Route> searchRoutes(String destination, DateTime? dateTime) {
    var filtered = getAvailableRoutes();
    
    if (destination.isNotEmpty) {
      filtered = filtered.where((route) =>
        route.destination.toLowerCase().contains(destination.toLowerCase())
      ).toList();
    }
    
    if (dateTime != null) {
      filtered = filtered.where((route) =>
        route.departureTime.year == dateTime.year &&
        route.departureTime.month == dateTime.month &&
        route.departureTime.day == dateTime.day
      ).toList();
    }
    
    return filtered;
  }

  void createRoute({
    required String destination,
    required DateTime departureTime,
    required int totalSeats,
    required double price,
  }) {
    final newRoute = Route(
      id: 'route_${DateTime.now().millisecondsSinceEpoch}',
      driverId: _currentDriver!.id,
      driver: _currentDriver!,
      destination: destination,
      departureTime: departureTime,
      availableSeats: totalSeats,
      totalSeats: totalSeats,
      price: price,
      status: 'active',
      createdAt: DateTime.now(),
    );
    
    _routes.add(newRoute);
    _activeRoute = newRoute;
    notifyListeners();
  }

  void bookRoute({
    required String routeId,
    required String userName,
    required String userPhone,
    required String pickupLocation,
    required int seatNumber,
  }) {
    final route = _routes.firstWhere((r) => r.id == routeId);
    final newBooking = Booking(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      routeId: routeId,
      userId: 'current_user',
      userName: userName,
      userPhone: userPhone,
      pickupLocation: pickupLocation,
      seatNumber: seatNumber,
      status: 'confirmed',
      createdAt: DateTime.now(),
    );
    
    _bookings.add(newBooking);
    _userBookings.add(newBooking);
    
    // Update route availability
    final index = _routes.indexWhere((r) => r.id == routeId);
    if (index != -1) {
      final updatedRoute = Route(
        id: route.id,
        driverId: route.driverId,
        driver: route.driver,
        destination: route.destination,
        departureTime: route.departureTime,
        availableSeats: route.availableSeats - 1,
        totalSeats: route.totalSeats,
        price: route.price,
        status: route.availableSeats - 1 == 0 ? 'full' : route.status,
        createdAt: route.createdAt,
      );
      _routes[index] = updatedRoute;
    }
    
    notifyListeners();
  }

  void cancelRoute() {
    _activeRoute = null;
    notifyListeners();
  }

  List<Booking> getRouteBookings(String routeId) {
    return _bookings.where((booking) => booking.routeId == routeId).toList();
  }

  double getEstimatedIncome(String routeId) {
    final route = _routes.firstWhere((r) => r.id == routeId);
    final bookings = getRouteBookings(routeId);
    return bookings.length * route.price;
  }
}
