import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ssma/screens/customer_screen.dart';
import 'package:ssma/screens/home_screen.dart';
import 'package:ssma/screens/inventory_screen.dart';
import 'package:ssma/screens/new_sale_screen.dart';
import 'package:ssma/screens/sales_history_screen.dart';
import 'package:ssma/screens/sync_settings_screen_v2.dart';

import 'services/db_service.dart';
import 'services/device_service.dart';
import 'package:ssma/sync/v2/sync_initializer_v2.dart';

SyncInitializer? sync_initializer_v2;
const bool kEnableLanSync =
    bool.fromEnvironment('ENABLE_LAN_SYNC', defaultValue: true);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PlatformDispatcher error: $error');
    return true;
  };

  await DBService.initializeIsar();
  runApp(const MyApp());
  if (kEnableLanSync) {
    unawaited(_bootstrapSync());
  }
}

Future<void> _bootstrapSync() async {
  try {
    await Future<void>.delayed(const Duration(seconds: 2));

    // ── Sync v2 (new P2P engine) ─────────────────────────────────────────
    syncV2 = SyncInitializerV2(port: 8080);
    await syncV2!.initialize();
    debugPrint('[Bootstrap]: Sync v2 engine initialized (deviceId=${syncV2!.deviceId})');
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
