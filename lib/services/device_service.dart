import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static const _key = 'device_id';
  static Future<String>? _deviceIdFuture;

  static Future<String> getDeviceId() {
    _deviceIdFuture ??= _fetchOrCreateDeviceId();
    return _deviceIdFuture!;
  }

  static Future<String> _fetchOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_key);

    if (id == null || id.trim().isEmpty) {
      id = const Uuid().v4();
      await prefs.setString(_key, id);
    }

    return id;
  }
}
