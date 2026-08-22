// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'godown_movement.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGodownMovementCollection on Isar {
  IsarCollection<GodownMovement> get godownMovements => this.collection();
}

const GodownMovementSchema = CollectionSchema(
  name: r'GodownMovement',
  id: 1272315708151161790,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'godownItemName': PropertySchema(
      id: 1,
      name: r'godownItemName',
      type: IsarType.string,
    ),
    r'godownItemUuid': PropertySchema(
      id: 2,
      name: r'godownItemUuid',
      type: IsarType.string,
    ),
    r'movementType': PropertySchema(
      id: 3,
      name: r'movementType',
      type: IsarType.string,
      enumMap: _GodownMovementmovementTypeEnumValueMap,
    ),
    r'note': PropertySchema(
      id: 4,
      name: r'note',
      type: IsarType.string,
    ),
    r'quantityChanged': PropertySchema(
      id: 5,
      name: r'quantityChanged',
      type: IsarType.long,
    ),
    r'referenceId': PropertySchema(
      id: 6,
      name: r'referenceId',
      type: IsarType.string,
    ),
    r'remainingQuantity': PropertySchema(
      id: 7,
      name: r'remainingQuantity',
      type: IsarType.long,
    ),
    r'uuid': PropertySchema(
      id: 8,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _godownMovementEstimateSize,
  serialize: _godownMovementSerialize,
  deserialize: _godownMovementDeserialize,
  deserializeProp: _godownMovementDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'godownItemUuid': IndexSchema(
      id: 8562866802903501140,
      name: r'godownItemUuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'godownItemUuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _godownMovementGetId,
  getLinks: _godownMovementGetLinks,
  attach: _godownMovementAttach,
  version: '3.1.0+1',
);

int _godownMovementEstimateSize(
  GodownMovement object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.godownItemName.length * 3;
  bytesCount += 3 + object.godownItemUuid.length * 3;
  bytesCount += 3 + object.movementType.name.length * 3;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.referenceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _godownMovementSerialize(
  GodownMovement object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.godownItemName);
  writer.writeString(offsets[2], object.godownItemUuid);
  writer.writeString(offsets[3], object.movementType.name);
  writer.writeString(offsets[4], object.note);
  writer.writeLong(offsets[5], object.quantityChanged);
  writer.writeString(offsets[6], object.referenceId);
  writer.writeLong(offsets[7], object.remainingQuantity);
  writer.writeString(offsets[8], object.uuid);
}

GodownMovement _godownMovementDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GodownMovement();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.godownItemName = reader.readString(offsets[1]);
  object.godownItemUuid = reader.readString(offsets[2]);
  object.isarId = id;
  object.movementType = _GodownMovementmovementTypeValueEnumMap[
          reader.readStringOrNull(offsets[3])] ??
      GodownMovementType.stockAdded;
  object.note = reader.readStringOrNull(offsets[4]);
  object.quantityChanged = reader.readLong(offsets[5]);
  object.referenceId = reader.readStringOrNull(offsets[6]);
  object.remainingQuantity = reader.readLong(offsets[7]);
  object.uuid = reader.readString(offsets[8]);
  return object;
}

P _godownMovementDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (_GodownMovementmovementTypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          GodownMovementType.stockAdded) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _GodownMovementmovementTypeEnumValueMap = {
  r'stockAdded': r'stockAdded',
  r'quantityIncreased': r'quantityIncreased',
  r'quantityDecreased': r'quantityDecreased',
  r'transferToShop': r'transferToShop',
  r'manualAdjustment': r'manualAdjustment',
  r'stockRemoved': r'stockRemoved',
};
const _GodownMovementmovementTypeValueEnumMap = {
  r'stockAdded': GodownMovementType.stockAdded,
  r'quantityIncreased': GodownMovementType.quantityIncreased,
  r'quantityDecreased': GodownMovementType.quantityDecreased,
  r'transferToShop': GodownMovementType.transferToShop,
  r'manualAdjustment': GodownMovementType.manualAdjustment,
  r'stockRemoved': GodownMovementType.stockRemoved,
};

Id _godownMovementGetId(GodownMovement object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _godownMovementGetLinks(GodownMovement object) {
  return [];
}

void _godownMovementAttach(
    IsarCollection<dynamic> col, Id id, GodownMovement object) {
  object.isarId = id;
}

extension GodownMovementByIndex on IsarCollection<GodownMovement> {
  Future<GodownMovement?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  GodownMovement? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<GodownMovement?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<GodownMovement?> getAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uuid', values);
  }

  Future<int> deleteAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uuid', values);
  }

  int deleteAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uuid', values);
  }

  Future<Id> putByUuid(GodownMovement object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(GodownMovement object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<GodownMovement> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<GodownMovement> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension GodownMovementQueryWhereSort
    on QueryBuilder<GodownMovement, GodownMovement, QWhere> {
  QueryBuilder<GodownMovement, GodownMovement, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GodownMovementQueryWhere
    on QueryBuilder<GodownMovement, GodownMovement, QWhereClause> {
  QueryBuilder<GodownMovement, GodownMovement, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterWhereClause> uuidEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterWhereClause>
      uuidNotEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterWhereClause>
      godownItemUuidEqualTo(String godownItemUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'godownItemUuid',
        value: [godownItemUuid],
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterWhereClause>
      godownItemUuidNotEqualTo(String godownItemUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'godownItemUuid',
              lower: [],
              upper: [godownItemUuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'godownItemUuid',
              lower: [godownItemUuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'godownItemUuid',
              lower: [godownItemUuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'godownItemUuid',
              lower: [],
              upper: [godownItemUuid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension GodownMovementQueryFilter
    on QueryBuilder<GodownMovement, GodownMovement, QFilterCondition> {
  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'godownItemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'godownItemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'godownItemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'godownItemName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'godownItemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'godownItemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'godownItemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'godownItemName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'godownItemName',
        value: '',
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'godownItemName',
        value: '',
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemUuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'godownItemUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'godownItemUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'godownItemUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'godownItemUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'godownItemUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'godownItemUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'godownItemUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'godownItemUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'godownItemUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      godownItemUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'godownItemUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      movementTypeEqualTo(
    GodownMovementType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      movementTypeGreaterThan(
    GodownMovementType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      movementTypeLessThan(
    GodownMovementType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      movementTypeBetween(
    GodownMovementType lower,
    GodownMovementType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'movementType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      movementTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      movementTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      movementTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      movementTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'movementType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      movementTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movementType',
        value: '',
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      movementTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'movementType',
        value: '',
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      quantityChangedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantityChanged',
        value: value,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      quantityChangedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantityChanged',
        value: value,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      quantityChangedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantityChanged',
        value: value,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      quantityChangedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantityChanged',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      referenceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'referenceId',
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      referenceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'referenceId',
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      referenceIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      referenceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'referenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      referenceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'referenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      referenceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'referenceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      referenceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'referenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      referenceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'referenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      referenceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'referenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      referenceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'referenceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      referenceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceId',
        value: '',
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      referenceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'referenceId',
        value: '',
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      remainingQuantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remainingQuantity',
        value: value,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      remainingQuantityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remainingQuantity',
        value: value,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      remainingQuantityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remainingQuantity',
        value: value,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      remainingQuantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remainingQuantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      uuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension GodownMovementQueryObject
    on QueryBuilder<GodownMovement, GodownMovement, QFilterCondition> {}

extension GodownMovementQueryLinks
    on QueryBuilder<GodownMovement, GodownMovement, QFilterCondition> {}

extension GodownMovementQuerySortBy
    on QueryBuilder<GodownMovement, GodownMovement, QSortBy> {
  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      sortByGodownItemName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'godownItemName', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      sortByGodownItemNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'godownItemName', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      sortByGodownItemUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'godownItemUuid', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      sortByGodownItemUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'godownItemUuid', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      sortByMovementType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementType', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      sortByMovementTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementType', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      sortByQuantityChanged() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantityChanged', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      sortByQuantityChangedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantityChanged', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      sortByReferenceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceId', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      sortByReferenceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceId', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      sortByRemainingQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingQuantity', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      sortByRemainingQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingQuantity', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension GodownMovementQuerySortThenBy
    on QueryBuilder<GodownMovement, GodownMovement, QSortThenBy> {
  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      thenByGodownItemName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'godownItemName', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      thenByGodownItemNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'godownItemName', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      thenByGodownItemUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'godownItemUuid', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      thenByGodownItemUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'godownItemUuid', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      thenByMovementType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementType', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      thenByMovementTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementType', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      thenByQuantityChanged() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantityChanged', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      thenByQuantityChangedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantityChanged', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      thenByReferenceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceId', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      thenByReferenceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceId', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      thenByRemainingQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingQuantity', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy>
      thenByRemainingQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingQuantity', Sort.desc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension GodownMovementQueryWhereDistinct
    on QueryBuilder<GodownMovement, GodownMovement, QDistinct> {
  QueryBuilder<GodownMovement, GodownMovement, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QDistinct>
      distinctByGodownItemName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'godownItemName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QDistinct>
      distinctByGodownItemUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'godownItemUuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QDistinct>
      distinctByMovementType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'movementType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QDistinct>
      distinctByQuantityChanged() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantityChanged');
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QDistinct> distinctByReferenceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referenceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QDistinct>
      distinctByRemainingQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remainingQuantity');
    });
  }

  QueryBuilder<GodownMovement, GodownMovement, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension GodownMovementQueryProperty
    on QueryBuilder<GodownMovement, GodownMovement, QQueryProperty> {
  QueryBuilder<GodownMovement, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<GodownMovement, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<GodownMovement, String, QQueryOperations>
      godownItemNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'godownItemName');
    });
  }

  QueryBuilder<GodownMovement, String, QQueryOperations>
      godownItemUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'godownItemUuid');
    });
  }

  QueryBuilder<GodownMovement, GodownMovementType, QQueryOperations>
      movementTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'movementType');
    });
  }

  QueryBuilder<GodownMovement, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<GodownMovement, int, QQueryOperations>
      quantityChangedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantityChanged');
    });
  }

  QueryBuilder<GodownMovement, String?, QQueryOperations>
      referenceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenceId');
    });
  }

  QueryBuilder<GodownMovement, int, QQueryOperations>
      remainingQuantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remainingQuantity');
    });
  }

  QueryBuilder<GodownMovement, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
