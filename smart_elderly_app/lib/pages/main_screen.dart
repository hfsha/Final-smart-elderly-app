import 'package:flutter/material.dart';
import 'package:smart_elderly_app/pages/dashboard/dashboard_page.dart';
import 'package:smart_elderly_app/pages/logs/logs_page.dart';
import 'package:smart_elderly_app/pages/settings/settings_page.dart';
import 'package:smart_elderly_app/pages/trends/trends_page.dart';
import 'package:provider/provider.dart';
import 'package:smart_elderly_app/services/sensor_service.dart';
import 'package:smart_elderly_app/widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    DashboardPage(),
    TrendsPage(),
    LogsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1 || index == 2) { // Index 1 is Trends, Index 2 is Logs
      final sensorService = Provider.of<SensorService>(context, listen: false);
      sensorService.fetchTrendsData(
        hours: 24, // You might want to get the selected hours from TrendsPage if it keeps state
        deviceId: 'ELDERLY_MONITOR_001',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Trends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
} 