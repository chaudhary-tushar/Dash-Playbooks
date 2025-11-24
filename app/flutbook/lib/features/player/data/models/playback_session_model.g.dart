// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_session_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlaybackSessionModelCollection on Isar {
  IsarCollection<PlaybackSessionModel> get playbackSessionModels =>
      this.collection();
}

const PlaybackSessionModelSchema = CollectionSchema(
  name: r'PlaybackSessionModel',
  id: -3987228333513238870,
  properties: {
    r'audiobookId': PropertySchema(
      id: 0,
      name: r'audiobookId',
      type: IsarType.string,
    ),
    r'currentPositionInMs': PropertySchema(
      id: 1,
      name: r'currentPositionInMs',
      type: IsarType.long,
    ),
    r'isPlaying': PropertySchema(
      id: 2,
      name: r'isPlaying',
      type: IsarType.bool,
    ),
    r'lastPlayedAt': PropertySchema(
      id: 3,
      name: r'lastPlayedAt',
      type: IsarType.dateTime,
    ),
    r'playbackSpeed': PropertySchema(
      id: 4,
      name: r'playbackSpeed',
      type: IsarType.double,
    ),
    r'sleepTimerActive': PropertySchema(
      id: 5,
      name: r'sleepTimerActive',
      type: IsarType.bool,
    ),
    r'sleepTimerDurationInMs': PropertySchema(
      id: 6,
      name: r'sleepTimerDurationInMs',
      type: IsarType.long,
    ),
  },

  estimateSize: _playbackSessionModelEstimateSize,
  serialize: _playbackSessionModelSerialize,
  deserialize: _playbackSessionModelDeserialize,
  deserializeProp: _playbackSessionModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _playbackSessionModelGetId,
  getLinks: _playbackSessionModelGetLinks,
  attach: _playbackSessionModelAttach,
  version: '3.3.0',
);

int _playbackSessionModelEstimateSize(
  PlaybackSessionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.audiobookId.length * 3;
  return bytesCount;
}

void _playbackSessionModelSerialize(
  PlaybackSessionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.audiobookId);
  writer.writeLong(offsets[1], object.currentPositionInMs);
  writer.writeBool(offsets[2], object.isPlaying);
  writer.writeDateTime(offsets[3], object.lastPlayedAt);
  writer.writeDouble(offsets[4], object.playbackSpeed);
  writer.writeBool(offsets[5], object.sleepTimerActive);
  writer.writeLong(offsets[6], object.sleepTimerDurationInMs);
}

PlaybackSessionModel _playbackSessionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlaybackSessionModel(
    audiobookId: reader.readString(offsets[0]),
    currentPositionInMs: reader.readLong(offsets[1]),
    id: id,
    isPlaying: reader.readBool(offsets[2]),
    lastPlayedAt: reader.readDateTime(offsets[3]),
    playbackSpeed: reader.readDouble(offsets[4]),
    sleepTimerActive: reader.readBool(offsets[5]),
    sleepTimerDurationInMs: reader.readLongOrNull(offsets[6]),
  );
  return object;
}

P _playbackSessionModelDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playbackSessionModelGetId(PlaybackSessionModel object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _playbackSessionModelGetLinks(
  PlaybackSessionModel object,
) {
  return [];
}

void _playbackSessionModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  PlaybackSessionModel object,
) {
  object.id = id;
}

extension PlaybackSessionModelQueryWhereSort
    on QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QWhere> {
  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlaybackSessionModelQueryWhere
    on QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QWhereClause> {
  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterWhereClause>
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

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterWhereClause>
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

extension PlaybackSessionModelQueryFilter
    on
        QueryBuilder<
          PlaybackSessionModel,
          PlaybackSessionModel,
          QFilterCondition
        > {
  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
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
    PlaybackSessionModel,
    PlaybackSessionModel,
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
    PlaybackSessionModel,
    PlaybackSessionModel,
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
    PlaybackSessionModel,
    PlaybackSessionModel,
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
    PlaybackSessionModel,
    PlaybackSessionModel,
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
    PlaybackSessionModel,
    PlaybackSessionModel,
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
    PlaybackSessionModel,
    PlaybackSessionModel,
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
    PlaybackSessionModel,
    PlaybackSessionModel,
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
    PlaybackSessionModel,
    PlaybackSessionModel,
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
    PlaybackSessionModel,
    PlaybackSessionModel,
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
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  currentPositionInMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentPositionInMs', value: value),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  currentPositionInMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentPositionInMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  currentPositionInMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentPositionInMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  currentPositionInMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentPositionInMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
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
    PlaybackSessionModel,
    PlaybackSessionModel,
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
    PlaybackSessionModel,
    PlaybackSessionModel,
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
    PlaybackSessionModel,
    PlaybackSessionModel,
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
    PlaybackSessionModel,
    PlaybackSessionModel,
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
    PlaybackSessionModel,
    PlaybackSessionModel,
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
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  isPlayingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isPlaying', value: value),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  lastPlayedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastPlayedAt', value: value),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  lastPlayedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastPlayedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  lastPlayedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastPlayedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  lastPlayedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastPlayedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  playbackSpeedEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'playbackSpeed',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  playbackSpeedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'playbackSpeed',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  playbackSpeedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'playbackSpeed',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  playbackSpeedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'playbackSpeed',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  sleepTimerActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sleepTimerActive', value: value),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  sleepTimerDurationInMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sleepTimerDurationInMs'),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  sleepTimerDurationInMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sleepTimerDurationInMs'),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  sleepTimerDurationInMsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sleepTimerDurationInMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  sleepTimerDurationInMsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sleepTimerDurationInMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  sleepTimerDurationInMsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sleepTimerDurationInMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlaybackSessionModel,
    PlaybackSessionModel,
    QAfterFilterCondition
  >
  sleepTimerDurationInMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sleepTimerDurationInMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PlaybackSessionModelQueryObject
    on
        QueryBuilder<
          PlaybackSessionModel,
          PlaybackSessionModel,
          QFilterCondition
        > {}

extension PlaybackSessionModelQueryLinks
    on
        QueryBuilder<
          PlaybackSessionModel,
          PlaybackSessionModel,
          QFilterCondition
        > {}

extension PlaybackSessionModelQuerySortBy
    on QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QSortBy> {
  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  sortByAudiobookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audiobookId', Sort.asc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  sortByAudiobookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audiobookId', Sort.desc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  sortByCurrentPositionInMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPositionInMs', Sort.asc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  sortByCurrentPositionInMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPositionInMs', Sort.desc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  sortByIsPlaying() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPlaying', Sort.asc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  sortByIsPlayingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPlaying', Sort.desc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  sortByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  sortByLastPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  sortByPlaybackSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSpeed', Sort.asc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  sortByPlaybackSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSpeed', Sort.desc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  sortBySleepTimerActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimerActive', Sort.asc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  sortBySleepTimerActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimerActive', Sort.desc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  sortBySleepTimerDurationInMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimerDurationInMs', Sort.asc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  sortBySleepTimerDurationInMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimerDurationInMs', Sort.desc);
    });
  }
}

extension PlaybackSessionModelQuerySortThenBy
    on QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QSortThenBy> {
  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  thenByAudiobookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audiobookId', Sort.asc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  thenByAudiobookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audiobookId', Sort.desc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  thenByCurrentPositionInMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPositionInMs', Sort.asc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  thenByCurrentPositionInMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPositionInMs', Sort.desc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  thenByIsPlaying() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPlaying', Sort.asc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  thenByIsPlayingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPlaying', Sort.desc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  thenByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  thenByLastPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  thenByPlaybackSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSpeed', Sort.asc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  thenByPlaybackSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSpeed', Sort.desc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  thenBySleepTimerActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimerActive', Sort.asc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  thenBySleepTimerActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimerActive', Sort.desc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  thenBySleepTimerDurationInMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimerDurationInMs', Sort.asc);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QAfterSortBy>
  thenBySleepTimerDurationInMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimerDurationInMs', Sort.desc);
    });
  }
}

extension PlaybackSessionModelQueryWhereDistinct
    on QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QDistinct> {
  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QDistinct>
  distinctByAudiobookId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audiobookId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QDistinct>
  distinctByCurrentPositionInMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentPositionInMs');
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QDistinct>
  distinctByIsPlaying() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPlaying');
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QDistinct>
  distinctByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayedAt');
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QDistinct>
  distinctByPlaybackSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playbackSpeed');
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QDistinct>
  distinctBySleepTimerActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepTimerActive');
    });
  }

  QueryBuilder<PlaybackSessionModel, PlaybackSessionModel, QDistinct>
  distinctBySleepTimerDurationInMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepTimerDurationInMs');
    });
  }
}

extension PlaybackSessionModelQueryProperty
    on
        QueryBuilder<
          PlaybackSessionModel,
          PlaybackSessionModel,
          QQueryProperty
        > {
  QueryBuilder<PlaybackSessionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlaybackSessionModel, String, QQueryOperations>
  audiobookIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audiobookId');
    });
  }

  QueryBuilder<PlaybackSessionModel, int, QQueryOperations>
  currentPositionInMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentPositionInMs');
    });
  }

  QueryBuilder<PlaybackSessionModel, bool, QQueryOperations>
  isPlayingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPlaying');
    });
  }

  QueryBuilder<PlaybackSessionModel, DateTime, QQueryOperations>
  lastPlayedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayedAt');
    });
  }

  QueryBuilder<PlaybackSessionModel, double, QQueryOperations>
  playbackSpeedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playbackSpeed');
    });
  }

  QueryBuilder<PlaybackSessionModel, bool, QQueryOperations>
  sleepTimerActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepTimerActive');
    });
  }

  QueryBuilder<PlaybackSessionModel, int?, QQueryOperations>
  sleepTimerDurationInMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepTimerDurationInMs');
    });
  }
}
