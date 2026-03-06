import 'package:flutter/material.dart';
import 'package:ssma/screens/customer_screen.dart';
import 'package:ssma/screens/home_screen.dart';
import 'package:ssma/screens/inventory_screen.dart';
import 'package:ssma/screens/new_sale_screen.dart';
import 'package:ssma/screens/sales_history_screen.dart';

import 'services/db_service.dart';
import 'services/device_service.dart';
import 'services/sync_service.dart';

late SyncService syncService; // global singleton

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize database
  await DBService.initializeIsar();

  // 2. Get persistent device ID
  final deviceId = await DeviceService.getDeviceId();

  // 3. Initialize Sync Service
  syncService = SyncService();

  // 4. Run app
  runApp(const MyApp());

  // 5. Trigger initial sync (non-blocking)
  _startInitialSync();
}

Future<void> _startInitialSync() async {
  try {
    await syncService.sync();
    debugPrint("✅ Initial sync completed");
  } catch (e) {
    debugPrint("⚠️ Initial sync failed: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SSMA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        textTheme: ThemeData.light().textTheme.apply(
          fontFamilyFallback: const ['Noto Sans', 'Roboto', 'Arial', 'sans-serif'],
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CustomerScreen(),
    InventoryScreen(),
    NewSaleScreen(),
    SalesHistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSync();
  }

  void _startAutoSync() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 5));
      try {
        await syncService.sync();
        debugPrint("🔄 Auto sync successful");
      } catch (e) {
        debugPrint("⚠️ Auto sync failed: $e");
      }
      return mounted;
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Inventory'),
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'New Sale'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Sales'),
        ],
      ),
    );
  }
}
