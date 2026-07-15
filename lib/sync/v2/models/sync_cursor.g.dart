// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_cursor.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncCursorCollection on Isar {
  IsarCollection<SyncCursor> get syncCursors => this.collection();
}

const SyncCursorSchema = CollectionSchema(
  name: r'SyncCursor',
  id: 355982195539933157,
  properties: {
    r'lastFullSyncMs': PropertySchema(
      id: 0,
      name: r'lastFullSyncMs',
      type: IsarType.long,
    ),
    r'lastPullCount': PropertySchema(
      id: 1,
      name: r'lastPullCount',
      type: IsarType.long,
    ),
    r'lastPullMs': PropertySchema(
      id: 2,
      name: r'lastPullMs',
      type: IsarType.long,
    ),
    r'lastPushCount': PropertySchema(
      id: 3,
      name: r'lastPushCount',
      type: IsarType.long,
    ),
    r'lastPushMs': PropertySchema(
      id: 4,
      name: r'lastPushMs',
      type: IsarType.long,
    ),
    r'lastReceivedSeq': PropertySchema(
      id: 5,
      name: r'lastReceivedSeq',
      type: IsarType.long,
    ),
    r'lastSentSeq': PropertySchema(
      id: 6,
      name: r'lastSentSeq',
      type: IsarType.long,
    ),
    r'remoteDeviceId': PropertySchema(
      id: 7,
      name: r'remoteDeviceId',
      type: IsarType.string,
    ),
    r'totalReceived': PropertySchema(
      id: 8,
      name: r'totalReceived',
      type: IsarType.long,
    ),
    r'totalSent': PropertySchema(
      id: 9,
      name: r'totalSent',
      type: IsarType.long,
    )
  },
  estimateSize: _syncCursorEstimateSize,
  serialize: _syncCursorSerialize,
  deserialize: _syncCursorDeserialize,
  deserializeProp: _syncCursorDeserializeProp,
  idName: r'id',
  indexes: {
    r'remoteDeviceId': IndexSchema(
      id: 706327905002303788,
      name: r'remoteDeviceId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'remoteDeviceId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _syncCursorGetId,
  getLinks: _syncCursorGetLinks,
  attach: _syncCursorAttach,
  version: '3.1.0+1',
);

int _syncCursorEstimateSize(
  SyncCursor object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.remoteDeviceId.length * 3;
  return bytesCount;
}

void _syncCursorSerialize(
  SyncCursor object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.lastFullSyncMs);
  writer.writeLong(offsets[1], object.lastPullCount);
  writer.writeLong(offsets[2], object.lastPullMs);
  writer.writeLong(offsets[3], object.lastPushCount);
  writer.writeLong(offsets[4], object.lastPushMs);
  writer.writeLong(offsets[5], object.lastReceivedSeq);
  writer.writeLong(offsets[6], object.lastSentSeq);
  writer.writeString(offsets[7], object.remoteDeviceId);
  writer.writeLong(offsets[8], object.totalReceived);
  writer.writeLong(offsets[9], object.totalSent);
}

SyncCursor _syncCursorDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncCursor();
  object.id = id;
  object.lastFullSyncMs = reader.readLong(offsets[0]);
  object.lastPullCount = reader.readLong(offsets[1]);
  object.lastPullMs = reader.readLong(offsets[2]);
  object.lastPushCount = reader.readLong(offsets[3]);
  object.lastPushMs = reader.readLong(offsets[4]);
  object.lastReceivedSeq = reader.readLong(offsets[5]);
  object.lastSentSeq = reader.readLong(offsets[6]);
  object.remoteDeviceId = reader.readString(offsets[7]);
  object.totalReceived = reader.readLong(offsets[8]);
  object.totalSent = reader.readLong(offsets[9]);
  return object;
}

P _syncCursorDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncCursorGetId(SyncCursor object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syncCursorGetLinks(SyncCursor object) {
  return [];
}

void _syncCursorAttach(IsarCollection<dynamic> col, Id id, SyncCursor object) {
  object.id = id;
}

extension SyncCursorByIndex on IsarCollection<SyncCursor> {
  Future<SyncCursor?> getByRemoteDeviceId(String remoteDeviceId) {
    return getByIndex(r'remoteDeviceId', [remoteDeviceId]);
  }

  SyncCursor? getByRemoteDeviceIdSync(String remoteDeviceId) {
    return getByIndexSync(r'remoteDeviceId', [remoteDeviceId]);
  }

  Future<bool> deleteByRemoteDeviceId(String remoteDeviceId) {
    return deleteByIndex(r'remoteDeviceId', [remoteDeviceId]);
  }

  bool deleteByRemoteDeviceIdSync(String remoteDeviceId) {
    return deleteByIndexSync(r'remoteDeviceId', [remoteDeviceId]);
  }

  Future<List<SyncCursor?>> getAllByRemoteDeviceId(
      List<String> remoteDeviceIdValues) {
    final values = remoteDeviceIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'remoteDeviceId', values);
  }

  List<SyncCursor?> getAllByRemoteDeviceIdSync(
      List<String> remoteDeviceIdValues) {
    final values = remoteDeviceIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'remoteDeviceId', values);
  }

  Future<int> deleteAllByRemoteDeviceId(List<String> remoteDeviceIdValues) {
    final values = remoteDeviceIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'remoteDeviceId', values);
  }

  int deleteAllByRemoteDeviceIdSync(List<String> remoteDeviceIdValues) {
    final values = remoteDeviceIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'remoteDeviceId', values);
  }

  Future<Id> putByRemoteDeviceId(SyncCursor object) {
    return putByIndex(r'remoteDeviceId', object);
  }

  Id putByRemoteDeviceIdSync(SyncCursor object, {bool saveLinks = true}) {
    return putByIndexSync(r'remoteDeviceId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRemoteDeviceId(List<SyncCursor> objects) {
    return putAllByIndex(r'remoteDeviceId', objects);
  }

  List<Id> putAllByRemoteDeviceIdSync(List<SyncCursor> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'remoteDeviceId', objects, saveLinks: saveLinks);
  }
}

extension SyncCursorQueryWhereSort
    on QueryBuilder<SyncCursor, SyncCursor, QWhere> {
  QueryBuilder<SyncCursor, SyncCursor, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyncCursorQueryWhere
    on QueryBuilder<SyncCursor, SyncCursor, QWhereClause> {
  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> idBetween(
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

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> remoteDeviceIdEqualTo(
      String remoteDeviceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'remoteDeviceId',
        value: [remoteDeviceId],
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause>
      remoteDeviceIdNotEqualTo(String remoteDeviceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remoteDeviceId',
              lower: [],
              upper: [remoteDeviceId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remoteDeviceId',
              lower: [remoteDeviceId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remoteDeviceId',
              lower: [remoteDeviceId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remoteDeviceId',
              lower: [],
              upper: [remoteDeviceId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SyncCursorQueryFilter
    on QueryBuilder<SyncCursor, SyncCursor, QFilterCondition> {
  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastFullSyncMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastFullSyncMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastFullSyncMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastFullSyncMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastFullSyncMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastFullSyncMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastFullSyncMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastFullSyncMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastPullCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPullCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastPullCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPullCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastPullCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPullCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastPullCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPullCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> lastPullMsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPullMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastPullMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPullMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastPullMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPullMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> lastPullMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPullMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastPushCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPushCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastPushCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPushCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastPushCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPushCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastPushCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPushCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> lastPushMsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPushMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastPushMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPushMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastPushMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPushMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> lastPushMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPushMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedSeqEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReceivedSeq',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedSeqGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReceivedSeq',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedSeqLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReceivedSeq',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedSeqBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReceivedSeq',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentSeqEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSentSeq',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentSeqGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSentSeq',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentSeqLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSentSeq',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentSeqBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSentSeq',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      remoteDeviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      remoteDeviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remoteDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      remoteDeviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remoteDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      remoteDeviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remoteDeviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      remoteDeviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'remoteDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      remoteDeviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'remoteDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      remoteDeviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'remoteDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      remoteDeviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'remoteDeviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      remoteDeviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteDeviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      remoteDeviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'remoteDeviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      totalReceivedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalReceived',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      totalReceivedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalReceived',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      totalReceivedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalReceived',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      totalReceivedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalReceived',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> totalSentEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSent',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      totalSentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalSent',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> totalSentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalSent',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> totalSentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalSent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SyncCursorQueryObject
    on QueryBuilder<SyncCursor, SyncCursor, QFilterCondition> {}

extension SyncCursorQueryLinks
    on QueryBuilder<SyncCursor, SyncCursor, QFilterCondition> {}

extension SyncCursorQuerySortBy
    on QueryBuilder<SyncCursor, SyncCursor, QSortBy> {
  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByLastFullSyncMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFullSyncMs', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      sortByLastFullSyncMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFullSyncMs', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByLastPullCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPullCount', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByLastPullCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPullCount', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByLastPullMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPullMs', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByLastPullMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPullMs', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByLastPushCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPushCount', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByLastPushCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPushCount', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByLastPushMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPushMs', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByLastPushMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPushMs', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByLastReceivedSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceivedSeq', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      sortByLastReceivedSeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceivedSeq', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByLastSentSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSentSeq', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByLastSentSeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSentSeq', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByRemoteDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteDeviceId', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      sortByRemoteDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteDeviceId', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByTotalReceived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReceived', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByTotalReceivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReceived', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByTotalSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSent', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByTotalSentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSent', Sort.desc);
    });
  }
}

extension SyncCursorQuerySortThenBy
    on QueryBuilder<SyncCursor, SyncCursor, QSortThenBy> {
  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByLastFullSyncMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFullSyncMs', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      thenByLastFullSyncMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFullSyncMs', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByLastPullCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPullCount', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByLastPullCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPullCount', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByLastPullMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPullMs', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByLastPullMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPullMs', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByLastPushCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPushCount', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByLastPushCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPushCount', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByLastPushMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPushMs', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByLastPushMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPushMs', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByLastReceivedSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceivedSeq', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      thenByLastReceivedSeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceivedSeq', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByLastSentSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSentSeq', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByLastSentSeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSentSeq', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByRemoteDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteDeviceId', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      thenByRemoteDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteDeviceId', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByTotalReceived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReceived', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByTotalReceivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReceived', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByTotalSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSent', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByTotalSentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSent', Sort.desc);
    });
  }
}

extension SyncCursorQueryWhereDistinct
    on QueryBuilder<SyncCursor, SyncCursor, QDistinct> {
  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByLastFullSyncMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastFullSyncMs');
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByLastPullCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPullCount');
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByLastPullMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPullMs');
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByLastPushCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPushCount');
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByLastPushMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPushMs');
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByLastReceivedSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReceivedSeq');
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByLastSentSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSentSeq');
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByRemoteDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteDeviceId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByTotalReceived() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalReceived');
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByTotalSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSent');
    });
  }
}

extension SyncCursorQueryProperty
    on QueryBuilder<SyncCursor, SyncCursor, QQueryProperty> {
  QueryBuilder<SyncCursor, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyncCursor, int, QQueryOperations> lastFullSyncMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastFullSyncMs');
    });
  }

  QueryBuilder<SyncCursor, int, QQueryOperations> lastPullCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPullCount');
    });
  }

  QueryBuilder<SyncCursor, int, QQueryOperations> lastPullMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPullMs');
    });
  }

  QueryBuilder<SyncCursor, int, QQueryOperations> lastPushCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPushCount');
    });
  }

  QueryBuilder<SyncCursor, int, QQueryOperations> lastPushMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPushMs');
    });
  }

  QueryBuilder<SyncCursor, int, QQueryOperations> lastReceivedSeqProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReceivedSeq');
    });
  }

  QueryBuilder<SyncCursor, int, QQueryOperations> lastSentSeqProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSentSeq');
    });
  }

  QueryBuilder<SyncCursor, String, QQueryOperations> remoteDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteDeviceId');
    });
  }

  QueryBuilder<SyncCursor, int, QQueryOperations> totalReceivedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalReceived');
    });
  }

  QueryBuilder<SyncCursor, int, QQueryOperations> totalSentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSent');
    });
  }
}
