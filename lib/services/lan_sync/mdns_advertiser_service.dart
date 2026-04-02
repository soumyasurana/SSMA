import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class MdnsAdvertiserService {
  MdnsAdvertiserService({
    required this.deviceId,
    required this.port,
    required this.serviceType,
  })  : instanceName = 'isar-sync-$deviceId.$serviceType',
        hostName = 'isar-sync-$deviceId.local';

  final String deviceId;
  final int port;
  final String serviceType;
  final String instanceName;
  final String hostName;

  RawDatagramSocket? _socket;
  InternetAddress? _ipv4Address;
  StreamSubscription<RawSocketEvent>? _subscription;

  Future<void> start() async {
    if (_socket != null) {
      return;
    }

    _ipv4Address = await _resolvePrimaryIpv4();
    if (_ipv4Address == null) {
      return;
    }

    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      5353,
      reuseAddress: true,
      reusePort: true,
    );

    socket.joinMulticast(InternetAddress('224.0.0.251'));
    socket.multicastLoopback = true;
    _socket = socket;

    _subscription = socket.listen((event) {
      if (event != RawSocketEvent.read) {
        return;
      }
      final datagram = socket.receive();
      if (datagram == null) {
        return;
      }
      _handleQuery(datagram);
    });
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _socket?.close();
    _socket = null;
  }

  Future<InternetAddress?> _resolvePrimaryIpv4() async {
    final interfaces = await NetworkInterface.list(
      includeLinkLocal: false,
      type: InternetAddressType.IPv4,
    );
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (!address.isLoopback) {
          return address;
        }
      }
    }
    return null;
  }

  void _handleQuery(Datagram datagram) {
    final socket = _socket;
    final ipv4Address = _ipv4Address;
    if (socket == null || ipv4Address == null) {
      return;
    }

    final data = datagram.data;
    if (data.length < 12) {
      return;
    }

    final questionCount = (data[4] << 8) | data[5];
    if (questionCount == 0) {
      return;
    }

    var offset = 12;
    var shouldRespond = false;

    for (var i = 0; i < questionCount; i++) {
      final parsedName = _readName(data, offset);
      final name = parsedName.$1;
      offset = parsedName.$2;
      if (offset + 4 > data.length) {
        return;
      }
      final type = (data[offset] << 8) | data[offset + 1];
      offset += 4;

      final matchesService = name == serviceType || name == instanceName;
      final matchesHost = name == hostName;
      final wantsAny = type == 255;
      final wantsPtr = type == 12;
      final wantsSrv = type == 33;
      final wantsTxt = type == 16;
      final wantsA = type == 1;

      if ((matchesService && (wantsPtr || wantsAny)) ||
          (matchesService && name == instanceName && (wantsSrv || wantsTxt)) ||
          (matchesHost && (wantsA || wantsAny)) ||
          (name == instanceName && (wantsSrv || wantsTxt || wantsAny))) {
        shouldRespond = true;
      }
    }

    if (!shouldRespond) {
      return;
    }

    final response = BytesBuilder();
    response.add(_header(answerCount: 4));
    response.add(_ptrRecord(serviceType, instanceName, ttl: 120));
    response.add(_srvRecord(instanceName, hostName, port, ttl: 120));
    response.add(_txtRecord(instanceName, ['deviceId=$deviceId'], ttl: 120));
    response.add(_aRecord(hostName, ipv4Address, ttl: 120));

    socket.send(
      response.takeBytes(),
      InternetAddress('224.0.0.251'),
      5353,
    );
  }

  Uint8List _header({required int answerCount}) {
    return Uint8List.fromList([
      0x00,
      0x00,
      0x84,
      0x00,
      0x00,
      0x00,
      0x00,
      answerCount,
      0x00,
      0x00,
      0x00,
      0x00,
    ]);
  }

  Uint8List _ptrRecord(String name, String target, {required int ttl}) {
    final targetBytes = _encodeName(target);
    final record = BytesBuilder();
    record.add(_encodeName(name));
    record.add(_u16(12));
    record.add(_u16(1));
    record.add(_u32(ttl));
    record.add(_u16(targetBytes.length));
    record.add(targetBytes);
    return record.takeBytes();
  }

  Uint8List _srvRecord(
    String name,
    String target,
    int port, {
    required int ttl,
  }) {
    final targetBytes = _encodeName(target);
    final data = BytesBuilder()
      ..add(_u16(0))
      ..add(_u16(0))
      ..add(_u16(port))
      ..add(targetBytes);
    final payload = data.takeBytes();

    final record = BytesBuilder();
    record.add(_encodeName(name));
    record.add(_u16(33));
    record.add(_u16(1));
    record.add(_u32(ttl));
    record.add(_u16(payload.length));
    record.add(payload);
    return record.takeBytes();
  }

  Uint8List _txtRecord(String name, List<String> entries, {required int ttl}) {
    final data = BytesBuilder();
    for (final entry in entries) {
      final bytes = Uint8List.fromList(entry.codeUnits);
      data.add([bytes.length]);
      data.add(bytes);
    }
    final payload = data.takeBytes();

    final record = BytesBuilder();
    record.add(_encodeName(name));
    record.add(_u16(16));
    record.add(_u16(1));
    record.add(_u32(ttl));
    record.add(_u16(payload.length));
    record.add(payload);
    return record.takeBytes();
  }

  Uint8List _aRecord(String name, InternetAddress address, {required int ttl}) {
    final record = BytesBuilder();
    record.add(_encodeName(name));
    record.add(_u16(1));
    record.add(_u16(1));
    record.add(_u32(ttl));
    record.add(_u16(4));
    record.add(address.rawAddress);
    return record.takeBytes();
  }

  Uint8List _encodeName(String name) {
    final builder = BytesBuilder();
    for (final label in name.split('.')) {
      if (label.isEmpty) {
        continue;
      }
      final bytes = Uint8List.fromList(label.codeUnits);
      builder.add([bytes.length]);
      builder.add(bytes);
    }
    builder.add([0]);
    return builder.takeBytes();
  }

  Uint8List _u16(int value) {
    return Uint8List.fromList([(value >> 8) & 0xff, value & 0xff]);
  }

  Uint8List _u32(int value) {
    return Uint8List.fromList([
      (value >> 24) & 0xff,
      (value >> 16) & 0xff,
      (value >> 8) & 0xff,
      value & 0xff,
    ]);
  }

  (String, int) _readName(Uint8List data, int offset) {
    final labels = <String>[];
    var index = offset;
    var jumped = false;
    var nextOffset = offset;

    while (index < data.length) {
      final length = data[index];
      if (length == 0) {
        if (!jumped) {
          nextOffset = index + 1;
        }
        break;
      }

      if ((length & 0xc0) == 0xc0) {
        final pointer = ((length & 0x3f) << 8) | data[index + 1];
        final result = _readName(data, pointer);
        labels.add(result.$1);
        if (!jumped) {
          nextOffset = index + 2;
        }
        jumped = true;
        break;
      }

      final start = index + 1;
      final end = start + length;
      labels.add(String.fromCharCodes(data.sublist(start, end)));
      index = end;
      if (!jumped) {
        nextOffset = index;
      }
    }

    return (labels.join('.'), nextOffset);
  }
}
