// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peer_device.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPeerDeviceCollection on Isar {
  IsarCollection<PeerDevice> get peerDevices => this.collection();
}

const PeerDeviceSchema = CollectionSchema(
  name: r'PeerDevice',
  id: -1188724204615970216,
  properties: {
    r'appVersion': PropertySchema(
      id: 0,
      name: r'appVersion',
      type: IsarType.string,
    ),
    r'autoSyncEnabled': PropertySchema(
      id: 1,
      name: r'autoSyncEnabled',
      type: IsarType.bool,
    ),
    r'connectionStatus': PropertySchema(
      id: 2,
      name: r'connectionStatus',
      type: IsarType.string,
    ),
    r'deviceId': PropertySchema(
      id: 3,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'deviceName': PropertySchema(
      id: 4,
      name: r'deviceName',
      type: IsarType.string,
    ),
    r'isPaired': PropertySchema(
      id: 5,
      name: r'isPaired',
      type: IsarType.bool,
    ),
    r'lastKnownIp': PropertySchema(
      id: 6,
      name: r'lastKnownIp',
      type: IsarType.string,
    ),
    r'lastKnownPort': PropertySchema(
      id: 7,
      name: r'lastKnownPort',
      type: IsarType.long,
    ),
    r'lastSeenMs': PropertySchema(
      id: 8,
      name: r'lastSeenMs',
      type: IsarType.long,
    ),
    r'lastSyncMs': PropertySchema(
      id: 9,
      name: r'lastSyncMs',
      type: IsarType.long,
    ),
    r'osVersion': PropertySchema(
      id: 10,
      name: r'osVersion',
      type: IsarType.string,
    ),
    r'pairedAtMs': PropertySchema(
      id: 11,
      name: r'pairedAtMs',
      type: IsarType.long,
    ),
    r'platform': PropertySchema(
      id: 12,
      name: r'platform',
      type: IsarType.string,
    ),
    r'receiveEnabled': PropertySchema(
      id: 13,
      name: r'receiveEnabled',
      type: IsarType.bool,
    ),
    r'registeredAtMs': PropertySchema(
      id: 14,
      name: r'registeredAtMs',
      type: IsarType.long,
    ),
    r'sendEnabled': PropertySchema(
      id: 15,
      name: r'sendEnabled',
      type: IsarType.bool,
    )
  },
  estimateSize: _peerDeviceEstimateSize,
  serialize: _peerDeviceSerialize,
  deserialize: _peerDeviceDeserialize,
  deserializeProp: _peerDeviceDeserializeProp,
  idName: r'id',
  indexes: {
    r'deviceId': IndexSchema(
      id: 4442814072367132509,
      name: r'deviceId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'deviceId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'lastSeenMs': IndexSchema(
      id: 8580165381704194654,
      name: r'lastSeenMs',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastSeenMs',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'connectionStatus': IndexSchema(
      id: -954687986695424102,
      name: r'connectionStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'connectionStatus',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isPaired': IndexSchema(
      id: -5832930451703820772,
      name: r'isPaired',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isPaired',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _peerDeviceGetId,
  getLinks: _peerDeviceGetLinks,
  attach: _peerDeviceAttach,
  version: '3.3.2',
);

int _peerDeviceEstimateSize(
  PeerDevice object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.appVersion.length * 3;
  bytesCount += 3 + object.connectionStatus.length * 3;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.deviceName.length * 3;
  bytesCount += 3 + object.lastKnownIp.length * 3;
  {
    final value = object.osVersion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.platform.length * 3;
  return bytesCount;
}

void _peerDeviceSerialize(
  PeerDevice object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.appVersion);
  writer.writeBool(offsets[1], object.autoSyncEnabled);
  writer.writeString(offsets[2], object.connectionStatus);
  writer.writeString(offsets[3], object.deviceId);
  writer.writeString(offsets[4], object.deviceName);
  writer.writeBool(offsets[5], object.isPaired);
  writer.writeString(offsets[6], object.lastKnownIp);
  writer.writeLong(offsets[7], object.lastKnownPort);
  writer.writeLong(offsets[8], object.lastSeenMs);
  writer.writeLong(offsets[9], object.lastSyncMs);
  writer.writeString(offsets[10], object.osVersion);
  writer.writeLong(offsets[11], object.pairedAtMs);
  writer.writeString(offsets[12], object.platform);
  writer.writeBool(offsets[13], object.receiveEnabled);
  writer.writeLong(offsets[14], object.registeredAtMs);
  writer.writeBool(offsets[15], object.sendEnabled);
}

PeerDevice _peerDeviceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PeerDevice();
  object.appVersion = reader.readString(offsets[0]);
  object.autoSyncEnabled = reader.readBool(offsets[1]);
  object.connectionStatus = reader.readString(offsets[2]);
  object.deviceId = reader.readString(offsets[3]);
  object.deviceName = reader.readString(offsets[4]);
  object.id = id;
  object.isPaired = reader.readBool(offsets[5]);
  object.lastKnownIp = reader.readString(offsets[6]);
  object.lastKnownPort = reader.readLong(offsets[7]);
  object.lastSeenMs = reader.readLong(offsets[8]);
  object.lastSyncMs = reader.readLong(offsets[9]);
  object.osVersion = reader.readStringOrNull(offsets[10]);
  object.pairedAtMs = reader.readLongOrNull(offsets[11]);
  object.platform = reader.readString(offsets[12]);
  object.receiveEnabled = reader.readBool(offsets[13]);
  object.registeredAtMs = reader.readLong(offsets[14]);
  object.sendEnabled = reader.readBool(offsets[15]);
  return object;
}

P _peerDeviceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _peerDeviceGetId(PeerDevice object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _peerDeviceGetLinks(PeerDevice object) {
  return [];
}

void _peerDeviceAttach(IsarCollection<dynamic> col, Id id, PeerDevice object) {
  object.id = id;
}

extension PeerDeviceByIndex on IsarCollection<PeerDevice> {
  Future<PeerDevice?> getByDeviceId(String deviceId) {
    return getByIndex(r'deviceId', [deviceId]);
  }

  PeerDevice? getByDeviceIdSync(String deviceId) {
    return getByIndexSync(r'deviceId', [deviceId]);
  }

  Future<bool> deleteByDeviceId(String deviceId) {
    return deleteByIndex(r'deviceId', [deviceId]);
  }

  bool deleteByDeviceIdSync(String deviceId) {
    return deleteByIndexSync(r'deviceId', [deviceId]);
  }

  Future<List<PeerDevice?>> getAllByDeviceId(List<String> deviceIdValues) {
    final values = deviceIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'deviceId', values);
  }

  List<PeerDevice?> getAllByDeviceIdSync(List<String> deviceIdValues) {
    final values = deviceIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'deviceId', values);
  }

  Future<int> deleteAllByDeviceId(List<String> deviceIdValues) {
    final values = deviceIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'deviceId', values);
  }

  int deleteAllByDeviceIdSync(List<String> deviceIdValues) {
    final values = deviceIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'deviceId', values);
  }

  Future<Id> putByDeviceId(PeerDevice object) {
    return putByIndex(r'deviceId', object);
  }

  Id putByDeviceIdSync(PeerDevice object, {bool saveLinks = true}) {
    return putByIndexSync(r'deviceId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDeviceId(List<PeerDevice> objects) {
    return putAllByIndex(r'deviceId', objects);
  }

  List<Id> putAllByDeviceIdSync(List<PeerDevice> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'deviceId', objects, saveLinks: saveLinks);
  }
}

extension PeerDeviceQueryWhereSort
    on QueryBuilder<PeerDevice, PeerDevice, QWhere> {
  QueryBuilder<PeerDevice, PeerDevice, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhere> anyLastSeenMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastSeenMs'),
      );
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhere> anyIsPaired() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isPaired'),
      );
    });
  }
}

extension PeerDeviceQueryWhere
    on QueryBuilder<PeerDevice, PeerDevice, QWhereClause> {
  QueryBuilder<PeerDevice, PeerDevice, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhereClause> deviceIdEqualTo(
      String deviceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'deviceId',
        value: [deviceId],
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhereClause> deviceIdNotEqualTo(
      String deviceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'deviceId',
              lower: [],
              upper: [deviceId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'deviceId',
              lower: [deviceId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'deviceId',
              lower: [deviceId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'deviceId',
              lower: [],
              upper: [deviceId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhereClause> lastSeenMsEqualTo(
      int lastSeenMs) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastSeenMs',
        value: [lastSeenMs],
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhereClause> lastSeenMsNotEqualTo(
      int lastSeenMs) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastSeenMs',
              lower: [],
              upper: [lastSeenMs],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastSeenMs',
              lower: [lastSeenMs],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastSeenMs',
              lower: [lastSeenMs],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastSeenMs',
              lower: [],
              upper: [lastSeenMs],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhereClause> lastSeenMsGreaterThan(
    int lastSeenMs, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastSeenMs',
        lower: [lastSeenMs],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhereClause> lastSeenMsLessThan(
    int lastSeenMs, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastSeenMs',
        lower: [],
        upper: [lastSeenMs],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhereClause> lastSeenMsBetween(
    int lowerLastSeenMs,
    int upperLastSeenMs, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastSeenMs',
        lower: [lowerLastSeenMs],
        includeLower: includeLower,
        upper: [upperLastSeenMs],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhereClause>
      connectionStatusEqualTo(String connectionStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'connectionStatus',
        value: [connectionStatus],
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhereClause>
      connectionStatusNotEqualTo(String connectionStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'connectionStatus',
              lower: [],
              upper: [connectionStatus],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'connectionStatus',
              lower: [connectionStatus],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'connectionStatus',
              lower: [connectionStatus],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'connectionStatus',
              lower: [],
              upper: [connectionStatus],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhereClause> isPairedEqualTo(
      bool isPaired) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isPaired',
        value: [isPaired],
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterWhereClause> isPairedNotEqualTo(
      bool isPaired) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isPaired',
              lower: [],
              upper: [isPaired],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isPaired',
              lower: [isPaired],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isPaired',
              lower: [isPaired],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isPaired',
              lower: [],
              upper: [isPaired],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PeerDeviceQueryFilter
    on QueryBuilder<PeerDevice, PeerDevice, QFilterCondition> {
  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> appVersionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      appVersionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      appVersionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> appVersionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'appVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      appVersionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      appVersionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      appVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> appVersionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'appVersion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      appVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      appVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'appVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      autoSyncEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoSyncEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      connectionStatusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'connectionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      connectionStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'connectionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      connectionStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'connectionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      connectionStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'connectionStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      connectionStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'connectionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      connectionStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'connectionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      connectionStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'connectionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      connectionStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'connectionStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      connectionStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'connectionStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      connectionStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'connectionStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> deviceIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> deviceIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> deviceNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      deviceNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      deviceNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> deviceNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      deviceNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      deviceNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      deviceNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> deviceNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      deviceNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceName',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      deviceNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceName',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> isPairedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPaired',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastKnownIpEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastKnownIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastKnownIpGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastKnownIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastKnownIpLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastKnownIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastKnownIpBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastKnownIp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastKnownIpStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastKnownIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastKnownIpEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastKnownIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastKnownIpContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastKnownIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastKnownIpMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastKnownIp',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastKnownIpIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastKnownIp',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastKnownIpIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastKnownIp',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastKnownPortEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastKnownPort',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastKnownPortGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastKnownPort',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastKnownPortLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastKnownPort',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastKnownPortBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastKnownPort',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> lastSeenMsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSeenMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastSeenMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSeenMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastSeenMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSeenMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> lastSeenMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSeenMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> lastSyncMsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastSyncMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      lastSyncMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> lastSyncMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      osVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'osVersion',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      osVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'osVersion',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> osVersionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'osVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      osVersionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'osVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> osVersionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'osVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> osVersionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'osVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      osVersionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'osVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> osVersionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'osVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> osVersionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'osVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> osVersionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'osVersion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      osVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'osVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      osVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'osVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      pairedAtMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pairedAtMs',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      pairedAtMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pairedAtMs',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> pairedAtMsEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pairedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      pairedAtMsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pairedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      pairedAtMsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pairedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> pairedAtMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pairedAtMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> platformEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'platform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      platformGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'platform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> platformLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'platform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> platformBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'platform',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      platformStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'platform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> platformEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'platform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> platformContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'platform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition> platformMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'platform',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      platformIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'platform',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      platformIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'platform',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      receiveEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiveEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      registeredAtMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'registeredAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      registeredAtMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'registeredAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      registeredAtMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'registeredAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      registeredAtMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'registeredAtMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterFilterCondition>
      sendEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sendEnabled',
        value: value,
      ));
    });
  }
}

extension PeerDeviceQueryObject
    on QueryBuilder<PeerDevice, PeerDevice, QFilterCondition> {}

extension PeerDeviceQueryLinks
    on QueryBuilder<PeerDevice, PeerDevice, QFilterCondition> {}

extension PeerDeviceQuerySortBy
    on QueryBuilder<PeerDevice, PeerDevice, QSortBy> {
  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByAppVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appVersion', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByAppVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appVersion', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByAutoSyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoSyncEnabled', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy>
      sortByAutoSyncEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoSyncEnabled', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByConnectionStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'connectionStatus', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy>
      sortByConnectionStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'connectionStatus', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByDeviceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByDeviceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByIsPaired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaired', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByIsPairedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaired', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByLastKnownIp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastKnownIp', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByLastKnownIpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastKnownIp', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByLastKnownPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastKnownPort', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByLastKnownPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastKnownPort', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByLastSeenMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenMs', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByLastSeenMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenMs', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByLastSyncMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncMs', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByLastSyncMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncMs', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByOsVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'osVersion', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByOsVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'osVersion', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByPairedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairedAtMs', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByPairedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairedAtMs', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByPlatform() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platform', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByPlatformDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platform', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByReceiveEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiveEnabled', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy>
      sortByReceiveEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiveEnabled', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortByRegisteredAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'registeredAtMs', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy>
      sortByRegisteredAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'registeredAtMs', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortBySendEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendEnabled', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> sortBySendEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendEnabled', Sort.desc);
    });
  }
}

extension PeerDeviceQuerySortThenBy
    on QueryBuilder<PeerDevice, PeerDevice, QSortThenBy> {
  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByAppVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appVersion', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByAppVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appVersion', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByAutoSyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoSyncEnabled', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy>
      thenByAutoSyncEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoSyncEnabled', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByConnectionStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'connectionStatus', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy>
      thenByConnectionStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'connectionStatus', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByDeviceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByDeviceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByIsPaired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaired', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByIsPairedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaired', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByLastKnownIp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastKnownIp', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByLastKnownIpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastKnownIp', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByLastKnownPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastKnownPort', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByLastKnownPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastKnownPort', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByLastSeenMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenMs', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByLastSeenMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenMs', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByLastSyncMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncMs', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByLastSyncMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncMs', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByOsVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'osVersion', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByOsVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'osVersion', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByPairedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairedAtMs', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByPairedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairedAtMs', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByPlatform() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platform', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByPlatformDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platform', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByReceiveEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiveEnabled', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy>
      thenByReceiveEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiveEnabled', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenByRegisteredAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'registeredAtMs', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy>
      thenByRegisteredAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'registeredAtMs', Sort.desc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenBySendEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendEnabled', Sort.asc);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QAfterSortBy> thenBySendEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendEnabled', Sort.desc);
    });
  }
}

extension PeerDeviceQueryWhereDistinct
    on QueryBuilder<PeerDevice, PeerDevice, QDistinct> {
  QueryBuilder<PeerDevice, PeerDevice, QDistinct> distinctByAppVersion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appVersion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QDistinct> distinctByAutoSyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoSyncEnabled');
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QDistinct> distinctByConnectionStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'connectionStatus',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QDistinct> distinctByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QDistinct> distinctByDeviceName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QDistinct> distinctByIsPaired() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPaired');
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QDistinct> distinctByLastKnownIp(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastKnownIp', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QDistinct> distinctByLastKnownPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastKnownPort');
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QDistinct> distinctByLastSeenMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSeenMs');
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QDistinct> distinctByLastSyncMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncMs');
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QDistinct> distinctByOsVersion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'osVersion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QDistinct> distinctByPairedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pairedAtMs');
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QDistinct> distinctByPlatform(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'platform', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QDistinct> distinctByReceiveEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiveEnabled');
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QDistinct> distinctByRegisteredAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'registeredAtMs');
    });
  }

  QueryBuilder<PeerDevice, PeerDevice, QDistinct> distinctBySendEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sendEnabled');
    });
  }
}

extension PeerDeviceQueryProperty
    on QueryBuilder<PeerDevice, PeerDevice, QQueryProperty> {
  QueryBuilder<PeerDevice, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PeerDevice, String, QQueryOperations> appVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appVersion');
    });
  }

  QueryBuilder<PeerDevice, bool, QQueryOperations> autoSyncEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoSyncEnabled');
    });
  }

  QueryBuilder<PeerDevice, String, QQueryOperations>
      connectionStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'connectionStatus');
    });
  }

  QueryBuilder<PeerDevice, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<PeerDevice, String, QQueryOperations> deviceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceName');
    });
  }

  QueryBuilder<PeerDevice, bool, QQueryOperations> isPairedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPaired');
    });
  }

  QueryBuilder<PeerDevice, String, QQueryOperations> lastKnownIpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastKnownIp');
    });
  }

  QueryBuilder<PeerDevice, int, QQueryOperations> lastKnownPortProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastKnownPort');
    });
  }

  QueryBuilder<PeerDevice, int, QQueryOperations> lastSeenMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSeenMs');
    });
  }

  QueryBuilder<PeerDevice, int, QQueryOperations> lastSyncMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncMs');
    });
  }

  QueryBuilder<PeerDevice, String?, QQueryOperations> osVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'osVersion');
    });
  }

  QueryBuilder<PeerDevice, int?, QQueryOperations> pairedAtMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pairedAtMs');
    });
  }

  QueryBuilder<PeerDevice, String, QQueryOperations> platformProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'platform');
    });
  }

  QueryBuilder<PeerDevice, bool, QQueryOperations> receiveEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiveEnabled');
    });
  }

  QueryBuilder<PeerDevice, int, QQueryOperations> registeredAtMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'registeredAtMs');
    });
  }

  QueryBuilder<PeerDevice, bool, QQueryOperations> sendEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sendEnabled');
    });
  }
}
