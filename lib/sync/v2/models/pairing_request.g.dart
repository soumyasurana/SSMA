// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_request.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPairingRequestCollection on Isar {
  IsarCollection<PairingRequest> get pairingRequests => this.collection();
}

const PairingRequestSchema = CollectionSchema(
  name: r'PairingRequest',
  id: 1782595776270177333,
  properties: {
    r'initiatorDeviceId': PropertySchema(
      id: 0,
      name: r'initiatorDeviceId',
      type: IsarType.string,
    ),
    r'initiatorDeviceName': PropertySchema(
      id: 1,
      name: r'initiatorDeviceName',
      type: IsarType.string,
    ),
    r'initiatorIp': PropertySchema(
      id: 2,
      name: r'initiatorIp',
      type: IsarType.string,
    ),
    r'initiatorPlatform': PropertySchema(
      id: 3,
      name: r'initiatorPlatform',
      type: IsarType.string,
    ),
    r'initiatorPort': PropertySchema(
      id: 4,
      name: r'initiatorPort',
      type: IsarType.long,
    ),
    r'isInitiator': PropertySchema(
      id: 5,
      name: r'isInitiator',
      type: IsarType.bool,
    ),
    r'receivedAtMs': PropertySchema(
      id: 6,
      name: r'receivedAtMs',
      type: IsarType.long,
    ),
    r'requestId': PropertySchema(
      id: 7,
      name: r'requestId',
      type: IsarType.string,
    ),
    r'respondedAtMs': PropertySchema(
      id: 8,
      name: r'respondedAtMs',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 9,
      name: r'status',
      type: IsarType.string,
    ),
    r'targetDeviceId': PropertySchema(
      id: 10,
      name: r'targetDeviceId',
      type: IsarType.string,
    ),
    r'targetDeviceName': PropertySchema(
      id: 11,
      name: r'targetDeviceName',
      type: IsarType.string,
    )
  },
  estimateSize: _pairingRequestEstimateSize,
  serialize: _pairingRequestSerialize,
  deserialize: _pairingRequestDeserialize,
  deserializeProp: _pairingRequestDeserializeProp,
  idName: r'id',
  indexes: {
    r'requestId': IndexSchema(
      id: 938047444593699237,
      name: r'requestId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'requestId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'initiatorDeviceId': IndexSchema(
      id: 8613069062840506877,
      name: r'initiatorDeviceId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'initiatorDeviceId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _pairingRequestGetId,
  getLinks: _pairingRequestGetLinks,
  attach: _pairingRequestAttach,
  version: '3.1.0+1',
);

int _pairingRequestEstimateSize(
  PairingRequest object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.initiatorDeviceId.length * 3;
  bytesCount += 3 + object.initiatorDeviceName.length * 3;
  bytesCount += 3 + object.initiatorIp.length * 3;
  bytesCount += 3 + object.initiatorPlatform.length * 3;
  bytesCount += 3 + object.requestId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  {
    final value = object.targetDeviceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.targetDeviceName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _pairingRequestSerialize(
  PairingRequest object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.initiatorDeviceId);
  writer.writeString(offsets[1], object.initiatorDeviceName);
  writer.writeString(offsets[2], object.initiatorIp);
  writer.writeString(offsets[3], object.initiatorPlatform);
  writer.writeLong(offsets[4], object.initiatorPort);
  writer.writeBool(offsets[5], object.isInitiator);
  writer.writeLong(offsets[6], object.receivedAtMs);
  writer.writeString(offsets[7], object.requestId);
  writer.writeLong(offsets[8], object.respondedAtMs);
  writer.writeString(offsets[9], object.status);
  writer.writeString(offsets[10], object.targetDeviceId);
  writer.writeString(offsets[11], object.targetDeviceName);
}

PairingRequest _pairingRequestDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PairingRequest();
  object.id = id;
  object.initiatorDeviceId = reader.readString(offsets[0]);
  object.initiatorDeviceName = reader.readString(offsets[1]);
  object.initiatorIp = reader.readString(offsets[2]);
  object.initiatorPlatform = reader.readString(offsets[3]);
  object.initiatorPort = reader.readLongOrNull(offsets[4]);
  object.isInitiator = reader.readBool(offsets[5]);
  object.receivedAtMs = reader.readLong(offsets[6]);
  object.requestId = reader.readString(offsets[7]);
  object.respondedAtMs = reader.readLongOrNull(offsets[8]);
  object.status = reader.readString(offsets[9]);
  object.targetDeviceId = reader.readStringOrNull(offsets[10]);
  object.targetDeviceName = reader.readStringOrNull(offsets[11]);
  return object;
}

P _pairingRequestDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pairingRequestGetId(PairingRequest object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pairingRequestGetLinks(PairingRequest object) {
  return [];
}

void _pairingRequestAttach(
    IsarCollection<dynamic> col, Id id, PairingRequest object) {
  object.id = id;
}

extension PairingRequestByIndex on IsarCollection<PairingRequest> {
  Future<PairingRequest?> getByRequestId(String requestId) {
    return getByIndex(r'requestId', [requestId]);
  }

  PairingRequest? getByRequestIdSync(String requestId) {
    return getByIndexSync(r'requestId', [requestId]);
  }

  Future<bool> deleteByRequestId(String requestId) {
    return deleteByIndex(r'requestId', [requestId]);
  }

  bool deleteByRequestIdSync(String requestId) {
    return deleteByIndexSync(r'requestId', [requestId]);
  }

  Future<List<PairingRequest?>> getAllByRequestId(
      List<String> requestIdValues) {
    final values = requestIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'requestId', values);
  }

  List<PairingRequest?> getAllByRequestIdSync(List<String> requestIdValues) {
    final values = requestIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'requestId', values);
  }

  Future<int> deleteAllByRequestId(List<String> requestIdValues) {
    final values = requestIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'requestId', values);
  }

  int deleteAllByRequestIdSync(List<String> requestIdValues) {
    final values = requestIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'requestId', values);
  }

  Future<Id> putByRequestId(PairingRequest object) {
    return putByIndex(r'requestId', object);
  }

  Id putByRequestIdSync(PairingRequest object, {bool saveLinks = true}) {
    return putByIndexSync(r'requestId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRequestId(List<PairingRequest> objects) {
    return putAllByIndex(r'requestId', objects);
  }

  List<Id> putAllByRequestIdSync(List<PairingRequest> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'requestId', objects, saveLinks: saveLinks);
  }
}

extension PairingRequestQueryWhereSort
    on QueryBuilder<PairingRequest, PairingRequest, QWhere> {
  QueryBuilder<PairingRequest, PairingRequest, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PairingRequestQueryWhere
    on QueryBuilder<PairingRequest, PairingRequest, QWhereClause> {
  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause> idBetween(
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

  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause>
      requestIdEqualTo(String requestId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'requestId',
        value: [requestId],
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause>
      requestIdNotEqualTo(String requestId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'requestId',
              lower: [],
              upper: [requestId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'requestId',
              lower: [requestId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'requestId',
              lower: [requestId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'requestId',
              lower: [],
              upper: [requestId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause>
      initiatorDeviceIdEqualTo(String initiatorDeviceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'initiatorDeviceId',
        value: [initiatorDeviceId],
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause>
      initiatorDeviceIdNotEqualTo(String initiatorDeviceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'initiatorDeviceId',
              lower: [],
              upper: [initiatorDeviceId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'initiatorDeviceId',
              lower: [initiatorDeviceId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'initiatorDeviceId',
              lower: [initiatorDeviceId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'initiatorDeviceId',
              lower: [],
              upper: [initiatorDeviceId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause> statusEqualTo(
      String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause>
      statusNotEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PairingRequestQueryFilter
    on QueryBuilder<PairingRequest, PairingRequest, QFilterCondition> {
  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
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

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initiatorDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'initiatorDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'initiatorDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'initiatorDeviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'initiatorDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'initiatorDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'initiatorDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'initiatorDeviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initiatorDeviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'initiatorDeviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initiatorDeviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'initiatorDeviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'initiatorDeviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'initiatorDeviceName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'initiatorDeviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'initiatorDeviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'initiatorDeviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'initiatorDeviceName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initiatorDeviceName',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorDeviceNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'initiatorDeviceName',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorIpEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initiatorIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorIpGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'initiatorIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorIpLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'initiatorIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorIpBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'initiatorIp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorIpStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'initiatorIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorIpEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'initiatorIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorIpContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'initiatorIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorIpMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'initiatorIp',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorIpIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initiatorIp',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorIpIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'initiatorIp',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorPlatformEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initiatorPlatform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorPlatformGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'initiatorPlatform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorPlatformLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'initiatorPlatform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorPlatformBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'initiatorPlatform',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorPlatformStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'initiatorPlatform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorPlatformEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'initiatorPlatform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorPlatformContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'initiatorPlatform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorPlatformMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'initiatorPlatform',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorPlatformIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initiatorPlatform',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorPlatformIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'initiatorPlatform',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorPortIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'initiatorPort',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorPortIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'initiatorPort',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorPortEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initiatorPort',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorPortGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'initiatorPort',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorPortLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'initiatorPort',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      initiatorPortBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'initiatorPort',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      isInitiatorEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isInitiator',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      receivedAtMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receivedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      receivedAtMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receivedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      receivedAtMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receivedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      receivedAtMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receivedAtMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      requestIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      requestIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      requestIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      requestIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requestId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      requestIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      requestIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      requestIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      requestIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'requestId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      requestIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestId',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      requestIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'requestId',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      respondedAtMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'respondedAtMs',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      respondedAtMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'respondedAtMs',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      respondedAtMsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'respondedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      respondedAtMsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'respondedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      respondedAtMsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'respondedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      respondedAtMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'respondedAtMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetDeviceId',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetDeviceId',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetDeviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetDeviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetDeviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetDeviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetDeviceName',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetDeviceName',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetDeviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetDeviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetDeviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetDeviceName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetDeviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetDeviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetDeviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetDeviceName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetDeviceName',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      targetDeviceNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetDeviceName',
        value: '',
      ));
    });
  }
}

extension PairingRequestQueryObject
    on QueryBuilder<PairingRequest, PairingRequest, QFilterCondition> {}

extension PairingRequestQueryLinks
    on QueryBuilder<PairingRequest, PairingRequest, QFilterCondition> {}

extension PairingRequestQuerySortBy
    on QueryBuilder<PairingRequest, PairingRequest, QSortBy> {
  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByInitiatorDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorDeviceId', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByInitiatorDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorDeviceId', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByInitiatorDeviceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorDeviceName', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByInitiatorDeviceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorDeviceName', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByInitiatorIp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorIp', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByInitiatorIpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorIp', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByInitiatorPlatform() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorPlatform', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByInitiatorPlatformDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorPlatform', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByInitiatorPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorPort', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByInitiatorPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorPort', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByIsInitiator() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInitiator', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByIsInitiatorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInitiator', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByReceivedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedAtMs', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByReceivedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedAtMs', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy> sortByRequestId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestId', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByRequestIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestId', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByRespondedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respondedAtMs', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByRespondedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respondedAtMs', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByTargetDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDeviceId', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByTargetDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDeviceId', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByTargetDeviceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDeviceName', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByTargetDeviceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDeviceName', Sort.desc);
    });
  }
}

extension PairingRequestQuerySortThenBy
    on QueryBuilder<PairingRequest, PairingRequest, QSortThenBy> {
  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByInitiatorDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorDeviceId', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByInitiatorDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorDeviceId', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByInitiatorDeviceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorDeviceName', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByInitiatorDeviceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorDeviceName', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByInitiatorIp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorIp', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByInitiatorIpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorIp', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByInitiatorPlatform() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorPlatform', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByInitiatorPlatformDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorPlatform', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByInitiatorPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorPort', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByInitiatorPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiatorPort', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByIsInitiator() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInitiator', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByIsInitiatorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInitiator', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByReceivedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedAtMs', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByReceivedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedAtMs', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy> thenByRequestId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestId', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByRequestIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestId', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByRespondedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respondedAtMs', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByRespondedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respondedAtMs', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByTargetDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDeviceId', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByTargetDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDeviceId', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByTargetDeviceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDeviceName', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByTargetDeviceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDeviceName', Sort.desc);
    });
  }
}

extension PairingRequestQueryWhereDistinct
    on QueryBuilder<PairingRequest, PairingRequest, QDistinct> {
  QueryBuilder<PairingRequest, PairingRequest, QDistinct>
      distinctByInitiatorDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initiatorDeviceId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct>
      distinctByInitiatorDeviceName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initiatorDeviceName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct> distinctByInitiatorIp(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initiatorIp', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct>
      distinctByInitiatorPlatform({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initiatorPlatform',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct>
      distinctByInitiatorPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initiatorPort');
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct>
      distinctByIsInitiator() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isInitiator');
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct>
      distinctByReceivedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receivedAtMs');
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct> distinctByRequestId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct>
      distinctByRespondedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'respondedAtMs');
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct>
      distinctByTargetDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetDeviceId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct>
      distinctByTargetDeviceName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetDeviceName',
          caseSensitive: caseSensitive);
    });
  }
}

extension PairingRequestQueryProperty
    on QueryBuilder<PairingRequest, PairingRequest, QQueryProperty> {
  QueryBuilder<PairingRequest, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PairingRequest, String, QQueryOperations>
      initiatorDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initiatorDeviceId');
    });
  }

  QueryBuilder<PairingRequest, String, QQueryOperations>
      initiatorDeviceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initiatorDeviceName');
    });
  }

  QueryBuilder<PairingRequest, String, QQueryOperations> initiatorIpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initiatorIp');
    });
  }

  QueryBuilder<PairingRequest, String, QQueryOperations>
      initiatorPlatformProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initiatorPlatform');
    });
  }

  QueryBuilder<PairingRequest, int?, QQueryOperations> initiatorPortProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initiatorPort');
    });
  }

  QueryBuilder<PairingRequest, bool, QQueryOperations> isInitiatorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isInitiator');
    });
  }

  QueryBuilder<PairingRequest, int, QQueryOperations> receivedAtMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receivedAtMs');
    });
  }

  QueryBuilder<PairingRequest, String, QQueryOperations> requestIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestId');
    });
  }

  QueryBuilder<PairingRequest, int?, QQueryOperations> respondedAtMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'respondedAtMs');
    });
  }

  QueryBuilder<PairingRequest, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PairingRequest, String?, QQueryOperations>
      targetDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetDeviceId');
    });
  }

  QueryBuilder<PairingRequest, String?, QQueryOperations>
      targetDeviceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetDeviceName');
    });
  }
}
