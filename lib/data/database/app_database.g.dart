// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _nameIdMeta = const VerificationMeta('nameId');
  @override
  late final GeneratedColumn<String> nameId = GeneratedColumn<String>(
    'name_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _templateKeyMeta = const VerificationMeta(
    'templateKey',
  );
  @override
  late final GeneratedColumn<String> templateKey = GeneratedColumn<String>(
    'template_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    colorHex,
    isDefault,
    isArchived,
    createdAt,
    nameId,
    templateKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('name_id')) {
      context.handle(
        _nameIdMeta,
        nameId.isAcceptableOrUnknown(data['name_id']!, _nameIdMeta),
      );
    }
    if (data.containsKey('template_key')) {
      context.handle(
        _templateKeyMeta,
        templateKey.isAcceptableOrUnknown(
          data['template_key']!,
          _templateKeyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      nameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_id'],
      ),
      templateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_key'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String? icon;
  final String? colorHex;
  final bool isDefault;
  final bool isArchived;
  final DateTime createdAt;

  /// Terjemahan Indonesia dari `name` (goal phrase) — dwibahasa (CLAUDE.md
  /// §Bahasa). Nullable: kategori lama/custom yang belum sempat diisi
  /// fallback ke `name` (Inggris) saat ditampilkan.
  final String? nameId;

  /// Key stabil ke entri kategori di `habit_templates.json` (mis.
  /// 'save_money') — dipakai untuk mencocokkan ulang terjemahan/goal-phrase
  /// lookup tanpa bergantung ke string `name` yang sekarang bisa 2 bahasa.
  /// Null untuk kategori custom buatan user.
  final String? templateKey;
  const Category({
    required this.id,
    required this.name,
    this.icon,
    this.colorHex,
    required this.isDefault,
    required this.isArchived,
    required this.createdAt,
    this.nameId,
    this.templateKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<String>(colorHex);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || nameId != null) {
      map['name_id'] = Variable<String>(nameId);
    }
    if (!nullToAbsent || templateKey != null) {
      map['template_key'] = Variable<String>(templateKey);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      colorHex: colorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(colorHex),
      isDefault: Value(isDefault),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      nameId: nameId == null && nullToAbsent
          ? const Value.absent()
          : Value(nameId),
      templateKey: templateKey == null && nullToAbsent
          ? const Value.absent()
          : Value(templateKey),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      colorHex: serializer.fromJson<String?>(json['colorHex']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      nameId: serializer.fromJson<String?>(json['nameId']),
      templateKey: serializer.fromJson<String?>(json['templateKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'colorHex': serializer.toJson<String?>(colorHex),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'nameId': serializer.toJson<String?>(nameId),
      'templateKey': serializer.toJson<String?>(templateKey),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    Value<String?> icon = const Value.absent(),
    Value<String?> colorHex = const Value.absent(),
    bool? isDefault,
    bool? isArchived,
    DateTime? createdAt,
    Value<String?> nameId = const Value.absent(),
    Value<String?> templateKey = const Value.absent(),
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon.present ? icon.value : this.icon,
    colorHex: colorHex.present ? colorHex.value : this.colorHex,
    isDefault: isDefault ?? this.isDefault,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    nameId: nameId.present ? nameId.value : this.nameId,
    templateKey: templateKey.present ? templateKey.value : this.templateKey,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      nameId: data.nameId.present ? data.nameId.value : this.nameId,
      templateKey: data.templateKey.present
          ? data.templateKey.value
          : this.templateKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('colorHex: $colorHex, ')
          ..write('isDefault: $isDefault, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('nameId: $nameId, ')
          ..write('templateKey: $templateKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    icon,
    colorHex,
    isDefault,
    isArchived,
    createdAt,
    nameId,
    templateKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.colorHex == this.colorHex &&
          other.isDefault == this.isDefault &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.nameId == this.nameId &&
          other.templateKey == this.templateKey);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> icon;
  final Value<String?> colorHex;
  final Value<bool> isDefault;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<String?> nameId;
  final Value<String?> templateKey;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nameId = const Value.absent(),
    this.templateKey = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nameId = const Value.absent(),
    this.templateKey = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? colorHex,
    Expression<bool>? isDefault,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<String>? nameId,
    Expression<String>? templateKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (colorHex != null) 'color_hex': colorHex,
      if (isDefault != null) 'is_default': isDefault,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (nameId != null) 'name_id': nameId,
      if (templateKey != null) 'template_key': templateKey,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? icon,
    Value<String?>? colorHex,
    Value<bool>? isDefault,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<String?>? nameId,
    Value<String?>? templateKey,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      isDefault: isDefault ?? this.isDefault,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      nameId: nameId ?? this.nameId,
      templateKey: templateKey ?? this.templateKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (nameId.present) {
      map['name_id'] = Variable<String>(nameId.value);
    }
    if (templateKey.present) {
      map['template_key'] = Variable<String>(templateKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('colorHex: $colorHex, ')
          ..write('isDefault: $isDefault, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('nameId: $nameId, ')
          ..write('templateKey: $templateKey')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalPeriodMeta = const VerificationMeta(
    'goalPeriod',
  );
  @override
  late final GeneratedColumn<String> goalPeriod = GeneratedColumn<String>(
    'goal_period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalValueMeta = const VerificationMeta(
    'goalValue',
  );
  @override
  late final GeneratedColumn<int> goalValue = GeneratedColumn<int>(
    'goal_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _goalValueWeekendMeta = const VerificationMeta(
    'goalValueWeekend',
  );
  @override
  late final GeneratedColumn<int> goalValueWeekend = GeneratedColumn<int>(
    'goal_value_weekend',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalUnitMeta = const VerificationMeta(
    'goalUnit',
  );
  @override
  late final GeneratedColumn<String> goalUnit = GeneratedColumn<String>(
    'goal_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('x'),
  );
  static const VerificationMeta _goalDirectionMeta = const VerificationMeta(
    'goalDirection',
  );
  @override
  late final GeneratedColumn<String> goalDirection = GeneratedColumn<String>(
    'goal_direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('atLeast'),
  );
  static const VerificationMeta _taskDaysMeta = const VerificationMeta(
    'taskDays',
  );
  @override
  late final GeneratedColumn<String> taskDays = GeneratedColumn<String>(
    'task_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeRangeMeta = const VerificationMeta(
    'timeRange',
  );
  @override
  late final GeneratedColumn<String> timeRange = GeneratedColumn<String>(
    'time_range',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('anytime'),
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<String> reminderTime = GeneratedColumn<String>(
    'reminder_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderIntervalMinutesMeta =
      const VerificationMeta('reminderIntervalMinutes');
  @override
  late final GeneratedColumn<int> reminderIntervalMinutes =
      GeneratedColumn<int>(
        'reminder_interval_minutes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _nameIdMeta = const VerificationMeta('nameId');
  @override
  late final GeneratedColumn<String> nameId = GeneratedColumn<String>(
    'name_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _templateKeyMeta = const VerificationMeta(
    'templateKey',
  );
  @override
  late final GeneratedColumn<String> templateKey = GeneratedColumn<String>(
    'template_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    name,
    description,
    icon,
    goalPeriod,
    goalValue,
    goalValueWeekend,
    goalUnit,
    goalDirection,
    taskDays,
    timeRange,
    reminderEnabled,
    reminderTime,
    reminderIntervalMinutes,
    startDate,
    endDate,
    isActive,
    sortOrder,
    createdAt,
    nameId,
    isCustom,
    templateKey,
    currency,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('goal_period')) {
      context.handle(
        _goalPeriodMeta,
        goalPeriod.isAcceptableOrUnknown(data['goal_period']!, _goalPeriodMeta),
      );
    } else if (isInserting) {
      context.missing(_goalPeriodMeta);
    }
    if (data.containsKey('goal_value')) {
      context.handle(
        _goalValueMeta,
        goalValue.isAcceptableOrUnknown(data['goal_value']!, _goalValueMeta),
      );
    }
    if (data.containsKey('goal_value_weekend')) {
      context.handle(
        _goalValueWeekendMeta,
        goalValueWeekend.isAcceptableOrUnknown(
          data['goal_value_weekend']!,
          _goalValueWeekendMeta,
        ),
      );
    }
    if (data.containsKey('goal_unit')) {
      context.handle(
        _goalUnitMeta,
        goalUnit.isAcceptableOrUnknown(data['goal_unit']!, _goalUnitMeta),
      );
    }
    if (data.containsKey('goal_direction')) {
      context.handle(
        _goalDirectionMeta,
        goalDirection.isAcceptableOrUnknown(
          data['goal_direction']!,
          _goalDirectionMeta,
        ),
      );
    }
    if (data.containsKey('task_days')) {
      context.handle(
        _taskDaysMeta,
        taskDays.isAcceptableOrUnknown(data['task_days']!, _taskDaysMeta),
      );
    } else if (isInserting) {
      context.missing(_taskDaysMeta);
    }
    if (data.containsKey('time_range')) {
      context.handle(
        _timeRangeMeta,
        timeRange.isAcceptableOrUnknown(data['time_range']!, _timeRangeMeta),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('reminder_interval_minutes')) {
      context.handle(
        _reminderIntervalMinutesMeta,
        reminderIntervalMinutes.isAcceptableOrUnknown(
          data['reminder_interval_minutes']!,
          _reminderIntervalMinutesMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('name_id')) {
      context.handle(
        _nameIdMeta,
        nameId.isAcceptableOrUnknown(data['name_id']!, _nameIdMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('template_key')) {
      context.handle(
        _templateKeyMeta,
        templateKey.isAcceptableOrUnknown(
          data['template_key']!,
          _templateKeyMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      goalPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_period'],
      )!,
      goalValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_value'],
      )!,
      goalValueWeekend: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_value_weekend'],
      ),
      goalUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_unit'],
      )!,
      goalDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_direction'],
      )!,
      taskDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_days'],
      )!,
      timeRange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_range'],
      )!,
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_time'],
      ),
      reminderIntervalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_interval_minutes'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      nameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_id'],
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      templateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_key'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      ),
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final String? icon;
  final String goalPeriod;
  final int goalValue;

  /// Override goalValue khusus Sabtu-Minggu untuk habit `daily` — null berarti
  /// nilai sama setiap hari (goalValue dipakai apa adanya, perilaku lama).
  final int? goalValueWeekend;
  final String goalUnit;
  final String goalDirection;
  final String taskDays;
  final String timeRange;
  final bool reminderEnabled;
  final String? reminderTime;

  /// Minutes between repeats starting at [reminderTime], e.g. every 30
  /// minutes — null means a single reminder at [reminderTime] (the
  /// pre-existing behavior). No end time: repeats until end of day.
  final int? reminderIntervalMinutes;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;

  /// Terjemahan Indonesia dari `name` — dwibahasa (CLAUDE.md §Bahasa).
  /// Nullable: habit lama/custom yang belum sempat diisi fallback ke `name`
  /// (Inggris) saat ditampilkan.
  final String? nameId;

  /// True kalau title boleh diedit user. Habit dari template bawaan
  /// (`templateKey` non-null, dikonfirmasi lewat backfill) dikunci
  /// (`isCustom=false`); default true supaya baris lama yang gagal
  /// dicocokkan ke template tetap aman untuk diedit alih-alih tiba-tiba
  /// terkunci tanpa alasan jelas ke user.
  final bool isCustom;

  /// Key stabil ke entri habit di `habit_templates.json` (mis.
  /// 'drink_water'). Null untuk habit custom buatan user.
  final String? templateKey;

  /// Kode mata uang (IDR/USD/SGD/MYR/EUR) untuk habit Budget Tracker —
  /// label/prefix tampilan saja, tidak mengubah cara angka diformat. Null
  /// untuk habit non-finance, dan default ke 'IDR' di kode saat null untuk
  /// habit finance lama yang dibuat sebelum kolom ini ada.
  final String? currency;
  const Habit({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    this.icon,
    required this.goalPeriod,
    required this.goalValue,
    this.goalValueWeekend,
    required this.goalUnit,
    required this.goalDirection,
    required this.taskDays,
    required this.timeRange,
    required this.reminderEnabled,
    this.reminderTime,
    this.reminderIntervalMinutes,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    this.nameId,
    required this.isCustom,
    this.templateKey,
    this.currency,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['goal_period'] = Variable<String>(goalPeriod);
    map['goal_value'] = Variable<int>(goalValue);
    if (!nullToAbsent || goalValueWeekend != null) {
      map['goal_value_weekend'] = Variable<int>(goalValueWeekend);
    }
    map['goal_unit'] = Variable<String>(goalUnit);
    map['goal_direction'] = Variable<String>(goalDirection);
    map['task_days'] = Variable<String>(taskDays);
    map['time_range'] = Variable<String>(timeRange);
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    if (!nullToAbsent || reminderTime != null) {
      map['reminder_time'] = Variable<String>(reminderTime);
    }
    if (!nullToAbsent || reminderIntervalMinutes != null) {
      map['reminder_interval_minutes'] = Variable<int>(reminderIntervalMinutes);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || nameId != null) {
      map['name_id'] = Variable<String>(nameId);
    }
    map['is_custom'] = Variable<bool>(isCustom);
    if (!nullToAbsent || templateKey != null) {
      map['template_key'] = Variable<String>(templateKey);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      goalPeriod: Value(goalPeriod),
      goalValue: Value(goalValue),
      goalValueWeekend: goalValueWeekend == null && nullToAbsent
          ? const Value.absent()
          : Value(goalValueWeekend),
      goalUnit: Value(goalUnit),
      goalDirection: Value(goalDirection),
      taskDays: Value(taskDays),
      timeRange: Value(timeRange),
      reminderEnabled: Value(reminderEnabled),
      reminderTime: reminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTime),
      reminderIntervalMinutes: reminderIntervalMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderIntervalMinutes),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      nameId: nameId == null && nullToAbsent
          ? const Value.absent()
          : Value(nameId),
      isCustom: Value(isCustom),
      templateKey: templateKey == null && nullToAbsent
          ? const Value.absent()
          : Value(templateKey),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      icon: serializer.fromJson<String?>(json['icon']),
      goalPeriod: serializer.fromJson<String>(json['goalPeriod']),
      goalValue: serializer.fromJson<int>(json['goalValue']),
      goalValueWeekend: serializer.fromJson<int?>(json['goalValueWeekend']),
      goalUnit: serializer.fromJson<String>(json['goalUnit']),
      goalDirection: serializer.fromJson<String>(json['goalDirection']),
      taskDays: serializer.fromJson<String>(json['taskDays']),
      timeRange: serializer.fromJson<String>(json['timeRange']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      reminderTime: serializer.fromJson<String?>(json['reminderTime']),
      reminderIntervalMinutes: serializer.fromJson<int?>(
        json['reminderIntervalMinutes'],
      ),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      nameId: serializer.fromJson<String?>(json['nameId']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      templateKey: serializer.fromJson<String?>(json['templateKey']),
      currency: serializer.fromJson<String?>(json['currency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'icon': serializer.toJson<String?>(icon),
      'goalPeriod': serializer.toJson<String>(goalPeriod),
      'goalValue': serializer.toJson<int>(goalValue),
      'goalValueWeekend': serializer.toJson<int?>(goalValueWeekend),
      'goalUnit': serializer.toJson<String>(goalUnit),
      'goalDirection': serializer.toJson<String>(goalDirection),
      'taskDays': serializer.toJson<String>(taskDays),
      'timeRange': serializer.toJson<String>(timeRange),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'reminderTime': serializer.toJson<String?>(reminderTime),
      'reminderIntervalMinutes': serializer.toJson<int?>(
        reminderIntervalMinutes,
      ),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'nameId': serializer.toJson<String?>(nameId),
      'isCustom': serializer.toJson<bool>(isCustom),
      'templateKey': serializer.toJson<String?>(templateKey),
      'currency': serializer.toJson<String?>(currency),
    };
  }

  Habit copyWith({
    int? id,
    int? categoryId,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    String? goalPeriod,
    int? goalValue,
    Value<int?> goalValueWeekend = const Value.absent(),
    String? goalUnit,
    String? goalDirection,
    String? taskDays,
    String? timeRange,
    bool? reminderEnabled,
    Value<String?> reminderTime = const Value.absent(),
    Value<int?> reminderIntervalMinutes = const Value.absent(),
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    Value<String?> nameId = const Value.absent(),
    bool? isCustom,
    Value<String?> templateKey = const Value.absent(),
    Value<String?> currency = const Value.absent(),
  }) => Habit(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    icon: icon.present ? icon.value : this.icon,
    goalPeriod: goalPeriod ?? this.goalPeriod,
    goalValue: goalValue ?? this.goalValue,
    goalValueWeekend: goalValueWeekend.present
        ? goalValueWeekend.value
        : this.goalValueWeekend,
    goalUnit: goalUnit ?? this.goalUnit,
    goalDirection: goalDirection ?? this.goalDirection,
    taskDays: taskDays ?? this.taskDays,
    timeRange: timeRange ?? this.timeRange,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderTime: reminderTime.present ? reminderTime.value : this.reminderTime,
    reminderIntervalMinutes: reminderIntervalMinutes.present
        ? reminderIntervalMinutes.value
        : this.reminderIntervalMinutes,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    nameId: nameId.present ? nameId.value : this.nameId,
    isCustom: isCustom ?? this.isCustom,
    templateKey: templateKey.present ? templateKey.value : this.templateKey,
    currency: currency.present ? currency.value : this.currency,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      icon: data.icon.present ? data.icon.value : this.icon,
      goalPeriod: data.goalPeriod.present
          ? data.goalPeriod.value
          : this.goalPeriod,
      goalValue: data.goalValue.present ? data.goalValue.value : this.goalValue,
      goalValueWeekend: data.goalValueWeekend.present
          ? data.goalValueWeekend.value
          : this.goalValueWeekend,
      goalUnit: data.goalUnit.present ? data.goalUnit.value : this.goalUnit,
      goalDirection: data.goalDirection.present
          ? data.goalDirection.value
          : this.goalDirection,
      taskDays: data.taskDays.present ? data.taskDays.value : this.taskDays,
      timeRange: data.timeRange.present ? data.timeRange.value : this.timeRange,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      reminderIntervalMinutes: data.reminderIntervalMinutes.present
          ? data.reminderIntervalMinutes.value
          : this.reminderIntervalMinutes,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      nameId: data.nameId.present ? data.nameId.value : this.nameId,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      templateKey: data.templateKey.present
          ? data.templateKey.value
          : this.templateKey,
      currency: data.currency.present ? data.currency.value : this.currency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('goalPeriod: $goalPeriod, ')
          ..write('goalValue: $goalValue, ')
          ..write('goalValueWeekend: $goalValueWeekend, ')
          ..write('goalUnit: $goalUnit, ')
          ..write('goalDirection: $goalDirection, ')
          ..write('taskDays: $taskDays, ')
          ..write('timeRange: $timeRange, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('reminderIntervalMinutes: $reminderIntervalMinutes, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('nameId: $nameId, ')
          ..write('isCustom: $isCustom, ')
          ..write('templateKey: $templateKey, ')
          ..write('currency: $currency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    categoryId,
    name,
    description,
    icon,
    goalPeriod,
    goalValue,
    goalValueWeekend,
    goalUnit,
    goalDirection,
    taskDays,
    timeRange,
    reminderEnabled,
    reminderTime,
    reminderIntervalMinutes,
    startDate,
    endDate,
    isActive,
    sortOrder,
    createdAt,
    nameId,
    isCustom,
    templateKey,
    currency,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.description == this.description &&
          other.icon == this.icon &&
          other.goalPeriod == this.goalPeriod &&
          other.goalValue == this.goalValue &&
          other.goalValueWeekend == this.goalValueWeekend &&
          other.goalUnit == this.goalUnit &&
          other.goalDirection == this.goalDirection &&
          other.taskDays == this.taskDays &&
          other.timeRange == this.timeRange &&
          other.reminderEnabled == this.reminderEnabled &&
          other.reminderTime == this.reminderTime &&
          other.reminderIntervalMinutes == this.reminderIntervalMinutes &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.nameId == this.nameId &&
          other.isCustom == this.isCustom &&
          other.templateKey == this.templateKey &&
          other.currency == this.currency);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> icon;
  final Value<String> goalPeriod;
  final Value<int> goalValue;
  final Value<int?> goalValueWeekend;
  final Value<String> goalUnit;
  final Value<String> goalDirection;
  final Value<String> taskDays;
  final Value<String> timeRange;
  final Value<bool> reminderEnabled;
  final Value<String?> reminderTime;
  final Value<int?> reminderIntervalMinutes;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<String?> nameId;
  final Value<bool> isCustom;
  final Value<String?> templateKey;
  final Value<String?> currency;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.goalPeriod = const Value.absent(),
    this.goalValue = const Value.absent(),
    this.goalValueWeekend = const Value.absent(),
    this.goalUnit = const Value.absent(),
    this.goalDirection = const Value.absent(),
    this.taskDays = const Value.absent(),
    this.timeRange = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.reminderIntervalMinutes = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nameId = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.templateKey = const Value.absent(),
    this.currency = const Value.absent(),
  });
  HabitsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String name,
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    required String goalPeriod,
    this.goalValue = const Value.absent(),
    this.goalValueWeekend = const Value.absent(),
    this.goalUnit = const Value.absent(),
    this.goalDirection = const Value.absent(),
    required String taskDays,
    this.timeRange = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.reminderIntervalMinutes = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nameId = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.templateKey = const Value.absent(),
    this.currency = const Value.absent(),
  }) : categoryId = Value(categoryId),
       name = Value(name),
       goalPeriod = Value(goalPeriod),
       taskDays = Value(taskDays),
       startDate = Value(startDate);
  static Insertable<Habit> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? icon,
    Expression<String>? goalPeriod,
    Expression<int>? goalValue,
    Expression<int>? goalValueWeekend,
    Expression<String>? goalUnit,
    Expression<String>? goalDirection,
    Expression<String>? taskDays,
    Expression<String>? timeRange,
    Expression<bool>? reminderEnabled,
    Expression<String>? reminderTime,
    Expression<int>? reminderIntervalMinutes,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<String>? nameId,
    Expression<bool>? isCustom,
    Expression<String>? templateKey,
    Expression<String>? currency,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (goalPeriod != null) 'goal_period': goalPeriod,
      if (goalValue != null) 'goal_value': goalValue,
      if (goalValueWeekend != null) 'goal_value_weekend': goalValueWeekend,
      if (goalUnit != null) 'goal_unit': goalUnit,
      if (goalDirection != null) 'goal_direction': goalDirection,
      if (taskDays != null) 'task_days': taskDays,
      if (timeRange != null) 'time_range': timeRange,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (reminderIntervalMinutes != null)
        'reminder_interval_minutes': reminderIntervalMinutes,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (nameId != null) 'name_id': nameId,
      if (isCustom != null) 'is_custom': isCustom,
      if (templateKey != null) 'template_key': templateKey,
      if (currency != null) 'currency': currency,
    });
  }

  HabitsCompanion copyWith({
    Value<int>? id,
    Value<int>? categoryId,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? icon,
    Value<String>? goalPeriod,
    Value<int>? goalValue,
    Value<int?>? goalValueWeekend,
    Value<String>? goalUnit,
    Value<String>? goalDirection,
    Value<String>? taskDays,
    Value<String>? timeRange,
    Value<bool>? reminderEnabled,
    Value<String?>? reminderTime,
    Value<int?>? reminderIntervalMinutes,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<bool>? isActive,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<String?>? nameId,
    Value<bool>? isCustom,
    Value<String?>? templateKey,
    Value<String?>? currency,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      goalPeriod: goalPeriod ?? this.goalPeriod,
      goalValue: goalValue ?? this.goalValue,
      goalValueWeekend: goalValueWeekend ?? this.goalValueWeekend,
      goalUnit: goalUnit ?? this.goalUnit,
      goalDirection: goalDirection ?? this.goalDirection,
      taskDays: taskDays ?? this.taskDays,
      timeRange: timeRange ?? this.timeRange,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderIntervalMinutes:
          reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      nameId: nameId ?? this.nameId,
      isCustom: isCustom ?? this.isCustom,
      templateKey: templateKey ?? this.templateKey,
      currency: currency ?? this.currency,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (goalPeriod.present) {
      map['goal_period'] = Variable<String>(goalPeriod.value);
    }
    if (goalValue.present) {
      map['goal_value'] = Variable<int>(goalValue.value);
    }
    if (goalValueWeekend.present) {
      map['goal_value_weekend'] = Variable<int>(goalValueWeekend.value);
    }
    if (goalUnit.present) {
      map['goal_unit'] = Variable<String>(goalUnit.value);
    }
    if (goalDirection.present) {
      map['goal_direction'] = Variable<String>(goalDirection.value);
    }
    if (taskDays.present) {
      map['task_days'] = Variable<String>(taskDays.value);
    }
    if (timeRange.present) {
      map['time_range'] = Variable<String>(timeRange.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<String>(reminderTime.value);
    }
    if (reminderIntervalMinutes.present) {
      map['reminder_interval_minutes'] = Variable<int>(
        reminderIntervalMinutes.value,
      );
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (nameId.present) {
      map['name_id'] = Variable<String>(nameId.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (templateKey.present) {
      map['template_key'] = Variable<String>(templateKey.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('goalPeriod: $goalPeriod, ')
          ..write('goalValue: $goalValue, ')
          ..write('goalValueWeekend: $goalValueWeekend, ')
          ..write('goalUnit: $goalUnit, ')
          ..write('goalDirection: $goalDirection, ')
          ..write('taskDays: $taskDays, ')
          ..write('timeRange: $timeRange, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('reminderIntervalMinutes: $reminderIntervalMinutes, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('nameId: $nameId, ')
          ..write('isCustom: $isCustom, ')
          ..write('templateKey: $templateKey, ')
          ..write('currency: $currency')
          ..write(')'))
        .toString();
  }
}

class $HabitLogsTable extends HabitLogs
    with TableInfo<$HabitLogsTable, HabitLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressValueMeta = const VerificationMeta(
    'progressValue',
  );
  @override
  late final GeneratedColumn<int> progressValue = GeneratedColumn<int>(
    'progress_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    date,
    progressValue,
    isDone,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('progress_value')) {
      context.handle(
        _progressValueMeta,
        progressValue.isAcceptableOrUnknown(
          data['progress_value']!,
          _progressValueMeta,
        ),
      );
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {habitId, date},
  ];
  @override
  HabitLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      progressValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress_value'],
      )!,
      isDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done'],
      )!,
    );
  }

  @override
  $HabitLogsTable createAlias(String alias) {
    return $HabitLogsTable(attachedDatabase, alias);
  }
}

class HabitLog extends DataClass implements Insertable<HabitLog> {
  final int id;
  final int habitId;
  final DateTime date;
  final int progressValue;
  final bool isDone;
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.progressValue,
    required this.isDone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<int>(habitId);
    map['date'] = Variable<DateTime>(date);
    map['progress_value'] = Variable<int>(progressValue);
    map['is_done'] = Variable<bool>(isDone);
    return map;
  }

  HabitLogsCompanion toCompanion(bool nullToAbsent) {
    return HabitLogsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      date: Value(date),
      progressValue: Value(progressValue),
      isDone: Value(isDone),
    );
  }

  factory HabitLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitLog(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<int>(json['habitId']),
      date: serializer.fromJson<DateTime>(json['date']),
      progressValue: serializer.fromJson<int>(json['progressValue']),
      isDone: serializer.fromJson<bool>(json['isDone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<int>(habitId),
      'date': serializer.toJson<DateTime>(date),
      'progressValue': serializer.toJson<int>(progressValue),
      'isDone': serializer.toJson<bool>(isDone),
    };
  }

  HabitLog copyWith({
    int? id,
    int? habitId,
    DateTime? date,
    int? progressValue,
    bool? isDone,
  }) => HabitLog(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    date: date ?? this.date,
    progressValue: progressValue ?? this.progressValue,
    isDone: isDone ?? this.isDone,
  );
  HabitLog copyWithCompanion(HabitLogsCompanion data) {
    return HabitLog(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      date: data.date.present ? data.date.value : this.date,
      progressValue: data.progressValue.present
          ? data.progressValue.value
          : this.progressValue,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitLog(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('progressValue: $progressValue, ')
          ..write('isDone: $isDone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, date, progressValue, isDone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitLog &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.date == this.date &&
          other.progressValue == this.progressValue &&
          other.isDone == this.isDone);
}

class HabitLogsCompanion extends UpdateCompanion<HabitLog> {
  final Value<int> id;
  final Value<int> habitId;
  final Value<DateTime> date;
  final Value<int> progressValue;
  final Value<bool> isDone;
  const HabitLogsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.date = const Value.absent(),
    this.progressValue = const Value.absent(),
    this.isDone = const Value.absent(),
  });
  HabitLogsCompanion.insert({
    this.id = const Value.absent(),
    required int habitId,
    required DateTime date,
    this.progressValue = const Value.absent(),
    this.isDone = const Value.absent(),
  }) : habitId = Value(habitId),
       date = Value(date);
  static Insertable<HabitLog> custom({
    Expression<int>? id,
    Expression<int>? habitId,
    Expression<DateTime>? date,
    Expression<int>? progressValue,
    Expression<bool>? isDone,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (date != null) 'date': date,
      if (progressValue != null) 'progress_value': progressValue,
      if (isDone != null) 'is_done': isDone,
    });
  }

  HabitLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? habitId,
    Value<DateTime>? date,
    Value<int>? progressValue,
    Value<bool>? isDone,
  }) {
    return HabitLogsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      progressValue: progressValue ?? this.progressValue,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (progressValue.present) {
      map['progress_value'] = Variable<int>(progressValue.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitLogsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('progressValue: $progressValue, ')
          ..write('isDone: $isDone')
          ..write(')'))
        .toString();
  }
}

class $UserProfileTable extends UserProfile
    with TableInfo<$UserProfileTable, UserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeKeyMeta = const VerificationMeta(
    'themeKey',
  );
  @override
  late final GeneratedColumn<String> themeKey = GeneratedColumn<String>(
    'theme_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('teal_sage'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    age,
    photoPath,
    themeKey,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('theme_key')) {
      context.handle(
        _themeKeyMeta,
        themeKey.isAcceptableOrUnknown(data['theme_key']!, _themeKeyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      themeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserProfileTable createAlias(String alias) {
    return $UserProfileTable(attachedDatabase, alias);
  }
}

class UserProfileRow extends DataClass implements Insertable<UserProfileRow> {
  final int id;
  final String name;
  final int? age;
  final String? photoPath;
  final String themeKey;
  final DateTime createdAt;
  const UserProfileRow({
    required this.id,
    required this.name,
    this.age,
    this.photoPath,
    required this.themeKey,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['theme_key'] = Variable<String>(themeKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserProfileCompanion toCompanion(bool nullToAbsent) {
    return UserProfileCompanion(
      id: Value(id),
      name: Value(name),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      themeKey: Value(themeKey),
      createdAt: Value(createdAt),
    );
  }

  factory UserProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      age: serializer.fromJson<int?>(json['age']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      themeKey: serializer.fromJson<String>(json['themeKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'age': serializer.toJson<int?>(age),
      'photoPath': serializer.toJson<String?>(photoPath),
      'themeKey': serializer.toJson<String>(themeKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserProfileRow copyWith({
    int? id,
    String? name,
    Value<int?> age = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    String? themeKey,
    DateTime? createdAt,
  }) => UserProfileRow(
    id: id ?? this.id,
    name: name ?? this.name,
    age: age.present ? age.value : this.age,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    themeKey: themeKey ?? this.themeKey,
    createdAt: createdAt ?? this.createdAt,
  );
  UserProfileRow copyWithCompanion(UserProfileCompanion data) {
    return UserProfileRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      age: data.age.present ? data.age.value : this.age,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      themeKey: data.themeKey.present ? data.themeKey.value : this.themeKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('photoPath: $photoPath, ')
          ..write('themeKey: $themeKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, age, photoPath, themeKey, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.age == this.age &&
          other.photoPath == this.photoPath &&
          other.themeKey == this.themeKey &&
          other.createdAt == this.createdAt);
}

class UserProfileCompanion extends UpdateCompanion<UserProfileRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> age;
  final Value<String?> photoPath;
  final Value<String> themeKey;
  final Value<DateTime> createdAt;
  const UserProfileCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.themeKey = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UserProfileCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.age = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.themeKey = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<UserProfileRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? age,
    Expression<String>? photoPath,
    Expression<String>? themeKey,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (photoPath != null) 'photo_path': photoPath,
      if (themeKey != null) 'theme_key': themeKey,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UserProfileCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? age,
    Value<String?>? photoPath,
    Value<String>? themeKey,
    Value<DateTime>? createdAt,
  }) {
    return UserProfileCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      photoPath: photoPath ?? this.photoPath,
      themeKey: themeKey ?? this.themeKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (themeKey.present) {
      map['theme_key'] = Variable<String>(themeKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('photoPath: $photoPath, ')
          ..write('themeKey: $themeKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $OnboardingResponsesTable extends OnboardingResponses
    with TableInfo<$OnboardingResponsesTable, OnboardingResponse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OnboardingResponsesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _questionKeyMeta = const VerificationMeta(
    'questionKey',
  );
  @override
  late final GeneratedColumn<String> questionKey = GeneratedColumn<String>(
    'question_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answerValueMeta = const VerificationMeta(
    'answerValue',
  );
  @override
  late final GeneratedColumn<String> answerValue = GeneratedColumn<String>(
    'answer_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    questionKey,
    answerValue,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'onboarding_responses';
  @override
  VerificationContext validateIntegrity(
    Insertable<OnboardingResponse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('question_key')) {
      context.handle(
        _questionKeyMeta,
        questionKey.isAcceptableOrUnknown(
          data['question_key']!,
          _questionKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionKeyMeta);
    }
    if (data.containsKey('answer_value')) {
      context.handle(
        _answerValueMeta,
        answerValue.isAcceptableOrUnknown(
          data['answer_value']!,
          _answerValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_answerValueMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OnboardingResponse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OnboardingResponse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      questionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_key'],
      )!,
      answerValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer_value'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OnboardingResponsesTable createAlias(String alias) {
    return $OnboardingResponsesTable(attachedDatabase, alias);
  }
}

class OnboardingResponse extends DataClass
    implements Insertable<OnboardingResponse> {
  final int id;
  final String questionKey;
  final String answerValue;
  final DateTime createdAt;
  const OnboardingResponse({
    required this.id,
    required this.questionKey,
    required this.answerValue,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['question_key'] = Variable<String>(questionKey);
    map['answer_value'] = Variable<String>(answerValue);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OnboardingResponsesCompanion toCompanion(bool nullToAbsent) {
    return OnboardingResponsesCompanion(
      id: Value(id),
      questionKey: Value(questionKey),
      answerValue: Value(answerValue),
      createdAt: Value(createdAt),
    );
  }

  factory OnboardingResponse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OnboardingResponse(
      id: serializer.fromJson<int>(json['id']),
      questionKey: serializer.fromJson<String>(json['questionKey']),
      answerValue: serializer.fromJson<String>(json['answerValue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'questionKey': serializer.toJson<String>(questionKey),
      'answerValue': serializer.toJson<String>(answerValue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OnboardingResponse copyWith({
    int? id,
    String? questionKey,
    String? answerValue,
    DateTime? createdAt,
  }) => OnboardingResponse(
    id: id ?? this.id,
    questionKey: questionKey ?? this.questionKey,
    answerValue: answerValue ?? this.answerValue,
    createdAt: createdAt ?? this.createdAt,
  );
  OnboardingResponse copyWithCompanion(OnboardingResponsesCompanion data) {
    return OnboardingResponse(
      id: data.id.present ? data.id.value : this.id,
      questionKey: data.questionKey.present
          ? data.questionKey.value
          : this.questionKey,
      answerValue: data.answerValue.present
          ? data.answerValue.value
          : this.answerValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OnboardingResponse(')
          ..write('id: $id, ')
          ..write('questionKey: $questionKey, ')
          ..write('answerValue: $answerValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, questionKey, answerValue, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OnboardingResponse &&
          other.id == this.id &&
          other.questionKey == this.questionKey &&
          other.answerValue == this.answerValue &&
          other.createdAt == this.createdAt);
}

class OnboardingResponsesCompanion extends UpdateCompanion<OnboardingResponse> {
  final Value<int> id;
  final Value<String> questionKey;
  final Value<String> answerValue;
  final Value<DateTime> createdAt;
  const OnboardingResponsesCompanion({
    this.id = const Value.absent(),
    this.questionKey = const Value.absent(),
    this.answerValue = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OnboardingResponsesCompanion.insert({
    this.id = const Value.absent(),
    required String questionKey,
    required String answerValue,
    this.createdAt = const Value.absent(),
  }) : questionKey = Value(questionKey),
       answerValue = Value(answerValue);
  static Insertable<OnboardingResponse> custom({
    Expression<int>? id,
    Expression<String>? questionKey,
    Expression<String>? answerValue,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionKey != null) 'question_key': questionKey,
      if (answerValue != null) 'answer_value': answerValue,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OnboardingResponsesCompanion copyWith({
    Value<int>? id,
    Value<String>? questionKey,
    Value<String>? answerValue,
    Value<DateTime>? createdAt,
  }) {
    return OnboardingResponsesCompanion(
      id: id ?? this.id,
      questionKey: questionKey ?? this.questionKey,
      answerValue: answerValue ?? this.answerValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (questionKey.present) {
      map['question_key'] = Variable<String>(questionKey.value);
    }
    if (answerValue.present) {
      map['answer_value'] = Variable<String>(answerValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OnboardingResponsesCompanion(')
          ..write('id: $id, ')
          ..write('questionKey: $questionKey, ')
          ..write('answerValue: $answerValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $HabitGroupLinksTable extends HabitGroupLinks
    with TableInfo<$HabitGroupLinksTable, HabitGroupLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitGroupLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupHabitIdMeta = const VerificationMeta(
    'groupHabitId',
  );
  @override
  late final GeneratedColumn<String> groupHabitId = GeneratedColumn<String>(
    'group_habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkedAtMeta = const VerificationMeta(
    'linkedAt',
  );
  @override
  late final GeneratedColumn<DateTime> linkedAt = GeneratedColumn<DateTime>(
    'linked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    groupId,
    groupHabitId,
    linkedAt,
    lastSyncedAt,
    uid,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_group_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitGroupLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('group_habit_id')) {
      context.handle(
        _groupHabitIdMeta,
        groupHabitId.isAcceptableOrUnknown(
          data['group_habit_id']!,
          _groupHabitIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_groupHabitIdMeta);
    }
    if (data.containsKey('linked_at')) {
      context.handle(
        _linkedAtMeta,
        linkedAt.isAcceptableOrUnknown(data['linked_at']!, _linkedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {habitId, groupHabitId, uid},
  ];
  @override
  HabitGroupLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitGroupLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      groupHabitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_habit_id'],
      )!,
      linkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}linked_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      ),
    );
  }

  @override
  $HabitGroupLinksTable createAlias(String alias) {
    return $HabitGroupLinksTable(attachedDatabase, alias);
  }
}

class HabitGroupLink extends DataClass implements Insertable<HabitGroupLink> {
  final int id;
  final int habitId;
  final String groupId;
  final String groupHabitId;
  final DateTime linkedAt;
  final DateTime? lastSyncedAt;

  /// Signed-in Firebase uid that created this link — this table is a local
  /// (per-device) DB, but a device isn't always 1:1 with 1 account (multiple
  /// accounts signed in/out on the same phone, or a shared/test device), so
  /// every link must be scoped to whoever actually made it. Without this,
  /// account B would see account A's links as "already linked" and vice
  /// versa. Nullable only for rows written before this column existed.
  final String? uid;
  const HabitGroupLink({
    required this.id,
    required this.habitId,
    required this.groupId,
    required this.groupHabitId,
    required this.linkedAt,
    this.lastSyncedAt,
    this.uid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<int>(habitId);
    map['group_id'] = Variable<String>(groupId);
    map['group_habit_id'] = Variable<String>(groupHabitId);
    map['linked_at'] = Variable<DateTime>(linkedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || uid != null) {
      map['uid'] = Variable<String>(uid);
    }
    return map;
  }

  HabitGroupLinksCompanion toCompanion(bool nullToAbsent) {
    return HabitGroupLinksCompanion(
      id: Value(id),
      habitId: Value(habitId),
      groupId: Value(groupId),
      groupHabitId: Value(groupHabitId),
      linkedAt: Value(linkedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      uid: uid == null && nullToAbsent ? const Value.absent() : Value(uid),
    );
  }

  factory HabitGroupLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitGroupLink(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<int>(json['habitId']),
      groupId: serializer.fromJson<String>(json['groupId']),
      groupHabitId: serializer.fromJson<String>(json['groupHabitId']),
      linkedAt: serializer.fromJson<DateTime>(json['linkedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      uid: serializer.fromJson<String?>(json['uid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<int>(habitId),
      'groupId': serializer.toJson<String>(groupId),
      'groupHabitId': serializer.toJson<String>(groupHabitId),
      'linkedAt': serializer.toJson<DateTime>(linkedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'uid': serializer.toJson<String?>(uid),
    };
  }

  HabitGroupLink copyWith({
    int? id,
    int? habitId,
    String? groupId,
    String? groupHabitId,
    DateTime? linkedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<String?> uid = const Value.absent(),
  }) => HabitGroupLink(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    groupId: groupId ?? this.groupId,
    groupHabitId: groupHabitId ?? this.groupHabitId,
    linkedAt: linkedAt ?? this.linkedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    uid: uid.present ? uid.value : this.uid,
  );
  HabitGroupLink copyWithCompanion(HabitGroupLinksCompanion data) {
    return HabitGroupLink(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      groupHabitId: data.groupHabitId.present
          ? data.groupHabitId.value
          : this.groupHabitId,
      linkedAt: data.linkedAt.present ? data.linkedAt.value : this.linkedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      uid: data.uid.present ? data.uid.value : this.uid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitGroupLink(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('groupId: $groupId, ')
          ..write('groupHabitId: $groupHabitId, ')
          ..write('linkedAt: $linkedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('uid: $uid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    habitId,
    groupId,
    groupHabitId,
    linkedAt,
    lastSyncedAt,
    uid,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitGroupLink &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.groupId == this.groupId &&
          other.groupHabitId == this.groupHabitId &&
          other.linkedAt == this.linkedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.uid == this.uid);
}

class HabitGroupLinksCompanion extends UpdateCompanion<HabitGroupLink> {
  final Value<int> id;
  final Value<int> habitId;
  final Value<String> groupId;
  final Value<String> groupHabitId;
  final Value<DateTime> linkedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<String?> uid;
  const HabitGroupLinksCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.groupHabitId = const Value.absent(),
    this.linkedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.uid = const Value.absent(),
  });
  HabitGroupLinksCompanion.insert({
    this.id = const Value.absent(),
    required int habitId,
    required String groupId,
    required String groupHabitId,
    this.linkedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.uid = const Value.absent(),
  }) : habitId = Value(habitId),
       groupId = Value(groupId),
       groupHabitId = Value(groupHabitId);
  static Insertable<HabitGroupLink> custom({
    Expression<int>? id,
    Expression<int>? habitId,
    Expression<String>? groupId,
    Expression<String>? groupHabitId,
    Expression<DateTime>? linkedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? uid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (groupId != null) 'group_id': groupId,
      if (groupHabitId != null) 'group_habit_id': groupHabitId,
      if (linkedAt != null) 'linked_at': linkedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (uid != null) 'uid': uid,
    });
  }

  HabitGroupLinksCompanion copyWith({
    Value<int>? id,
    Value<int>? habitId,
    Value<String>? groupId,
    Value<String>? groupHabitId,
    Value<DateTime>? linkedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<String?>? uid,
  }) {
    return HabitGroupLinksCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      groupId: groupId ?? this.groupId,
      groupHabitId: groupHabitId ?? this.groupHabitId,
      linkedAt: linkedAt ?? this.linkedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      uid: uid ?? this.uid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (groupHabitId.present) {
      map['group_habit_id'] = Variable<String>(groupHabitId.value);
    }
    if (linkedAt.present) {
      map['linked_at'] = Variable<DateTime>(linkedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitGroupLinksCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('groupId: $groupId, ')
          ..write('groupHabitId: $groupHabitId, ')
          ..write('linkedAt: $linkedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('uid: $uid')
          ..write(')'))
        .toString();
  }
}

class $HabitSpendingBreakdownsTable extends HabitSpendingBreakdowns
    with TableInfo<$HabitSpendingBreakdownsTable, HabitSpendingBreakdown> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitSpendingBreakdownsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryKeyMeta = const VerificationMeta(
    'categoryKey',
  );
  @override
  late final GeneratedColumn<String> categoryKey = GeneratedColumn<String>(
    'category_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    date,
    categoryKey,
    label,
    amount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_spending_breakdowns';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitSpendingBreakdown> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('category_key')) {
      context.handle(
        _categoryKeyMeta,
        categoryKey.isAcceptableOrUnknown(
          data['category_key']!,
          _categoryKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryKeyMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitSpendingBreakdown map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitSpendingBreakdown(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      categoryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_key'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HabitSpendingBreakdownsTable createAlias(String alias) {
    return $HabitSpendingBreakdownsTable(attachedDatabase, alias);
  }
}

class HabitSpendingBreakdown extends DataClass
    implements Insertable<HabitSpendingBreakdown> {
  final int id;
  final int habitId;
  final DateTime date;
  final String categoryKey;

  /// Teks bebas sub-kategori/detail, opsional untuk kategori manapun (mis.
  /// "Bensin" di bawah kategori Fixed Spending).
  final String? label;
  final int amount;
  final DateTime createdAt;
  const HabitSpendingBreakdown({
    required this.id,
    required this.habitId,
    required this.date,
    required this.categoryKey,
    this.label,
    required this.amount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<int>(habitId);
    map['date'] = Variable<DateTime>(date);
    map['category_key'] = Variable<String>(categoryKey);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['amount'] = Variable<int>(amount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HabitSpendingBreakdownsCompanion toCompanion(bool nullToAbsent) {
    return HabitSpendingBreakdownsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      date: Value(date),
      categoryKey: Value(categoryKey),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      amount: Value(amount),
      createdAt: Value(createdAt),
    );
  }

  factory HabitSpendingBreakdown.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitSpendingBreakdown(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<int>(json['habitId']),
      date: serializer.fromJson<DateTime>(json['date']),
      categoryKey: serializer.fromJson<String>(json['categoryKey']),
      label: serializer.fromJson<String?>(json['label']),
      amount: serializer.fromJson<int>(json['amount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<int>(habitId),
      'date': serializer.toJson<DateTime>(date),
      'categoryKey': serializer.toJson<String>(categoryKey),
      'label': serializer.toJson<String?>(label),
      'amount': serializer.toJson<int>(amount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HabitSpendingBreakdown copyWith({
    int? id,
    int? habitId,
    DateTime? date,
    String? categoryKey,
    Value<String?> label = const Value.absent(),
    int? amount,
    DateTime? createdAt,
  }) => HabitSpendingBreakdown(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    date: date ?? this.date,
    categoryKey: categoryKey ?? this.categoryKey,
    label: label.present ? label.value : this.label,
    amount: amount ?? this.amount,
    createdAt: createdAt ?? this.createdAt,
  );
  HabitSpendingBreakdown copyWithCompanion(
    HabitSpendingBreakdownsCompanion data,
  ) {
    return HabitSpendingBreakdown(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      date: data.date.present ? data.date.value : this.date,
      categoryKey: data.categoryKey.present
          ? data.categoryKey.value
          : this.categoryKey,
      label: data.label.present ? data.label.value : this.label,
      amount: data.amount.present ? data.amount.value : this.amount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitSpendingBreakdown(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('label: $label, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, habitId, date, categoryKey, label, amount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitSpendingBreakdown &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.date == this.date &&
          other.categoryKey == this.categoryKey &&
          other.label == this.label &&
          other.amount == this.amount &&
          other.createdAt == this.createdAt);
}

class HabitSpendingBreakdownsCompanion
    extends UpdateCompanion<HabitSpendingBreakdown> {
  final Value<int> id;
  final Value<int> habitId;
  final Value<DateTime> date;
  final Value<String> categoryKey;
  final Value<String?> label;
  final Value<int> amount;
  final Value<DateTime> createdAt;
  const HabitSpendingBreakdownsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.date = const Value.absent(),
    this.categoryKey = const Value.absent(),
    this.label = const Value.absent(),
    this.amount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HabitSpendingBreakdownsCompanion.insert({
    this.id = const Value.absent(),
    required int habitId,
    required DateTime date,
    required String categoryKey,
    this.label = const Value.absent(),
    required int amount,
    this.createdAt = const Value.absent(),
  }) : habitId = Value(habitId),
       date = Value(date),
       categoryKey = Value(categoryKey),
       amount = Value(amount);
  static Insertable<HabitSpendingBreakdown> custom({
    Expression<int>? id,
    Expression<int>? habitId,
    Expression<DateTime>? date,
    Expression<String>? categoryKey,
    Expression<String>? label,
    Expression<int>? amount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (date != null) 'date': date,
      if (categoryKey != null) 'category_key': categoryKey,
      if (label != null) 'label': label,
      if (amount != null) 'amount': amount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HabitSpendingBreakdownsCompanion copyWith({
    Value<int>? id,
    Value<int>? habitId,
    Value<DateTime>? date,
    Value<String>? categoryKey,
    Value<String?>? label,
    Value<int>? amount,
    Value<DateTime>? createdAt,
  }) {
    return HabitSpendingBreakdownsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      categoryKey: categoryKey ?? this.categoryKey,
      label: label ?? this.label,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (categoryKey.present) {
      map['category_key'] = Variable<String>(categoryKey.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitSpendingBreakdownsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('label: $label, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitLogsTable habitLogs = $HabitLogsTable(this);
  late final $UserProfileTable userProfile = $UserProfileTable(this);
  late final $OnboardingResponsesTable onboardingResponses =
      $OnboardingResponsesTable(this);
  late final $HabitGroupLinksTable habitGroupLinks = $HabitGroupLinksTable(
    this,
  );
  late final $HabitSpendingBreakdownsTable habitSpendingBreakdowns =
      $HabitSpendingBreakdownsTable(this);
  late final Index idxHabitLogsDate = Index(
    'idx_habit_logs_date',
    'CREATE INDEX idx_habit_logs_date ON habit_logs (date)',
  );
  late final Index idxHabitLogsHabitId = Index(
    'idx_habit_logs_habit_id',
    'CREATE INDEX idx_habit_logs_habit_id ON habit_logs (habit_id)',
  );
  late final Index idxHabitGroupLinksHabitId = Index(
    'idx_habit_group_links_habit_id',
    'CREATE INDEX idx_habit_group_links_habit_id ON habit_group_links (habit_id)',
  );
  late final Index idxHabitSpendingBreakdownsHabitDate = Index(
    'idx_habit_spending_breakdowns_habit_date',
    'CREATE INDEX idx_habit_spending_breakdowns_habit_date ON habit_spending_breakdowns (habit_id, date)',
  );
  late final CategoryDao categoryDao = CategoryDao(this as AppDatabase);
  late final HabitDao habitDao = HabitDao(this as AppDatabase);
  late final HabitLogDao habitLogDao = HabitLogDao(this as AppDatabase);
  late final ProfileDao profileDao = ProfileDao(this as AppDatabase);
  late final HabitGroupLinkDao habitGroupLinkDao = HabitGroupLinkDao(
    this as AppDatabase,
  );
  late final HabitSpendingBreakdownDao habitSpendingBreakdownDao =
      HabitSpendingBreakdownDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    habits,
    habitLogs,
    userProfile,
    onboardingResponses,
    habitGroupLinks,
    habitSpendingBreakdowns,
    idxHabitLogsDate,
    idxHabitLogsHabitId,
    idxHabitGroupLinksHabitId,
    idxHabitSpendingBreakdownsHabitDate,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('habit_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('habit_group_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('habit_spending_breakdowns', kind: UpdateKind.delete),
      ],
    ),
  ]);
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> icon,
      Value<String?> colorHex,
      Value<bool> isDefault,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<String?> nameId,
      Value<String?> templateKey,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> icon,
      Value<String?> colorHex,
      Value<bool> isDefault,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<String?> nameId,
      Value<String?> templateKey,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HabitsTable, List<Habit>> _habitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.habits,
    aliasName: $_aliasNameGenerator(db.categories.id, db.habits.categoryId),
  );

  $$HabitsTableProcessedTableManager get habitsRefs {
    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameId => $composableBuilder(
    column: $table.nameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateKey => $composableBuilder(
    column: $table.templateKey,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> habitsRefs(
    Expression<bool> Function($$HabitsTableFilterComposer f) f,
  ) {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameId => $composableBuilder(
    column: $table.nameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateKey => $composableBuilder(
    column: $table.templateKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get nameId =>
      $composableBuilder(column: $table.nameId, builder: (column) => column);

  GeneratedColumn<String> get templateKey => $composableBuilder(
    column: $table.templateKey,
    builder: (column) => column,
  );

  Expression<T> habitsRefs<T extends Object>(
    Expression<T> Function($$HabitsTableAnnotationComposer a) f,
  ) {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool habitsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> nameId = const Value.absent(),
                Value<String?> templateKey = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                icon: icon,
                colorHex: colorHex,
                isDefault: isDefault,
                isArchived: isArchived,
                createdAt: createdAt,
                nameId: nameId,
                templateKey: templateKey,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> icon = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> nameId = const Value.absent(),
                Value<String?> templateKey = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                colorHex: colorHex,
                isDefault: isDefault,
                isArchived: isArchived,
                createdAt: createdAt,
                nameId: nameId,
                templateKey: templateKey,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (habitsRefs) db.habits],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (habitsRefs)
                    await $_getPrefetchedData<
                      Category,
                      $CategoriesTable,
                      Habit
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._habitsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(db, table, p0).habitsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool habitsRefs})
    >;
typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      required int categoryId,
      required String name,
      Value<String?> description,
      Value<String?> icon,
      required String goalPeriod,
      Value<int> goalValue,
      Value<int?> goalValueWeekend,
      Value<String> goalUnit,
      Value<String> goalDirection,
      required String taskDays,
      Value<String> timeRange,
      Value<bool> reminderEnabled,
      Value<String?> reminderTime,
      Value<int?> reminderIntervalMinutes,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<String?> nameId,
      Value<bool> isCustom,
      Value<String?> templateKey,
      Value<String?> currency,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      Value<int> categoryId,
      Value<String> name,
      Value<String?> description,
      Value<String?> icon,
      Value<String> goalPeriod,
      Value<int> goalValue,
      Value<int?> goalValueWeekend,
      Value<String> goalUnit,
      Value<String> goalDirection,
      Value<String> taskDays,
      Value<String> timeRange,
      Value<bool> reminderEnabled,
      Value<String?> reminderTime,
      Value<int?> reminderIntervalMinutes,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<String?> nameId,
      Value<bool> isCustom,
      Value<String?> templateKey,
      Value<String?> currency,
    });

final class $$HabitsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitsTable, Habit> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.habits.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$HabitLogsTable, List<HabitLog>>
  _habitLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.habitLogs,
    aliasName: $_aliasNameGenerator(db.habits.id, db.habitLogs.habitId),
  );

  $$HabitLogsTableProcessedTableManager get habitLogsRefs {
    final manager = $$HabitLogsTableTableManager(
      $_db,
      $_db.habitLogs,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HabitGroupLinksTable, List<HabitGroupLink>>
  _habitGroupLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.habitGroupLinks,
    aliasName: $_aliasNameGenerator(db.habits.id, db.habitGroupLinks.habitId),
  );

  $$HabitGroupLinksTableProcessedTableManager get habitGroupLinksRefs {
    final manager = $$HabitGroupLinksTableTableManager(
      $_db,
      $_db.habitGroupLinks,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _habitGroupLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $HabitSpendingBreakdownsTable,
    List<HabitSpendingBreakdown>
  >
  _habitSpendingBreakdownsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.habitSpendingBreakdowns,
        aliasName: $_aliasNameGenerator(
          db.habits.id,
          db.habitSpendingBreakdowns.habitId,
        ),
      );

  $$HabitSpendingBreakdownsTableProcessedTableManager
  get habitSpendingBreakdownsRefs {
    final manager = $$HabitSpendingBreakdownsTableTableManager(
      $_db,
      $_db.habitSpendingBreakdowns,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _habitSpendingBreakdownsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalPeriod => $composableBuilder(
    column: $table.goalPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goalValue => $composableBuilder(
    column: $table.goalValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goalValueWeekend => $composableBuilder(
    column: $table.goalValueWeekend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalUnit => $composableBuilder(
    column: $table.goalUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalDirection => $composableBuilder(
    column: $table.goalDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskDays => $composableBuilder(
    column: $table.taskDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeRange => $composableBuilder(
    column: $table.timeRange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderIntervalMinutes => $composableBuilder(
    column: $table.reminderIntervalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameId => $composableBuilder(
    column: $table.nameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateKey => $composableBuilder(
    column: $table.templateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> habitLogsRefs(
    Expression<bool> Function($$HabitLogsTableFilterComposer f) f,
  ) {
    final $$HabitLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogs,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableFilterComposer(
            $db: $db,
            $table: $db.habitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> habitGroupLinksRefs(
    Expression<bool> Function($$HabitGroupLinksTableFilterComposer f) f,
  ) {
    final $$HabitGroupLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitGroupLinks,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitGroupLinksTableFilterComposer(
            $db: $db,
            $table: $db.habitGroupLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> habitSpendingBreakdownsRefs(
    Expression<bool> Function($$HabitSpendingBreakdownsTableFilterComposer f) f,
  ) {
    final $$HabitSpendingBreakdownsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.habitSpendingBreakdowns,
          getReferencedColumn: (t) => t.habitId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HabitSpendingBreakdownsTableFilterComposer(
                $db: $db,
                $table: $db.habitSpendingBreakdowns,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalPeriod => $composableBuilder(
    column: $table.goalPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalValue => $composableBuilder(
    column: $table.goalValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalValueWeekend => $composableBuilder(
    column: $table.goalValueWeekend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalUnit => $composableBuilder(
    column: $table.goalUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalDirection => $composableBuilder(
    column: $table.goalDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskDays => $composableBuilder(
    column: $table.taskDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeRange => $composableBuilder(
    column: $table.timeRange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderIntervalMinutes => $composableBuilder(
    column: $table.reminderIntervalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameId => $composableBuilder(
    column: $table.nameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateKey => $composableBuilder(
    column: $table.templateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get goalPeriod => $composableBuilder(
    column: $table.goalPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get goalValue =>
      $composableBuilder(column: $table.goalValue, builder: (column) => column);

  GeneratedColumn<int> get goalValueWeekend => $composableBuilder(
    column: $table.goalValueWeekend,
    builder: (column) => column,
  );

  GeneratedColumn<String> get goalUnit =>
      $composableBuilder(column: $table.goalUnit, builder: (column) => column);

  GeneratedColumn<String> get goalDirection => $composableBuilder(
    column: $table.goalDirection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taskDays =>
      $composableBuilder(column: $table.taskDays, builder: (column) => column);

  GeneratedColumn<String> get timeRange =>
      $composableBuilder(column: $table.timeRange, builder: (column) => column);

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderIntervalMinutes => $composableBuilder(
    column: $table.reminderIntervalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get nameId =>
      $composableBuilder(column: $table.nameId, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<String> get templateKey => $composableBuilder(
    column: $table.templateKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> habitLogsRefs<T extends Object>(
    Expression<T> Function($$HabitLogsTableAnnotationComposer a) f,
  ) {
    final $$HabitLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogs,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.habitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> habitGroupLinksRefs<T extends Object>(
    Expression<T> Function($$HabitGroupLinksTableAnnotationComposer a) f,
  ) {
    final $$HabitGroupLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitGroupLinks,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitGroupLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.habitGroupLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> habitSpendingBreakdownsRefs<T extends Object>(
    Expression<T> Function($$HabitSpendingBreakdownsTableAnnotationComposer a)
    f,
  ) {
    final $$HabitSpendingBreakdownsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.habitSpendingBreakdowns,
          getReferencedColumn: (t) => t.habitId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HabitSpendingBreakdownsTableAnnotationComposer(
                $db: $db,
                $table: $db.habitSpendingBreakdowns,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, $$HabitsTableReferences),
          Habit,
          PrefetchHooks Function({
            bool categoryId,
            bool habitLogsRefs,
            bool habitGroupLinksRefs,
            bool habitSpendingBreakdownsRefs,
          })
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String> goalPeriod = const Value.absent(),
                Value<int> goalValue = const Value.absent(),
                Value<int?> goalValueWeekend = const Value.absent(),
                Value<String> goalUnit = const Value.absent(),
                Value<String> goalDirection = const Value.absent(),
                Value<String> taskDays = const Value.absent(),
                Value<String> timeRange = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                Value<int?> reminderIntervalMinutes = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> nameId = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<String?> templateKey = const Value.absent(),
                Value<String?> currency = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                categoryId: categoryId,
                name: name,
                description: description,
                icon: icon,
                goalPeriod: goalPeriod,
                goalValue: goalValue,
                goalValueWeekend: goalValueWeekend,
                goalUnit: goalUnit,
                goalDirection: goalDirection,
                taskDays: taskDays,
                timeRange: timeRange,
                reminderEnabled: reminderEnabled,
                reminderTime: reminderTime,
                reminderIntervalMinutes: reminderIntervalMinutes,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                sortOrder: sortOrder,
                createdAt: createdAt,
                nameId: nameId,
                isCustom: isCustom,
                templateKey: templateKey,
                currency: currency,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int categoryId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                required String goalPeriod,
                Value<int> goalValue = const Value.absent(),
                Value<int?> goalValueWeekend = const Value.absent(),
                Value<String> goalUnit = const Value.absent(),
                Value<String> goalDirection = const Value.absent(),
                required String taskDays,
                Value<String> timeRange = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                Value<int?> reminderIntervalMinutes = const Value.absent(),
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> nameId = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<String?> templateKey = const Value.absent(),
                Value<String?> currency = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                categoryId: categoryId,
                name: name,
                description: description,
                icon: icon,
                goalPeriod: goalPeriod,
                goalValue: goalValue,
                goalValueWeekend: goalValueWeekend,
                goalUnit: goalUnit,
                goalDirection: goalDirection,
                taskDays: taskDays,
                timeRange: timeRange,
                reminderEnabled: reminderEnabled,
                reminderTime: reminderTime,
                reminderIntervalMinutes: reminderIntervalMinutes,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                sortOrder: sortOrder,
                createdAt: createdAt,
                nameId: nameId,
                isCustom: isCustom,
                templateKey: templateKey,
                currency: currency,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$HabitsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                habitLogsRefs = false,
                habitGroupLinksRefs = false,
                habitSpendingBreakdownsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (habitLogsRefs) db.habitLogs,
                    if (habitGroupLinksRefs) db.habitGroupLinks,
                    if (habitSpendingBreakdownsRefs) db.habitSpendingBreakdowns,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$HabitsTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $$HabitsTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (habitLogsRefs)
                        await $_getPrefetchedData<
                          Habit,
                          $HabitsTable,
                          HabitLog
                        >(
                          currentTable: table,
                          referencedTable: $$HabitsTableReferences
                              ._habitLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HabitsTableReferences(
                                db,
                                table,
                                p0,
                              ).habitLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.habitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (habitGroupLinksRefs)
                        await $_getPrefetchedData<
                          Habit,
                          $HabitsTable,
                          HabitGroupLink
                        >(
                          currentTable: table,
                          referencedTable: $$HabitsTableReferences
                              ._habitGroupLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HabitsTableReferences(
                                db,
                                table,
                                p0,
                              ).habitGroupLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.habitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (habitSpendingBreakdownsRefs)
                        await $_getPrefetchedData<
                          Habit,
                          $HabitsTable,
                          HabitSpendingBreakdown
                        >(
                          currentTable: table,
                          referencedTable: $$HabitsTableReferences
                              ._habitSpendingBreakdownsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HabitsTableReferences(
                                db,
                                table,
                                p0,
                              ).habitSpendingBreakdownsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.habitId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, $$HabitsTableReferences),
      Habit,
      PrefetchHooks Function({
        bool categoryId,
        bool habitLogsRefs,
        bool habitGroupLinksRefs,
        bool habitSpendingBreakdownsRefs,
      })
    >;
typedef $$HabitLogsTableCreateCompanionBuilder =
    HabitLogsCompanion Function({
      Value<int> id,
      required int habitId,
      required DateTime date,
      Value<int> progressValue,
      Value<bool> isDone,
    });
typedef $$HabitLogsTableUpdateCompanionBuilder =
    HabitLogsCompanion Function({
      Value<int> id,
      Value<int> habitId,
      Value<DateTime> date,
      Value<int> progressValue,
      Value<bool> isDone,
    });

final class $$HabitLogsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitLogsTable, HabitLog> {
  $$HabitLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDatabase db) => db.habits.createAlias(
    $_aliasNameGenerator(db.habitLogs.habitId, db.habits.id),
  );

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<int>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitLogsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progressValue => $composableBuilder(
    column: $table.progressValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progressValue => $composableBuilder(
    column: $table.progressValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get progressValue => $composableBuilder(
    column: $table.progressValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitLogsTable,
          HabitLog,
          $$HabitLogsTableFilterComposer,
          $$HabitLogsTableOrderingComposer,
          $$HabitLogsTableAnnotationComposer,
          $$HabitLogsTableCreateCompanionBuilder,
          $$HabitLogsTableUpdateCompanionBuilder,
          (HabitLog, $$HabitLogsTableReferences),
          HabitLog,
          PrefetchHooks Function({bool habitId})
        > {
  $$HabitLogsTableTableManager(_$AppDatabase db, $HabitLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> habitId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> progressValue = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
              }) => HabitLogsCompanion(
                id: id,
                habitId: habitId,
                date: date,
                progressValue: progressValue,
                isDone: isDone,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int habitId,
                required DateTime date,
                Value<int> progressValue = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
              }) => HabitLogsCompanion.insert(
                id: id,
                habitId: habitId,
                date: date,
                progressValue: progressValue,
                isDone: isDone,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HabitLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable: $$HabitLogsTableReferences
                                    ._habitIdTable(db),
                                referencedColumn: $$HabitLogsTableReferences
                                    ._habitIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HabitLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitLogsTable,
      HabitLog,
      $$HabitLogsTableFilterComposer,
      $$HabitLogsTableOrderingComposer,
      $$HabitLogsTableAnnotationComposer,
      $$HabitLogsTableCreateCompanionBuilder,
      $$HabitLogsTableUpdateCompanionBuilder,
      (HabitLog, $$HabitLogsTableReferences),
      HabitLog,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$UserProfileTableCreateCompanionBuilder =
    UserProfileCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> age,
      Value<String?> photoPath,
      Value<String> themeKey,
      Value<DateTime> createdAt,
    });
typedef $$UserProfileTableUpdateCompanionBuilder =
    UserProfileCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> age,
      Value<String?> photoPath,
      Value<String> themeKey,
      Value<DateTime> createdAt,
    });

class $$UserProfileTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeKey => $composableBuilder(
    column: $table.themeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeKey => $composableBuilder(
    column: $table.themeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get themeKey =>
      $composableBuilder(column: $table.themeKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserProfileTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfileTable,
          UserProfileRow,
          $$UserProfileTableFilterComposer,
          $$UserProfileTableOrderingComposer,
          $$UserProfileTableAnnotationComposer,
          $$UserProfileTableCreateCompanionBuilder,
          $$UserProfileTableUpdateCompanionBuilder,
          (
            UserProfileRow,
            BaseReferences<_$AppDatabase, $UserProfileTable, UserProfileRow>,
          ),
          UserProfileRow,
          PrefetchHooks Function()
        > {
  $$UserProfileTableTableManager(_$AppDatabase db, $UserProfileTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String> themeKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserProfileCompanion(
                id: id,
                name: name,
                age: age,
                photoPath: photoPath,
                themeKey: themeKey,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> age = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String> themeKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserProfileCompanion.insert(
                id: id,
                name: name,
                age: age,
                photoPath: photoPath,
                themeKey: themeKey,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfileTable,
      UserProfileRow,
      $$UserProfileTableFilterComposer,
      $$UserProfileTableOrderingComposer,
      $$UserProfileTableAnnotationComposer,
      $$UserProfileTableCreateCompanionBuilder,
      $$UserProfileTableUpdateCompanionBuilder,
      (
        UserProfileRow,
        BaseReferences<_$AppDatabase, $UserProfileTable, UserProfileRow>,
      ),
      UserProfileRow,
      PrefetchHooks Function()
    >;
typedef $$OnboardingResponsesTableCreateCompanionBuilder =
    OnboardingResponsesCompanion Function({
      Value<int> id,
      required String questionKey,
      required String answerValue,
      Value<DateTime> createdAt,
    });
typedef $$OnboardingResponsesTableUpdateCompanionBuilder =
    OnboardingResponsesCompanion Function({
      Value<int> id,
      Value<String> questionKey,
      Value<String> answerValue,
      Value<DateTime> createdAt,
    });

class $$OnboardingResponsesTableFilterComposer
    extends Composer<_$AppDatabase, $OnboardingResponsesTable> {
  $$OnboardingResponsesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionKey => $composableBuilder(
    column: $table.questionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answerValue => $composableBuilder(
    column: $table.answerValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OnboardingResponsesTableOrderingComposer
    extends Composer<_$AppDatabase, $OnboardingResponsesTable> {
  $$OnboardingResponsesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionKey => $composableBuilder(
    column: $table.questionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answerValue => $composableBuilder(
    column: $table.answerValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OnboardingResponsesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OnboardingResponsesTable> {
  $$OnboardingResponsesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionKey => $composableBuilder(
    column: $table.questionKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get answerValue => $composableBuilder(
    column: $table.answerValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OnboardingResponsesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OnboardingResponsesTable,
          OnboardingResponse,
          $$OnboardingResponsesTableFilterComposer,
          $$OnboardingResponsesTableOrderingComposer,
          $$OnboardingResponsesTableAnnotationComposer,
          $$OnboardingResponsesTableCreateCompanionBuilder,
          $$OnboardingResponsesTableUpdateCompanionBuilder,
          (
            OnboardingResponse,
            BaseReferences<
              _$AppDatabase,
              $OnboardingResponsesTable,
              OnboardingResponse
            >,
          ),
          OnboardingResponse,
          PrefetchHooks Function()
        > {
  $$OnboardingResponsesTableTableManager(
    _$AppDatabase db,
    $OnboardingResponsesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OnboardingResponsesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OnboardingResponsesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$OnboardingResponsesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> questionKey = const Value.absent(),
                Value<String> answerValue = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OnboardingResponsesCompanion(
                id: id,
                questionKey: questionKey,
                answerValue: answerValue,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String questionKey,
                required String answerValue,
                Value<DateTime> createdAt = const Value.absent(),
              }) => OnboardingResponsesCompanion.insert(
                id: id,
                questionKey: questionKey,
                answerValue: answerValue,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OnboardingResponsesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OnboardingResponsesTable,
      OnboardingResponse,
      $$OnboardingResponsesTableFilterComposer,
      $$OnboardingResponsesTableOrderingComposer,
      $$OnboardingResponsesTableAnnotationComposer,
      $$OnboardingResponsesTableCreateCompanionBuilder,
      $$OnboardingResponsesTableUpdateCompanionBuilder,
      (
        OnboardingResponse,
        BaseReferences<
          _$AppDatabase,
          $OnboardingResponsesTable,
          OnboardingResponse
        >,
      ),
      OnboardingResponse,
      PrefetchHooks Function()
    >;
typedef $$HabitGroupLinksTableCreateCompanionBuilder =
    HabitGroupLinksCompanion Function({
      Value<int> id,
      required int habitId,
      required String groupId,
      required String groupHabitId,
      Value<DateTime> linkedAt,
      Value<DateTime?> lastSyncedAt,
      Value<String?> uid,
    });
typedef $$HabitGroupLinksTableUpdateCompanionBuilder =
    HabitGroupLinksCompanion Function({
      Value<int> id,
      Value<int> habitId,
      Value<String> groupId,
      Value<String> groupHabitId,
      Value<DateTime> linkedAt,
      Value<DateTime?> lastSyncedAt,
      Value<String?> uid,
    });

final class $$HabitGroupLinksTableReferences
    extends
        BaseReferences<_$AppDatabase, $HabitGroupLinksTable, HabitGroupLink> {
  $$HabitGroupLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HabitsTable _habitIdTable(_$AppDatabase db) => db.habits.createAlias(
    $_aliasNameGenerator(db.habitGroupLinks.habitId, db.habits.id),
  );

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<int>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitGroupLinksTableFilterComposer
    extends Composer<_$AppDatabase, $HabitGroupLinksTable> {
  $$HabitGroupLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupHabitId => $composableBuilder(
    column: $table.groupHabitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get linkedAt => $composableBuilder(
    column: $table.linkedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitGroupLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitGroupLinksTable> {
  $$HabitGroupLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupHabitId => $composableBuilder(
    column: $table.groupHabitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get linkedAt => $composableBuilder(
    column: $table.linkedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitGroupLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitGroupLinksTable> {
  $$HabitGroupLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get groupHabitId => $composableBuilder(
    column: $table.groupHabitId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get linkedAt =>
      $composableBuilder(column: $table.linkedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitGroupLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitGroupLinksTable,
          HabitGroupLink,
          $$HabitGroupLinksTableFilterComposer,
          $$HabitGroupLinksTableOrderingComposer,
          $$HabitGroupLinksTableAnnotationComposer,
          $$HabitGroupLinksTableCreateCompanionBuilder,
          $$HabitGroupLinksTableUpdateCompanionBuilder,
          (HabitGroupLink, $$HabitGroupLinksTableReferences),
          HabitGroupLink,
          PrefetchHooks Function({bool habitId})
        > {
  $$HabitGroupLinksTableTableManager(
    _$AppDatabase db,
    $HabitGroupLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitGroupLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitGroupLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitGroupLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> habitId = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> groupHabitId = const Value.absent(),
                Value<DateTime> linkedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> uid = const Value.absent(),
              }) => HabitGroupLinksCompanion(
                id: id,
                habitId: habitId,
                groupId: groupId,
                groupHabitId: groupHabitId,
                linkedAt: linkedAt,
                lastSyncedAt: lastSyncedAt,
                uid: uid,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int habitId,
                required String groupId,
                required String groupHabitId,
                Value<DateTime> linkedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> uid = const Value.absent(),
              }) => HabitGroupLinksCompanion.insert(
                id: id,
                habitId: habitId,
                groupId: groupId,
                groupHabitId: groupHabitId,
                linkedAt: linkedAt,
                lastSyncedAt: lastSyncedAt,
                uid: uid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HabitGroupLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable:
                                    $$HabitGroupLinksTableReferences
                                        ._habitIdTable(db),
                                referencedColumn:
                                    $$HabitGroupLinksTableReferences
                                        ._habitIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HabitGroupLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitGroupLinksTable,
      HabitGroupLink,
      $$HabitGroupLinksTableFilterComposer,
      $$HabitGroupLinksTableOrderingComposer,
      $$HabitGroupLinksTableAnnotationComposer,
      $$HabitGroupLinksTableCreateCompanionBuilder,
      $$HabitGroupLinksTableUpdateCompanionBuilder,
      (HabitGroupLink, $$HabitGroupLinksTableReferences),
      HabitGroupLink,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$HabitSpendingBreakdownsTableCreateCompanionBuilder =
    HabitSpendingBreakdownsCompanion Function({
      Value<int> id,
      required int habitId,
      required DateTime date,
      required String categoryKey,
      Value<String?> label,
      required int amount,
      Value<DateTime> createdAt,
    });
typedef $$HabitSpendingBreakdownsTableUpdateCompanionBuilder =
    HabitSpendingBreakdownsCompanion Function({
      Value<int> id,
      Value<int> habitId,
      Value<DateTime> date,
      Value<String> categoryKey,
      Value<String?> label,
      Value<int> amount,
      Value<DateTime> createdAt,
    });

final class $$HabitSpendingBreakdownsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $HabitSpendingBreakdownsTable,
          HabitSpendingBreakdown
        > {
  $$HabitSpendingBreakdownsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HabitsTable _habitIdTable(_$AppDatabase db) => db.habits.createAlias(
    $_aliasNameGenerator(db.habitSpendingBreakdowns.habitId, db.habits.id),
  );

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<int>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitSpendingBreakdownsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitSpendingBreakdownsTable> {
  $$HabitSpendingBreakdownsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitSpendingBreakdownsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitSpendingBreakdownsTable> {
  $$HabitSpendingBreakdownsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitSpendingBreakdownsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitSpendingBreakdownsTable> {
  $$HabitSpendingBreakdownsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitSpendingBreakdownsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitSpendingBreakdownsTable,
          HabitSpendingBreakdown,
          $$HabitSpendingBreakdownsTableFilterComposer,
          $$HabitSpendingBreakdownsTableOrderingComposer,
          $$HabitSpendingBreakdownsTableAnnotationComposer,
          $$HabitSpendingBreakdownsTableCreateCompanionBuilder,
          $$HabitSpendingBreakdownsTableUpdateCompanionBuilder,
          (HabitSpendingBreakdown, $$HabitSpendingBreakdownsTableReferences),
          HabitSpendingBreakdown,
          PrefetchHooks Function({bool habitId})
        > {
  $$HabitSpendingBreakdownsTableTableManager(
    _$AppDatabase db,
    $HabitSpendingBreakdownsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitSpendingBreakdownsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$HabitSpendingBreakdownsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HabitSpendingBreakdownsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> habitId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> categoryKey = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HabitSpendingBreakdownsCompanion(
                id: id,
                habitId: habitId,
                date: date,
                categoryKey: categoryKey,
                label: label,
                amount: amount,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int habitId,
                required DateTime date,
                required String categoryKey,
                Value<String?> label = const Value.absent(),
                required int amount,
                Value<DateTime> createdAt = const Value.absent(),
              }) => HabitSpendingBreakdownsCompanion.insert(
                id: id,
                habitId: habitId,
                date: date,
                categoryKey: categoryKey,
                label: label,
                amount: amount,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HabitSpendingBreakdownsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable:
                                    $$HabitSpendingBreakdownsTableReferences
                                        ._habitIdTable(db),
                                referencedColumn:
                                    $$HabitSpendingBreakdownsTableReferences
                                        ._habitIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HabitSpendingBreakdownsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitSpendingBreakdownsTable,
      HabitSpendingBreakdown,
      $$HabitSpendingBreakdownsTableFilterComposer,
      $$HabitSpendingBreakdownsTableOrderingComposer,
      $$HabitSpendingBreakdownsTableAnnotationComposer,
      $$HabitSpendingBreakdownsTableCreateCompanionBuilder,
      $$HabitSpendingBreakdownsTableUpdateCompanionBuilder,
      (HabitSpendingBreakdown, $$HabitSpendingBreakdownsTableReferences),
      HabitSpendingBreakdown,
      PrefetchHooks Function({bool habitId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitLogsTableTableManager get habitLogs =>
      $$HabitLogsTableTableManager(_db, _db.habitLogs);
  $$UserProfileTableTableManager get userProfile =>
      $$UserProfileTableTableManager(_db, _db.userProfile);
  $$OnboardingResponsesTableTableManager get onboardingResponses =>
      $$OnboardingResponsesTableTableManager(_db, _db.onboardingResponses);
  $$HabitGroupLinksTableTableManager get habitGroupLinks =>
      $$HabitGroupLinksTableTableManager(_db, _db.habitGroupLinks);
  $$HabitSpendingBreakdownsTableTableManager get habitSpendingBreakdowns =>
      $$HabitSpendingBreakdownsTableTableManager(
        _db,
        _db.habitSpendingBreakdowns,
      );
}
