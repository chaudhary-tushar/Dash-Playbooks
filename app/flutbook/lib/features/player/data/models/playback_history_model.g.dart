// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_history_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlaybackHistoryModelCollection on Isar {
  IsarCollection<PlaybackHistoryModel> get playbackHistoryModels =>
      this.collection();
}

const PlaybackHistoryModelSchema = CollectionSchema(
  name: r'PlaybackHistoryModel',
  id: 5780041652328880953,
  properties: {
    r'audiobookId': PropertySchema(
      id: 0,
      name: r'audiobookId',
      type: IsarType.string,
    ),
    r'durationInMs': PropertySchema(
      id: 1,
      name: r'durationInMs',
      type: IsarType.long,
    ),
    r'playedAt': PropertySchema(
      id: 2,
      name: r'playedAt',
      type: IsarType.dateTime,
    ),
    r'positionInMs': PropertySchema(
      id: 3,
      name: r'positionInMs',
      type: IsarType.long,
    ),
  },

  estimateSize: _playbackHistoryModelEstimateSize,
  serialize: _playbackHistoryModelSerialize,
  deserialize: _playbackHistoryModelDeserialize,
  deserializeProp: _playbackHistoryModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _playbackHistoryModelGetId,
  getLinks: _playbackHistoryModelGetLinks,
  attach: _playbackHistoryModelAttach,
  version: '3.3.0',
);

int _playbackHistoryModelEstimateSize(
  PlaybackHistoryModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.audiobookId.length * 3;
  return bytesCount;
}

void _playbackHistoryModelSerialize(
  PlaybackHistoryModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.audiobookId);
  writer.writeLong(offsets[1], object.durationInMs);
  writer.writeDateTime(offsets[2], object.playedAt);
  writer.writeLong(offsets[3], object.positionInMs);
}

PlaybackHistoryModel _playbackHistoryModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlaybackHistoryModel(
    audiobookId: reader.readString(offsets[0]),
    durationInMs: reader.readLong(offsets[1]),
    id: id,
    playedAt: reader.readDateTime(offsets[2]),
    positionInMs: reader.readLong(offsets[3]),
  );
  return object;
}

P _playbackHistoryModelDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playbackHistoryModelGetId(PlaybackHistoryModel object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _playbackHistoryModelGetLinks(
  PlaybackHistoryModel object,
) {
  return [];
}

void _playbackHistoryModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  PlaybackHistoryModel object,
) {
  object.id = id;
}

extension PlaybackHistoryModelQueryWhereSort
    on QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QWhere> {
  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlaybackHistoryModelQueryWhere
    on QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QWhereClause> {
  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterWhereClause>
  idBetween(
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

extension PlaybackHistoryModelQueryFilter
    on
        QueryBuilder<
          PlaybackHistoryModel,
          PlaybackHistoryModel,
          QFilterCondition
        > {
  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  audiobookIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'audiobookId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  audiobookIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'audiobookId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  audiobookIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'audiobookId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  audiobookIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'audiobookId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  audiobookIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'audiobookId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  audiobookIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'audiobookId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  audiobookIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'audiobookId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  audiobookIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'audiobookId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  audiobookIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'audiobookId', value: ''),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  audiobookIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'audiobookId', value: ''),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  durationInMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'durationInMs', value: value),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  durationInMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'durationInMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  durationInMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'durationInMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  durationInMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'durationInMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'id'),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'id'),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  idGreaterThan(Id? value, {bool include = false}) {
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

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  idLessThan(Id? value, {bool include = false}) {
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

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  idBetween(
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

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  playedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playedAt', value: value),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  playedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'playedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  playedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'playedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  playedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'playedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  positionInMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'positionInMs', value: value),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  positionInMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'positionInMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  positionInMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'positionInMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackHistoryModel,
    PlaybackHistoryModel,
    QAfterFilterCondition
  >
  positionInMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'positionInMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PlaybackHistoryModelQueryObject
    on
        QueryBuilder<
          PlaybackHistoryModel,
          PlaybackHistoryModel,
          QFilterCondition
        > {}

extension PlaybackHistoryModelQueryLinks
    on
        QueryBuilder<
          PlaybackHistoryModel,
          PlaybackHistoryModel,
          QFilterCondition
        > {}

extension PlaybackHistoryModelQuerySortBy
    on QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QSortBy> {
  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  sortByAudiobookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audiobookId', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  sortByAudiobookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audiobookId', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  sortByDurationInMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationInMs', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  sortByDurationInMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationInMs', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  sortByPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playedAt', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  sortByPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playedAt', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  sortByPositionInMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionInMs', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  sortByPositionInMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionInMs', Sort.desc);
    });
  }
}

extension PlaybackHistoryModelQuerySortThenBy
    on QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QSortThenBy> {
  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  thenByAudiobookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audiobookId', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  thenByAudiobookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audiobookId', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  thenByDurationInMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationInMs', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  thenByDurationInMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationInMs', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  thenByPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playedAt', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  thenByPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playedAt', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  thenByPositionInMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionInMs', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QAfterSortBy>
  thenByPositionInMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionInMs', Sort.desc);
    });
  }
}

extension PlaybackHistoryModelQueryWhereDistinct
    on QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QDistinct> {
  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QDistinct>
  distinctByAudiobookId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audiobookId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QDistinct>
  distinctByDurationInMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationInMs');
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QDistinct>
  distinctByPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playedAt');
    });
  }

  QueryBuilder<PlaybackHistoryModel, PlaybackHistoryModel, QDistinct>
  distinctByPositionInMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'positionInMs');
    });
  }
}

extension PlaybackHistoryModelQueryProperty
    on
        QueryBuilder<
          PlaybackHistoryModel,
          PlaybackHistoryModel,
          QQueryProperty
        > {
  QueryBuilder<PlaybackHistoryModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlaybackHistoryModel, String, QQueryOperations>
  audiobookIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audiobookId');
    });
  }

  QueryBuilder<PlaybackHistoryModel, int, QQueryOperations>
  durationInMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationInMs');
    });
  }

  QueryBuilder<PlaybackHistoryModel, DateTime, QQueryOperations>
  playedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playedAt');
    });
  }

  QueryBuilder<PlaybackHistoryModel, int, QQueryOperations>
  positionInMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positionInMs');
    });
  }
}
