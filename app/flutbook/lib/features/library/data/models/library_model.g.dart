// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLibraryModelCollection on Isar {
  IsarCollection<LibraryModel> get libraryModels => this.collection();
}

const LibraryModelSchema = CollectionSchema(
  name: r'LibraryModel',
  id: 5460103172959763277,
  properties: {
    r'audiobookIds': PropertySchema(
      id: 0,
      name: r'audiobookIds',
      type: IsarType.stringList,
    ),
    r'internalId': PropertySchema(
      id: 1,
      name: r'internalId',
      type: IsarType.string,
    ),
    r'lastScanAt': PropertySchema(
      id: 2,
      name: r'lastScanAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(id: 3, name: r'name', type: IsarType.string),
    r'path': PropertySchema(id: 4, name: r'path', type: IsarType.string),
    r'totalAudiobooks': PropertySchema(
      id: 5,
      name: r'totalAudiobooks',
      type: IsarType.long,
    ),
    r'totalDurationInMs': PropertySchema(
      id: 6,
      name: r'totalDurationInMs',
      type: IsarType.long,
    ),
  },

  estimateSize: _libraryModelEstimateSize,
  serialize: _libraryModelSerialize,
  deserialize: _libraryModelDeserialize,
  deserializeProp: _libraryModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _libraryModelGetId,
  getLinks: _libraryModelGetLinks,
  attach: _libraryModelAttach,
  version: '3.3.0',
);

int _libraryModelEstimateSize(
  LibraryModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.audiobookIds.length * 3;
  {
    for (var i = 0; i < object.audiobookIds.length; i++) {
      final value = object.audiobookIds[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.internalId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.path.length * 3;
  return bytesCount;
}

void _libraryModelSerialize(
  LibraryModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.audiobookIds);
  writer.writeString(offsets[1], object.internalId);
  writer.writeDateTime(offsets[2], object.lastScanAt);
  writer.writeString(offsets[3], object.name);
  writer.writeString(offsets[4], object.path);
  writer.writeLong(offsets[5], object.totalAudiobooks);
  writer.writeLong(offsets[6], object.totalDurationInMs);
}

LibraryModel _libraryModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LibraryModel(
    audiobookIds: reader.readStringList(offsets[0]) ?? [],
    id: id,
    internalId: reader.readStringOrNull(offsets[1]),
    lastScanAt: reader.readDateTime(offsets[2]),
    name: reader.readString(offsets[3]),
    path: reader.readString(offsets[4]),
    totalAudiobooks: reader.readLong(offsets[5]),
    totalDurationInMs: reader.readLong(offsets[6]),
  );
  return object;
}

P _libraryModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _libraryModelGetId(LibraryModel object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _libraryModelGetLinks(LibraryModel object) {
  return [];
}

void _libraryModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  LibraryModel object,
) {
  object.id = id;
}

extension LibraryModelQueryWhereSort
    on QueryBuilder<LibraryModel, LibraryModel, QWhere> {
  QueryBuilder<LibraryModel, LibraryModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LibraryModelQueryWhere
    on QueryBuilder<LibraryModel, LibraryModel, QWhereClause> {
  QueryBuilder<LibraryModel, LibraryModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<LibraryModel, LibraryModel, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension LibraryModelQueryFilter
    on QueryBuilder<LibraryModel, LibraryModel, QFilterCondition> {
  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  audiobookIdsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'audiobookIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  audiobookIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'audiobookIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  audiobookIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'audiobookIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  audiobookIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'audiobookIds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  audiobookIdsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'audiobookIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  audiobookIdsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'audiobookIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  audiobookIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'audiobookIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  audiobookIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'audiobookIds',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  audiobookIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'audiobookIds', value: ''),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  audiobookIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'audiobookIds', value: ''),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  audiobookIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'audiobookIds', length, true, length, true);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  audiobookIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'audiobookIds', 0, true, 0, true);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  audiobookIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'audiobookIds', 0, false, 999999, true);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  audiobookIdsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'audiobookIds', 0, true, length, include);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  audiobookIdsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'audiobookIds', length, include, 999999, true);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  audiobookIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audiobookIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'id'),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'id'),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> idEqualTo(
    Id? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> idGreaterThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> idLessThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  internalIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'internalId'),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  internalIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'internalId'),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  internalIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'internalId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  internalIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'internalId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  internalIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'internalId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  internalIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'internalId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  internalIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'internalId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  internalIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'internalId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  internalIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'internalId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  internalIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'internalId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  internalIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'internalId', value: ''),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  internalIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'internalId', value: ''),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  lastScanAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastScanAt', value: value),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  lastScanAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastScanAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  lastScanAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastScanAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  lastScanAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastScanAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> pathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  pathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> pathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> pathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'path',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  pathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> pathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> pathContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition> pathMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'path',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  pathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'path', value: ''),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  pathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'path', value: ''),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  totalAudiobooksEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalAudiobooks', value: value),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  totalAudiobooksGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalAudiobooks',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  totalAudiobooksLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalAudiobooks',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  totalAudiobooksBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalAudiobooks',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  totalDurationInMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalDurationInMs', value: value),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  totalDurationInMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalDurationInMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  totalDurationInMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalDurationInMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterFilterCondition>
  totalDurationInMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalDurationInMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension LibraryModelQueryObject
    on QueryBuilder<LibraryModel, LibraryModel, QFilterCondition> {}

extension LibraryModelQueryLinks
    on QueryBuilder<LibraryModel, LibraryModel, QFilterCondition> {}

extension LibraryModelQuerySortBy
    on QueryBuilder<LibraryModel, LibraryModel, QSortBy> {
  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy> sortByInternalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'internalId', Sort.asc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy>
  sortByInternalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'internalId', Sort.desc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy> sortByLastScanAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastScanAt', Sort.asc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy>
  sortByLastScanAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastScanAt', Sort.desc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy> sortByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy> sortByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy>
  sortByTotalAudiobooks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAudiobooks', Sort.asc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy>
  sortByTotalAudiobooksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAudiobooks', Sort.desc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy>
  sortByTotalDurationInMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationInMs', Sort.asc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy>
  sortByTotalDurationInMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationInMs', Sort.desc);
    });
  }
}

extension LibraryModelQuerySortThenBy
    on QueryBuilder<LibraryModel, LibraryModel, QSortThenBy> {
  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy> thenByInternalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'internalId', Sort.asc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy>
  thenByInternalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'internalId', Sort.desc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy> thenByLastScanAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastScanAt', Sort.asc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy>
  thenByLastScanAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastScanAt', Sort.desc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy> thenByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy> thenByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy>
  thenByTotalAudiobooks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAudiobooks', Sort.asc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy>
  thenByTotalAudiobooksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAudiobooks', Sort.desc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy>
  thenByTotalDurationInMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationInMs', Sort.asc);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QAfterSortBy>
  thenByTotalDurationInMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationInMs', Sort.desc);
    });
  }
}

extension LibraryModelQueryWhereDistinct
    on QueryBuilder<LibraryModel, LibraryModel, QDistinct> {
  QueryBuilder<LibraryModel, LibraryModel, QDistinct> distinctByAudiobookIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audiobookIds');
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QDistinct> distinctByInternalId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'internalId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QDistinct> distinctByLastScanAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastScanAt');
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QDistinct> distinctByPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'path', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QDistinct>
  distinctByTotalAudiobooks() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAudiobooks');
    });
  }

  QueryBuilder<LibraryModel, LibraryModel, QDistinct>
  distinctByTotalDurationInMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDurationInMs');
    });
  }
}

extension LibraryModelQueryProperty
    on QueryBuilder<LibraryModel, LibraryModel, QQueryProperty> {
  QueryBuilder<LibraryModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LibraryModel, List<String>, QQueryOperations>
  audiobookIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audiobookIds');
    });
  }

  QueryBuilder<LibraryModel, String?, QQueryOperations> internalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'internalId');
    });
  }

  QueryBuilder<LibraryModel, DateTime, QQueryOperations> lastScanAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastScanAt');
    });
  }

  QueryBuilder<LibraryModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<LibraryModel, String, QQueryOperations> pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'path');
    });
  }

  QueryBuilder<LibraryModel, int, QQueryOperations> totalAudiobooksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAudiobooks');
    });
  }

  QueryBuilder<LibraryModel, int, QQueryOperations>
  totalDurationInMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDurationInMs');
    });
  }
}
