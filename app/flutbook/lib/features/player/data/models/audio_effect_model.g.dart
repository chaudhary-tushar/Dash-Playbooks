// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_effect_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAudioEffectModelCollection on Isar {
  IsarCollection<AudioEffectModel> get audioEffectModels => this.collection();
}

const AudioEffectModelSchema = CollectionSchema(
  name: r'AudioEffectModel',
  id: -2901505613039365165,
  properties: {
    r'bassBoost': PropertySchema(
      id: 0,
      name: r'bassBoost',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'domainId': PropertySchema(
      id: 2,
      name: r'domainId',
      type: IsarType.string,
    ),
    r'eqBandsJson': PropertySchema(
      id: 3,
      name: r'eqBandsJson',
      type: IsarType.string,
    ),
    r'isEnabled': PropertySchema(
      id: 4,
      name: r'isEnabled',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(id: 5, name: r'name', type: IsarType.string),
    r'presetName': PropertySchema(
      id: 6,
      name: r'presetName',
      type: IsarType.string,
    ),
    r'trebleBoost': PropertySchema(
      id: 7,
      name: r'trebleBoost',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 8,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _audioEffectModelEstimateSize,
  serialize: _audioEffectModelSerialize,
  deserialize: _audioEffectModelDeserialize,
  deserializeProp: _audioEffectModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _audioEffectModelGetId,
  getLinks: _audioEffectModelGetLinks,
  attach: _audioEffectModelAttach,
  version: '3.3.0',
);

int _audioEffectModelEstimateSize(
  AudioEffectModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.domainId.length * 3;
  bytesCount += 3 + object.eqBandsJson.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.presetName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _audioEffectModelSerialize(
  AudioEffectModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.bassBoost);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.domainId);
  writer.writeString(offsets[3], object.eqBandsJson);
  writer.writeBool(offsets[4], object.isEnabled);
  writer.writeString(offsets[5], object.name);
  writer.writeString(offsets[6], object.presetName);
  writer.writeDouble(offsets[7], object.trebleBoost);
  writer.writeDateTime(offsets[8], object.updatedAt);
}

AudioEffectModel _audioEffectModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AudioEffectModel();
  object.bassBoost = reader.readDouble(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.domainId = reader.readString(offsets[2]);
  object.eqBandsJson = reader.readString(offsets[3]);
  object.id = id;
  object.isEnabled = reader.readBool(offsets[4]);
  object.name = reader.readString(offsets[5]);
  object.presetName = reader.readStringOrNull(offsets[6]);
  object.trebleBoost = reader.readDouble(offsets[7]);
  object.updatedAt = reader.readDateTime(offsets[8]);
  return object;
}

P _audioEffectModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _audioEffectModelGetId(AudioEffectModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _audioEffectModelGetLinks(AudioEffectModel object) {
  return [];
}

void _audioEffectModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  AudioEffectModel object,
) {
  object.id = id;
}

extension AudioEffectModelQueryWhereSort
    on QueryBuilder<AudioEffectModel, AudioEffectModel, QWhere> {
  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AudioEffectModelQueryWhere
    on QueryBuilder<AudioEffectModel, AudioEffectModel, QWhereClause> {
  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterWhereClause>
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

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterWhereClause> idBetween(
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

extension AudioEffectModelQueryFilter
    on QueryBuilder<AudioEffectModel, AudioEffectModel, QFilterCondition> {
  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  bassBoostEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'bassBoost',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  bassBoostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bassBoost',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  bassBoostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bassBoost',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  bassBoostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bassBoost',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  domainIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  domainIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  domainIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  domainIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'domainId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  domainIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  domainIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  domainIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  domainIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'domainId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  domainIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'domainId', value: ''),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  domainIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'domainId', value: ''),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  eqBandsJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'eqBandsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  eqBandsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'eqBandsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  eqBandsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'eqBandsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  eqBandsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'eqBandsJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  eqBandsJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'eqBandsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  eqBandsJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'eqBandsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  eqBandsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'eqBandsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  eqBandsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'eqBandsJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  eqBandsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'eqBandsJson', value: ''),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  eqBandsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'eqBandsJson', value: ''),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
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

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  isEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isEnabled', value: value),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  nameEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
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

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  nameLessThan(
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

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  nameBetween(
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

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
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

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  nameMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  presetNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'presetName'),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  presetNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'presetName'),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  presetNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'presetName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  presetNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'presetName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  presetNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'presetName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  presetNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'presetName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  presetNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'presetName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  presetNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'presetName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  presetNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'presetName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  presetNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'presetName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  presetNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'presetName', value: ''),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  presetNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'presetName', value: ''),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  trebleBoostEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'trebleBoost',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  trebleBoostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trebleBoost',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  trebleBoostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trebleBoost',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  trebleBoostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trebleBoost',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AudioEffectModelQueryObject
    on QueryBuilder<AudioEffectModel, AudioEffectModel, QFilterCondition> {}

extension AudioEffectModelQueryLinks
    on QueryBuilder<AudioEffectModel, AudioEffectModel, QFilterCondition> {}

extension AudioEffectModelQuerySortBy
    on QueryBuilder<AudioEffectModel, AudioEffectModel, QSortBy> {
  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByBassBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bassBoost', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByBassBoostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bassBoost', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByEqBandsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eqBandsJson', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByEqBandsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eqBandsJson', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByPresetName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presetName', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByPresetNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presetName', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByTrebleBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trebleBoost', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByTrebleBoostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trebleBoost', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AudioEffectModelQuerySortThenBy
    on QueryBuilder<AudioEffectModel, AudioEffectModel, QSortThenBy> {
  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByBassBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bassBoost', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByBassBoostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bassBoost', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByEqBandsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eqBandsJson', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByEqBandsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eqBandsJson', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByPresetName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presetName', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByPresetNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presetName', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByTrebleBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trebleBoost', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByTrebleBoostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trebleBoost', Sort.desc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AudioEffectModelQueryWhereDistinct
    on QueryBuilder<AudioEffectModel, AudioEffectModel, QDistinct> {
  QueryBuilder<AudioEffectModel, AudioEffectModel, QDistinct>
  distinctByBassBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bassBoost');
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QDistinct>
  distinctByDomainId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'domainId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QDistinct>
  distinctByEqBandsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eqBandsJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QDistinct>
  distinctByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEnabled');
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QDistinct>
  distinctByPresetName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'presetName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QDistinct>
  distinctByTrebleBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trebleBoost');
    });
  }

  QueryBuilder<AudioEffectModel, AudioEffectModel, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension AudioEffectModelQueryProperty
    on QueryBuilder<AudioEffectModel, AudioEffectModel, QQueryProperty> {
  QueryBuilder<AudioEffectModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AudioEffectModel, double, QQueryOperations> bassBoostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bassBoost');
    });
  }

  QueryBuilder<AudioEffectModel, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AudioEffectModel, String, QQueryOperations> domainIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'domainId');
    });
  }

  QueryBuilder<AudioEffectModel, String, QQueryOperations>
  eqBandsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eqBandsJson');
    });
  }

  QueryBuilder<AudioEffectModel, bool, QQueryOperations> isEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEnabled');
    });
  }

  QueryBuilder<AudioEffectModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<AudioEffectModel, String?, QQueryOperations>
  presetNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'presetName');
    });
  }

  QueryBuilder<AudioEffectModel, double, QQueryOperations>
  trebleBoostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trebleBoost');
    });
  }

  QueryBuilder<AudioEffectModel, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
