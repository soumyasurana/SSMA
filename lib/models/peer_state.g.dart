// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peer_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPeerStateCollection on Isar {
  IsarCollection<PeerState> get peerStates => this.collection();
}

const PeerStateSchema = CollectionSchema(
  name: r'PeerState',
  id: -5186589119661943172,
  properties: {
    r'healthStatus': PropertySchema(
      id: 0,
      name: r'healthStatus',
      type: IsarType.string,
    ),
    r'lastPulledChangeSeq': PropertySchema(
      id: 1,
      name: r'lastPulledChangeSeq',
      type: IsarType.long,
    ),
    r'lastSeen': PropertySchema(
      id: 2,
      name: r'lastSeen',
      type: IsarType.long,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 3,
      name: r'lastSyncedAt',
      type: IsarType.long,
    ),
    r'peerId': PropertySchema(
      id: 4,
      name: r'peerId',
      type: IsarType.string,
    ),
    r'peerIp': PropertySchema(
      id: 5,
      name: r'peerIp',
      type: IsarType.string,
    ),
    r'peerPort': PropertySchema(
      id: 6,
      name: r'peerPort',
      type: IsarType.long,
    )
  },
  estimateSize: _peerStateEstimateSize,
  serialize: _peerStateSerialize,
  deserialize: _peerStateDeserialize,
  deserializeProp: _peerStateDeserializeProp,
  idName: r'id',
  indexes: {
    r'peerId': IndexSchema(
      id: -9089303509033685807,
      name: r'peerId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'peerId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'lastSeen': IndexSchema(
      id: -4002271667734767009,
      name: r'lastSeen',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastSeen',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _peerStateGetId,
  getLinks: _peerStateGetLinks,
  attach: _peerStateAttach,
  version: '3.1.0+1',
);

int _peerStateEstimateSize(
  PeerState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.healthStatus.length * 3;
  bytesCount += 3 + object.peerId.length * 3;
  bytesCount += 3 + object.peerIp.length * 3;
  return bytesCount;
}

void _peerStateSerialize(
  PeerState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.healthStatus);
  writer.writeLong(offsets[1], object.lastPulledChangeSeq);
  writer.writeLong(offsets[2], object.lastSeen);
  writer.writeLong(offsets[3], object.lastSyncedAt);
  writer.writeString(offsets[4], object.peerId);
  writer.writeString(offsets[5], object.peerIp);
  writer.writeLong(offsets[6], object.peerPort);
}

PeerState _peerStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PeerState();
  object.healthStatus = reader.readString(offsets[0]);
  object.id = id;
  object.lastPulledChangeSeq = reader.readLong(offsets[1]);
  object.lastSeen = reader.readLong(offsets[2]);
  object.lastSyncedAt = reader.readLong(offsets[3]);
  object.peerId = reader.readString(offsets[4]);
  object.peerIp = reader.readString(offsets[5]);
  object.peerPort = reader.readLong(offsets[6]);
  return object;
}

P _peerStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _peerStateGetId(PeerState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _peerStateGetLinks(PeerState object) {
  return [];
}

void _peerStateAttach(IsarCollection<dynamic> col, Id id, PeerState object) {
  object.id = id;
}

extension PeerStateByIndex on IsarCollection<PeerState> {
  Future<PeerState?> getByPeerId(String peerId) {
    return getByIndex(r'peerId', [peerId]);
  }

  PeerState? getByPeerIdSync(String peerId) {
    return getByIndexSync(r'peerId', [peerId]);
  }

  Future<bool> deleteByPeerId(String peerId) {
    return deleteByIndex(r'peerId', [peerId]);
  }

  bool deleteByPeerIdSync(String peerId) {
    return deleteByIndexSync(r'peerId', [peerId]);
  }

  Future<List<PeerState?>> getAllByPeerId(List<String> peerIdValues) {
    final values = peerIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'peerId', values);
  }

  List<PeerState?> getAllByPeerIdSync(List<String> peerIdValues) {
    final values = peerIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'peerId', values);
  }

  Future<int> deleteAllByPeerId(List<String> peerIdValues) {
    final values = peerIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'peerId', values);
  }

  int deleteAllByPeerIdSync(List<String> peerIdValues) {
    final values = peerIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'peerId', values);
  }

  Future<Id> putByPeerId(PeerState object) {
    return putByIndex(r'peerId', object);
  }

  Id putByPeerIdSync(PeerState object, {bool saveLinks = true}) {
    return putByIndexSync(r'peerId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPeerId(List<PeerState> objects) {
    return putAllByIndex(r'peerId', objects);
  }

  List<Id> putAllByPeerIdSync(List<PeerState> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'peerId', objects, saveLinks: saveLinks);
  }
}

extension PeerStateQueryWhereSort
    on QueryBuilder<PeerState, PeerState, QWhere> {
  QueryBuilder<PeerState, PeerState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterWhere> anyLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastSeen'),
      );
    });
  }
}

extension PeerStateQueryWhere
    on QueryBuilder<PeerState, PeerState, QWhereClause> {
  QueryBuilder<PeerState, PeerState, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PeerState, PeerState, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterWhereClause> idBetween(
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

  QueryBuilder<PeerState, PeerState, QAfterWhereClause> peerIdEqualTo(
      String peerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'peerId',
        value: [peerId],
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterWhereClause> peerIdNotEqualTo(
      String peerId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId',
              lower: [],
              upper: [peerId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId',
              lower: [peerId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId',
              lower: [peerId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId',
              lower: [],
              upper: [peerId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterWhereClause> lastSeenEqualTo(
      int lastSeen) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastSeen',
        value: [lastSeen],
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterWhereClause> lastSeenNotEqualTo(
      int lastSeen) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastSeen',
              lower: [],
              upper: [lastSeen],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastSeen',
              lower: [lastSeen],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastSeen',
              lower: [lastSeen],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastSeen',
              lower: [],
              upper: [lastSeen],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterWhereClause> lastSeenGreaterThan(
    int lastSeen, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastSeen',
        lower: [lastSeen],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterWhereClause> lastSeenLessThan(
    int lastSeen, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastSeen',
        lower: [],
        upper: [lastSeen],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterWhereClause> lastSeenBetween(
    int lowerLastSeen,
    int upperLastSeen, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastSeen',
        lower: [lowerLastSeen],
        includeLower: includeLower,
        upper: [upperLastSeen],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PeerStateQueryFilter
    on QueryBuilder<PeerState, PeerState, QFilterCondition> {
  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> healthStatusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'healthStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition>
      healthStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'healthStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition>
      healthStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'healthStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> healthStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'healthStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition>
      healthStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'healthStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition>
      healthStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'healthStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition>
      healthStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'healthStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> healthStatusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'healthStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition>
      healthStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'healthStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition>
      healthStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'healthStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition>
      lastPulledChangeSeqEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPulledChangeSeq',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition>
      lastPulledChangeSeqGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPulledChangeSeq',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition>
      lastPulledChangeSeqLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPulledChangeSeq',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition>
      lastPulledChangeSeqBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPulledChangeSeq',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> lastSeenEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> lastSeenGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> lastSeenLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> lastSeenBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSeen',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> lastSyncedAtEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition>
      lastSyncedAtGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition>
      lastSyncedAtLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> lastSyncedAtBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'peerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'peerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'peerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'peerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'peerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'peerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'peerId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerId',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'peerId',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIpEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIpGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'peerIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIpLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'peerIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIpBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'peerIp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIpStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'peerIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIpEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'peerIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIpContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'peerIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIpMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'peerIp',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIpIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerIp',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerIpIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'peerIp',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerPortEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerPort',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerPortGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'peerPort',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerPortLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'peerPort',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterFilterCondition> peerPortBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'peerPort',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PeerStateQueryObject
    on QueryBuilder<PeerState, PeerState, QFilterCondition> {}

extension PeerStateQueryLinks
    on QueryBuilder<PeerState, PeerState, QFilterCondition> {}

extension PeerStateQuerySortBy on QueryBuilder<PeerState, PeerState, QSortBy> {
  QueryBuilder<PeerState, PeerState, QAfterSortBy> sortByHealthStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthStatus', Sort.asc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> sortByHealthStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthStatus', Sort.desc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> sortByLastPulledChangeSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPulledChangeSeq', Sort.asc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy>
      sortByLastPulledChangeSeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPulledChangeSeq', Sort.desc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> sortByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.asc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> sortByLastSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.desc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> sortByPeerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerId', Sort.asc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> sortByPeerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerId', Sort.desc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> sortByPeerIp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerIp', Sort.asc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> sortByPeerIpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerIp', Sort.desc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> sortByPeerPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerPort', Sort.asc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> sortByPeerPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerPort', Sort.desc);
    });
  }
}

extension PeerStateQuerySortThenBy
    on QueryBuilder<PeerState, PeerState, QSortThenBy> {
  QueryBuilder<PeerState, PeerState, QAfterSortBy> thenByHealthStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthStatus', Sort.asc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> thenByHealthStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthStatus', Sort.desc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> thenByLastPulledChangeSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPulledChangeSeq', Sort.asc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy>
      thenByLastPulledChangeSeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPulledChangeSeq', Sort.desc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> thenByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.asc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> thenByLastSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.desc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> thenByPeerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerId', Sort.asc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> thenByPeerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerId', Sort.desc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> thenByPeerIp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerIp', Sort.asc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> thenByPeerIpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerIp', Sort.desc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> thenByPeerPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerPort', Sort.asc);
    });
  }

  QueryBuilder<PeerState, PeerState, QAfterSortBy> thenByPeerPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerPort', Sort.desc);
    });
  }
}

extension PeerStateQueryWhereDistinct
    on QueryBuilder<PeerState, PeerState, QDistinct> {
  QueryBuilder<PeerState, PeerState, QDistinct> distinctByHealthStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'healthStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeerState, PeerState, QDistinct>
      distinctByLastPulledChangeSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPulledChangeSeq');
    });
  }

  QueryBuilder<PeerState, PeerState, QDistinct> distinctByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSeen');
    });
  }

  QueryBuilder<PeerState, PeerState, QDistinct> distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<PeerState, PeerState, QDistinct> distinctByPeerId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'peerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeerState, PeerState, QDistinct> distinctByPeerIp(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'peerIp', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeerState, PeerState, QDistinct> distinctByPeerPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'peerPort');
    });
  }
}

extension PeerStateQueryProperty
    on QueryBuilder<PeerState, PeerState, QQueryProperty> {
  QueryBuilder<PeerState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PeerState, String, QQueryOperations> healthStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'healthStatus');
    });
  }

  QueryBuilder<PeerState, int, QQueryOperations> lastPulledChangeSeqProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPulledChangeSeq');
    });
  }

  QueryBuilder<PeerState, int, QQueryOperations> lastSeenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSeen');
    });
  }

  QueryBuilder<PeerState, int, QQueryOperations> lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<PeerState, String, QQueryOperations> peerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'peerId');
    });
  }

  QueryBuilder<PeerState, String, QQueryOperations> peerIpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'peerIp');
    });
  }

  QueryBuilder<PeerState, int, QQueryOperations> peerPortProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'peerPort');
    });
  }
}
