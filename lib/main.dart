import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ssma/screens/customer_screen.dart';
import 'package:ssma/screens/home_screen.dart';
import 'package:ssma/screens/inventory_screen.dart';
import 'package:ssma/screens/new_sale_screen.dart';
import 'package:ssma/screens/sales_history_screen.dart';

import 'services/db_service.dart';
import 'services/sync_service.dart';

SyncService? syncService;
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
    final service = SyncService();
    syncService = service;
    final started = await service.start();
    if (!started) {
      debugPrint('LAN sync disabled: startup failed safely.');
      return;
    }
    unawaited(_startInitialSync(service));
  } catch (error, stackTrace) {
    debugPrint('Sync bootstrap failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

Future<void> _startInitialSync(SyncService service) async {
  try {
    await service.sync();
    debugPrint('Initial sync completed');
  } catch (error, stackTrace) {
    debugPrint('Initial sync failed: $error');
    debugPrintStack(stackTrace: stackTrace);
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
    if (kEnableLanSync) {
      _startAutoSync();
    }
  }

  void _startAutoSync() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 5));
      try {
        await syncService?.sync();
        debugPrint('Auto sync successful');
      } catch (error, stackTrace) {
        debugPrint('Auto sync failed: $error');
        debugPrintStack(stackTrace: stackTrace);
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
