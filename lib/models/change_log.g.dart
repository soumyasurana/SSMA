// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChangeLogCollection on Isar {
  IsarCollection<ChangeLog> get changeLogs => this.collection();
}

const ChangeLogSchema = CollectionSchema(
  name: r'ChangeLog',
  id: 8397397906208021083,
  properties: {
    r'changeSeq': PropertySchema(
      id: 0,
      name: r'changeSeq',
      type: IsarType.long,
    ),
    r'collection': PropertySchema(
      id: 1,
      name: r'collection',
      type: IsarType.string,
    ),
    r'opId': PropertySchema(
      id: 2,
      name: r'opId',
      type: IsarType.string,
    ),
    r'operation': PropertySchema(
      id: 3,
      name: r'operation',
      type: IsarType.string,
      enumMap: _ChangeLogoperationEnumValueMap,
    ),
    r'originDeviceId': PropertySchema(
      id: 4,
      name: r'originDeviceId',
      type: IsarType.string,
    ),
    r'recordId': PropertySchema(
      id: 5,
      name: r'recordId',
      type: IsarType.string,
    ),
    r'synced': PropertySchema(
      id: 6,
      name: r'synced',
      type: IsarType.bool,
    ),
    r'timestamp': PropertySchema(
      id: 7,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _changeLogEstimateSize,
  serialize: _changeLogSerialize,
  deserialize: _changeLogDeserialize,
  deserializeProp: _changeLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'collection': IndexSchema(
      id: -1843270535372135219,
      name: r'collection',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'collection',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'recordId': IndexSchema(
      id: 907839981883940929,
      name: r'recordId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'recordId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'opId': IndexSchema(
      id: -7257366839637970090,
      name: r'opId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'opId',
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
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'synced': IndexSchema(
      id: -4832663256418428922,
      name: r'synced',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'synced',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _changeLogGetId,
  getLinks: _changeLogGetLinks,
  attach: _changeLogAttach,
  version: '3.1.0+1',
);

int _changeLogEstimateSize(
  ChangeLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.collection.length * 3;
  bytesCount += 3 + object.opId.length * 3;
  bytesCount += 3 + object.operation.name.length * 3;
  bytesCount += 3 + object.originDeviceId.length * 3;
  bytesCount += 3 + object.recordId.length * 3;
  return bytesCount;
}

void _changeLogSerialize(
  ChangeLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.changeSeq);
  writer.writeString(offsets[1], object.collection);
  writer.writeString(offsets[2], object.opId);
  writer.writeString(offsets[3], object.operation.name);
  writer.writeString(offsets[4], object.originDeviceId);
  writer.writeString(offsets[5], object.recordId);
  writer.writeBool(offsets[6], object.synced);
  writer.writeDateTime(offsets[7], object.timestamp);
}

ChangeLog _changeLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChangeLog();
  object.changeSeq = reader.readLong(offsets[0]);
  object.collection = reader.readString(offsets[1]);
  object.id = id;
  object.opId = reader.readString(offsets[2]);
  object.operation =
      _ChangeLogoperationValueEnumMap[reader.readStringOrNull(offsets[3])] ??
          ChangeOperation.create;
  object.originDeviceId = reader.readString(offsets[4]);
  object.recordId = reader.readString(offsets[5]);
  object.synced = reader.readBool(offsets[6]);
  object.timestamp = reader.readDateTime(offsets[7]);
  return object;
}

P _changeLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (_ChangeLogoperationValueEnumMap[
              reader.readStringOrNull(offset)] ??
          ChangeOperation.create) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ChangeLogoperationEnumValueMap = {
  r'create': r'create',
  r'update': r'update',
  r'delete': r'delete',
};
const _ChangeLogoperationValueEnumMap = {
  r'create': ChangeOperation.create,
  r'update': ChangeOperation.update,
  r'delete': ChangeOperation.delete,
};

Id _changeLogGetId(ChangeLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _changeLogGetLinks(ChangeLog object) {
  return [];
}

void _changeLogAttach(IsarCollection<dynamic> col, Id id, ChangeLog object) {
  object.id = id;
}

extension ChangeLogByIndex on IsarCollection<ChangeLog> {
  Future<ChangeLog?> getByOpId(String opId) {
    return getByIndex(r'opId', [opId]);
  }

  ChangeLog? getByOpIdSync(String opId) {
    return getByIndexSync(r'opId', [opId]);
  }

  Future<bool> deleteByOpId(String opId) {
    return deleteByIndex(r'opId', [opId]);
  }

  bool deleteByOpIdSync(String opId) {
    return deleteByIndexSync(r'opId', [opId]);
  }

  Future<List<ChangeLog?>> getAllByOpId(List<String> opIdValues) {
    final values = opIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'opId', values);
  }

  List<ChangeLog?> getAllByOpIdSync(List<String> opIdValues) {
    final values = opIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'opId', values);
  }

  Future<int> deleteAllByOpId(List<String> opIdValues) {
    final values = opIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'opId', values);
  }

  int deleteAllByOpIdSync(List<String> opIdValues) {
    final values = opIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'opId', values);
  }

  Future<Id> putByOpId(ChangeLog object) {
    return putByIndex(r'opId', object);
  }

  Id putByOpIdSync(ChangeLog object, {bool saveLinks = true}) {
    return putByIndexSync(r'opId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOpId(List<ChangeLog> objects) {
    return putAllByIndex(r'opId', objects);
  }

  List<Id> putAllByOpIdSync(List<ChangeLog> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'opId', objects, saveLinks: saveLinks);
  }
}

extension ChangeLogQueryWhereSort
    on QueryBuilder<ChangeLog, ChangeLog, QWhere> {
  QueryBuilder<ChangeLog, ChangeLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhere> anyChangeSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'changeSeq'),
      );
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhere> anySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'synced'),
      );
    });
  }
}

extension ChangeLogQueryWhere
    on QueryBuilder<ChangeLog, ChangeLog, QWhereClause> {
  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> idBetween(
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> collectionEqualTo(
      String collection) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'collection',
        value: [collection],
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> collectionNotEqualTo(
      String collection) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collection',
              lower: [],
              upper: [collection],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collection',
              lower: [collection],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collection',
              lower: [collection],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collection',
              lower: [],
              upper: [collection],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> recordIdEqualTo(
      String recordId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'recordId',
        value: [recordId],
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> recordIdNotEqualTo(
      String recordId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordId',
              lower: [],
              upper: [recordId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordId',
              lower: [recordId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordId',
              lower: [recordId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordId',
              lower: [],
              upper: [recordId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> opIdEqualTo(
      String opId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'opId',
        value: [opId],
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> opIdNotEqualTo(
      String opId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'opId',
              lower: [],
              upper: [opId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'opId',
              lower: [opId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'opId',
              lower: [opId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'opId',
              lower: [],
              upper: [opId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> changeSeqEqualTo(
      int changeSeq) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'changeSeq',
        value: [changeSeq],
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> changeSeqNotEqualTo(
      int changeSeq) {
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> changeSeqGreaterThan(
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> changeSeqLessThan(
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> changeSeqBetween(
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> timestampEqualTo(
      DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> timestampNotEqualTo(
      DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> timestampGreaterThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [timestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [],
        upper: [timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [lowerTimestamp],
        includeLower: includeLower,
        upper: [upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> syncedEqualTo(
      bool synced) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'synced',
        value: [synced],
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterWhereClause> syncedNotEqualTo(
      bool synced) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'synced',
              lower: [],
              upper: [synced],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'synced',
              lower: [synced],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'synced',
              lower: [synced],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'synced',
              lower: [],
              upper: [synced],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ChangeLogQueryFilter
    on QueryBuilder<ChangeLog, ChangeLog, QFilterCondition> {
  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> changeSeqEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeSeq',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> changeSeqLessThan(
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> changeSeqBetween(
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> collectionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collection',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
      collectionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collection',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> collectionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collection',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> collectionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collection',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
      collectionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'collection',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> collectionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'collection',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> collectionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'collection',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> collectionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'collection',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
      collectionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collection',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
      collectionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'collection',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> opIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'opId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> opIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'opId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> opIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'opId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> opIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'opId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> opIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'opId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> opIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'opId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> opIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'opId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> opIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'opId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> opIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'opId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> opIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'opId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> operationEqualTo(
    ChangeOperation value, {
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
      operationGreaterThan(
    ChangeOperation value, {
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> operationLessThan(
    ChangeOperation value, {
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> operationBetween(
    ChangeOperation lower,
    ChangeOperation upper, {
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> operationStartsWith(
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> operationEndsWith(
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> operationContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> operationMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> operationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operation',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
      operationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operation',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
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

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
      originDeviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
      originDeviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originDeviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
      originDeviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originDeviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
      originDeviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originDeviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> recordIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> recordIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> recordIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> recordIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recordId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> recordIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> recordIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> recordIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> recordIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recordId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> recordIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
      recordIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recordId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> syncedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'synced',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> timestampEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ChangeLogQueryObject
    on QueryBuilder<ChangeLog, ChangeLog, QFilterCondition> {}

extension ChangeLogQueryLinks
    on QueryBuilder<ChangeLog, ChangeLog, QFilterCondition> {}

extension ChangeLogQuerySortBy on QueryBuilder<ChangeLog, ChangeLog, QSortBy> {
  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> sortByChangeSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeSeq', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> sortByChangeSeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeSeq', Sort.desc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> sortByCollection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collection', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> sortByCollectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collection', Sort.desc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> sortByOpId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'opId', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> sortByOpIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'opId', Sort.desc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> sortByOperation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> sortByOperationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.desc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> sortByOriginDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originDeviceId', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> sortByOriginDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originDeviceId', Sort.desc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> sortByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> sortByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension ChangeLogQuerySortThenBy
    on QueryBuilder<ChangeLog, ChangeLog, QSortThenBy> {
  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenByChangeSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeSeq', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenByChangeSeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeSeq', Sort.desc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenByCollection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collection', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenByCollectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collection', Sort.desc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenByOpId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'opId', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenByOpIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'opId', Sort.desc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenByOperation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenByOperationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.desc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenByOriginDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originDeviceId', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenByOriginDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originDeviceId', Sort.desc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension ChangeLogQueryWhereDistinct
    on QueryBuilder<ChangeLog, ChangeLog, QDistinct> {
  QueryBuilder<ChangeLog, ChangeLog, QDistinct> distinctByChangeSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changeSeq');
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QDistinct> distinctByCollection(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collection', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QDistinct> distinctByOpId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'opId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QDistinct> distinctByOperation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QDistinct> distinctByOriginDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originDeviceId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QDistinct> distinctByRecordId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<ChangeLog, ChangeLog, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension ChangeLogQueryProperty
    on QueryBuilder<ChangeLog, ChangeLog, QQueryProperty> {
  QueryBuilder<ChangeLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ChangeLog, int, QQueryOperations> changeSeqProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changeSeq');
    });
  }

  QueryBuilder<ChangeLog, String, QQueryOperations> collectionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collection');
    });
  }

  QueryBuilder<ChangeLog, String, QQueryOperations> opIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'opId');
    });
  }

  QueryBuilder<ChangeLog, ChangeOperation, QQueryOperations>
      operationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operation');
    });
  }

  QueryBuilder<ChangeLog, String, QQueryOperations> originDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originDeviceId');
    });
  }

  QueryBuilder<ChangeLog, String, QQueryOperations> recordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordId');
    });
  }

  QueryBuilder<ChangeLog, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<ChangeLog, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
