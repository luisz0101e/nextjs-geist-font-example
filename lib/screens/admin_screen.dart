import 'package:flutter/material.dart';
import 'package:kalilu/models/driver.dart';
import 'package:kalilu/models/route.dart';
import 'package:kalilu/services/mock_data_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final drivers = MockDataService.getMockDrivers();
    final routes = MockDataService.getMockRoutes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: _selectedIndex == 0
          ? _buildDashboardView(drivers, routes)
          : _buildManagementView(drivers, routes),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_accounts),
            label: 'Gestión',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardView(List<Driver> drivers, List<Route> routes) {
    final verifiedDrivers = drivers.where((d) => d.isVerified).length;
    final pendingDrivers = drivers.where((d) => !d.isVerified).length;
    final activeRoutes = routes.where((r) => r.status == 'active').length;
    final fullRoutes = routes.where((r) => r.status == 'full').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas Generales',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Conductores',
                  drivers.length.toString(),
                  Icons.people,
                  Colors.blue,
                  subtitle: '$verifiedDrivers verificados',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pendientes',
                  pendingDrivers.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Rutas Activas',
                  activeRoutes.toString(),
                  Icons.directions_car,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Rutas Llenas',
                  fullRoutes.toString(),
                  Icons.event_busy,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Ingresos Estimados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    '\$125.50 USD',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Ingresos mensuales estimados',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementView(List<Driver> drivers, List<Route> routes) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Conductores'),
              Tab(text: 'Rutas'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildDriversList(drivers),
                _buildRoutesList(routes),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriversList(List<Driver> drivers) {
    return ListView.builder(
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final driver = drivers[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: driver.isVerified ? Colors.green : Colors.orange,
              child: Icon(
                driver.isVerified ? Icons.check : Icons.pending,
                color: Colors.white,
              ),
            ),
            title: Text(driver.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(driver.licensePlate),
                Text(driver.phone),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(' ${driver.rating}'),
                  ],
                ),
              ],
            ),
            trailing: Switch(
              value: driver.isVerified,
              onChanged: (value) {
                // Actualizar estado del conductor
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoutesList(List<Route> routes) {
    return ListView.builder(
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(route.destination),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Conductor: ${route.driver.name}'),
                Text('Precio: \$${route.price.toStringAsFixed(2)} USD'),
                Text('Asientos: ${route.availableSeats}/${route.totalSeats}'),
                Text('Estado: ${route.status}'),
              ],
            ),
            trailing: Chip(
              label: Text(route.status),
              backgroundColor: route.status == 'active'
                  ? Colors.green[100]
                  : route.status == 'full'
                      ? Colors.red[100]
                      : Colors.grey[100],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
