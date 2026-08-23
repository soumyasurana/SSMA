// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_change_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncChangeLogCollection on Isar {
  IsarCollection<SyncChangeLog> get syncChangeLogs => this.collection();
}

const SyncChangeLogSchema = CollectionSchema(
  name: r'SyncChangeLog',
  id: 8123791731743284991,
  properties: {
    r'acknowledged': PropertySchema(
      id: 0,
      name: r'acknowledged',
      type: IsarType.bool,
    ),
    r'changeId': PropertySchema(
      id: 1,
      name: r'changeId',
      type: IsarType.string,
    ),
    r'changeSeq': PropertySchema(
      id: 2,
      name: r'changeSeq',
      type: IsarType.long,
    ),
    r'entityId': PropertySchema(
      id: 3,
      name: r'entityId',
      type: IsarType.string,
    ),
    r'entityType': PropertySchema(
      id: 4,
      name: r'entityType',
      type: IsarType.string,
    ),
    r'entityVersion': PropertySchema(
      id: 5,
      name: r'entityVersion',
      type: IsarType.long,
    ),
    r'operation': PropertySchema(
      id: 6,
      name: r'operation',
      type: IsarType.string,
    ),
    r'originDeviceId': PropertySchema(
      id: 7,
      name: r'originDeviceId',
      type: IsarType.string,
    ),
    r'payload': PropertySchema(
      id: 8,
      name: r'payload',
      type: IsarType.string,
    ),
    r'previousChangeHash': PropertySchema(
      id: 9,
      name: r'previousChangeHash',
      type: IsarType.string,
    ),
    r'timestampMs': PropertySchema(
      id: 10,
      name: r'timestampMs',
      type: IsarType.long,
    )
  },
  estimateSize: _syncChangeLogEstimateSize,
  serialize: _syncChangeLogSerialize,
  deserialize: _syncChangeLogDeserialize,
  deserializeProp: _syncChangeLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'changeId': IndexSchema(
      id: 8607903509764266093,
      name: r'changeId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'changeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'changeSeq': IndexSchema(
      id: 4496260395805165179,
      name: r'changeSeq',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'changeSeq',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'entityType': IndexSchema(
      id: -5109706325448941117,
      name: r'entityType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entityType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'entityId': IndexSchema(
      id: 745355021660786263,
      name: r'entityId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entityId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'originDeviceId': IndexSchema(
      id: 8292248109096074014,
      name: r'originDeviceId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'originDeviceId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'acknowledged': IndexSchema(
      id: -5432716960520154632,
      name: r'acknowledged',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'acknowledged',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _syncChangeLogGetId,
  getLinks: _syncChangeLogGetLinks,
  attach: _syncChangeLogAttach,
  version: '3.3.2',
);

int _syncChangeLogEstimateSize(
  SyncChangeLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.changeId.length * 3;
  bytesCount += 3 + object.entityId.length * 3;
  bytesCount += 3 + object.entityType.length * 3;
  bytesCount += 3 + object.operation.length * 3;
  bytesCount += 3 + object.originDeviceId.length * 3;
  bytesCount += 3 + object.payload.length * 3;
  {
    final value = object.previousChangeHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _syncChangeLogSerialize(
  SyncChangeLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.acknowledged);
  writer.writeString(offsets[1], object.changeId);
  writer.writeLong(offsets[2], object.changeSeq);
  writer.writeString(offsets[3], object.entityId);
  writer.writeString(offsets[4], object.entityType);
  writer.writeLong(offsets[5], object.entityVersion);
  writer.writeString(offsets[6], object.operation);
  writer.writeString(offsets[7], object.originDeviceId);
  writer.writeString(offsets[8], object.payload);
  writer.writeString(offsets[9], object.previousChangeHash);
  writer.writeLong(offsets[10], object.timestampMs);
}

SyncChangeLog _syncChangeLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncChangeLog();
  object.acknowledged = reader.readBool(offsets[0]);
  object.changeId = reader.readString(offsets[1]);
  object.changeSeq = reader.readLong(offsets[2]);
  object.entityId = reader.readString(offsets[3]);
  object.entityType = reader.readString(offsets[4]);
  object.entityVersion = reader.readLong(offsets[5]);
  object.id = id;
  object.operation = reader.readString(offsets[6]);
  object.originDeviceId = reader.readString(offsets[7]);
  object.payload = reader.readString(offsets[8]);
  object.previousChangeHash = reader.readStringOrNull(offsets[9]);
  object.timestampMs = reader.readLong(offsets[10]);
  return object;
}

P _syncChangeLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncChangeLogGetId(SyncChangeLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syncChangeLogGetLinks(SyncChangeLog object) {
  return [];
}

void _syncChangeLogAttach(
    IsarCollection<dynamic> col, Id id, SyncChangeLog object) {
  object.id = id;
}

extension SyncChangeLogByIndex on IsarCollection<SyncChangeLog> {
  Future<SyncChangeLog?> getByChangeId(String changeId) {
    return getByIndex(r'changeId', [changeId]);
  }

  SyncChangeLog? getByChangeIdSync(String changeId) {
    return getByIndexSync(r'changeId', [changeId]);
  }

  Future<bool> deleteByChangeId(String changeId) {
    return deleteByIndex(r'changeId', [changeId]);
  }

  bool deleteByChangeIdSync(String changeId) {
    return deleteByIndexSync(r'changeId', [changeId]);
  }

  Future<List<SyncChangeLog?>> getAllByChangeId(List<String> changeIdValues) {
    final values = changeIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'changeId', values);
  }

  List<SyncChangeLog?> getAllByChangeIdSync(List<String> changeIdValues) {
    final values = changeIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'changeId', values);
  }

  Future<int> deleteAllByChangeId(List<String> changeIdValues) {
    final values = changeIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'changeId', values);
  }

  int deleteAllByChangeIdSync(List<String> changeIdValues) {
    final values = changeIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'changeId', values);
  }

  Future<Id> putByChangeId(SyncChangeLog object) {
    return putByIndex(r'changeId', object);
  }

  Id putByChangeIdSync(SyncChangeLog object, {bool saveLinks = true}) {
    return putByIndexSync(r'changeId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByChangeId(List<SyncChangeLog> objects) {
    return putAllByIndex(r'changeId', objects);
  }

  List<Id> putAllByChangeIdSync(List<SyncChangeLog> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'changeId', objects, saveLinks: saveLinks);
  }
}

extension SyncChangeLogQueryWhereSort
    on QueryBuilder<SyncChangeLog, SyncChangeLog, QWhere> {
  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhere> anyChangeSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'changeSeq'),
      );
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhere> anyAcknowledged() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'acknowledged'),
      );
    });
  }
}

extension SyncChangeLogQueryWhere
    on QueryBuilder<SyncChangeLog, SyncChangeLog, QWhereClause> {
  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause> idBetween(
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

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause> changeIdEqualTo(
      String changeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'changeId',
        value: [changeId],
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause>
      changeIdNotEqualTo(String changeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'changeId',
              lower: [],
              upper: [changeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'changeId',
              lower: [changeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'changeId',
              lower: [changeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'changeId',
              lower: [],
              upper: [changeId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause>
      changeSeqEqualTo(int changeSeq) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'changeSeq',
        value: [changeSeq],
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause>
      changeSeqNotEqualTo(int changeSeq) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'changeSeq',
              lower: [],
              upper: [changeSeq],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'changeSeq',
              lower: [changeSeq],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'changeSeq',
              lower: [changeSeq],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'changeSeq',
              lower: [],
              upper: [changeSeq],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause>
      changeSeqGreaterThan(
    int changeSeq, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'changeSeq',
        lower: [changeSeq],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause>
      changeSeqLessThan(
    int changeSeq, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'changeSeq',
        lower: [],
        upper: [changeSeq],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause>
      changeSeqBetween(
    int lowerChangeSeq,
    int upperChangeSeq, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'changeSeq',
        lower: [lowerChangeSeq],
        includeLower: includeLower,
        upper: [upperChangeSeq],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause>
      entityTypeEqualTo(String entityType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entityType',
        value: [entityType],
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause>
      entityTypeNotEqualTo(String entityType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityType',
              lower: [],
              upper: [entityType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityType',
              lower: [entityType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityType',
              lower: [entityType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityType',
              lower: [],
              upper: [entityType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause> entityIdEqualTo(
      String entityId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entityId',
        value: [entityId],
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause>
      entityIdNotEqualTo(String entityId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityId',
              lower: [],
              upper: [entityId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityId',
              lower: [entityId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityId',
              lower: [entityId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityId',
              lower: [],
              upper: [entityId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause>
      originDeviceIdEqualTo(String originDeviceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'originDeviceId',
        value: [originDeviceId],
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause>
      originDeviceIdNotEqualTo(String originDeviceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originDeviceId',
              lower: [],
              upper: [originDeviceId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originDeviceId',
              lower: [originDeviceId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originDeviceId',
              lower: [originDeviceId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originDeviceId',
              lower: [],
              upper: [originDeviceId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause>
      acknowledgedEqualTo(bool acknowledged) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'acknowledged',
        value: [acknowledged],
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterWhereClause>
      acknowledgedNotEqualTo(bool acknowledged) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'acknowledged',
              lower: [],
              upper: [acknowledged],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'acknowledged',
              lower: [acknowledged],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'acknowledged',
              lower: [acknowledged],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'acknowledged',
              lower: [],
              upper: [acknowledged],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SyncChangeLogQueryFilter
    on QueryBuilder<SyncChangeLog, SyncChangeLog, QFilterCondition> {
  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      acknowledgedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'acknowledged',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      changeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      changeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'changeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      changeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'changeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      changeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'changeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      changeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'changeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      changeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'changeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      changeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'changeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      changeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'changeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      changeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      changeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'changeId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      changeSeqEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeSeq',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      changeSeqGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'changeSeq',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      changeSeqLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'changeSeq',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      changeSeqBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'changeSeq',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityVersionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityVersionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      entityVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      operationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      operationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      operationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      operationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      operationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      operationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      operationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      operationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      operationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operation',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      operationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operation',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      originDeviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      originDeviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      originDeviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      originDeviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originDeviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      originDeviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      originDeviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      originDeviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      originDeviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originDeviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      originDeviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originDeviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      originDeviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originDeviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      payloadEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      payloadGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      payloadLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      payloadBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'payload',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      payloadStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      payloadEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      payloadContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      payloadMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'payload',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payload',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'payload',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      previousChangeHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'previousChangeHash',
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      previousChangeHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'previousChangeHash',
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      previousChangeHashEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousChangeHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      previousChangeHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'previousChangeHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      previousChangeHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'previousChangeHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      previousChangeHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'previousChangeHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      previousChangeHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'previousChangeHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      previousChangeHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'previousChangeHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      previousChangeHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'previousChangeHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      previousChangeHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'previousChangeHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      previousChangeHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousChangeHash',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      previousChangeHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'previousChangeHash',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      timestampMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestampMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      timestampMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestampMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      timestampMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestampMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterFilterCondition>
      timestampMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestampMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SyncChangeLogQueryObject
    on QueryBuilder<SyncChangeLog, SyncChangeLog, QFilterCondition> {}

extension SyncChangeLogQueryLinks
    on QueryBuilder<SyncChangeLog, SyncChangeLog, QFilterCondition> {}

extension SyncChangeLogQuerySortBy
    on QueryBuilder<SyncChangeLog, SyncChangeLog, QSortBy> {
  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      sortByAcknowledged() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acknowledged', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      sortByAcknowledgedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acknowledged', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> sortByChangeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeId', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      sortByChangeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeId', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> sortByChangeSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeSeq', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      sortByChangeSeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeSeq', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> sortByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      sortByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> sortByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      sortByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      sortByEntityVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityVersion', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      sortByEntityVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityVersion', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> sortByOperation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      sortByOperationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      sortByOriginDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originDeviceId', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      sortByOriginDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originDeviceId', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> sortByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> sortByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      sortByPreviousChangeHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousChangeHash', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      sortByPreviousChangeHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousChangeHash', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> sortByTimestampMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestampMs', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      sortByTimestampMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestampMs', Sort.desc);
    });
  }
}

extension SyncChangeLogQuerySortThenBy
    on QueryBuilder<SyncChangeLog, SyncChangeLog, QSortThenBy> {
  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      thenByAcknowledged() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acknowledged', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      thenByAcknowledgedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acknowledged', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> thenByChangeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeId', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      thenByChangeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeId', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> thenByChangeSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeSeq', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      thenByChangeSeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeSeq', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> thenByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      thenByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> thenByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      thenByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      thenByEntityVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityVersion', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      thenByEntityVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityVersion', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> thenByOperation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      thenByOperationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      thenByOriginDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originDeviceId', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      thenByOriginDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originDeviceId', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> thenByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> thenByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      thenByPreviousChangeHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousChangeHash', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      thenByPreviousChangeHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousChangeHash', Sort.desc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy> thenByTimestampMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestampMs', Sort.asc);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QAfterSortBy>
      thenByTimestampMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestampMs', Sort.desc);
    });
  }
}

extension SyncChangeLogQueryWhereDistinct
    on QueryBuilder<SyncChangeLog, SyncChangeLog, QDistinct> {
  QueryBuilder<SyncChangeLog, SyncChangeLog, QDistinct>
      distinctByAcknowledged() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'acknowledged');
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QDistinct> distinctByChangeId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QDistinct> distinctByChangeSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changeSeq');
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QDistinct> distinctByEntityId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QDistinct> distinctByEntityType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QDistinct>
      distinctByEntityVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityVersion');
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QDistinct> distinctByOperation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QDistinct>
      distinctByOriginDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originDeviceId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QDistinct> distinctByPayload(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QDistinct>
      distinctByPreviousChangeHash({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previousChangeHash',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncChangeLog, SyncChangeLog, QDistinct>
      distinctByTimestampMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestampMs');
    });
  }
}

extension SyncChangeLogQueryProperty
    on QueryBuilder<SyncChangeLog, SyncChangeLog, QQueryProperty> {
  QueryBuilder<SyncChangeLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyncChangeLog, bool, QQueryOperations> acknowledgedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'acknowledged');
    });
  }

  QueryBuilder<SyncChangeLog, String, QQueryOperations> changeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changeId');
    });
  }

  QueryBuilder<SyncChangeLog, int, QQueryOperations> changeSeqProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changeSeq');
    });
  }

  QueryBuilder<SyncChangeLog, String, QQueryOperations> entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityId');
    });
  }

  QueryBuilder<SyncChangeLog, String, QQueryOperations> entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityType');
    });
  }

  QueryBuilder<SyncChangeLog, int, QQueryOperations> entityVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityVersion');
    });
  }

  QueryBuilder<SyncChangeLog, String, QQueryOperations> operationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operation');
    });
  }

  QueryBuilder<SyncChangeLog, String, QQueryOperations>
      originDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originDeviceId');
    });
  }

  QueryBuilder<SyncChangeLog, String, QQueryOperations> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }

  QueryBuilder<SyncChangeLog, String?, QQueryOperations>
      previousChangeHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousChangeHash');
    });
  }

  QueryBuilder<SyncChangeLog, int, QQueryOperations> timestampMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestampMs');
    });
  }
}
