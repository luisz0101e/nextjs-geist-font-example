import 'package:kalilu/models/driver.dart';
import 'package:kalilu/models/route.dart';
import 'package:kalilu/models/booking.dart';

class MockDataService {
  static List<Driver> getMockDrivers() {
    return [
      Driver(
        id: '1',
        name: 'Carlos Rodríguez',
        licensePlate: 'ABC-123',
        licenseNumber: 'LIC001234',
        isVerified: true,
        phone: '+593 98 765 4321',
        rating: 4.8,
      ),
      Driver(
        id: '2',
        name: 'María González',
        licensePlate: 'DEF-456',
        licenseNumber: 'LIC005678',
        isVerified: true,
        phone: '+593 99 876 5432',
        rating: 4.9,
      ),
      Driver(
        id: '3',
        name: 'Juan Pérez',
        licensePlate: 'GHI-789',
        licenseNumber: 'LIC009012',
        isVerified: false,
        phone: '+593 96 543 2109',
        rating: 4.5,
      ),
      Driver(
        id: '4',
        name: 'Ana López',
        licensePlate: 'JKL-012',
        licenseNumber: 'LIC003456',
        isVerified: true,
        phone: '+593 97 654 3210',
        rating: 4.7,
      ),
    ];
  }

  static List<Route> getMockRoutes() {
    final drivers = getMockDrivers();
    
    return [
      Route(
        id: '1',
        driverId: '1',
        driver: drivers[0],
        destination: 'Centro Comercial Quicentro',
        departureTime: DateTime.parse('2024-01-15T08:00:00'),
        availableSeats: 2,
        totalSeats: 4,
        price: 2.00,
        status: 'active',
        createdAt: DateTime.parse('2024-01-14T10:00:00'),
      ),
      Route(
        id: '2',
        driverId: '2',
        driver: drivers[1],
        destination: 'Universidad Central del Ecuador',
        departureTime: DateTime.parse('2024-01-15T07:30:00'),
        availableSeats: 1,
        totalSeats: 4,
        price: 1.50,
        status: 'active',
        createdAt: DateTime.parse('2024-01-14T09:30:00'),
      ),
      Route(
        id: '3',
        driverId: '4',
        driver: drivers[3],
        destination: 'Aeropuerto Mariscal Sucre',
        departureTime: DateTime.parse('2024-01-15T06:00:00'),
        availableSeats: 0,
        totalSeats: 4,
        price: 6.25,
        status: 'full',
        createdAt: DateTime.parse('2024-01-14T08:00:00'),
      ),
      Route(
        id: '4',
        driverId: '1',
        driver: drivers[0],
        destination: 'La Mariscal',
        departureTime: DateTime.parse('2024-01-15T18:00:00'),
        availableSeats: 3,
        totalSeats: 4,
        price: 2.50,
        status: 'active',
        createdAt: DateTime.parse('2024-01-14T11:00:00'),
      ),
    ];
  }

  static List<Booking> getMockBookings() {
    return [
      Booking(
        id: '1',
        routeId: '1',
        userId: 'user1',
        userName: 'Pedro Martínez',
        userPhone: '+593 98 123 4567',
        pickupLocation: 'Av. 6 de Diciembre y Colón',
        seatNumber: 1,
        status: 'confirmed',
        createdAt: DateTime.parse('2024-01-14T12:00:00'),
      ),
      Booking(
        id: '2',
        routeId: '1',
        userId: 'user2',
        userName: 'Laura Sánchez',
        userPhone: '+593 99 234 5678',
        pickupLocation: 'Av. Amazonas y Naciones Unidas',
        seatNumber: 2,
        status: 'confirmed',
        createdAt: DateTime.parse('2024-01-14T13:00:00'),
      ),
      Booking(
        id: '3',
        routeId: '2',
        userId: 'user3',
        userName: 'Diego Torres',
        userPhone: '+593 96 345 6789',
        pickupLocation: 'Av. Eloy Alfaro y 12 de Octubre',
        seatNumber: 1,
        status: 'confirmed',
        createdAt: DateTime.parse('2024-01-14T14:00:00'),
      ),
    ];
  }

  static String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)} USD';
  }

  static String formatPhone(String phone) {
    return phone;
  }
}
