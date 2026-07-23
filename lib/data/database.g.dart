// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MuscleGroupsTable extends MuscleGroups
    with TableInfo<$MuscleGroupsTable, MuscleGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MuscleGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sortOrder',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'MuscleGroups';
  @override
  VerificationContext validateIntegrity(
    Insertable<MuscleGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sortOrder')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sortOrder']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MuscleGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MuscleGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sortOrder'],
      )!,
    );
  }

  @override
  $MuscleGroupsTable createAlias(String alias) {
    return $MuscleGroupsTable(attachedDatabase, alias);
  }
}

class MuscleGroup extends DataClass implements Insertable<MuscleGroup> {
  final String id;
  final int sortOrder;
  const MuscleGroup({required this.id, required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sortOrder'] = Variable<int>(sortOrder);
    return map;
  }

  MuscleGroupsCompanion toCompanion(bool nullToAbsent) {
    return MuscleGroupsCompanion(id: Value(id), sortOrder: Value(sortOrder));
  }

  factory MuscleGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MuscleGroup(
      id: serializer.fromJson<String>(json['id']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  MuscleGroup copyWith({String? id, int? sortOrder}) =>
      MuscleGroup(id: id ?? this.id, sortOrder: sortOrder ?? this.sortOrder);
  MuscleGroup copyWithCompanion(MuscleGroupsCompanion data) {
    return MuscleGroup(
      id: data.id.present ? data.id.value : this.id,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MuscleGroup(')
          ..write('id: $id, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MuscleGroup &&
          other.id == this.id &&
          other.sortOrder == this.sortOrder);
}

class MuscleGroupsCompanion extends UpdateCompanion<MuscleGroup> {
  final Value<String> id;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const MuscleGroupsCompanion({
    this.id = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MuscleGroupsCompanion.insert({
    required String id,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sortOrder = Value(sortOrder);
  static Insertable<MuscleGroup> custom({
    Expression<String>? id,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MuscleGroupsCompanion copyWith({
    Value<String>? id,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return MuscleGroupsCompanion(
      id: id ?? this.id,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sortOrder.present) {
      map['sortOrder'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MuscleGroupsCompanion(')
          ..write('id: $id, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EquipmentsTable extends Equipments
    with TableInfo<$EquipmentsTable, Equipment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EquipmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sortOrder',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Equipments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Equipment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sortOrder')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sortOrder']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Equipment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Equipment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sortOrder'],
      )!,
    );
  }

  @override
  $EquipmentsTable createAlias(String alias) {
    return $EquipmentsTable(attachedDatabase, alias);
  }
}

class Equipment extends DataClass implements Insertable<Equipment> {
  final String id;
  final int sortOrder;
  const Equipment({required this.id, required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sortOrder'] = Variable<int>(sortOrder);
    return map;
  }

  EquipmentsCompanion toCompanion(bool nullToAbsent) {
    return EquipmentsCompanion(id: Value(id), sortOrder: Value(sortOrder));
  }

  factory Equipment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Equipment(
      id: serializer.fromJson<String>(json['id']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Equipment copyWith({String? id, int? sortOrder}) =>
      Equipment(id: id ?? this.id, sortOrder: sortOrder ?? this.sortOrder);
  Equipment copyWithCompanion(EquipmentsCompanion data) {
    return Equipment(
      id: data.id.present ? data.id.value : this.id,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Equipment(')
          ..write('id: $id, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Equipment &&
          other.id == this.id &&
          other.sortOrder == this.sortOrder);
}

class EquipmentsCompanion extends UpdateCompanion<Equipment> {
  final Value<String> id;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const EquipmentsCompanion({
    this.id = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EquipmentsCompanion.insert({
    required String id,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sortOrder = Value(sortOrder);
  static Insertable<Equipment> custom({
    Expression<String>? id,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EquipmentsCompanion copyWith({
    Value<String>? id,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return EquipmentsCompanion(
      id: id ?? this.id,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sortOrder.present) {
      map['sortOrder'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EquipmentsCompanion(')
          ..write('id: $id, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasurementTypesTable extends MeasurementTypes
    with TableInfo<$MeasurementTypesTable, MeasurementType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameCustomMeta = const VerificationMeta(
    'nameCustom',
  );
  @override
  late final GeneratedColumn<String> nameCustom = GeneratedColumn<String>(
    'nameCustom',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitKindMeta = const VerificationMeta(
    'unitKind',
  );
  @override
  late final GeneratedColumn<String> unitKind = GeneratedColumn<String>(
    'unitKind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (unitKind IN (\'mass\', \'percent\', \'length\'))',
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'isBuiltIn',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isBuiltIn" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'isArchived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isArchived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sortOrder',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nameCustom,
    unitKind,
    isBuiltIn,
    isArchived,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'MeasurementTypes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nameCustom')) {
      context.handle(
        _nameCustomMeta,
        nameCustom.isAcceptableOrUnknown(data['nameCustom']!, _nameCustomMeta),
      );
    }
    if (data.containsKey('unitKind')) {
      context.handle(
        _unitKindMeta,
        unitKind.isAcceptableOrUnknown(data['unitKind']!, _unitKindMeta),
      );
    } else if (isInserting) {
      context.missing(_unitKindMeta);
    }
    if (data.containsKey('isBuiltIn')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['isBuiltIn']!, _isBuiltInMeta),
      );
    } else if (isInserting) {
      context.missing(_isBuiltInMeta);
    }
    if (data.containsKey('isArchived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['isArchived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('sortOrder')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sortOrder']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeasurementType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nameCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nameCustom'],
      ),
      unitKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unitKind'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isBuiltIn'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isArchived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sortOrder'],
      )!,
    );
  }

  @override
  $MeasurementTypesTable createAlias(String alias) {
    return $MeasurementTypesTable(attachedDatabase, alias);
  }
}

class MeasurementType extends DataClass implements Insertable<MeasurementType> {
  final String id;
  final String? nameCustom;
  final String unitKind;
  final bool isBuiltIn;
  final bool isArchived;
  final int sortOrder;
  const MeasurementType({
    required this.id,
    this.nameCustom,
    required this.unitKind,
    required this.isBuiltIn,
    required this.isArchived,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || nameCustom != null) {
      map['nameCustom'] = Variable<String>(nameCustom);
    }
    map['unitKind'] = Variable<String>(unitKind);
    map['isBuiltIn'] = Variable<bool>(isBuiltIn);
    map['isArchived'] = Variable<bool>(isArchived);
    map['sortOrder'] = Variable<int>(sortOrder);
    return map;
  }

  MeasurementTypesCompanion toCompanion(bool nullToAbsent) {
    return MeasurementTypesCompanion(
      id: Value(id),
      nameCustom: nameCustom == null && nullToAbsent
          ? const Value.absent()
          : Value(nameCustom),
      unitKind: Value(unitKind),
      isBuiltIn: Value(isBuiltIn),
      isArchived: Value(isArchived),
      sortOrder: Value(sortOrder),
    );
  }

  factory MeasurementType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementType(
      id: serializer.fromJson<String>(json['id']),
      nameCustom: serializer.fromJson<String?>(json['nameCustom']),
      unitKind: serializer.fromJson<String>(json['unitKind']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nameCustom': serializer.toJson<String?>(nameCustom),
      'unitKind': serializer.toJson<String>(unitKind),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'isArchived': serializer.toJson<bool>(isArchived),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  MeasurementType copyWith({
    String? id,
    Value<String?> nameCustom = const Value.absent(),
    String? unitKind,
    bool? isBuiltIn,
    bool? isArchived,
    int? sortOrder,
  }) => MeasurementType(
    id: id ?? this.id,
    nameCustom: nameCustom.present ? nameCustom.value : this.nameCustom,
    unitKind: unitKind ?? this.unitKind,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    isArchived: isArchived ?? this.isArchived,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  MeasurementType copyWithCompanion(MeasurementTypesCompanion data) {
    return MeasurementType(
      id: data.id.present ? data.id.value : this.id,
      nameCustom: data.nameCustom.present
          ? data.nameCustom.value
          : this.nameCustom,
      unitKind: data.unitKind.present ? data.unitKind.value : this.unitKind,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementType(')
          ..write('id: $id, ')
          ..write('nameCustom: $nameCustom, ')
          ..write('unitKind: $unitKind, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('isArchived: $isArchived, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nameCustom, unitKind, isBuiltIn, isArchived, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementType &&
          other.id == this.id &&
          other.nameCustom == this.nameCustom &&
          other.unitKind == this.unitKind &&
          other.isBuiltIn == this.isBuiltIn &&
          other.isArchived == this.isArchived &&
          other.sortOrder == this.sortOrder);
}

class MeasurementTypesCompanion extends UpdateCompanion<MeasurementType> {
  final Value<String> id;
  final Value<String?> nameCustom;
  final Value<String> unitKind;
  final Value<bool> isBuiltIn;
  final Value<bool> isArchived;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const MeasurementTypesCompanion({
    this.id = const Value.absent(),
    this.nameCustom = const Value.absent(),
    this.unitKind = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementTypesCompanion.insert({
    required String id,
    this.nameCustom = const Value.absent(),
    required String unitKind,
    required bool isBuiltIn,
    this.isArchived = const Value.absent(),
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       unitKind = Value(unitKind),
       isBuiltIn = Value(isBuiltIn),
       sortOrder = Value(sortOrder);
  static Insertable<MeasurementType> custom({
    Expression<String>? id,
    Expression<String>? nameCustom,
    Expression<String>? unitKind,
    Expression<bool>? isBuiltIn,
    Expression<bool>? isArchived,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameCustom != null) 'nameCustom': nameCustom,
      if (unitKind != null) 'unitKind': unitKind,
      if (isBuiltIn != null) 'isBuiltIn': isBuiltIn,
      if (isArchived != null) 'isArchived': isArchived,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementTypesCompanion copyWith({
    Value<String>? id,
    Value<String?>? nameCustom,
    Value<String>? unitKind,
    Value<bool>? isBuiltIn,
    Value<bool>? isArchived,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return MeasurementTypesCompanion(
      id: id ?? this.id,
      nameCustom: nameCustom ?? this.nameCustom,
      unitKind: unitKind ?? this.unitKind,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nameCustom.present) {
      map['nameCustom'] = Variable<String>(nameCustom.value);
    }
    if (unitKind.present) {
      map['unitKind'] = Variable<String>(unitKind.value);
    }
    if (isBuiltIn.present) {
      map['isBuiltIn'] = Variable<bool>(isBuiltIn.value);
    }
    if (isArchived.present) {
      map['isArchived'] = Variable<bool>(isArchived.value);
    }
    if (sortOrder.present) {
      map['sortOrder'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementTypesCompanion(')
          ..write('id: $id, ')
          ..write('nameCustom: $nameCustom, ')
          ..write('unitKind: $unitKind, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('isArchived: $isArchived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'createdAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updatedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'isDeleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isDeleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _youtubeUrlMeta = const VerificationMeta(
    'youtubeUrl',
  );
  @override
  late final GeneratedColumn<String> youtubeUrl = GeneratedColumn<String>(
    'youtubeUrl',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageAssetMeta = const VerificationMeta(
    'imageAsset',
  );
  @override
  late final GeneratedColumn<String> imageAsset = GeneratedColumn<String>(
    'imageAsset',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exerciseTypeMeta = const VerificationMeta(
    'exerciseType',
  );
  @override
  late final GeneratedColumn<String> exerciseType = GeneratedColumn<String>(
    'exerciseType',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (exerciseType IN (\'strength\', \'cardio\', \'reps\', \'time\', \'stretch\'))',
  );
  static const VerificationMeta _primaryMuscleGroupIdMeta =
      const VerificationMeta('primaryMuscleGroupId');
  @override
  late final GeneratedColumn<String> primaryMuscleGroupId =
      GeneratedColumn<String>(
        'primaryMuscleGroupId',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES MuscleGroups (id)',
        ),
      );
  static const VerificationMeta _equipmentIdMeta = const VerificationMeta(
    'equipmentId',
  );
  @override
  late final GeneratedColumn<String> equipmentId = GeneratedColumn<String>(
    'equipmentId',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES Equipments (id)',
    ),
  );
  static const VerificationMeta _effortMetricMeta = const VerificationMeta(
    'effortMetric',
  );
  @override
  late final GeneratedColumn<String> effortMetric = GeneratedColumn<String>(
    'effortMetric',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'none\' CHECK (effortMetric IN (\'none\', \'rpe\', \'rir\'))',
    defaultValue: const CustomExpression('\'none\''),
  );
  static const VerificationMeta _statsMetricsJsonMeta = const VerificationMeta(
    'statsMetricsJson',
  );
  @override
  late final GeneratedColumn<String> statsMetricsJson = GeneratedColumn<String>(
    'statsMetricsJson',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'isBuiltIn',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isBuiltIn" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'isArchived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isArchived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    isDeleted,
    id,
    name,
    description,
    youtubeUrl,
    imageAsset,
    exerciseType,
    primaryMuscleGroupId,
    equipmentId,
    effortMetric,
    statsMetricsJson,
    isBuiltIn,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('createdAt')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['createdAt']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updatedAt')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updatedAt']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('isDeleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['isDeleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('youtubeUrl')) {
      context.handle(
        _youtubeUrlMeta,
        youtubeUrl.isAcceptableOrUnknown(data['youtubeUrl']!, _youtubeUrlMeta),
      );
    }
    if (data.containsKey('imageAsset')) {
      context.handle(
        _imageAssetMeta,
        imageAsset.isAcceptableOrUnknown(data['imageAsset']!, _imageAssetMeta),
      );
    }
    if (data.containsKey('exerciseType')) {
      context.handle(
        _exerciseTypeMeta,
        exerciseType.isAcceptableOrUnknown(
          data['exerciseType']!,
          _exerciseTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseTypeMeta);
    }
    if (data.containsKey('primaryMuscleGroupId')) {
      context.handle(
        _primaryMuscleGroupIdMeta,
        primaryMuscleGroupId.isAcceptableOrUnknown(
          data['primaryMuscleGroupId']!,
          _primaryMuscleGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('equipmentId')) {
      context.handle(
        _equipmentIdMeta,
        equipmentId.isAcceptableOrUnknown(
          data['equipmentId']!,
          _equipmentIdMeta,
        ),
      );
    }
    if (data.containsKey('effortMetric')) {
      context.handle(
        _effortMetricMeta,
        effortMetric.isAcceptableOrUnknown(
          data['effortMetric']!,
          _effortMetricMeta,
        ),
      );
    }
    if (data.containsKey('statsMetricsJson')) {
      context.handle(
        _statsMetricsJsonMeta,
        statsMetricsJson.isAcceptableOrUnknown(
          data['statsMetricsJson']!,
          _statsMetricsJsonMeta,
        ),
      );
    }
    if (data.containsKey('isBuiltIn')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['isBuiltIn']!, _isBuiltInMeta),
      );
    }
    if (data.containsKey('isArchived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['isArchived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}createdAt'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updatedAt'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isDeleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      youtubeUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}youtubeUrl'],
      ),
      imageAsset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imageAsset'],
      ),
      exerciseType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exerciseType'],
      )!,
      primaryMuscleGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primaryMuscleGroupId'],
      ),
      equipmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipmentId'],
      ),
      effortMetric: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effortMetric'],
      )!,
      statsMetricsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statsMetricsJson'],
      ),
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isBuiltIn'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isArchived'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  final String id;

  /// 1-80 chars after trim, validated in the service layer. For built-in
  /// exercises this is the canonical English name (used in CSV/search).
  final String name;
  final String? description;
  final String? youtubeUrl;

  /// Asset path; only ever populated for built-in exercises (D-3).
  final String? imageAsset;
  final String exerciseType;
  final String? primaryMuscleGroupId;
  final String? equipmentId;
  final String effortMetric;

  /// Reserved for a future exercise-type constructor (D-14); unused in MVP.
  final String? statsMetricsJson;
  final bool isBuiltIn;
  final bool isArchived;
  const Exercise({
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.id,
    required this.name,
    this.description,
    this.youtubeUrl,
    this.imageAsset,
    required this.exerciseType,
    this.primaryMuscleGroupId,
    this.equipmentId,
    required this.effortMetric,
    this.statsMetricsJson,
    required this.isBuiltIn,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['createdAt'] = Variable<String>(createdAt);
    map['updatedAt'] = Variable<String>(updatedAt);
    map['isDeleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || youtubeUrl != null) {
      map['youtubeUrl'] = Variable<String>(youtubeUrl);
    }
    if (!nullToAbsent || imageAsset != null) {
      map['imageAsset'] = Variable<String>(imageAsset);
    }
    map['exerciseType'] = Variable<String>(exerciseType);
    if (!nullToAbsent || primaryMuscleGroupId != null) {
      map['primaryMuscleGroupId'] = Variable<String>(primaryMuscleGroupId);
    }
    if (!nullToAbsent || equipmentId != null) {
      map['equipmentId'] = Variable<String>(equipmentId);
    }
    map['effortMetric'] = Variable<String>(effortMetric);
    if (!nullToAbsent || statsMetricsJson != null) {
      map['statsMetricsJson'] = Variable<String>(statsMetricsJson);
    }
    map['isBuiltIn'] = Variable<bool>(isBuiltIn);
    map['isArchived'] = Variable<bool>(isArchived);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      youtubeUrl: youtubeUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(youtubeUrl),
      imageAsset: imageAsset == null && nullToAbsent
          ? const Value.absent()
          : Value(imageAsset),
      exerciseType: Value(exerciseType),
      primaryMuscleGroupId: primaryMuscleGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryMuscleGroupId),
      equipmentId: equipmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(equipmentId),
      effortMetric: Value(effortMetric),
      statsMetricsJson: statsMetricsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(statsMetricsJson),
      isBuiltIn: Value(isBuiltIn),
      isArchived: Value(isArchived),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      youtubeUrl: serializer.fromJson<String?>(json['youtubeUrl']),
      imageAsset: serializer.fromJson<String?>(json['imageAsset']),
      exerciseType: serializer.fromJson<String>(json['exerciseType']),
      primaryMuscleGroupId: serializer.fromJson<String?>(
        json['primaryMuscleGroupId'],
      ),
      equipmentId: serializer.fromJson<String?>(json['equipmentId']),
      effortMetric: serializer.fromJson<String>(json['effortMetric']),
      statsMetricsJson: serializer.fromJson<String?>(json['statsMetricsJson']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'youtubeUrl': serializer.toJson<String?>(youtubeUrl),
      'imageAsset': serializer.toJson<String?>(imageAsset),
      'exerciseType': serializer.toJson<String>(exerciseType),
      'primaryMuscleGroupId': serializer.toJson<String?>(primaryMuscleGroupId),
      'equipmentId': serializer.toJson<String?>(equipmentId),
      'effortMetric': serializer.toJson<String>(effortMetric),
      'statsMetricsJson': serializer.toJson<String?>(statsMetricsJson),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  Exercise copyWith({
    String? createdAt,
    String? updatedAt,
    bool? isDeleted,
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> youtubeUrl = const Value.absent(),
    Value<String?> imageAsset = const Value.absent(),
    String? exerciseType,
    Value<String?> primaryMuscleGroupId = const Value.absent(),
    Value<String?> equipmentId = const Value.absent(),
    String? effortMetric,
    Value<String?> statsMetricsJson = const Value.absent(),
    bool? isBuiltIn,
    bool? isArchived,
  }) => Exercise(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    youtubeUrl: youtubeUrl.present ? youtubeUrl.value : this.youtubeUrl,
    imageAsset: imageAsset.present ? imageAsset.value : this.imageAsset,
    exerciseType: exerciseType ?? this.exerciseType,
    primaryMuscleGroupId: primaryMuscleGroupId.present
        ? primaryMuscleGroupId.value
        : this.primaryMuscleGroupId,
    equipmentId: equipmentId.present ? equipmentId.value : this.equipmentId,
    effortMetric: effortMetric ?? this.effortMetric,
    statsMetricsJson: statsMetricsJson.present
        ? statsMetricsJson.value
        : this.statsMetricsJson,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    isArchived: isArchived ?? this.isArchived,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      youtubeUrl: data.youtubeUrl.present
          ? data.youtubeUrl.value
          : this.youtubeUrl,
      imageAsset: data.imageAsset.present
          ? data.imageAsset.value
          : this.imageAsset,
      exerciseType: data.exerciseType.present
          ? data.exerciseType.value
          : this.exerciseType,
      primaryMuscleGroupId: data.primaryMuscleGroupId.present
          ? data.primaryMuscleGroupId.value
          : this.primaryMuscleGroupId,
      equipmentId: data.equipmentId.present
          ? data.equipmentId.value
          : this.equipmentId,
      effortMetric: data.effortMetric.present
          ? data.effortMetric.value
          : this.effortMetric,
      statsMetricsJson: data.statsMetricsJson.present
          ? data.statsMetricsJson.value
          : this.statsMetricsJson,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('youtubeUrl: $youtubeUrl, ')
          ..write('imageAsset: $imageAsset, ')
          ..write('exerciseType: $exerciseType, ')
          ..write('primaryMuscleGroupId: $primaryMuscleGroupId, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('effortMetric: $effortMetric, ')
          ..write('statsMetricsJson: $statsMetricsJson, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    isDeleted,
    id,
    name,
    description,
    youtubeUrl,
    imageAsset,
    exerciseType,
    primaryMuscleGroupId,
    equipmentId,
    effortMetric,
    statsMetricsJson,
    isBuiltIn,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.youtubeUrl == this.youtubeUrl &&
          other.imageAsset == this.imageAsset &&
          other.exerciseType == this.exerciseType &&
          other.primaryMuscleGroupId == this.primaryMuscleGroupId &&
          other.equipmentId == this.equipmentId &&
          other.effortMetric == this.effortMetric &&
          other.statsMetricsJson == this.statsMetricsJson &&
          other.isBuiltIn == this.isBuiltIn &&
          other.isArchived == this.isArchived);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> youtubeUrl;
  final Value<String?> imageAsset;
  final Value<String> exerciseType;
  final Value<String?> primaryMuscleGroupId;
  final Value<String?> equipmentId;
  final Value<String> effortMetric;
  final Value<String?> statsMetricsJson;
  final Value<bool> isBuiltIn;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.youtubeUrl = const Value.absent(),
    this.imageAsset = const Value.absent(),
    this.exerciseType = const Value.absent(),
    this.primaryMuscleGroupId = const Value.absent(),
    this.equipmentId = const Value.absent(),
    this.effortMetric = const Value.absent(),
    this.statsMetricsJson = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.isDeleted = const Value.absent(),
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.youtubeUrl = const Value.absent(),
    this.imageAsset = const Value.absent(),
    required String exerciseType,
    this.primaryMuscleGroupId = const Value.absent(),
    this.equipmentId = const Value.absent(),
    this.effortMetric = const Value.absent(),
    this.statsMetricsJson = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name),
       exerciseType = Value(exerciseType);
  static Insertable<Exercise> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? youtubeUrl,
    Expression<String>? imageAsset,
    Expression<String>? exerciseType,
    Expression<String>? primaryMuscleGroupId,
    Expression<String>? equipmentId,
    Expression<String>? effortMetric,
    Expression<String>? statsMetricsJson,
    Expression<bool>? isBuiltIn,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (isDeleted != null) 'isDeleted': isDeleted,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (youtubeUrl != null) 'youtubeUrl': youtubeUrl,
      if (imageAsset != null) 'imageAsset': imageAsset,
      if (exerciseType != null) 'exerciseType': exerciseType,
      if (primaryMuscleGroupId != null)
        'primaryMuscleGroupId': primaryMuscleGroupId,
      if (equipmentId != null) 'equipmentId': equipmentId,
      if (effortMetric != null) 'effortMetric': effortMetric,
      if (statsMetricsJson != null) 'statsMetricsJson': statsMetricsJson,
      if (isBuiltIn != null) 'isBuiltIn': isBuiltIn,
      if (isArchived != null) 'isArchived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<bool>? isDeleted,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? youtubeUrl,
    Value<String?>? imageAsset,
    Value<String>? exerciseType,
    Value<String?>? primaryMuscleGroupId,
    Value<String?>? equipmentId,
    Value<String>? effortMetric,
    Value<String?>? statsMetricsJson,
    Value<bool>? isBuiltIn,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return ExercisesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      imageAsset: imageAsset ?? this.imageAsset,
      exerciseType: exerciseType ?? this.exerciseType,
      primaryMuscleGroupId: primaryMuscleGroupId ?? this.primaryMuscleGroupId,
      equipmentId: equipmentId ?? this.equipmentId,
      effortMetric: effortMetric ?? this.effortMetric,
      statsMetricsJson: statsMetricsJson ?? this.statsMetricsJson,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['createdAt'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updatedAt'] = Variable<String>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['isDeleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (youtubeUrl.present) {
      map['youtubeUrl'] = Variable<String>(youtubeUrl.value);
    }
    if (imageAsset.present) {
      map['imageAsset'] = Variable<String>(imageAsset.value);
    }
    if (exerciseType.present) {
      map['exerciseType'] = Variable<String>(exerciseType.value);
    }
    if (primaryMuscleGroupId.present) {
      map['primaryMuscleGroupId'] = Variable<String>(
        primaryMuscleGroupId.value,
      );
    }
    if (equipmentId.present) {
      map['equipmentId'] = Variable<String>(equipmentId.value);
    }
    if (effortMetric.present) {
      map['effortMetric'] = Variable<String>(effortMetric.value);
    }
    if (statsMetricsJson.present) {
      map['statsMetricsJson'] = Variable<String>(statsMetricsJson.value);
    }
    if (isBuiltIn.present) {
      map['isBuiltIn'] = Variable<bool>(isBuiltIn.value);
    }
    if (isArchived.present) {
      map['isArchived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('youtubeUrl: $youtubeUrl, ')
          ..write('imageAsset: $imageAsset, ')
          ..write('exerciseType: $exerciseType, ')
          ..write('primaryMuscleGroupId: $primaryMuscleGroupId, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('effortMetric: $effortMetric, ')
          ..write('statsMetricsJson: $statsMetricsJson, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseSecondaryMusclesTable extends ExerciseSecondaryMuscles
    with TableInfo<$ExerciseSecondaryMusclesTable, ExerciseSecondaryMuscle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseSecondaryMusclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exerciseId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES Exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _muscleGroupIdMeta = const VerificationMeta(
    'muscleGroupId',
  );
  @override
  late final GeneratedColumn<String> muscleGroupId = GeneratedColumn<String>(
    'muscleGroupId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES MuscleGroups (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [exerciseId, muscleGroupId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ExerciseSecondaryMuscles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseSecondaryMuscle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exerciseId')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exerciseId']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('muscleGroupId')) {
      context.handle(
        _muscleGroupIdMeta,
        muscleGroupId.isAcceptableOrUnknown(
          data['muscleGroupId']!,
          _muscleGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_muscleGroupIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId, muscleGroupId};
  @override
  ExerciseSecondaryMuscle map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseSecondaryMuscle(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exerciseId'],
      )!,
      muscleGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscleGroupId'],
      )!,
    );
  }

  @override
  $ExerciseSecondaryMusclesTable createAlias(String alias) {
    return $ExerciseSecondaryMusclesTable(attachedDatabase, alias);
  }
}

class ExerciseSecondaryMuscle extends DataClass
    implements Insertable<ExerciseSecondaryMuscle> {
  final String exerciseId;
  final String muscleGroupId;
  const ExerciseSecondaryMuscle({
    required this.exerciseId,
    required this.muscleGroupId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exerciseId'] = Variable<String>(exerciseId);
    map['muscleGroupId'] = Variable<String>(muscleGroupId);
    return map;
  }

  ExerciseSecondaryMusclesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseSecondaryMusclesCompanion(
      exerciseId: Value(exerciseId),
      muscleGroupId: Value(muscleGroupId),
    );
  }

  factory ExerciseSecondaryMuscle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseSecondaryMuscle(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      muscleGroupId: serializer.fromJson<String>(json['muscleGroupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'muscleGroupId': serializer.toJson<String>(muscleGroupId),
    };
  }

  ExerciseSecondaryMuscle copyWith({
    String? exerciseId,
    String? muscleGroupId,
  }) => ExerciseSecondaryMuscle(
    exerciseId: exerciseId ?? this.exerciseId,
    muscleGroupId: muscleGroupId ?? this.muscleGroupId,
  );
  ExerciseSecondaryMuscle copyWithCompanion(
    ExerciseSecondaryMusclesCompanion data,
  ) {
    return ExerciseSecondaryMuscle(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      muscleGroupId: data.muscleGroupId.present
          ? data.muscleGroupId.value
          : this.muscleGroupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseSecondaryMuscle(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscleGroupId: $muscleGroupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, muscleGroupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseSecondaryMuscle &&
          other.exerciseId == this.exerciseId &&
          other.muscleGroupId == this.muscleGroupId);
}

class ExerciseSecondaryMusclesCompanion
    extends UpdateCompanion<ExerciseSecondaryMuscle> {
  final Value<String> exerciseId;
  final Value<String> muscleGroupId;
  final Value<int> rowid;
  const ExerciseSecondaryMusclesCompanion({
    this.exerciseId = const Value.absent(),
    this.muscleGroupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseSecondaryMusclesCompanion.insert({
    required String exerciseId,
    required String muscleGroupId,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       muscleGroupId = Value(muscleGroupId);
  static Insertable<ExerciseSecondaryMuscle> custom({
    Expression<String>? exerciseId,
    Expression<String>? muscleGroupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exerciseId': exerciseId,
      if (muscleGroupId != null) 'muscleGroupId': muscleGroupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseSecondaryMusclesCompanion copyWith({
    Value<String>? exerciseId,
    Value<String>? muscleGroupId,
    Value<int>? rowid,
  }) {
    return ExerciseSecondaryMusclesCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      muscleGroupId: muscleGroupId ?? this.muscleGroupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exerciseId'] = Variable<String>(exerciseId.value);
    }
    if (muscleGroupId.present) {
      map['muscleGroupId'] = Variable<String>(muscleGroupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseSecondaryMusclesCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscleGroupId: $muscleGroupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseL10nTable extends ExerciseL10n
    with TableInfo<$ExerciseL10nTable, ExerciseL10nData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseL10nTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exerciseId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES Exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (locale IN (\'ru\', \'en\'))',
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
  @override
  List<GeneratedColumn> get $columns => [exerciseId, locale, name, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ExerciseL10n';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseL10nData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exerciseId')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exerciseId']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    } else if (isInserting) {
      context.missing(_localeMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId, locale};
  @override
  ExerciseL10nData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseL10nData(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exerciseId'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $ExerciseL10nTable createAlias(String alias) {
    return $ExerciseL10nTable(attachedDatabase, alias);
  }
}

class ExerciseL10nData extends DataClass
    implements Insertable<ExerciseL10nData> {
  final String exerciseId;
  final String locale;
  final String name;
  final String? description;
  const ExerciseL10nData({
    required this.exerciseId,
    required this.locale,
    required this.name,
    this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exerciseId'] = Variable<String>(exerciseId);
    map['locale'] = Variable<String>(locale);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  ExerciseL10nCompanion toCompanion(bool nullToAbsent) {
    return ExerciseL10nCompanion(
      exerciseId: Value(exerciseId),
      locale: Value(locale),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory ExerciseL10nData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseL10nData(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      locale: serializer.fromJson<String>(json['locale']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'locale': serializer.toJson<String>(locale),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
    };
  }

  ExerciseL10nData copyWith({
    String? exerciseId,
    String? locale,
    String? name,
    Value<String?> description = const Value.absent(),
  }) => ExerciseL10nData(
    exerciseId: exerciseId ?? this.exerciseId,
    locale: locale ?? this.locale,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
  );
  ExerciseL10nData copyWithCompanion(ExerciseL10nCompanion data) {
    return ExerciseL10nData(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      locale: data.locale.present ? data.locale.value : this.locale,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseL10nData(')
          ..write('exerciseId: $exerciseId, ')
          ..write('locale: $locale, ')
          ..write('name: $name, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, locale, name, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseL10nData &&
          other.exerciseId == this.exerciseId &&
          other.locale == this.locale &&
          other.name == this.name &&
          other.description == this.description);
}

class ExerciseL10nCompanion extends UpdateCompanion<ExerciseL10nData> {
  final Value<String> exerciseId;
  final Value<String> locale;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> rowid;
  const ExerciseL10nCompanion({
    this.exerciseId = const Value.absent(),
    this.locale = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseL10nCompanion.insert({
    required String exerciseId,
    required String locale,
    required String name,
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       locale = Value(locale),
       name = Value(name);
  static Insertable<ExerciseL10nData> custom({
    Expression<String>? exerciseId,
    Expression<String>? locale,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exerciseId': exerciseId,
      if (locale != null) 'locale': locale,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseL10nCompanion copyWith({
    Value<String>? exerciseId,
    Value<String>? locale,
    Value<String>? name,
    Value<String?>? description,
    Value<int>? rowid,
  }) {
    return ExerciseL10nCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      locale: locale ?? this.locale,
      name: name ?? this.name,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exerciseId'] = Variable<String>(exerciseId.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseL10nCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('locale: $locale, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutTagsTable extends WorkoutTags
    with TableInfo<$WorkoutTagsTable, WorkoutTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'createdAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updatedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'isDeleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isDeleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'colorHex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#4C7BD9'),
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'isHidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isHidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    isDeleted,
    id,
    name,
    colorHex,
    isHidden,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'WorkoutTags';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('createdAt')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['createdAt']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updatedAt')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updatedAt']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('isDeleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['isDeleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('colorHex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['colorHex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('isHidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['isHidden']!, _isHiddenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutTag(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}createdAt'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updatedAt'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isDeleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colorHex'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isHidden'],
      )!,
    );
  }

  @override
  $WorkoutTagsTable createAlias(String alias) {
    return $WorkoutTagsTable(attachedDatabase, alias);
  }
}

class WorkoutTag extends DataClass implements Insertable<WorkoutTag> {
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  final String id;

  /// 1-30 chars, unique among non-deleted tags case-insensitively
  /// (validated in the service layer).
  final String name;
  final String colorHex;
  final bool isHidden;
  const WorkoutTag({
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.id,
    required this.name,
    required this.colorHex,
    required this.isHidden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['createdAt'] = Variable<String>(createdAt);
    map['updatedAt'] = Variable<String>(updatedAt);
    map['isDeleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['colorHex'] = Variable<String>(colorHex);
    map['isHidden'] = Variable<bool>(isHidden);
    return map;
  }

  WorkoutTagsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutTagsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      id: Value(id),
      name: Value(name),
      colorHex: Value(colorHex),
      isHidden: Value(isHidden),
    );
  }

  factory WorkoutTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutTag(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
      'isHidden': serializer.toJson<bool>(isHidden),
    };
  }

  WorkoutTag copyWith({
    String? createdAt,
    String? updatedAt,
    bool? isDeleted,
    String? id,
    String? name,
    String? colorHex,
    bool? isHidden,
  }) => WorkoutTag(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    id: id ?? this.id,
    name: name ?? this.name,
    colorHex: colorHex ?? this.colorHex,
    isHidden: isHidden ?? this.isHidden,
  );
  WorkoutTag copyWithCompanion(WorkoutTagsCompanion data) {
    return WorkoutTag(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTag(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('isHidden: $isHidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    isDeleted,
    id,
    name,
    colorHex,
    isHidden,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutTag &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.isHidden == this.isHidden);
}

class WorkoutTagsCompanion extends UpdateCompanion<WorkoutTag> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> name;
  final Value<String> colorHex;
  final Value<bool> isHidden;
  final Value<int> rowid;
  const WorkoutTagsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutTagsCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.isDeleted = const Value.absent(),
    required String id,
    required String name,
    this.colorHex = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name);
  static Insertable<WorkoutTag> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<bool>? isHidden,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (isDeleted != null) 'isDeleted': isDeleted,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'colorHex': colorHex,
      if (isHidden != null) 'isHidden': isHidden,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutTagsCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<bool>? isDeleted,
    Value<String>? id,
    Value<String>? name,
    Value<String>? colorHex,
    Value<bool>? isHidden,
    Value<int>? rowid,
  }) {
    return WorkoutTagsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      isHidden: isHidden ?? this.isHidden,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['createdAt'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updatedAt'] = Variable<String>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['isDeleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['colorHex'] = Variable<String>(colorHex.value);
    }
    if (isHidden.present) {
      map['isHidden'] = Variable<bool>(isHidden.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTagsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('isHidden: $isHidden, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutsTable extends Workouts with TableInfo<$WorkoutsTable, Workout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'createdAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updatedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'isDeleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isDeleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'draft\' CHECK (status IN (\'draft\', \'planned\', \'inProgress\', \'completed\', \'skipped\', \'cancelled\'))',
    defaultValue: const CustomExpression('\'draft\''),
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<String> startedAt = GeneratedColumn<String>(
    'startedAt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<String> finishedAt = GeneratedColumn<String>(
    'finishedAt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualDurationSecMeta = const VerificationMeta(
    'actualDurationSec',
  );
  @override
  late final GeneratedColumn<int> actualDurationSec = GeneratedColumn<int>(
    'actualDurationSec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    isDeleted,
    id,
    date,
    name,
    status,
    comment,
    startedAt,
    finishedAt,
    actualDurationSec,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Workouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Workout> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('createdAt')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['createdAt']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updatedAt')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updatedAt']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('isDeleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['isDeleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('startedAt')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['startedAt']!, _startedAtMeta),
      );
    }
    if (data.containsKey('finishedAt')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finishedAt']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('actualDurationSec')) {
      context.handle(
        _actualDurationSecMeta,
        actualDurationSec.isAcceptableOrUnknown(
          data['actualDurationSec']!,
          _actualDurationSecMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workout(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}createdAt'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updatedAt'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isDeleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}startedAt'],
      ),
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finishedAt'],
      ),
      actualDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actualDurationSec'],
      ),
    );
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }
}

class Workout extends DataClass implements Insertable<Workout> {
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  final String id;

  /// Local calendar date `YYYY-MM-DD` (not a UTC timestamp).
  final String date;
  final String? name;
  final String status;
  final String? comment;
  final String? startedAt;
  final String? finishedAt;
  final int? actualDurationSec;
  const Workout({
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.id,
    required this.date,
    this.name,
    required this.status,
    this.comment,
    this.startedAt,
    this.finishedAt,
    this.actualDurationSec,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['createdAt'] = Variable<String>(createdAt);
    map['updatedAt'] = Variable<String>(updatedAt);
    map['isDeleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    if (!nullToAbsent || startedAt != null) {
      map['startedAt'] = Variable<String>(startedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finishedAt'] = Variable<String>(finishedAt);
    }
    if (!nullToAbsent || actualDurationSec != null) {
      map['actualDurationSec'] = Variable<int>(actualDurationSec);
    }
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      id: Value(id),
      date: Value(date),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      status: Value(status),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      actualDurationSec: actualDurationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDurationSec),
    );
  }

  factory Workout.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workout(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      name: serializer.fromJson<String?>(json['name']),
      status: serializer.fromJson<String>(json['status']),
      comment: serializer.fromJson<String?>(json['comment']),
      startedAt: serializer.fromJson<String?>(json['startedAt']),
      finishedAt: serializer.fromJson<String?>(json['finishedAt']),
      actualDurationSec: serializer.fromJson<int?>(json['actualDurationSec']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<String>(date),
      'name': serializer.toJson<String?>(name),
      'status': serializer.toJson<String>(status),
      'comment': serializer.toJson<String?>(comment),
      'startedAt': serializer.toJson<String?>(startedAt),
      'finishedAt': serializer.toJson<String?>(finishedAt),
      'actualDurationSec': serializer.toJson<int?>(actualDurationSec),
    };
  }

  Workout copyWith({
    String? createdAt,
    String? updatedAt,
    bool? isDeleted,
    String? id,
    String? date,
    Value<String?> name = const Value.absent(),
    String? status,
    Value<String?> comment = const Value.absent(),
    Value<String?> startedAt = const Value.absent(),
    Value<String?> finishedAt = const Value.absent(),
    Value<int?> actualDurationSec = const Value.absent(),
  }) => Workout(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    id: id ?? this.id,
    date: date ?? this.date,
    name: name.present ? name.value : this.name,
    status: status ?? this.status,
    comment: comment.present ? comment.value : this.comment,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    actualDurationSec: actualDurationSec.present
        ? actualDurationSec.value
        : this.actualDurationSec,
  );
  Workout copyWithCompanion(WorkoutsCompanion data) {
    return Workout(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      comment: data.comment.present ? data.comment.value : this.comment,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      actualDurationSec: data.actualDurationSec.present
          ? data.actualDurationSec.value
          : this.actualDurationSec,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workout(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('comment: $comment, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('actualDurationSec: $actualDurationSec')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    isDeleted,
    id,
    date,
    name,
    status,
    comment,
    startedAt,
    finishedAt,
    actualDurationSec,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workout &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.date == this.date &&
          other.name == this.name &&
          other.status == this.status &&
          other.comment == this.comment &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.actualDurationSec == this.actualDurationSec);
}

class WorkoutsCompanion extends UpdateCompanion<Workout> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> date;
  final Value<String?> name;
  final Value<String> status;
  final Value<String?> comment;
  final Value<String?> startedAt;
  final Value<String?> finishedAt;
  final Value<int?> actualDurationSec;
  final Value<int> rowid;
  const WorkoutsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.comment = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.actualDurationSec = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.isDeleted = const Value.absent(),
    required String id,
    required String date,
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.comment = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.actualDurationSec = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       date = Value(date);
  static Insertable<Workout> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? date,
    Expression<String>? name,
    Expression<String>? status,
    Expression<String>? comment,
    Expression<String>? startedAt,
    Expression<String>? finishedAt,
    Expression<int>? actualDurationSec,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (isDeleted != null) 'isDeleted': isDeleted,
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (comment != null) 'comment': comment,
      if (startedAt != null) 'startedAt': startedAt,
      if (finishedAt != null) 'finishedAt': finishedAt,
      if (actualDurationSec != null) 'actualDurationSec': actualDurationSec,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutsCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<bool>? isDeleted,
    Value<String>? id,
    Value<String>? date,
    Value<String?>? name,
    Value<String>? status,
    Value<String?>? comment,
    Value<String?>? startedAt,
    Value<String?>? finishedAt,
    Value<int?>? actualDurationSec,
    Value<int>? rowid,
  }) {
    return WorkoutsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      date: date ?? this.date,
      name: name ?? this.name,
      status: status ?? this.status,
      comment: comment ?? this.comment,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      actualDurationSec: actualDurationSec ?? this.actualDurationSec,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['createdAt'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updatedAt'] = Variable<String>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['isDeleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (startedAt.present) {
      map['startedAt'] = Variable<String>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finishedAt'] = Variable<String>(finishedAt.value);
    }
    if (actualDurationSec.present) {
      map['actualDurationSec'] = Variable<int>(actualDurationSec.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('comment: $comment, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('actualDurationSec: $actualDurationSec, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutTagLinksTable extends WorkoutTagLinks
    with TableInfo<$WorkoutTagLinksTable, WorkoutTagLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutTagLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workoutId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES Workouts (id)',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tagId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES WorkoutTags (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [workoutId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'WorkoutTagLinks';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutTagLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('workoutId')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workoutId']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('tagId')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tagId']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workoutId, tagId};
  @override
  WorkoutTagLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutTagLink(
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workoutId'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tagId'],
      )!,
    );
  }

  @override
  $WorkoutTagLinksTable createAlias(String alias) {
    return $WorkoutTagLinksTable(attachedDatabase, alias);
  }
}

class WorkoutTagLink extends DataClass implements Insertable<WorkoutTagLink> {
  final String workoutId;
  final String tagId;
  const WorkoutTagLink({required this.workoutId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['workoutId'] = Variable<String>(workoutId);
    map['tagId'] = Variable<String>(tagId);
    return map;
  }

  WorkoutTagLinksCompanion toCompanion(bool nullToAbsent) {
    return WorkoutTagLinksCompanion(
      workoutId: Value(workoutId),
      tagId: Value(tagId),
    );
  }

  factory WorkoutTagLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutTagLink(
      workoutId: serializer.fromJson<String>(json['workoutId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workoutId': serializer.toJson<String>(workoutId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  WorkoutTagLink copyWith({String? workoutId, String? tagId}) => WorkoutTagLink(
    workoutId: workoutId ?? this.workoutId,
    tagId: tagId ?? this.tagId,
  );
  WorkoutTagLink copyWithCompanion(WorkoutTagLinksCompanion data) {
    return WorkoutTagLink(
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTagLink(')
          ..write('workoutId: $workoutId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(workoutId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutTagLink &&
          other.workoutId == this.workoutId &&
          other.tagId == this.tagId);
}

class WorkoutTagLinksCompanion extends UpdateCompanion<WorkoutTagLink> {
  final Value<String> workoutId;
  final Value<String> tagId;
  final Value<int> rowid;
  const WorkoutTagLinksCompanion({
    this.workoutId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutTagLinksCompanion.insert({
    required String workoutId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : workoutId = Value(workoutId),
       tagId = Value(tagId);
  static Insertable<WorkoutTagLink> custom({
    Expression<String>? workoutId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workoutId != null) 'workoutId': workoutId,
      if (tagId != null) 'tagId': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutTagLinksCompanion copyWith({
    Value<String>? workoutId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return WorkoutTagLinksCompanion(
      workoutId: workoutId ?? this.workoutId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workoutId.present) {
      map['workoutId'] = Variable<String>(workoutId.value);
    }
    if (tagId.present) {
      map['tagId'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTagLinksCompanion(')
          ..write('workoutId: $workoutId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutExercisesTable extends WorkoutExercises
    with TableInfo<$WorkoutExercisesTable, WorkoutExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'createdAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updatedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'isDeleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isDeleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workoutId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES Workouts (id)',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exerciseId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES Exercises (id)',
    ),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'orderIndex',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressionDecisionMeta =
      const VerificationMeta('progressionDecision');
  @override
  late final GeneratedColumn<String>
  progressionDecision = GeneratedColumn<String>(
    'progressionDecision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'none\' CHECK (progressionDecision IN (\'none\', \'increase\', \'repeat\', \'decrease\'))',
    defaultValue: const CustomExpression('\'none\''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    isDeleted,
    id,
    workoutId,
    exerciseId,
    orderIndex,
    comment,
    progressionDecision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'WorkoutExercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('createdAt')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['createdAt']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updatedAt')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updatedAt']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('isDeleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['isDeleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workoutId')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workoutId']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('exerciseId')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exerciseId']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('orderIndex')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['orderIndex']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('progressionDecision')) {
      context.handle(
        _progressionDecisionMeta,
        progressionDecision.isAcceptableOrUnknown(
          data['progressionDecision']!,
          _progressionDecisionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutExercise(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}createdAt'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updatedAt'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isDeleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workoutId'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exerciseId'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orderIndex'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      progressionDecision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}progressionDecision'],
      )!,
    );
  }

  @override
  $WorkoutExercisesTable createAlias(String alias) {
    return $WorkoutExercisesTable(attachedDatabase, alias);
  }
}

class WorkoutExercise extends DataClass implements Insertable<WorkoutExercise> {
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  final String id;
  final String workoutId;
  final String exerciseId;
  final int orderIndex;
  final String? comment;
  final String progressionDecision;
  const WorkoutExercise({
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.orderIndex,
    this.comment,
    required this.progressionDecision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['createdAt'] = Variable<String>(createdAt);
    map['updatedAt'] = Variable<String>(updatedAt);
    map['isDeleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['workoutId'] = Variable<String>(workoutId);
    map['exerciseId'] = Variable<String>(exerciseId);
    map['orderIndex'] = Variable<int>(orderIndex);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    map['progressionDecision'] = Variable<String>(progressionDecision);
    return map;
  }

  WorkoutExercisesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutExercisesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      id: Value(id),
      workoutId: Value(workoutId),
      exerciseId: Value(exerciseId),
      orderIndex: Value(orderIndex),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      progressionDecision: Value(progressionDecision),
    );
  }

  factory WorkoutExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutExercise(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      workoutId: serializer.fromJson<String>(json['workoutId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      comment: serializer.fromJson<String?>(json['comment']),
      progressionDecision: serializer.fromJson<String>(
        json['progressionDecision'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'workoutId': serializer.toJson<String>(workoutId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'comment': serializer.toJson<String?>(comment),
      'progressionDecision': serializer.toJson<String>(progressionDecision),
    };
  }

  WorkoutExercise copyWith({
    String? createdAt,
    String? updatedAt,
    bool? isDeleted,
    String? id,
    String? workoutId,
    String? exerciseId,
    int? orderIndex,
    Value<String?> comment = const Value.absent(),
    String? progressionDecision,
  }) => WorkoutExercise(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    id: id ?? this.id,
    workoutId: workoutId ?? this.workoutId,
    exerciseId: exerciseId ?? this.exerciseId,
    orderIndex: orderIndex ?? this.orderIndex,
    comment: comment.present ? comment.value : this.comment,
    progressionDecision: progressionDecision ?? this.progressionDecision,
  );
  WorkoutExercise copyWithCompanion(WorkoutExercisesCompanion data) {
    return WorkoutExercise(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      comment: data.comment.present ? data.comment.value : this.comment,
      progressionDecision: data.progressionDecision.present
          ? data.progressionDecision.value
          : this.progressionDecision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExercise(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('comment: $comment, ')
          ..write('progressionDecision: $progressionDecision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    isDeleted,
    id,
    workoutId,
    exerciseId,
    orderIndex,
    comment,
    progressionDecision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutExercise &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.exerciseId == this.exerciseId &&
          other.orderIndex == this.orderIndex &&
          other.comment == this.comment &&
          other.progressionDecision == this.progressionDecision);
}

class WorkoutExercisesCompanion extends UpdateCompanion<WorkoutExercise> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> workoutId;
  final Value<String> exerciseId;
  final Value<int> orderIndex;
  final Value<String?> comment;
  final Value<String> progressionDecision;
  final Value<int> rowid;
  const WorkoutExercisesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.comment = const Value.absent(),
    this.progressionDecision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutExercisesCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.isDeleted = const Value.absent(),
    required String id,
    required String workoutId,
    required String exerciseId,
    required int orderIndex,
    this.comment = const Value.absent(),
    this.progressionDecision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       workoutId = Value(workoutId),
       exerciseId = Value(exerciseId),
       orderIndex = Value(orderIndex);
  static Insertable<WorkoutExercise> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? workoutId,
    Expression<String>? exerciseId,
    Expression<int>? orderIndex,
    Expression<String>? comment,
    Expression<String>? progressionDecision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (isDeleted != null) 'isDeleted': isDeleted,
      if (id != null) 'id': id,
      if (workoutId != null) 'workoutId': workoutId,
      if (exerciseId != null) 'exerciseId': exerciseId,
      if (orderIndex != null) 'orderIndex': orderIndex,
      if (comment != null) 'comment': comment,
      if (progressionDecision != null)
        'progressionDecision': progressionDecision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutExercisesCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<bool>? isDeleted,
    Value<String>? id,
    Value<String>? workoutId,
    Value<String>? exerciseId,
    Value<int>? orderIndex,
    Value<String?>? comment,
    Value<String>? progressionDecision,
    Value<int>? rowid,
  }) {
    return WorkoutExercisesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
      comment: comment ?? this.comment,
      progressionDecision: progressionDecision ?? this.progressionDecision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['createdAt'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updatedAt'] = Variable<String>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['isDeleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutId.present) {
      map['workoutId'] = Variable<String>(workoutId.value);
    }
    if (exerciseId.present) {
      map['exerciseId'] = Variable<String>(exerciseId.value);
    }
    if (orderIndex.present) {
      map['orderIndex'] = Variable<int>(orderIndex.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (progressionDecision.present) {
      map['progressionDecision'] = Variable<String>(progressionDecision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExercisesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('comment: $comment, ')
          ..write('progressionDecision: $progressionDecision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseSetsTable extends ExerciseSets
    with TableInfo<$ExerciseSetsTable, ExerciseSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'createdAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updatedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'isDeleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isDeleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutExerciseIdMeta = const VerificationMeta(
    'workoutExerciseId',
  );
  @override
  late final GeneratedColumn<String> workoutExerciseId =
      GeneratedColumn<String>(
        'workoutExerciseId',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES WorkoutExercises (id)',
        ),
      );
  static const VerificationMeta _setNumberMeta = const VerificationMeta(
    'setNumber',
  );
  @override
  late final GeneratedColumn<int> setNumber = GeneratedColumn<int>(
    'setNumber',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'isCompleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isCompleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _plannedWeightKgMeta = const VerificationMeta(
    'plannedWeightKg',
  );
  @override
  late final GeneratedColumn<double> plannedWeightKg = GeneratedColumn<double>(
    'plannedWeightKg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedRepsMeta = const VerificationMeta(
    'plannedReps',
  );
  @override
  late final GeneratedColumn<int> plannedReps = GeneratedColumn<int>(
    'plannedReps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualWeightKgMeta = const VerificationMeta(
    'actualWeightKg',
  );
  @override
  late final GeneratedColumn<double> actualWeightKg = GeneratedColumn<double>(
    'actualWeightKg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualRepsMeta = const VerificationMeta(
    'actualReps',
  );
  @override
  late final GeneratedColumn<int> actualReps = GeneratedColumn<int>(
    'actualReps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<double> rpe = GeneratedColumn<double>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rirMeta = const VerificationMeta('rir');
  @override
  late final GeneratedColumn<int> rir = GeneratedColumn<int>(
    'rir',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedDurationSecMeta =
      const VerificationMeta('plannedDurationSec');
  @override
  late final GeneratedColumn<int> plannedDurationSec = GeneratedColumn<int>(
    'plannedDurationSec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualDurationSecMeta = const VerificationMeta(
    'actualDurationSec',
  );
  @override
  late final GeneratedColumn<int> actualDurationSec = GeneratedColumn<int>(
    'actualDurationSec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedDistanceMMeta = const VerificationMeta(
    'plannedDistanceM',
  );
  @override
  late final GeneratedColumn<double> plannedDistanceM = GeneratedColumn<double>(
    'plannedDistanceM',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualDistanceMMeta = const VerificationMeta(
    'actualDistanceM',
  );
  @override
  late final GeneratedColumn<double> actualDistanceM = GeneratedColumn<double>(
    'actualDistanceM',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resistanceMeta = const VerificationMeta(
    'resistance',
  );
  @override
  late final GeneratedColumn<double> resistance = GeneratedColumn<double>(
    'resistance',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inclinePercentMeta = const VerificationMeta(
    'inclinePercent',
  );
  @override
  late final GeneratedColumn<double> inclinePercent = GeneratedColumn<double>(
    'inclinePercent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgHeartRateMeta = const VerificationMeta(
    'avgHeartRate',
  );
  @override
  late final GeneratedColumn<int> avgHeartRate = GeneratedColumn<int>(
    'avgHeartRate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'none\' CHECK (side IN (\'none\', \'left\', \'right\', \'both\'))',
    defaultValue: const CustomExpression('\'none\''),
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    isDeleted,
    id,
    workoutExerciseId,
    setNumber,
    isCompleted,
    plannedWeightKg,
    plannedReps,
    actualWeightKg,
    actualReps,
    rpe,
    rir,
    plannedDurationSec,
    actualDurationSec,
    plannedDistanceM,
    actualDistanceM,
    resistance,
    inclinePercent,
    avgHeartRate,
    side,
    comment,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ExerciseSets';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('createdAt')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['createdAt']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updatedAt')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updatedAt']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('isDeleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['isDeleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workoutExerciseId')) {
      context.handle(
        _workoutExerciseIdMeta,
        workoutExerciseId.isAcceptableOrUnknown(
          data['workoutExerciseId']!,
          _workoutExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutExerciseIdMeta);
    }
    if (data.containsKey('setNumber')) {
      context.handle(
        _setNumberMeta,
        setNumber.isAcceptableOrUnknown(data['setNumber']!, _setNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_setNumberMeta);
    }
    if (data.containsKey('isCompleted')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['isCompleted']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('plannedWeightKg')) {
      context.handle(
        _plannedWeightKgMeta,
        plannedWeightKg.isAcceptableOrUnknown(
          data['plannedWeightKg']!,
          _plannedWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('plannedReps')) {
      context.handle(
        _plannedRepsMeta,
        plannedReps.isAcceptableOrUnknown(
          data['plannedReps']!,
          _plannedRepsMeta,
        ),
      );
    }
    if (data.containsKey('actualWeightKg')) {
      context.handle(
        _actualWeightKgMeta,
        actualWeightKg.isAcceptableOrUnknown(
          data['actualWeightKg']!,
          _actualWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('actualReps')) {
      context.handle(
        _actualRepsMeta,
        actualReps.isAcceptableOrUnknown(data['actualReps']!, _actualRepsMeta),
      );
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('rir')) {
      context.handle(
        _rirMeta,
        rir.isAcceptableOrUnknown(data['rir']!, _rirMeta),
      );
    }
    if (data.containsKey('plannedDurationSec')) {
      context.handle(
        _plannedDurationSecMeta,
        plannedDurationSec.isAcceptableOrUnknown(
          data['plannedDurationSec']!,
          _plannedDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('actualDurationSec')) {
      context.handle(
        _actualDurationSecMeta,
        actualDurationSec.isAcceptableOrUnknown(
          data['actualDurationSec']!,
          _actualDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('plannedDistanceM')) {
      context.handle(
        _plannedDistanceMMeta,
        plannedDistanceM.isAcceptableOrUnknown(
          data['plannedDistanceM']!,
          _plannedDistanceMMeta,
        ),
      );
    }
    if (data.containsKey('actualDistanceM')) {
      context.handle(
        _actualDistanceMMeta,
        actualDistanceM.isAcceptableOrUnknown(
          data['actualDistanceM']!,
          _actualDistanceMMeta,
        ),
      );
    }
    if (data.containsKey('resistance')) {
      context.handle(
        _resistanceMeta,
        resistance.isAcceptableOrUnknown(data['resistance']!, _resistanceMeta),
      );
    }
    if (data.containsKey('inclinePercent')) {
      context.handle(
        _inclinePercentMeta,
        inclinePercent.isAcceptableOrUnknown(
          data['inclinePercent']!,
          _inclinePercentMeta,
        ),
      );
    }
    if (data.containsKey('avgHeartRate')) {
      context.handle(
        _avgHeartRateMeta,
        avgHeartRate.isAcceptableOrUnknown(
          data['avgHeartRate']!,
          _avgHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseSet(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}createdAt'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updatedAt'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isDeleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workoutExerciseId'],
      )!,
      setNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}setNumber'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isCompleted'],
      )!,
      plannedWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}plannedWeightKg'],
      ),
      plannedReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plannedReps'],
      ),
      actualWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actualWeightKg'],
      ),
      actualReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actualReps'],
      ),
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rpe'],
      ),
      rir: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rir'],
      ),
      plannedDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plannedDurationSec'],
      ),
      actualDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actualDurationSec'],
      ),
      plannedDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}plannedDistanceM'],
      ),
      actualDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actualDistanceM'],
      ),
      resistance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}resistance'],
      ),
      inclinePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}inclinePercent'],
      ),
      avgHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avgHeartRate'],
      ),
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
    );
  }

  @override
  $ExerciseSetsTable createAlias(String alias) {
    return $ExerciseSetsTable(attachedDatabase, alias);
  }
}

class ExerciseSet extends DataClass implements Insertable<ExerciseSet> {
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  final String id;
  final String workoutExerciseId;
  final int setNumber;
  final bool isCompleted;
  final double? plannedWeightKg;
  final int? plannedReps;
  final double? actualWeightKg;
  final int? actualReps;
  final double? rpe;
  final int? rir;
  final int? plannedDurationSec;
  final int? actualDurationSec;
  final double? plannedDistanceM;
  final double? actualDistanceM;
  final double? resistance;
  final double? inclinePercent;
  final int? avgHeartRate;
  final String side;
  final String? comment;
  const ExerciseSet({
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.id,
    required this.workoutExerciseId,
    required this.setNumber,
    required this.isCompleted,
    this.plannedWeightKg,
    this.plannedReps,
    this.actualWeightKg,
    this.actualReps,
    this.rpe,
    this.rir,
    this.plannedDurationSec,
    this.actualDurationSec,
    this.plannedDistanceM,
    this.actualDistanceM,
    this.resistance,
    this.inclinePercent,
    this.avgHeartRate,
    required this.side,
    this.comment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['createdAt'] = Variable<String>(createdAt);
    map['updatedAt'] = Variable<String>(updatedAt);
    map['isDeleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['workoutExerciseId'] = Variable<String>(workoutExerciseId);
    map['setNumber'] = Variable<int>(setNumber);
    map['isCompleted'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || plannedWeightKg != null) {
      map['plannedWeightKg'] = Variable<double>(plannedWeightKg);
    }
    if (!nullToAbsent || plannedReps != null) {
      map['plannedReps'] = Variable<int>(plannedReps);
    }
    if (!nullToAbsent || actualWeightKg != null) {
      map['actualWeightKg'] = Variable<double>(actualWeightKg);
    }
    if (!nullToAbsent || actualReps != null) {
      map['actualReps'] = Variable<int>(actualReps);
    }
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<double>(rpe);
    }
    if (!nullToAbsent || rir != null) {
      map['rir'] = Variable<int>(rir);
    }
    if (!nullToAbsent || plannedDurationSec != null) {
      map['plannedDurationSec'] = Variable<int>(plannedDurationSec);
    }
    if (!nullToAbsent || actualDurationSec != null) {
      map['actualDurationSec'] = Variable<int>(actualDurationSec);
    }
    if (!nullToAbsent || plannedDistanceM != null) {
      map['plannedDistanceM'] = Variable<double>(plannedDistanceM);
    }
    if (!nullToAbsent || actualDistanceM != null) {
      map['actualDistanceM'] = Variable<double>(actualDistanceM);
    }
    if (!nullToAbsent || resistance != null) {
      map['resistance'] = Variable<double>(resistance);
    }
    if (!nullToAbsent || inclinePercent != null) {
      map['inclinePercent'] = Variable<double>(inclinePercent);
    }
    if (!nullToAbsent || avgHeartRate != null) {
      map['avgHeartRate'] = Variable<int>(avgHeartRate);
    }
    map['side'] = Variable<String>(side);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    return map;
  }

  ExerciseSetsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseSetsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      id: Value(id),
      workoutExerciseId: Value(workoutExerciseId),
      setNumber: Value(setNumber),
      isCompleted: Value(isCompleted),
      plannedWeightKg: plannedWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedWeightKg),
      plannedReps: plannedReps == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedReps),
      actualWeightKg: actualWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(actualWeightKg),
      actualReps: actualReps == null && nullToAbsent
          ? const Value.absent()
          : Value(actualReps),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      rir: rir == null && nullToAbsent ? const Value.absent() : Value(rir),
      plannedDurationSec: plannedDurationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedDurationSec),
      actualDurationSec: actualDurationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDurationSec),
      plannedDistanceM: plannedDistanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedDistanceM),
      actualDistanceM: actualDistanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDistanceM),
      resistance: resistance == null && nullToAbsent
          ? const Value.absent()
          : Value(resistance),
      inclinePercent: inclinePercent == null && nullToAbsent
          ? const Value.absent()
          : Value(inclinePercent),
      avgHeartRate: avgHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(avgHeartRate),
      side: Value(side),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
    );
  }

  factory ExerciseSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseSet(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      workoutExerciseId: serializer.fromJson<String>(json['workoutExerciseId']),
      setNumber: serializer.fromJson<int>(json['setNumber']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      plannedWeightKg: serializer.fromJson<double?>(json['plannedWeightKg']),
      plannedReps: serializer.fromJson<int?>(json['plannedReps']),
      actualWeightKg: serializer.fromJson<double?>(json['actualWeightKg']),
      actualReps: serializer.fromJson<int?>(json['actualReps']),
      rpe: serializer.fromJson<double?>(json['rpe']),
      rir: serializer.fromJson<int?>(json['rir']),
      plannedDurationSec: serializer.fromJson<int?>(json['plannedDurationSec']),
      actualDurationSec: serializer.fromJson<int?>(json['actualDurationSec']),
      plannedDistanceM: serializer.fromJson<double?>(json['plannedDistanceM']),
      actualDistanceM: serializer.fromJson<double?>(json['actualDistanceM']),
      resistance: serializer.fromJson<double?>(json['resistance']),
      inclinePercent: serializer.fromJson<double?>(json['inclinePercent']),
      avgHeartRate: serializer.fromJson<int?>(json['avgHeartRate']),
      side: serializer.fromJson<String>(json['side']),
      comment: serializer.fromJson<String?>(json['comment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'workoutExerciseId': serializer.toJson<String>(workoutExerciseId),
      'setNumber': serializer.toJson<int>(setNumber),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'plannedWeightKg': serializer.toJson<double?>(plannedWeightKg),
      'plannedReps': serializer.toJson<int?>(plannedReps),
      'actualWeightKg': serializer.toJson<double?>(actualWeightKg),
      'actualReps': serializer.toJson<int?>(actualReps),
      'rpe': serializer.toJson<double?>(rpe),
      'rir': serializer.toJson<int?>(rir),
      'plannedDurationSec': serializer.toJson<int?>(plannedDurationSec),
      'actualDurationSec': serializer.toJson<int?>(actualDurationSec),
      'plannedDistanceM': serializer.toJson<double?>(plannedDistanceM),
      'actualDistanceM': serializer.toJson<double?>(actualDistanceM),
      'resistance': serializer.toJson<double?>(resistance),
      'inclinePercent': serializer.toJson<double?>(inclinePercent),
      'avgHeartRate': serializer.toJson<int?>(avgHeartRate),
      'side': serializer.toJson<String>(side),
      'comment': serializer.toJson<String?>(comment),
    };
  }

  ExerciseSet copyWith({
    String? createdAt,
    String? updatedAt,
    bool? isDeleted,
    String? id,
    String? workoutExerciseId,
    int? setNumber,
    bool? isCompleted,
    Value<double?> plannedWeightKg = const Value.absent(),
    Value<int?> plannedReps = const Value.absent(),
    Value<double?> actualWeightKg = const Value.absent(),
    Value<int?> actualReps = const Value.absent(),
    Value<double?> rpe = const Value.absent(),
    Value<int?> rir = const Value.absent(),
    Value<int?> plannedDurationSec = const Value.absent(),
    Value<int?> actualDurationSec = const Value.absent(),
    Value<double?> plannedDistanceM = const Value.absent(),
    Value<double?> actualDistanceM = const Value.absent(),
    Value<double?> resistance = const Value.absent(),
    Value<double?> inclinePercent = const Value.absent(),
    Value<int?> avgHeartRate = const Value.absent(),
    String? side,
    Value<String?> comment = const Value.absent(),
  }) => ExerciseSet(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    id: id ?? this.id,
    workoutExerciseId: workoutExerciseId ?? this.workoutExerciseId,
    setNumber: setNumber ?? this.setNumber,
    isCompleted: isCompleted ?? this.isCompleted,
    plannedWeightKg: plannedWeightKg.present
        ? plannedWeightKg.value
        : this.plannedWeightKg,
    plannedReps: plannedReps.present ? plannedReps.value : this.plannedReps,
    actualWeightKg: actualWeightKg.present
        ? actualWeightKg.value
        : this.actualWeightKg,
    actualReps: actualReps.present ? actualReps.value : this.actualReps,
    rpe: rpe.present ? rpe.value : this.rpe,
    rir: rir.present ? rir.value : this.rir,
    plannedDurationSec: plannedDurationSec.present
        ? plannedDurationSec.value
        : this.plannedDurationSec,
    actualDurationSec: actualDurationSec.present
        ? actualDurationSec.value
        : this.actualDurationSec,
    plannedDistanceM: plannedDistanceM.present
        ? plannedDistanceM.value
        : this.plannedDistanceM,
    actualDistanceM: actualDistanceM.present
        ? actualDistanceM.value
        : this.actualDistanceM,
    resistance: resistance.present ? resistance.value : this.resistance,
    inclinePercent: inclinePercent.present
        ? inclinePercent.value
        : this.inclinePercent,
    avgHeartRate: avgHeartRate.present ? avgHeartRate.value : this.avgHeartRate,
    side: side ?? this.side,
    comment: comment.present ? comment.value : this.comment,
  );
  ExerciseSet copyWithCompanion(ExerciseSetsCompanion data) {
    return ExerciseSet(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      workoutExerciseId: data.workoutExerciseId.present
          ? data.workoutExerciseId.value
          : this.workoutExerciseId,
      setNumber: data.setNumber.present ? data.setNumber.value : this.setNumber,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      plannedWeightKg: data.plannedWeightKg.present
          ? data.plannedWeightKg.value
          : this.plannedWeightKg,
      plannedReps: data.plannedReps.present
          ? data.plannedReps.value
          : this.plannedReps,
      actualWeightKg: data.actualWeightKg.present
          ? data.actualWeightKg.value
          : this.actualWeightKg,
      actualReps: data.actualReps.present
          ? data.actualReps.value
          : this.actualReps,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      rir: data.rir.present ? data.rir.value : this.rir,
      plannedDurationSec: data.plannedDurationSec.present
          ? data.plannedDurationSec.value
          : this.plannedDurationSec,
      actualDurationSec: data.actualDurationSec.present
          ? data.actualDurationSec.value
          : this.actualDurationSec,
      plannedDistanceM: data.plannedDistanceM.present
          ? data.plannedDistanceM.value
          : this.plannedDistanceM,
      actualDistanceM: data.actualDistanceM.present
          ? data.actualDistanceM.value
          : this.actualDistanceM,
      resistance: data.resistance.present
          ? data.resistance.value
          : this.resistance,
      inclinePercent: data.inclinePercent.present
          ? data.inclinePercent.value
          : this.inclinePercent,
      avgHeartRate: data.avgHeartRate.present
          ? data.avgHeartRate.value
          : this.avgHeartRate,
      side: data.side.present ? data.side.value : this.side,
      comment: data.comment.present ? data.comment.value : this.comment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseSet(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('workoutExerciseId: $workoutExerciseId, ')
          ..write('setNumber: $setNumber, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('plannedWeightKg: $plannedWeightKg, ')
          ..write('plannedReps: $plannedReps, ')
          ..write('actualWeightKg: $actualWeightKg, ')
          ..write('actualReps: $actualReps, ')
          ..write('rpe: $rpe, ')
          ..write('rir: $rir, ')
          ..write('plannedDurationSec: $plannedDurationSec, ')
          ..write('actualDurationSec: $actualDurationSec, ')
          ..write('plannedDistanceM: $plannedDistanceM, ')
          ..write('actualDistanceM: $actualDistanceM, ')
          ..write('resistance: $resistance, ')
          ..write('inclinePercent: $inclinePercent, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('side: $side, ')
          ..write('comment: $comment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    updatedAt,
    isDeleted,
    id,
    workoutExerciseId,
    setNumber,
    isCompleted,
    plannedWeightKg,
    plannedReps,
    actualWeightKg,
    actualReps,
    rpe,
    rir,
    plannedDurationSec,
    actualDurationSec,
    plannedDistanceM,
    actualDistanceM,
    resistance,
    inclinePercent,
    avgHeartRate,
    side,
    comment,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseSet &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.workoutExerciseId == this.workoutExerciseId &&
          other.setNumber == this.setNumber &&
          other.isCompleted == this.isCompleted &&
          other.plannedWeightKg == this.plannedWeightKg &&
          other.plannedReps == this.plannedReps &&
          other.actualWeightKg == this.actualWeightKg &&
          other.actualReps == this.actualReps &&
          other.rpe == this.rpe &&
          other.rir == this.rir &&
          other.plannedDurationSec == this.plannedDurationSec &&
          other.actualDurationSec == this.actualDurationSec &&
          other.plannedDistanceM == this.plannedDistanceM &&
          other.actualDistanceM == this.actualDistanceM &&
          other.resistance == this.resistance &&
          other.inclinePercent == this.inclinePercent &&
          other.avgHeartRate == this.avgHeartRate &&
          other.side == this.side &&
          other.comment == this.comment);
}

class ExerciseSetsCompanion extends UpdateCompanion<ExerciseSet> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> workoutExerciseId;
  final Value<int> setNumber;
  final Value<bool> isCompleted;
  final Value<double?> plannedWeightKg;
  final Value<int?> plannedReps;
  final Value<double?> actualWeightKg;
  final Value<int?> actualReps;
  final Value<double?> rpe;
  final Value<int?> rir;
  final Value<int?> plannedDurationSec;
  final Value<int?> actualDurationSec;
  final Value<double?> plannedDistanceM;
  final Value<double?> actualDistanceM;
  final Value<double?> resistance;
  final Value<double?> inclinePercent;
  final Value<int?> avgHeartRate;
  final Value<String> side;
  final Value<String?> comment;
  final Value<int> rowid;
  const ExerciseSetsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.workoutExerciseId = const Value.absent(),
    this.setNumber = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.plannedWeightKg = const Value.absent(),
    this.plannedReps = const Value.absent(),
    this.actualWeightKg = const Value.absent(),
    this.actualReps = const Value.absent(),
    this.rpe = const Value.absent(),
    this.rir = const Value.absent(),
    this.plannedDurationSec = const Value.absent(),
    this.actualDurationSec = const Value.absent(),
    this.plannedDistanceM = const Value.absent(),
    this.actualDistanceM = const Value.absent(),
    this.resistance = const Value.absent(),
    this.inclinePercent = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.side = const Value.absent(),
    this.comment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseSetsCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.isDeleted = const Value.absent(),
    required String id,
    required String workoutExerciseId,
    required int setNumber,
    this.isCompleted = const Value.absent(),
    this.plannedWeightKg = const Value.absent(),
    this.plannedReps = const Value.absent(),
    this.actualWeightKg = const Value.absent(),
    this.actualReps = const Value.absent(),
    this.rpe = const Value.absent(),
    this.rir = const Value.absent(),
    this.plannedDurationSec = const Value.absent(),
    this.actualDurationSec = const Value.absent(),
    this.plannedDistanceM = const Value.absent(),
    this.actualDistanceM = const Value.absent(),
    this.resistance = const Value.absent(),
    this.inclinePercent = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.side = const Value.absent(),
    this.comment = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       workoutExerciseId = Value(workoutExerciseId),
       setNumber = Value(setNumber);
  static Insertable<ExerciseSet> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? workoutExerciseId,
    Expression<int>? setNumber,
    Expression<bool>? isCompleted,
    Expression<double>? plannedWeightKg,
    Expression<int>? plannedReps,
    Expression<double>? actualWeightKg,
    Expression<int>? actualReps,
    Expression<double>? rpe,
    Expression<int>? rir,
    Expression<int>? plannedDurationSec,
    Expression<int>? actualDurationSec,
    Expression<double>? plannedDistanceM,
    Expression<double>? actualDistanceM,
    Expression<double>? resistance,
    Expression<double>? inclinePercent,
    Expression<int>? avgHeartRate,
    Expression<String>? side,
    Expression<String>? comment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (isDeleted != null) 'isDeleted': isDeleted,
      if (id != null) 'id': id,
      if (workoutExerciseId != null) 'workoutExerciseId': workoutExerciseId,
      if (setNumber != null) 'setNumber': setNumber,
      if (isCompleted != null) 'isCompleted': isCompleted,
      if (plannedWeightKg != null) 'plannedWeightKg': plannedWeightKg,
      if (plannedReps != null) 'plannedReps': plannedReps,
      if (actualWeightKg != null) 'actualWeightKg': actualWeightKg,
      if (actualReps != null) 'actualReps': actualReps,
      if (rpe != null) 'rpe': rpe,
      if (rir != null) 'rir': rir,
      if (plannedDurationSec != null) 'plannedDurationSec': plannedDurationSec,
      if (actualDurationSec != null) 'actualDurationSec': actualDurationSec,
      if (plannedDistanceM != null) 'plannedDistanceM': plannedDistanceM,
      if (actualDistanceM != null) 'actualDistanceM': actualDistanceM,
      if (resistance != null) 'resistance': resistance,
      if (inclinePercent != null) 'inclinePercent': inclinePercent,
      if (avgHeartRate != null) 'avgHeartRate': avgHeartRate,
      if (side != null) 'side': side,
      if (comment != null) 'comment': comment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseSetsCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<bool>? isDeleted,
    Value<String>? id,
    Value<String>? workoutExerciseId,
    Value<int>? setNumber,
    Value<bool>? isCompleted,
    Value<double?>? plannedWeightKg,
    Value<int?>? plannedReps,
    Value<double?>? actualWeightKg,
    Value<int?>? actualReps,
    Value<double?>? rpe,
    Value<int?>? rir,
    Value<int?>? plannedDurationSec,
    Value<int?>? actualDurationSec,
    Value<double?>? plannedDistanceM,
    Value<double?>? actualDistanceM,
    Value<double?>? resistance,
    Value<double?>? inclinePercent,
    Value<int?>? avgHeartRate,
    Value<String>? side,
    Value<String?>? comment,
    Value<int>? rowid,
  }) {
    return ExerciseSetsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      workoutExerciseId: workoutExerciseId ?? this.workoutExerciseId,
      setNumber: setNumber ?? this.setNumber,
      isCompleted: isCompleted ?? this.isCompleted,
      plannedWeightKg: plannedWeightKg ?? this.plannedWeightKg,
      plannedReps: plannedReps ?? this.plannedReps,
      actualWeightKg: actualWeightKg ?? this.actualWeightKg,
      actualReps: actualReps ?? this.actualReps,
      rpe: rpe ?? this.rpe,
      rir: rir ?? this.rir,
      plannedDurationSec: plannedDurationSec ?? this.plannedDurationSec,
      actualDurationSec: actualDurationSec ?? this.actualDurationSec,
      plannedDistanceM: plannedDistanceM ?? this.plannedDistanceM,
      actualDistanceM: actualDistanceM ?? this.actualDistanceM,
      resistance: resistance ?? this.resistance,
      inclinePercent: inclinePercent ?? this.inclinePercent,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      side: side ?? this.side,
      comment: comment ?? this.comment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['createdAt'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updatedAt'] = Variable<String>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['isDeleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutExerciseId.present) {
      map['workoutExerciseId'] = Variable<String>(workoutExerciseId.value);
    }
    if (setNumber.present) {
      map['setNumber'] = Variable<int>(setNumber.value);
    }
    if (isCompleted.present) {
      map['isCompleted'] = Variable<bool>(isCompleted.value);
    }
    if (plannedWeightKg.present) {
      map['plannedWeightKg'] = Variable<double>(plannedWeightKg.value);
    }
    if (plannedReps.present) {
      map['plannedReps'] = Variable<int>(plannedReps.value);
    }
    if (actualWeightKg.present) {
      map['actualWeightKg'] = Variable<double>(actualWeightKg.value);
    }
    if (actualReps.present) {
      map['actualReps'] = Variable<int>(actualReps.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<double>(rpe.value);
    }
    if (rir.present) {
      map['rir'] = Variable<int>(rir.value);
    }
    if (plannedDurationSec.present) {
      map['plannedDurationSec'] = Variable<int>(plannedDurationSec.value);
    }
    if (actualDurationSec.present) {
      map['actualDurationSec'] = Variable<int>(actualDurationSec.value);
    }
    if (plannedDistanceM.present) {
      map['plannedDistanceM'] = Variable<double>(plannedDistanceM.value);
    }
    if (actualDistanceM.present) {
      map['actualDistanceM'] = Variable<double>(actualDistanceM.value);
    }
    if (resistance.present) {
      map['resistance'] = Variable<double>(resistance.value);
    }
    if (inclinePercent.present) {
      map['inclinePercent'] = Variable<double>(inclinePercent.value);
    }
    if (avgHeartRate.present) {
      map['avgHeartRate'] = Variable<int>(avgHeartRate.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseSetsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('workoutExerciseId: $workoutExerciseId, ')
          ..write('setNumber: $setNumber, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('plannedWeightKg: $plannedWeightKg, ')
          ..write('plannedReps: $plannedReps, ')
          ..write('actualWeightKg: $actualWeightKg, ')
          ..write('actualReps: $actualReps, ')
          ..write('rpe: $rpe, ')
          ..write('rir: $rir, ')
          ..write('plannedDurationSec: $plannedDurationSec, ')
          ..write('actualDurationSec: $actualDurationSec, ')
          ..write('plannedDistanceM: $plannedDistanceM, ')
          ..write('actualDistanceM: $actualDistanceM, ')
          ..write('resistance: $resistance, ')
          ..write('inclinePercent: $inclinePercent, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('side: $side, ')
          ..write('comment: $comment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutTemplatesTable extends WorkoutTemplates
    with TableInfo<$WorkoutTemplatesTable, WorkoutTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'createdAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updatedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'isDeleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isDeleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'isArchived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isArchived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    isDeleted,
    id,
    name,
    comment,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'WorkoutTemplates';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('createdAt')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['createdAt']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updatedAt')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updatedAt']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('isDeleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['isDeleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('isArchived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['isArchived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutTemplate(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}createdAt'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updatedAt'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isDeleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isArchived'],
      )!,
    );
  }

  @override
  $WorkoutTemplatesTable createAlias(String alias) {
    return $WorkoutTemplatesTable(attachedDatabase, alias);
  }
}

class WorkoutTemplate extends DataClass implements Insertable<WorkoutTemplate> {
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  final String id;
  final String name;
  final String? comment;
  final bool isArchived;
  const WorkoutTemplate({
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.id,
    required this.name,
    this.comment,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['createdAt'] = Variable<String>(createdAt);
    map['updatedAt'] = Variable<String>(updatedAt);
    map['isDeleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    map['isArchived'] = Variable<bool>(isArchived);
    return map;
  }

  WorkoutTemplatesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutTemplatesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      id: Value(id),
      name: Value(name),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      isArchived: Value(isArchived),
    );
  }

  factory WorkoutTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutTemplate(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      comment: serializer.fromJson<String?>(json['comment']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'comment': serializer.toJson<String?>(comment),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  WorkoutTemplate copyWith({
    String? createdAt,
    String? updatedAt,
    bool? isDeleted,
    String? id,
    String? name,
    Value<String?> comment = const Value.absent(),
    bool? isArchived,
  }) => WorkoutTemplate(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    id: id ?? this.id,
    name: name ?? this.name,
    comment: comment.present ? comment.value : this.comment,
    isArchived: isArchived ?? this.isArchived,
  );
  WorkoutTemplate copyWithCompanion(WorkoutTemplatesCompanion data) {
    return WorkoutTemplate(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      comment: data.comment.present ? data.comment.value : this.comment,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTemplate(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('comment: $comment, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    isDeleted,
    id,
    name,
    comment,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutTemplate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.name == this.name &&
          other.comment == this.comment &&
          other.isArchived == this.isArchived);
}

class WorkoutTemplatesCompanion extends UpdateCompanion<WorkoutTemplate> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> comment;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const WorkoutTemplatesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.comment = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutTemplatesCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.isDeleted = const Value.absent(),
    required String id,
    required String name,
    this.comment = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name);
  static Insertable<WorkoutTemplate> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? comment,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (isDeleted != null) 'isDeleted': isDeleted,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (comment != null) 'comment': comment,
      if (isArchived != null) 'isArchived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutTemplatesCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<bool>? isDeleted,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? comment,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return WorkoutTemplatesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      name: name ?? this.name,
      comment: comment ?? this.comment,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['createdAt'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updatedAt'] = Variable<String>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['isDeleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (isArchived.present) {
      map['isArchived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTemplatesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('comment: $comment, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TemplateExercisesTable extends TemplateExercises
    with TableInfo<$TemplateExercisesTable, TemplateExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplateExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'createdAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updatedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'isDeleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isDeleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'templateId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES WorkoutTemplates (id)',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exerciseId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES Exercises (id)',
    ),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'orderIndex',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    isDeleted,
    id,
    templateId,
    exerciseId,
    orderIndex,
    comment,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'TemplateExercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemplateExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('createdAt')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['createdAt']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updatedAt')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updatedAt']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('isDeleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['isDeleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('templateId')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['templateId']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('exerciseId')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exerciseId']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('orderIndex')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['orderIndex']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemplateExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateExercise(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}createdAt'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updatedAt'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isDeleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}templateId'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exerciseId'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orderIndex'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
    );
  }

  @override
  $TemplateExercisesTable createAlias(String alias) {
    return $TemplateExercisesTable(attachedDatabase, alias);
  }
}

class TemplateExercise extends DataClass
    implements Insertable<TemplateExercise> {
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  final String id;
  final String templateId;
  final String exerciseId;
  final int orderIndex;
  final String? comment;
  const TemplateExercise({
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.id,
    required this.templateId,
    required this.exerciseId,
    required this.orderIndex,
    this.comment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['createdAt'] = Variable<String>(createdAt);
    map['updatedAt'] = Variable<String>(updatedAt);
    map['isDeleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['templateId'] = Variable<String>(templateId);
    map['exerciseId'] = Variable<String>(exerciseId);
    map['orderIndex'] = Variable<int>(orderIndex);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    return map;
  }

  TemplateExercisesCompanion toCompanion(bool nullToAbsent) {
    return TemplateExercisesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      id: Value(id),
      templateId: Value(templateId),
      exerciseId: Value(exerciseId),
      orderIndex: Value(orderIndex),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
    );
  }

  factory TemplateExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplateExercise(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      comment: serializer.fromJson<String?>(json['comment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'comment': serializer.toJson<String?>(comment),
    };
  }

  TemplateExercise copyWith({
    String? createdAt,
    String? updatedAt,
    bool? isDeleted,
    String? id,
    String? templateId,
    String? exerciseId,
    int? orderIndex,
    Value<String?> comment = const Value.absent(),
  }) => TemplateExercise(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    exerciseId: exerciseId ?? this.exerciseId,
    orderIndex: orderIndex ?? this.orderIndex,
    comment: comment.present ? comment.value : this.comment,
  );
  TemplateExercise copyWithCompanion(TemplateExercisesCompanion data) {
    return TemplateExercise(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      comment: data.comment.present ? data.comment.value : this.comment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateExercise(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('comment: $comment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    isDeleted,
    id,
    templateId,
    exerciseId,
    orderIndex,
    comment,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateExercise &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.exerciseId == this.exerciseId &&
          other.orderIndex == this.orderIndex &&
          other.comment == this.comment);
}

class TemplateExercisesCompanion extends UpdateCompanion<TemplateExercise> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> templateId;
  final Value<String> exerciseId;
  final Value<int> orderIndex;
  final Value<String?> comment;
  final Value<int> rowid;
  const TemplateExercisesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.comment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TemplateExercisesCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.isDeleted = const Value.absent(),
    required String id,
    required String templateId,
    required String exerciseId,
    required int orderIndex,
    this.comment = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       templateId = Value(templateId),
       exerciseId = Value(exerciseId),
       orderIndex = Value(orderIndex);
  static Insertable<TemplateExercise> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? exerciseId,
    Expression<int>? orderIndex,
    Expression<String>? comment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (isDeleted != null) 'isDeleted': isDeleted,
      if (id != null) 'id': id,
      if (templateId != null) 'templateId': templateId,
      if (exerciseId != null) 'exerciseId': exerciseId,
      if (orderIndex != null) 'orderIndex': orderIndex,
      if (comment != null) 'comment': comment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemplateExercisesCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<bool>? isDeleted,
    Value<String>? id,
    Value<String>? templateId,
    Value<String>? exerciseId,
    Value<int>? orderIndex,
    Value<String?>? comment,
    Value<int>? rowid,
  }) {
    return TemplateExercisesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
      comment: comment ?? this.comment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['createdAt'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updatedAt'] = Variable<String>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['isDeleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['templateId'] = Variable<String>(templateId.value);
    }
    if (exerciseId.present) {
      map['exerciseId'] = Variable<String>(exerciseId.value);
    }
    if (orderIndex.present) {
      map['orderIndex'] = Variable<int>(orderIndex.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplateExercisesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('comment: $comment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TemplateSetsTable extends TemplateSets
    with TableInfo<$TemplateSetsTable, TemplateSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplateSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'createdAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updatedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'isDeleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isDeleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateExerciseIdMeta =
      const VerificationMeta('templateExerciseId');
  @override
  late final GeneratedColumn<String> templateExerciseId =
      GeneratedColumn<String>(
        'templateExerciseId',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES TemplateExercises (id)',
        ),
      );
  static const VerificationMeta _setNumberMeta = const VerificationMeta(
    'setNumber',
  );
  @override
  late final GeneratedColumn<int> setNumber = GeneratedColumn<int>(
    'setNumber',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedWeightKgMeta = const VerificationMeta(
    'plannedWeightKg',
  );
  @override
  late final GeneratedColumn<double> plannedWeightKg = GeneratedColumn<double>(
    'plannedWeightKg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedRepsMeta = const VerificationMeta(
    'plannedReps',
  );
  @override
  late final GeneratedColumn<int> plannedReps = GeneratedColumn<int>(
    'plannedReps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedDurationSecMeta =
      const VerificationMeta('plannedDurationSec');
  @override
  late final GeneratedColumn<int> plannedDurationSec = GeneratedColumn<int>(
    'plannedDurationSec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedDistanceMMeta = const VerificationMeta(
    'plannedDistanceM',
  );
  @override
  late final GeneratedColumn<double> plannedDistanceM = GeneratedColumn<double>(
    'plannedDistanceM',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'none\' CHECK (side IN (\'none\', \'left\', \'right\', \'both\'))',
    defaultValue: const CustomExpression('\'none\''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    isDeleted,
    id,
    templateExerciseId,
    setNumber,
    plannedWeightKg,
    plannedReps,
    plannedDurationSec,
    plannedDistanceM,
    side,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'TemplateSets';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemplateSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('createdAt')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['createdAt']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updatedAt')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updatedAt']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('isDeleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['isDeleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('templateExerciseId')) {
      context.handle(
        _templateExerciseIdMeta,
        templateExerciseId.isAcceptableOrUnknown(
          data['templateExerciseId']!,
          _templateExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templateExerciseIdMeta);
    }
    if (data.containsKey('setNumber')) {
      context.handle(
        _setNumberMeta,
        setNumber.isAcceptableOrUnknown(data['setNumber']!, _setNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_setNumberMeta);
    }
    if (data.containsKey('plannedWeightKg')) {
      context.handle(
        _plannedWeightKgMeta,
        plannedWeightKg.isAcceptableOrUnknown(
          data['plannedWeightKg']!,
          _plannedWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('plannedReps')) {
      context.handle(
        _plannedRepsMeta,
        plannedReps.isAcceptableOrUnknown(
          data['plannedReps']!,
          _plannedRepsMeta,
        ),
      );
    }
    if (data.containsKey('plannedDurationSec')) {
      context.handle(
        _plannedDurationSecMeta,
        plannedDurationSec.isAcceptableOrUnknown(
          data['plannedDurationSec']!,
          _plannedDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('plannedDistanceM')) {
      context.handle(
        _plannedDistanceMMeta,
        plannedDistanceM.isAcceptableOrUnknown(
          data['plannedDistanceM']!,
          _plannedDistanceMMeta,
        ),
      );
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemplateSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateSet(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}createdAt'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updatedAt'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isDeleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      templateExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}templateExerciseId'],
      )!,
      setNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}setNumber'],
      )!,
      plannedWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}plannedWeightKg'],
      ),
      plannedReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plannedReps'],
      ),
      plannedDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plannedDurationSec'],
      ),
      plannedDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}plannedDistanceM'],
      ),
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      )!,
    );
  }

  @override
  $TemplateSetsTable createAlias(String alias) {
    return $TemplateSetsTable(attachedDatabase, alias);
  }
}

class TemplateSet extends DataClass implements Insertable<TemplateSet> {
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  final String id;
  final String templateExerciseId;
  final int setNumber;
  final double? plannedWeightKg;
  final int? plannedReps;
  final int? plannedDurationSec;
  final double? plannedDistanceM;
  final String side;
  const TemplateSet({
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.id,
    required this.templateExerciseId,
    required this.setNumber,
    this.plannedWeightKg,
    this.plannedReps,
    this.plannedDurationSec,
    this.plannedDistanceM,
    required this.side,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['createdAt'] = Variable<String>(createdAt);
    map['updatedAt'] = Variable<String>(updatedAt);
    map['isDeleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['templateExerciseId'] = Variable<String>(templateExerciseId);
    map['setNumber'] = Variable<int>(setNumber);
    if (!nullToAbsent || plannedWeightKg != null) {
      map['plannedWeightKg'] = Variable<double>(plannedWeightKg);
    }
    if (!nullToAbsent || plannedReps != null) {
      map['plannedReps'] = Variable<int>(plannedReps);
    }
    if (!nullToAbsent || plannedDurationSec != null) {
      map['plannedDurationSec'] = Variable<int>(plannedDurationSec);
    }
    if (!nullToAbsent || plannedDistanceM != null) {
      map['plannedDistanceM'] = Variable<double>(plannedDistanceM);
    }
    map['side'] = Variable<String>(side);
    return map;
  }

  TemplateSetsCompanion toCompanion(bool nullToAbsent) {
    return TemplateSetsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      id: Value(id),
      templateExerciseId: Value(templateExerciseId),
      setNumber: Value(setNumber),
      plannedWeightKg: plannedWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedWeightKg),
      plannedReps: plannedReps == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedReps),
      plannedDurationSec: plannedDurationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedDurationSec),
      plannedDistanceM: plannedDistanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedDistanceM),
      side: Value(side),
    );
  }

  factory TemplateSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplateSet(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      templateExerciseId: serializer.fromJson<String>(
        json['templateExerciseId'],
      ),
      setNumber: serializer.fromJson<int>(json['setNumber']),
      plannedWeightKg: serializer.fromJson<double?>(json['plannedWeightKg']),
      plannedReps: serializer.fromJson<int?>(json['plannedReps']),
      plannedDurationSec: serializer.fromJson<int?>(json['plannedDurationSec']),
      plannedDistanceM: serializer.fromJson<double?>(json['plannedDistanceM']),
      side: serializer.fromJson<String>(json['side']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'templateExerciseId': serializer.toJson<String>(templateExerciseId),
      'setNumber': serializer.toJson<int>(setNumber),
      'plannedWeightKg': serializer.toJson<double?>(plannedWeightKg),
      'plannedReps': serializer.toJson<int?>(plannedReps),
      'plannedDurationSec': serializer.toJson<int?>(plannedDurationSec),
      'plannedDistanceM': serializer.toJson<double?>(plannedDistanceM),
      'side': serializer.toJson<String>(side),
    };
  }

  TemplateSet copyWith({
    String? createdAt,
    String? updatedAt,
    bool? isDeleted,
    String? id,
    String? templateExerciseId,
    int? setNumber,
    Value<double?> plannedWeightKg = const Value.absent(),
    Value<int?> plannedReps = const Value.absent(),
    Value<int?> plannedDurationSec = const Value.absent(),
    Value<double?> plannedDistanceM = const Value.absent(),
    String? side,
  }) => TemplateSet(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    id: id ?? this.id,
    templateExerciseId: templateExerciseId ?? this.templateExerciseId,
    setNumber: setNumber ?? this.setNumber,
    plannedWeightKg: plannedWeightKg.present
        ? plannedWeightKg.value
        : this.plannedWeightKg,
    plannedReps: plannedReps.present ? plannedReps.value : this.plannedReps,
    plannedDurationSec: plannedDurationSec.present
        ? plannedDurationSec.value
        : this.plannedDurationSec,
    plannedDistanceM: plannedDistanceM.present
        ? plannedDistanceM.value
        : this.plannedDistanceM,
    side: side ?? this.side,
  );
  TemplateSet copyWithCompanion(TemplateSetsCompanion data) {
    return TemplateSet(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      templateExerciseId: data.templateExerciseId.present
          ? data.templateExerciseId.value
          : this.templateExerciseId,
      setNumber: data.setNumber.present ? data.setNumber.value : this.setNumber,
      plannedWeightKg: data.plannedWeightKg.present
          ? data.plannedWeightKg.value
          : this.plannedWeightKg,
      plannedReps: data.plannedReps.present
          ? data.plannedReps.value
          : this.plannedReps,
      plannedDurationSec: data.plannedDurationSec.present
          ? data.plannedDurationSec.value
          : this.plannedDurationSec,
      plannedDistanceM: data.plannedDistanceM.present
          ? data.plannedDistanceM.value
          : this.plannedDistanceM,
      side: data.side.present ? data.side.value : this.side,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateSet(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('templateExerciseId: $templateExerciseId, ')
          ..write('setNumber: $setNumber, ')
          ..write('plannedWeightKg: $plannedWeightKg, ')
          ..write('plannedReps: $plannedReps, ')
          ..write('plannedDurationSec: $plannedDurationSec, ')
          ..write('plannedDistanceM: $plannedDistanceM, ')
          ..write('side: $side')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    isDeleted,
    id,
    templateExerciseId,
    setNumber,
    plannedWeightKg,
    plannedReps,
    plannedDurationSec,
    plannedDistanceM,
    side,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateSet &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.templateExerciseId == this.templateExerciseId &&
          other.setNumber == this.setNumber &&
          other.plannedWeightKg == this.plannedWeightKg &&
          other.plannedReps == this.plannedReps &&
          other.plannedDurationSec == this.plannedDurationSec &&
          other.plannedDistanceM == this.plannedDistanceM &&
          other.side == this.side);
}

class TemplateSetsCompanion extends UpdateCompanion<TemplateSet> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> templateExerciseId;
  final Value<int> setNumber;
  final Value<double?> plannedWeightKg;
  final Value<int?> plannedReps;
  final Value<int?> plannedDurationSec;
  final Value<double?> plannedDistanceM;
  final Value<String> side;
  final Value<int> rowid;
  const TemplateSetsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.templateExerciseId = const Value.absent(),
    this.setNumber = const Value.absent(),
    this.plannedWeightKg = const Value.absent(),
    this.plannedReps = const Value.absent(),
    this.plannedDurationSec = const Value.absent(),
    this.plannedDistanceM = const Value.absent(),
    this.side = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TemplateSetsCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.isDeleted = const Value.absent(),
    required String id,
    required String templateExerciseId,
    required int setNumber,
    this.plannedWeightKg = const Value.absent(),
    this.plannedReps = const Value.absent(),
    this.plannedDurationSec = const Value.absent(),
    this.plannedDistanceM = const Value.absent(),
    this.side = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       templateExerciseId = Value(templateExerciseId),
       setNumber = Value(setNumber);
  static Insertable<TemplateSet> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? templateExerciseId,
    Expression<int>? setNumber,
    Expression<double>? plannedWeightKg,
    Expression<int>? plannedReps,
    Expression<int>? plannedDurationSec,
    Expression<double>? plannedDistanceM,
    Expression<String>? side,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (isDeleted != null) 'isDeleted': isDeleted,
      if (id != null) 'id': id,
      if (templateExerciseId != null) 'templateExerciseId': templateExerciseId,
      if (setNumber != null) 'setNumber': setNumber,
      if (plannedWeightKg != null) 'plannedWeightKg': plannedWeightKg,
      if (plannedReps != null) 'plannedReps': plannedReps,
      if (plannedDurationSec != null) 'plannedDurationSec': plannedDurationSec,
      if (plannedDistanceM != null) 'plannedDistanceM': plannedDistanceM,
      if (side != null) 'side': side,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemplateSetsCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<bool>? isDeleted,
    Value<String>? id,
    Value<String>? templateExerciseId,
    Value<int>? setNumber,
    Value<double?>? plannedWeightKg,
    Value<int?>? plannedReps,
    Value<int?>? plannedDurationSec,
    Value<double?>? plannedDistanceM,
    Value<String>? side,
    Value<int>? rowid,
  }) {
    return TemplateSetsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      templateExerciseId: templateExerciseId ?? this.templateExerciseId,
      setNumber: setNumber ?? this.setNumber,
      plannedWeightKg: plannedWeightKg ?? this.plannedWeightKg,
      plannedReps: plannedReps ?? this.plannedReps,
      plannedDurationSec: plannedDurationSec ?? this.plannedDurationSec,
      plannedDistanceM: plannedDistanceM ?? this.plannedDistanceM,
      side: side ?? this.side,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['createdAt'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updatedAt'] = Variable<String>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['isDeleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateExerciseId.present) {
      map['templateExerciseId'] = Variable<String>(templateExerciseId.value);
    }
    if (setNumber.present) {
      map['setNumber'] = Variable<int>(setNumber.value);
    }
    if (plannedWeightKg.present) {
      map['plannedWeightKg'] = Variable<double>(plannedWeightKg.value);
    }
    if (plannedReps.present) {
      map['plannedReps'] = Variable<int>(plannedReps.value);
    }
    if (plannedDurationSec.present) {
      map['plannedDurationSec'] = Variable<int>(plannedDurationSec.value);
    }
    if (plannedDistanceM.present) {
      map['plannedDistanceM'] = Variable<double>(plannedDistanceM.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplateSetsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('templateExerciseId: $templateExerciseId, ')
          ..write('setNumber: $setNumber, ')
          ..write('plannedWeightKg: $plannedWeightKg, ')
          ..write('plannedReps: $plannedReps, ')
          ..write('plannedDurationSec: $plannedDurationSec, ')
          ..write('plannedDistanceM: $plannedDistanceM, ')
          ..write('side: $side, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BodyMeasurementsTable extends BodyMeasurements
    with TableInfo<$BodyMeasurementsTable, BodyMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'createdAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updatedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'isDeleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isDeleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measurementTypeIdMeta = const VerificationMeta(
    'measurementTypeId',
  );
  @override
  late final GeneratedColumn<String> measurementTypeId =
      GeneratedColumn<String>(
        'measurementTypeId',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES MeasurementTypes (id)',
        ),
      );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMetricMeta = const VerificationMeta(
    'valueMetric',
  );
  @override
  late final GeneratedColumn<double> valueMetric = GeneratedColumn<double>(
    'valueMetric',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'manual\' CHECK (source IN (\'manual\', \'import\', \'health\'))',
    defaultValue: const CustomExpression('\'manual\''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    isDeleted,
    id,
    measurementTypeId,
    date,
    valueMetric,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'BodyMeasurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyMeasurement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('createdAt')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['createdAt']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updatedAt')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updatedAt']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('isDeleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['isDeleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('measurementTypeId')) {
      context.handle(
        _measurementTypeIdMeta,
        measurementTypeId.isAcceptableOrUnknown(
          data['measurementTypeId']!,
          _measurementTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_measurementTypeIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('valueMetric')) {
      context.handle(
        _valueMetricMeta,
        valueMetric.isAcceptableOrUnknown(
          data['valueMetric']!,
          _valueMetricMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valueMetricMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyMeasurement(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}createdAt'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updatedAt'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isDeleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      measurementTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}measurementTypeId'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      valueMetric: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valueMetric'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $BodyMeasurementsTable createAlias(String alias) {
    return $BodyMeasurementsTable(attachedDatabase, alias);
  }
}

class BodyMeasurement extends DataClass implements Insertable<BodyMeasurement> {
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  final String id;
  final String measurementTypeId;

  /// Local calendar date `YYYY-MM-DD`.
  final String date;
  final double valueMetric;
  final String source;
  const BodyMeasurement({
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.id,
    required this.measurementTypeId,
    required this.date,
    required this.valueMetric,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['createdAt'] = Variable<String>(createdAt);
    map['updatedAt'] = Variable<String>(updatedAt);
    map['isDeleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['measurementTypeId'] = Variable<String>(measurementTypeId);
    map['date'] = Variable<String>(date);
    map['valueMetric'] = Variable<double>(valueMetric);
    map['source'] = Variable<String>(source);
    return map;
  }

  BodyMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return BodyMeasurementsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      id: Value(id),
      measurementTypeId: Value(measurementTypeId),
      date: Value(date),
      valueMetric: Value(valueMetric),
      source: Value(source),
    );
  }

  factory BodyMeasurement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyMeasurement(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      measurementTypeId: serializer.fromJson<String>(json['measurementTypeId']),
      date: serializer.fromJson<String>(json['date']),
      valueMetric: serializer.fromJson<double>(json['valueMetric']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'measurementTypeId': serializer.toJson<String>(measurementTypeId),
      'date': serializer.toJson<String>(date),
      'valueMetric': serializer.toJson<double>(valueMetric),
      'source': serializer.toJson<String>(source),
    };
  }

  BodyMeasurement copyWith({
    String? createdAt,
    String? updatedAt,
    bool? isDeleted,
    String? id,
    String? measurementTypeId,
    String? date,
    double? valueMetric,
    String? source,
  }) => BodyMeasurement(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    id: id ?? this.id,
    measurementTypeId: measurementTypeId ?? this.measurementTypeId,
    date: date ?? this.date,
    valueMetric: valueMetric ?? this.valueMetric,
    source: source ?? this.source,
  );
  BodyMeasurement copyWithCompanion(BodyMeasurementsCompanion data) {
    return BodyMeasurement(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      measurementTypeId: data.measurementTypeId.present
          ? data.measurementTypeId.value
          : this.measurementTypeId,
      date: data.date.present ? data.date.value : this.date,
      valueMetric: data.valueMetric.present
          ? data.valueMetric.value
          : this.valueMetric,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurement(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('measurementTypeId: $measurementTypeId, ')
          ..write('date: $date, ')
          ..write('valueMetric: $valueMetric, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    isDeleted,
    id,
    measurementTypeId,
    date,
    valueMetric,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyMeasurement &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.measurementTypeId == this.measurementTypeId &&
          other.date == this.date &&
          other.valueMetric == this.valueMetric &&
          other.source == this.source);
}

class BodyMeasurementsCompanion extends UpdateCompanion<BodyMeasurement> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> measurementTypeId;
  final Value<String> date;
  final Value<double> valueMetric;
  final Value<String> source;
  final Value<int> rowid;
  const BodyMeasurementsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.measurementTypeId = const Value.absent(),
    this.date = const Value.absent(),
    this.valueMetric = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BodyMeasurementsCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.isDeleted = const Value.absent(),
    required String id,
    required String measurementTypeId,
    required String date,
    required double valueMetric,
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       measurementTypeId = Value(measurementTypeId),
       date = Value(date),
       valueMetric = Value(valueMetric);
  static Insertable<BodyMeasurement> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? measurementTypeId,
    Expression<String>? date,
    Expression<double>? valueMetric,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (isDeleted != null) 'isDeleted': isDeleted,
      if (id != null) 'id': id,
      if (measurementTypeId != null) 'measurementTypeId': measurementTypeId,
      if (date != null) 'date': date,
      if (valueMetric != null) 'valueMetric': valueMetric,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BodyMeasurementsCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<bool>? isDeleted,
    Value<String>? id,
    Value<String>? measurementTypeId,
    Value<String>? date,
    Value<double>? valueMetric,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return BodyMeasurementsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      measurementTypeId: measurementTypeId ?? this.measurementTypeId,
      date: date ?? this.date,
      valueMetric: valueMetric ?? this.valueMetric,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['createdAt'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updatedAt'] = Variable<String>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['isDeleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (measurementTypeId.present) {
      map['measurementTypeId'] = Variable<String>(measurementTypeId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (valueMetric.present) {
      map['valueMetric'] = Variable<double>(valueMetric.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('measurementTypeId: $measurementTypeId, ')
          ..write('date: $date, ')
          ..write('valueMetric: $valueMetric, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalRecordsTable extends PersonalRecords
    with TableInfo<$PersonalRecordsTable, PersonalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exerciseId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES Exercises (id)',
    ),
  );
  static const VerificationMeta _recordTypeMeta = const VerificationMeta(
    'recordType',
  );
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
    'recordType',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (recordType IN (\'maxWeight\', \'maxRepsAtWeight\', \'max1RM\', \'maxVolumeWorkout\', \'maxDistance\', \'bestPace\', \'longestDuration\'))',
  );
  static const VerificationMeta _keyValueMeta = const VerificationMeta(
    'keyValue',
  );
  @override
  late final GeneratedColumn<double> keyValue = GeneratedColumn<double>(
    'keyValue',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workoutId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES Workouts (id)',
    ),
  );
  static const VerificationMeta _exerciseSetIdMeta = const VerificationMeta(
    'exerciseSetId',
  );
  @override
  late final GeneratedColumn<String> exerciseSetId = GeneratedColumn<String>(
    'exerciseSetId',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ExerciseSets (id)',
    ),
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
  late final GeneratedColumn<String> achievedAt = GeneratedColumn<String>(
    'achievedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _computedAtMeta = const VerificationMeta(
    'computedAt',
  );
  @override
  late final GeneratedColumn<String> computedAt = GeneratedColumn<String>(
    'computedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    exerciseId,
    recordType,
    keyValue,
    value,
    workoutId,
    exerciseSetId,
    achievedAt,
    computedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'PersonalRecords';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exerciseId')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exerciseId']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('recordType')) {
      context.handle(
        _recordTypeMeta,
        recordType.isAcceptableOrUnknown(data['recordType']!, _recordTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_recordTypeMeta);
    }
    if (data.containsKey('keyValue')) {
      context.handle(
        _keyValueMeta,
        keyValue.isAcceptableOrUnknown(data['keyValue']!, _keyValueMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('workoutId')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workoutId']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('exerciseSetId')) {
      context.handle(
        _exerciseSetIdMeta,
        exerciseSetId.isAcceptableOrUnknown(
          data['exerciseSetId']!,
          _exerciseSetIdMeta,
        ),
      );
    }
    if (data.containsKey('achievedAt')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achievedAt']!, _achievedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_achievedAtMeta);
    }
    if (data.containsKey('computedAt')) {
      context.handle(
        _computedAtMeta,
        computedAt.isAcceptableOrUnknown(data['computedAt']!, _computedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_computedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId, recordType, keyValue};
  @override
  PersonalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalRecord(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exerciseId'],
      )!,
      recordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recordType'],
      )!,
      keyValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}keyValue'],
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workoutId'],
      )!,
      exerciseSetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exerciseSetId'],
      ),
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}achievedAt'],
      )!,
      computedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}computedAt'],
      )!,
    );
  }

  @override
  $PersonalRecordsTable createAlias(String alias) {
    return $PersonalRecordsTable(attachedDatabase, alias);
  }
}

class PersonalRecord extends DataClass implements Insertable<PersonalRecord> {
  final String exerciseId;
  final String recordType;
  final double? keyValue;
  final double value;
  final String workoutId;
  final String? exerciseSetId;

  /// Local calendar date `YYYY-MM-DD` of the source workout.
  final String achievedAt;
  final String computedAt;
  const PersonalRecord({
    required this.exerciseId,
    required this.recordType,
    this.keyValue,
    required this.value,
    required this.workoutId,
    this.exerciseSetId,
    required this.achievedAt,
    required this.computedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exerciseId'] = Variable<String>(exerciseId);
    map['recordType'] = Variable<String>(recordType);
    if (!nullToAbsent || keyValue != null) {
      map['keyValue'] = Variable<double>(keyValue);
    }
    map['value'] = Variable<double>(value);
    map['workoutId'] = Variable<String>(workoutId);
    if (!nullToAbsent || exerciseSetId != null) {
      map['exerciseSetId'] = Variable<String>(exerciseSetId);
    }
    map['achievedAt'] = Variable<String>(achievedAt);
    map['computedAt'] = Variable<String>(computedAt);
    return map;
  }

  PersonalRecordsCompanion toCompanion(bool nullToAbsent) {
    return PersonalRecordsCompanion(
      exerciseId: Value(exerciseId),
      recordType: Value(recordType),
      keyValue: keyValue == null && nullToAbsent
          ? const Value.absent()
          : Value(keyValue),
      value: Value(value),
      workoutId: Value(workoutId),
      exerciseSetId: exerciseSetId == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseSetId),
      achievedAt: Value(achievedAt),
      computedAt: Value(computedAt),
    );
  }

  factory PersonalRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalRecord(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      recordType: serializer.fromJson<String>(json['recordType']),
      keyValue: serializer.fromJson<double?>(json['keyValue']),
      value: serializer.fromJson<double>(json['value']),
      workoutId: serializer.fromJson<String>(json['workoutId']),
      exerciseSetId: serializer.fromJson<String?>(json['exerciseSetId']),
      achievedAt: serializer.fromJson<String>(json['achievedAt']),
      computedAt: serializer.fromJson<String>(json['computedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'recordType': serializer.toJson<String>(recordType),
      'keyValue': serializer.toJson<double?>(keyValue),
      'value': serializer.toJson<double>(value),
      'workoutId': serializer.toJson<String>(workoutId),
      'exerciseSetId': serializer.toJson<String?>(exerciseSetId),
      'achievedAt': serializer.toJson<String>(achievedAt),
      'computedAt': serializer.toJson<String>(computedAt),
    };
  }

  PersonalRecord copyWith({
    String? exerciseId,
    String? recordType,
    Value<double?> keyValue = const Value.absent(),
    double? value,
    String? workoutId,
    Value<String?> exerciseSetId = const Value.absent(),
    String? achievedAt,
    String? computedAt,
  }) => PersonalRecord(
    exerciseId: exerciseId ?? this.exerciseId,
    recordType: recordType ?? this.recordType,
    keyValue: keyValue.present ? keyValue.value : this.keyValue,
    value: value ?? this.value,
    workoutId: workoutId ?? this.workoutId,
    exerciseSetId: exerciseSetId.present
        ? exerciseSetId.value
        : this.exerciseSetId,
    achievedAt: achievedAt ?? this.achievedAt,
    computedAt: computedAt ?? this.computedAt,
  );
  PersonalRecord copyWithCompanion(PersonalRecordsCompanion data) {
    return PersonalRecord(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      keyValue: data.keyValue.present ? data.keyValue.value : this.keyValue,
      value: data.value.present ? data.value.value : this.value,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      exerciseSetId: data.exerciseSetId.present
          ? data.exerciseSetId.value
          : this.exerciseSetId,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
      computedAt: data.computedAt.present
          ? data.computedAt.value
          : this.computedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecord(')
          ..write('exerciseId: $exerciseId, ')
          ..write('recordType: $recordType, ')
          ..write('keyValue: $keyValue, ')
          ..write('value: $value, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseSetId: $exerciseSetId, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('computedAt: $computedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    exerciseId,
    recordType,
    keyValue,
    value,
    workoutId,
    exerciseSetId,
    achievedAt,
    computedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalRecord &&
          other.exerciseId == this.exerciseId &&
          other.recordType == this.recordType &&
          other.keyValue == this.keyValue &&
          other.value == this.value &&
          other.workoutId == this.workoutId &&
          other.exerciseSetId == this.exerciseSetId &&
          other.achievedAt == this.achievedAt &&
          other.computedAt == this.computedAt);
}

class PersonalRecordsCompanion extends UpdateCompanion<PersonalRecord> {
  final Value<String> exerciseId;
  final Value<String> recordType;
  final Value<double?> keyValue;
  final Value<double> value;
  final Value<String> workoutId;
  final Value<String?> exerciseSetId;
  final Value<String> achievedAt;
  final Value<String> computedAt;
  final Value<int> rowid;
  const PersonalRecordsCompanion({
    this.exerciseId = const Value.absent(),
    this.recordType = const Value.absent(),
    this.keyValue = const Value.absent(),
    this.value = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.exerciseSetId = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.computedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalRecordsCompanion.insert({
    required String exerciseId,
    required String recordType,
    this.keyValue = const Value.absent(),
    required double value,
    required String workoutId,
    this.exerciseSetId = const Value.absent(),
    required String achievedAt,
    required String computedAt,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       recordType = Value(recordType),
       value = Value(value),
       workoutId = Value(workoutId),
       achievedAt = Value(achievedAt),
       computedAt = Value(computedAt);
  static Insertable<PersonalRecord> custom({
    Expression<String>? exerciseId,
    Expression<String>? recordType,
    Expression<double>? keyValue,
    Expression<double>? value,
    Expression<String>? workoutId,
    Expression<String>? exerciseSetId,
    Expression<String>? achievedAt,
    Expression<String>? computedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exerciseId': exerciseId,
      if (recordType != null) 'recordType': recordType,
      if (keyValue != null) 'keyValue': keyValue,
      if (value != null) 'value': value,
      if (workoutId != null) 'workoutId': workoutId,
      if (exerciseSetId != null) 'exerciseSetId': exerciseSetId,
      if (achievedAt != null) 'achievedAt': achievedAt,
      if (computedAt != null) 'computedAt': computedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalRecordsCompanion copyWith({
    Value<String>? exerciseId,
    Value<String>? recordType,
    Value<double?>? keyValue,
    Value<double>? value,
    Value<String>? workoutId,
    Value<String?>? exerciseSetId,
    Value<String>? achievedAt,
    Value<String>? computedAt,
    Value<int>? rowid,
  }) {
    return PersonalRecordsCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      recordType: recordType ?? this.recordType,
      keyValue: keyValue ?? this.keyValue,
      value: value ?? this.value,
      workoutId: workoutId ?? this.workoutId,
      exerciseSetId: exerciseSetId ?? this.exerciseSetId,
      achievedAt: achievedAt ?? this.achievedAt,
      computedAt: computedAt ?? this.computedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exerciseId'] = Variable<String>(exerciseId.value);
    }
    if (recordType.present) {
      map['recordType'] = Variable<String>(recordType.value);
    }
    if (keyValue.present) {
      map['keyValue'] = Variable<double>(keyValue.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (workoutId.present) {
      map['workoutId'] = Variable<String>(workoutId.value);
    }
    if (exerciseSetId.present) {
      map['exerciseSetId'] = Variable<String>(exerciseSetId.value);
    }
    if (achievedAt.present) {
      map['achievedAt'] = Variable<String>(achievedAt.value);
    }
    if (computedAt.present) {
      map['computedAt'] = Variable<String>(computedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecordsCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('recordType: $recordType, ')
          ..write('keyValue: $keyValue, ')
          ..write('value: $value, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseSetId: $exerciseSetId, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('computedAt: $computedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseProgressionStatesTable extends ExerciseProgressionStates
    with TableInfo<$ExerciseProgressionStatesTable, ExerciseProgressionState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseProgressionStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exerciseId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES Exercises (id)',
    ),
  );
  static const VerificationMeta _stagnationCountMeta = const VerificationMeta(
    'stagnationCount',
  );
  @override
  late final GeneratedColumn<int> stagnationCount = GeneratedColumn<int>(
    'stagnationCount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastCountedWorkoutIdMeta =
      const VerificationMeta('lastCountedWorkoutId');
  @override
  late final GeneratedColumn<String> lastCountedWorkoutId =
      GeneratedColumn<String>(
        'lastCountedWorkoutId',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES Workouts (id)',
        ),
      );
  static const VerificationMeta _computedAtMeta = const VerificationMeta(
    'computedAt',
  );
  @override
  late final GeneratedColumn<String> computedAt = GeneratedColumn<String>(
    'computedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    exerciseId,
    stagnationCount,
    lastCountedWorkoutId,
    computedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ExerciseProgressionStates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseProgressionState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exerciseId')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exerciseId']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('stagnationCount')) {
      context.handle(
        _stagnationCountMeta,
        stagnationCount.isAcceptableOrUnknown(
          data['stagnationCount']!,
          _stagnationCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stagnationCountMeta);
    }
    if (data.containsKey('lastCountedWorkoutId')) {
      context.handle(
        _lastCountedWorkoutIdMeta,
        lastCountedWorkoutId.isAcceptableOrUnknown(
          data['lastCountedWorkoutId']!,
          _lastCountedWorkoutIdMeta,
        ),
      );
    }
    if (data.containsKey('computedAt')) {
      context.handle(
        _computedAtMeta,
        computedAt.isAcceptableOrUnknown(data['computedAt']!, _computedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_computedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId};
  @override
  ExerciseProgressionState map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseProgressionState(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exerciseId'],
      )!,
      stagnationCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stagnationCount'],
      )!,
      lastCountedWorkoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lastCountedWorkoutId'],
      ),
      computedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}computedAt'],
      )!,
    );
  }

  @override
  $ExerciseProgressionStatesTable createAlias(String alias) {
    return $ExerciseProgressionStatesTable(attachedDatabase, alias);
  }
}

class ExerciseProgressionState extends DataClass
    implements Insertable<ExerciseProgressionState> {
  final String exerciseId;
  final int stagnationCount;
  final String? lastCountedWorkoutId;
  final String computedAt;
  const ExerciseProgressionState({
    required this.exerciseId,
    required this.stagnationCount,
    this.lastCountedWorkoutId,
    required this.computedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exerciseId'] = Variable<String>(exerciseId);
    map['stagnationCount'] = Variable<int>(stagnationCount);
    if (!nullToAbsent || lastCountedWorkoutId != null) {
      map['lastCountedWorkoutId'] = Variable<String>(lastCountedWorkoutId);
    }
    map['computedAt'] = Variable<String>(computedAt);
    return map;
  }

  ExerciseProgressionStatesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseProgressionStatesCompanion(
      exerciseId: Value(exerciseId),
      stagnationCount: Value(stagnationCount),
      lastCountedWorkoutId: lastCountedWorkoutId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCountedWorkoutId),
      computedAt: Value(computedAt),
    );
  }

  factory ExerciseProgressionState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseProgressionState(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      stagnationCount: serializer.fromJson<int>(json['stagnationCount']),
      lastCountedWorkoutId: serializer.fromJson<String?>(
        json['lastCountedWorkoutId'],
      ),
      computedAt: serializer.fromJson<String>(json['computedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'stagnationCount': serializer.toJson<int>(stagnationCount),
      'lastCountedWorkoutId': serializer.toJson<String?>(lastCountedWorkoutId),
      'computedAt': serializer.toJson<String>(computedAt),
    };
  }

  ExerciseProgressionState copyWith({
    String? exerciseId,
    int? stagnationCount,
    Value<String?> lastCountedWorkoutId = const Value.absent(),
    String? computedAt,
  }) => ExerciseProgressionState(
    exerciseId: exerciseId ?? this.exerciseId,
    stagnationCount: stagnationCount ?? this.stagnationCount,
    lastCountedWorkoutId: lastCountedWorkoutId.present
        ? lastCountedWorkoutId.value
        : this.lastCountedWorkoutId,
    computedAt: computedAt ?? this.computedAt,
  );
  ExerciseProgressionState copyWithCompanion(
    ExerciseProgressionStatesCompanion data,
  ) {
    return ExerciseProgressionState(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      stagnationCount: data.stagnationCount.present
          ? data.stagnationCount.value
          : this.stagnationCount,
      lastCountedWorkoutId: data.lastCountedWorkoutId.present
          ? data.lastCountedWorkoutId.value
          : this.lastCountedWorkoutId,
      computedAt: data.computedAt.present
          ? data.computedAt.value
          : this.computedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseProgressionState(')
          ..write('exerciseId: $exerciseId, ')
          ..write('stagnationCount: $stagnationCount, ')
          ..write('lastCountedWorkoutId: $lastCountedWorkoutId, ')
          ..write('computedAt: $computedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    exerciseId,
    stagnationCount,
    lastCountedWorkoutId,
    computedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseProgressionState &&
          other.exerciseId == this.exerciseId &&
          other.stagnationCount == this.stagnationCount &&
          other.lastCountedWorkoutId == this.lastCountedWorkoutId &&
          other.computedAt == this.computedAt);
}

class ExerciseProgressionStatesCompanion
    extends UpdateCompanion<ExerciseProgressionState> {
  final Value<String> exerciseId;
  final Value<int> stagnationCount;
  final Value<String?> lastCountedWorkoutId;
  final Value<String> computedAt;
  final Value<int> rowid;
  const ExerciseProgressionStatesCompanion({
    this.exerciseId = const Value.absent(),
    this.stagnationCount = const Value.absent(),
    this.lastCountedWorkoutId = const Value.absent(),
    this.computedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseProgressionStatesCompanion.insert({
    required String exerciseId,
    required int stagnationCount,
    this.lastCountedWorkoutId = const Value.absent(),
    required String computedAt,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       stagnationCount = Value(stagnationCount),
       computedAt = Value(computedAt);
  static Insertable<ExerciseProgressionState> custom({
    Expression<String>? exerciseId,
    Expression<int>? stagnationCount,
    Expression<String>? lastCountedWorkoutId,
    Expression<String>? computedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exerciseId': exerciseId,
      if (stagnationCount != null) 'stagnationCount': stagnationCount,
      if (lastCountedWorkoutId != null)
        'lastCountedWorkoutId': lastCountedWorkoutId,
      if (computedAt != null) 'computedAt': computedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseProgressionStatesCompanion copyWith({
    Value<String>? exerciseId,
    Value<int>? stagnationCount,
    Value<String?>? lastCountedWorkoutId,
    Value<String>? computedAt,
    Value<int>? rowid,
  }) {
    return ExerciseProgressionStatesCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      stagnationCount: stagnationCount ?? this.stagnationCount,
      lastCountedWorkoutId: lastCountedWorkoutId ?? this.lastCountedWorkoutId,
      computedAt: computedAt ?? this.computedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exerciseId'] = Variable<String>(exerciseId.value);
    }
    if (stagnationCount.present) {
      map['stagnationCount'] = Variable<int>(stagnationCount.value);
    }
    if (lastCountedWorkoutId.present) {
      map['lastCountedWorkoutId'] = Variable<String>(
        lastCountedWorkoutId.value,
      );
    }
    if (computedAt.present) {
      map['computedAt'] = Variable<String>(computedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseProgressionStatesCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('stagnationCount: $stagnationCount, ')
          ..write('lastCountedWorkoutId: $lastCountedWorkoutId, ')
          ..write('computedAt: $computedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitSystemMeta = const VerificationMeta(
    'unitSystem',
  );
  @override
  late final GeneratedColumn<String> unitSystem = GeneratedColumn<String>(
    'unitSystem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'metric\' CHECK (unitSystem IN (\'metric\', \'imperial\'))',
    defaultValue: const CustomExpression('\'metric\''),
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'system\' CHECK (theme IN (\'system\', \'light\', \'dark\'))',
    defaultValue: const CustomExpression('\'system\''),
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'system\' CHECK (locale IN (\'system\', \'ru\', \'en\'))',
    defaultValue: const CustomExpression('\'system\''),
  );
  static const VerificationMeta _showTagsMeta = const VerificationMeta(
    'showTags',
  );
  @override
  late final GeneratedColumn<bool> showTags = GeneratedColumn<bool>(
    'showTags',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("showTags" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _defaultRestTimerSecMeta =
      const VerificationMeta('defaultRestTimerSec');
  @override
  late final GeneratedColumn<int> defaultRestTimerSec = GeneratedColumn<int>(
    'defaultRestTimerSec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(120),
  );
  static const VerificationMeta _restTimerAutoStartMeta =
      const VerificationMeta('restTimerAutoStart');
  @override
  late final GeneratedColumn<bool> restTimerAutoStart = GeneratedColumn<bool>(
    'restTimerAutoStart',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("restTimerAutoStart" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updatedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    unitSystem,
    theme,
    locale,
    showTags,
    defaultRestTimerSec,
    restTimerAutoStart,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'AppSettingsTable';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('unitSystem')) {
      context.handle(
        _unitSystemMeta,
        unitSystem.isAcceptableOrUnknown(data['unitSystem']!, _unitSystemMeta),
      );
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('showTags')) {
      context.handle(
        _showTagsMeta,
        showTags.isAcceptableOrUnknown(data['showTags']!, _showTagsMeta),
      );
    }
    if (data.containsKey('defaultRestTimerSec')) {
      context.handle(
        _defaultRestTimerSecMeta,
        defaultRestTimerSec.isAcceptableOrUnknown(
          data['defaultRestTimerSec']!,
          _defaultRestTimerSecMeta,
        ),
      );
    }
    if (data.containsKey('restTimerAutoStart')) {
      context.handle(
        _restTimerAutoStartMeta,
        restTimerAutoStart.isAcceptableOrUnknown(
          data['restTimerAutoStart']!,
          _restTimerAutoStartMeta,
        ),
      );
    }
    if (data.containsKey('updatedAt')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updatedAt']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      unitSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unitSystem'],
      )!,
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      showTags: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}showTags'],
      )!,
      defaultRestTimerSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}defaultRestTimerSec'],
      )!,
      restTimerAutoStart: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}restTimerAutoStart'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updatedAt'],
      )!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final String id;
  final String unitSystem;
  final String theme;
  final String locale;
  final bool showTags;

  /// Seconds, 10-600 (validated in the service layer). Default 120 (Q-4).
  final int defaultRestTimerSec;
  final bool restTimerAutoStart;
  final String updatedAt;
  const AppSettingsRow({
    required this.id,
    required this.unitSystem,
    required this.theme,
    required this.locale,
    required this.showTags,
    required this.defaultRestTimerSec,
    required this.restTimerAutoStart,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['unitSystem'] = Variable<String>(unitSystem);
    map['theme'] = Variable<String>(theme);
    map['locale'] = Variable<String>(locale);
    map['showTags'] = Variable<bool>(showTags);
    map['defaultRestTimerSec'] = Variable<int>(defaultRestTimerSec);
    map['restTimerAutoStart'] = Variable<bool>(restTimerAutoStart);
    map['updatedAt'] = Variable<String>(updatedAt);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      id: Value(id),
      unitSystem: Value(unitSystem),
      theme: Value(theme),
      locale: Value(locale),
      showTags: Value(showTags),
      defaultRestTimerSec: Value(defaultRestTimerSec),
      restTimerAutoStart: Value(restTimerAutoStart),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<String>(json['id']),
      unitSystem: serializer.fromJson<String>(json['unitSystem']),
      theme: serializer.fromJson<String>(json['theme']),
      locale: serializer.fromJson<String>(json['locale']),
      showTags: serializer.fromJson<bool>(json['showTags']),
      defaultRestTimerSec: serializer.fromJson<int>(
        json['defaultRestTimerSec'],
      ),
      restTimerAutoStart: serializer.fromJson<bool>(json['restTimerAutoStart']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'unitSystem': serializer.toJson<String>(unitSystem),
      'theme': serializer.toJson<String>(theme),
      'locale': serializer.toJson<String>(locale),
      'showTags': serializer.toJson<bool>(showTags),
      'defaultRestTimerSec': serializer.toJson<int>(defaultRestTimerSec),
      'restTimerAutoStart': serializer.toJson<bool>(restTimerAutoStart),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  AppSettingsRow copyWith({
    String? id,
    String? unitSystem,
    String? theme,
    String? locale,
    bool? showTags,
    int? defaultRestTimerSec,
    bool? restTimerAutoStart,
    String? updatedAt,
  }) => AppSettingsRow(
    id: id ?? this.id,
    unitSystem: unitSystem ?? this.unitSystem,
    theme: theme ?? this.theme,
    locale: locale ?? this.locale,
    showTags: showTags ?? this.showTags,
    defaultRestTimerSec: defaultRestTimerSec ?? this.defaultRestTimerSec,
    restTimerAutoStart: restTimerAutoStart ?? this.restTimerAutoStart,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSettingsRow copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      unitSystem: data.unitSystem.present
          ? data.unitSystem.value
          : this.unitSystem,
      theme: data.theme.present ? data.theme.value : this.theme,
      locale: data.locale.present ? data.locale.value : this.locale,
      showTags: data.showTags.present ? data.showTags.value : this.showTags,
      defaultRestTimerSec: data.defaultRestTimerSec.present
          ? data.defaultRestTimerSec.value
          : this.defaultRestTimerSec,
      restTimerAutoStart: data.restTimerAutoStart.present
          ? data.restTimerAutoStart.value
          : this.restTimerAutoStart,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('theme: $theme, ')
          ..write('locale: $locale, ')
          ..write('showTags: $showTags, ')
          ..write('defaultRestTimerSec: $defaultRestTimerSec, ')
          ..write('restTimerAutoStart: $restTimerAutoStart, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    unitSystem,
    theme,
    locale,
    showTags,
    defaultRestTimerSec,
    restTimerAutoStart,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.unitSystem == this.unitSystem &&
          other.theme == this.theme &&
          other.locale == this.locale &&
          other.showTags == this.showTags &&
          other.defaultRestTimerSec == this.defaultRestTimerSec &&
          other.restTimerAutoStart == this.restTimerAutoStart &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<String> id;
  final Value<String> unitSystem;
  final Value<String> theme;
  final Value<String> locale;
  final Value<bool> showTags;
  final Value<int> defaultRestTimerSec;
  final Value<bool> restTimerAutoStart;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const AppSettingsTableCompanion({
    this.id = const Value.absent(),
    this.unitSystem = const Value.absent(),
    this.theme = const Value.absent(),
    this.locale = const Value.absent(),
    this.showTags = const Value.absent(),
    this.defaultRestTimerSec = const Value.absent(),
    this.restTimerAutoStart = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    required String id,
    this.unitSystem = const Value.absent(),
    this.theme = const Value.absent(),
    this.locale = const Value.absent(),
    this.showTags = const Value.absent(),
    this.defaultRestTimerSec = const Value.absent(),
    this.restTimerAutoStart = const Value.absent(),
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt);
  static Insertable<AppSettingsRow> custom({
    Expression<String>? id,
    Expression<String>? unitSystem,
    Expression<String>? theme,
    Expression<String>? locale,
    Expression<bool>? showTags,
    Expression<int>? defaultRestTimerSec,
    Expression<bool>? restTimerAutoStart,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unitSystem != null) 'unitSystem': unitSystem,
      if (theme != null) 'theme': theme,
      if (locale != null) 'locale': locale,
      if (showTags != null) 'showTags': showTags,
      if (defaultRestTimerSec != null)
        'defaultRestTimerSec': defaultRestTimerSec,
      if (restTimerAutoStart != null) 'restTimerAutoStart': restTimerAutoStart,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? unitSystem,
    Value<String>? theme,
    Value<String>? locale,
    Value<bool>? showTags,
    Value<int>? defaultRestTimerSec,
    Value<bool>? restTimerAutoStart,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsTableCompanion(
      id: id ?? this.id,
      unitSystem: unitSystem ?? this.unitSystem,
      theme: theme ?? this.theme,
      locale: locale ?? this.locale,
      showTags: showTags ?? this.showTags,
      defaultRestTimerSec: defaultRestTimerSec ?? this.defaultRestTimerSec,
      restTimerAutoStart: restTimerAutoStart ?? this.restTimerAutoStart,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (unitSystem.present) {
      map['unitSystem'] = Variable<String>(unitSystem.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (showTags.present) {
      map['showTags'] = Variable<bool>(showTags.value);
    }
    if (defaultRestTimerSec.present) {
      map['defaultRestTimerSec'] = Variable<int>(defaultRestTimerSec.value);
    }
    if (restTimerAutoStart.present) {
      map['restTimerAutoStart'] = Variable<bool>(restTimerAutoStart.value);
    }
    if (updatedAt.present) {
      map['updatedAt'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('theme: $theme, ')
          ..write('locale: $locale, ')
          ..write('showTags: $showTags, ')
          ..write('defaultRestTimerSec: $defaultRestTimerSec, ')
          ..write('restTimerAutoStart: $restTimerAutoStart, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportExportOperationsTable extends ImportExportOperations
    with TableInfo<$ImportExportOperationsTable, ImportExportOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportExportOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operationType',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'export\' CHECK (operationType IN (\'export\', \'import\'))',
    defaultValue: const CustomExpression('\'export\''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (status IN (\'inProgress\', \'success\', \'failed\'))',
  );
  static const VerificationMeta _formatVersionMeta = const VerificationMeta(
    'formatVersion',
  );
  @override
  late final GeneratedColumn<int> formatVersion = GeneratedColumn<int>(
    'formatVersion',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<String> startedAt = GeneratedColumn<String>(
    'startedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<String> finishedAt = GeneratedColumn<String>(
    'finishedAt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemCountsJsonMeta = const VerificationMeta(
    'itemCountsJson',
  );
  @override
  late final GeneratedColumn<String> itemCountsJson = GeneratedColumn<String>(
    'itemCountsJson',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorSummaryMeta = const VerificationMeta(
    'errorSummary',
  );
  @override
  late final GeneratedColumn<String> errorSummary = GeneratedColumn<String>(
    'errorSummary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operationType,
    status,
    formatVersion,
    startedAt,
    finishedAt,
    itemCountsJson,
    errorSummary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ImportExportOperations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportExportOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('operationType')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operationType']!,
          _operationTypeMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('formatVersion')) {
      context.handle(
        _formatVersionMeta,
        formatVersion.isAcceptableOrUnknown(
          data['formatVersion']!,
          _formatVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_formatVersionMeta);
    }
    if (data.containsKey('startedAt')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['startedAt']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finishedAt')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finishedAt']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('itemCountsJson')) {
      context.handle(
        _itemCountsJsonMeta,
        itemCountsJson.isAcceptableOrUnknown(
          data['itemCountsJson']!,
          _itemCountsJsonMeta,
        ),
      );
    }
    if (data.containsKey('errorSummary')) {
      context.handle(
        _errorSummaryMeta,
        errorSummary.isAcceptableOrUnknown(
          data['errorSummary']!,
          _errorSummaryMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportExportOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportExportOperation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operationType'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      formatVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}formatVersion'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}startedAt'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finishedAt'],
      ),
      itemCountsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}itemCountsJson'],
      ),
      errorSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}errorSummary'],
      ),
    );
  }

  @override
  $ImportExportOperationsTable createAlias(String alias) {
    return $ImportExportOperationsTable(attachedDatabase, alias);
  }
}

class ImportExportOperation extends DataClass
    implements Insertable<ImportExportOperation> {
  final String id;
  final String operationType;
  final String status;
  final int formatVersion;
  final String startedAt;
  final String? finishedAt;
  final String? itemCountsJson;
  final String? errorSummary;
  const ImportExportOperation({
    required this.id,
    required this.operationType,
    required this.status,
    required this.formatVersion,
    required this.startedAt,
    this.finishedAt,
    this.itemCountsJson,
    this.errorSummary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['operationType'] = Variable<String>(operationType);
    map['status'] = Variable<String>(status);
    map['formatVersion'] = Variable<int>(formatVersion);
    map['startedAt'] = Variable<String>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finishedAt'] = Variable<String>(finishedAt);
    }
    if (!nullToAbsent || itemCountsJson != null) {
      map['itemCountsJson'] = Variable<String>(itemCountsJson);
    }
    if (!nullToAbsent || errorSummary != null) {
      map['errorSummary'] = Variable<String>(errorSummary);
    }
    return map;
  }

  ImportExportOperationsCompanion toCompanion(bool nullToAbsent) {
    return ImportExportOperationsCompanion(
      id: Value(id),
      operationType: Value(operationType),
      status: Value(status),
      formatVersion: Value(formatVersion),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      itemCountsJson: itemCountsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(itemCountsJson),
      errorSummary: errorSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(errorSummary),
    );
  }

  factory ImportExportOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportExportOperation(
      id: serializer.fromJson<String>(json['id']),
      operationType: serializer.fromJson<String>(json['operationType']),
      status: serializer.fromJson<String>(json['status']),
      formatVersion: serializer.fromJson<int>(json['formatVersion']),
      startedAt: serializer.fromJson<String>(json['startedAt']),
      finishedAt: serializer.fromJson<String?>(json['finishedAt']),
      itemCountsJson: serializer.fromJson<String?>(json['itemCountsJson']),
      errorSummary: serializer.fromJson<String?>(json['errorSummary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'operationType': serializer.toJson<String>(operationType),
      'status': serializer.toJson<String>(status),
      'formatVersion': serializer.toJson<int>(formatVersion),
      'startedAt': serializer.toJson<String>(startedAt),
      'finishedAt': serializer.toJson<String?>(finishedAt),
      'itemCountsJson': serializer.toJson<String?>(itemCountsJson),
      'errorSummary': serializer.toJson<String?>(errorSummary),
    };
  }

  ImportExportOperation copyWith({
    String? id,
    String? operationType,
    String? status,
    int? formatVersion,
    String? startedAt,
    Value<String?> finishedAt = const Value.absent(),
    Value<String?> itemCountsJson = const Value.absent(),
    Value<String?> errorSummary = const Value.absent(),
  }) => ImportExportOperation(
    id: id ?? this.id,
    operationType: operationType ?? this.operationType,
    status: status ?? this.status,
    formatVersion: formatVersion ?? this.formatVersion,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    itemCountsJson: itemCountsJson.present
        ? itemCountsJson.value
        : this.itemCountsJson,
    errorSummary: errorSummary.present ? errorSummary.value : this.errorSummary,
  );
  ImportExportOperation copyWithCompanion(
    ImportExportOperationsCompanion data,
  ) {
    return ImportExportOperation(
      id: data.id.present ? data.id.value : this.id,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      status: data.status.present ? data.status.value : this.status,
      formatVersion: data.formatVersion.present
          ? data.formatVersion.value
          : this.formatVersion,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      itemCountsJson: data.itemCountsJson.present
          ? data.itemCountsJson.value
          : this.itemCountsJson,
      errorSummary: data.errorSummary.present
          ? data.errorSummary.value
          : this.errorSummary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportExportOperation(')
          ..write('id: $id, ')
          ..write('operationType: $operationType, ')
          ..write('status: $status, ')
          ..write('formatVersion: $formatVersion, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('itemCountsJson: $itemCountsJson, ')
          ..write('errorSummary: $errorSummary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operationType,
    status,
    formatVersion,
    startedAt,
    finishedAt,
    itemCountsJson,
    errorSummary,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportExportOperation &&
          other.id == this.id &&
          other.operationType == this.operationType &&
          other.status == this.status &&
          other.formatVersion == this.formatVersion &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.itemCountsJson == this.itemCountsJson &&
          other.errorSummary == this.errorSummary);
}

class ImportExportOperationsCompanion
    extends UpdateCompanion<ImportExportOperation> {
  final Value<String> id;
  final Value<String> operationType;
  final Value<String> status;
  final Value<int> formatVersion;
  final Value<String> startedAt;
  final Value<String?> finishedAt;
  final Value<String?> itemCountsJson;
  final Value<String?> errorSummary;
  final Value<int> rowid;
  const ImportExportOperationsCompanion({
    this.id = const Value.absent(),
    this.operationType = const Value.absent(),
    this.status = const Value.absent(),
    this.formatVersion = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.itemCountsJson = const Value.absent(),
    this.errorSummary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportExportOperationsCompanion.insert({
    required String id,
    this.operationType = const Value.absent(),
    required String status,
    required int formatVersion,
    required String startedAt,
    this.finishedAt = const Value.absent(),
    this.itemCountsJson = const Value.absent(),
    this.errorSummary = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       status = Value(status),
       formatVersion = Value(formatVersion),
       startedAt = Value(startedAt);
  static Insertable<ImportExportOperation> custom({
    Expression<String>? id,
    Expression<String>? operationType,
    Expression<String>? status,
    Expression<int>? formatVersion,
    Expression<String>? startedAt,
    Expression<String>? finishedAt,
    Expression<String>? itemCountsJson,
    Expression<String>? errorSummary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationType != null) 'operationType': operationType,
      if (status != null) 'status': status,
      if (formatVersion != null) 'formatVersion': formatVersion,
      if (startedAt != null) 'startedAt': startedAt,
      if (finishedAt != null) 'finishedAt': finishedAt,
      if (itemCountsJson != null) 'itemCountsJson': itemCountsJson,
      if (errorSummary != null) 'errorSummary': errorSummary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportExportOperationsCompanion copyWith({
    Value<String>? id,
    Value<String>? operationType,
    Value<String>? status,
    Value<int>? formatVersion,
    Value<String>? startedAt,
    Value<String?>? finishedAt,
    Value<String?>? itemCountsJson,
    Value<String?>? errorSummary,
    Value<int>? rowid,
  }) {
    return ImportExportOperationsCompanion(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      status: status ?? this.status,
      formatVersion: formatVersion ?? this.formatVersion,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      itemCountsJson: itemCountsJson ?? this.itemCountsJson,
      errorSummary: errorSummary ?? this.errorSummary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (operationType.present) {
      map['operationType'] = Variable<String>(operationType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (formatVersion.present) {
      map['formatVersion'] = Variable<int>(formatVersion.value);
    }
    if (startedAt.present) {
      map['startedAt'] = Variable<String>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finishedAt'] = Variable<String>(finishedAt.value);
    }
    if (itemCountsJson.present) {
      map['itemCountsJson'] = Variable<String>(itemCountsJson.value);
    }
    if (errorSummary.present) {
      map['errorSummary'] = Variable<String>(errorSummary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportExportOperationsCompanion(')
          ..write('id: $id, ')
          ..write('operationType: $operationType, ')
          ..write('status: $status, ')
          ..write('formatVersion: $formatVersion, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('itemCountsJson: $itemCountsJson, ')
          ..write('errorSummary: $errorSummary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeedInfoTableTable extends SeedInfoTable
    with TableInfo<$SeedInfoTableTable, SeedInfoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeedInfoTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _seedVersionMeta = const VerificationMeta(
    'seedVersion',
  );
  @override
  late final GeneratedColumn<int> seedVersion = GeneratedColumn<int>(
    'seedVersion',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, seedVersion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'SeedInfoTable';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeedInfoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('seedVersion')) {
      context.handle(
        _seedVersionMeta,
        seedVersion.isAcceptableOrUnknown(
          data['seedVersion']!,
          _seedVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_seedVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SeedInfoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeedInfoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      seedVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seedVersion'],
      )!,
    );
  }

  @override
  $SeedInfoTableTable createAlias(String alias) {
    return $SeedInfoTableTable(attachedDatabase, alias);
  }
}

class SeedInfoRow extends DataClass implements Insertable<SeedInfoRow> {
  final int id;
  final int seedVersion;
  const SeedInfoRow({required this.id, required this.seedVersion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['seedVersion'] = Variable<int>(seedVersion);
    return map;
  }

  SeedInfoTableCompanion toCompanion(bool nullToAbsent) {
    return SeedInfoTableCompanion(
      id: Value(id),
      seedVersion: Value(seedVersion),
    );
  }

  factory SeedInfoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeedInfoRow(
      id: serializer.fromJson<int>(json['id']),
      seedVersion: serializer.fromJson<int>(json['seedVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'seedVersion': serializer.toJson<int>(seedVersion),
    };
  }

  SeedInfoRow copyWith({int? id, int? seedVersion}) => SeedInfoRow(
    id: id ?? this.id,
    seedVersion: seedVersion ?? this.seedVersion,
  );
  SeedInfoRow copyWithCompanion(SeedInfoTableCompanion data) {
    return SeedInfoRow(
      id: data.id.present ? data.id.value : this.id,
      seedVersion: data.seedVersion.present
          ? data.seedVersion.value
          : this.seedVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeedInfoRow(')
          ..write('id: $id, ')
          ..write('seedVersion: $seedVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, seedVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeedInfoRow &&
          other.id == this.id &&
          other.seedVersion == this.seedVersion);
}

class SeedInfoTableCompanion extends UpdateCompanion<SeedInfoRow> {
  final Value<int> id;
  final Value<int> seedVersion;
  const SeedInfoTableCompanion({
    this.id = const Value.absent(),
    this.seedVersion = const Value.absent(),
  });
  SeedInfoTableCompanion.insert({
    this.id = const Value.absent(),
    required int seedVersion,
  }) : seedVersion = Value(seedVersion);
  static Insertable<SeedInfoRow> custom({
    Expression<int>? id,
    Expression<int>? seedVersion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seedVersion != null) 'seedVersion': seedVersion,
    });
  }

  SeedInfoTableCompanion copyWith({Value<int>? id, Value<int>? seedVersion}) {
    return SeedInfoTableCompanion(
      id: id ?? this.id,
      seedVersion: seedVersion ?? this.seedVersion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (seedVersion.present) {
      map['seedVersion'] = Variable<int>(seedVersion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeedInfoTableCompanion(')
          ..write('id: $id, ')
          ..write('seedVersion: $seedVersion')
          ..write(')'))
        .toString();
  }
}

class $ActiveWorkoutStatesTable extends ActiveWorkoutStates
    with TableInfo<$ActiveWorkoutStatesTable, ActiveWorkoutState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActiveWorkoutStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workoutId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES Workouts (id)',
    ),
  );
  static const VerificationMeta _startedAtUtcMeta = const VerificationMeta(
    'startedAtUtc',
  );
  @override
  late final GeneratedColumn<String> startedAtUtc = GeneratedColumn<String>(
    'startedAtUtc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accumulatedActiveSecMeta =
      const VerificationMeta('accumulatedActiveSec');
  @override
  late final GeneratedColumn<int> accumulatedActiveSec = GeneratedColumn<int>(
    'accumulatedActiveSec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isPausedMeta = const VerificationMeta(
    'isPaused',
  );
  @override
  late final GeneratedColumn<bool> isPaused = GeneratedColumn<bool>(
    'isPaused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isPaused" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pauseStartedAtUtcMeta = const VerificationMeta(
    'pauseStartedAtUtc',
  );
  @override
  late final GeneratedColumn<String> pauseStartedAtUtc =
      GeneratedColumn<String>(
        'pauseStartedAtUtc',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _restTimerEndsAtUtcMeta =
      const VerificationMeta('restTimerEndsAtUtc');
  @override
  late final GeneratedColumn<String> restTimerEndsAtUtc =
      GeneratedColumn<String>(
        'restTimerEndsAtUtc',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _restTimerDurationSecMeta =
      const VerificationMeta('restTimerDurationSec');
  @override
  late final GeneratedColumn<int> restTimerDurationSec = GeneratedColumn<int>(
    'restTimerDurationSec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updatedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    workoutId,
    startedAtUtc,
    accumulatedActiveSec,
    isPaused,
    pauseStartedAtUtc,
    restTimerEndsAtUtc,
    restTimerDurationSec,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ActiveWorkoutStates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActiveWorkoutState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('workoutId')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workoutId']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('startedAtUtc')) {
      context.handle(
        _startedAtUtcMeta,
        startedAtUtc.isAcceptableOrUnknown(
          data['startedAtUtc']!,
          _startedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtUtcMeta);
    }
    if (data.containsKey('accumulatedActiveSec')) {
      context.handle(
        _accumulatedActiveSecMeta,
        accumulatedActiveSec.isAcceptableOrUnknown(
          data['accumulatedActiveSec']!,
          _accumulatedActiveSecMeta,
        ),
      );
    }
    if (data.containsKey('isPaused')) {
      context.handle(
        _isPausedMeta,
        isPaused.isAcceptableOrUnknown(data['isPaused']!, _isPausedMeta),
      );
    }
    if (data.containsKey('pauseStartedAtUtc')) {
      context.handle(
        _pauseStartedAtUtcMeta,
        pauseStartedAtUtc.isAcceptableOrUnknown(
          data['pauseStartedAtUtc']!,
          _pauseStartedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('restTimerEndsAtUtc')) {
      context.handle(
        _restTimerEndsAtUtcMeta,
        restTimerEndsAtUtc.isAcceptableOrUnknown(
          data['restTimerEndsAtUtc']!,
          _restTimerEndsAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('restTimerDurationSec')) {
      context.handle(
        _restTimerDurationSecMeta,
        restTimerDurationSec.isAcceptableOrUnknown(
          data['restTimerDurationSec']!,
          _restTimerDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('updatedAt')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updatedAt']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workoutId};
  @override
  ActiveWorkoutState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActiveWorkoutState(
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workoutId'],
      )!,
      startedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}startedAtUtc'],
      )!,
      accumulatedActiveSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accumulatedActiveSec'],
      )!,
      isPaused: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isPaused'],
      )!,
      pauseStartedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pauseStartedAtUtc'],
      ),
      restTimerEndsAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restTimerEndsAtUtc'],
      ),
      restTimerDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}restTimerDurationSec'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updatedAt'],
      )!,
    );
  }

  @override
  $ActiveWorkoutStatesTable createAlias(String alias) {
    return $ActiveWorkoutStatesTable(attachedDatabase, alias);
  }
}

class ActiveWorkoutState extends DataClass
    implements Insertable<ActiveWorkoutState> {
  final String workoutId;
  final String startedAtUtc;
  final int accumulatedActiveSec;
  final bool isPaused;
  final String? pauseStartedAtUtc;
  final String? restTimerEndsAtUtc;
  final int? restTimerDurationSec;
  final String updatedAt;
  const ActiveWorkoutState({
    required this.workoutId,
    required this.startedAtUtc,
    required this.accumulatedActiveSec,
    required this.isPaused,
    this.pauseStartedAtUtc,
    this.restTimerEndsAtUtc,
    this.restTimerDurationSec,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['workoutId'] = Variable<String>(workoutId);
    map['startedAtUtc'] = Variable<String>(startedAtUtc);
    map['accumulatedActiveSec'] = Variable<int>(accumulatedActiveSec);
    map['isPaused'] = Variable<bool>(isPaused);
    if (!nullToAbsent || pauseStartedAtUtc != null) {
      map['pauseStartedAtUtc'] = Variable<String>(pauseStartedAtUtc);
    }
    if (!nullToAbsent || restTimerEndsAtUtc != null) {
      map['restTimerEndsAtUtc'] = Variable<String>(restTimerEndsAtUtc);
    }
    if (!nullToAbsent || restTimerDurationSec != null) {
      map['restTimerDurationSec'] = Variable<int>(restTimerDurationSec);
    }
    map['updatedAt'] = Variable<String>(updatedAt);
    return map;
  }

  ActiveWorkoutStatesCompanion toCompanion(bool nullToAbsent) {
    return ActiveWorkoutStatesCompanion(
      workoutId: Value(workoutId),
      startedAtUtc: Value(startedAtUtc),
      accumulatedActiveSec: Value(accumulatedActiveSec),
      isPaused: Value(isPaused),
      pauseStartedAtUtc: pauseStartedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(pauseStartedAtUtc),
      restTimerEndsAtUtc: restTimerEndsAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(restTimerEndsAtUtc),
      restTimerDurationSec: restTimerDurationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(restTimerDurationSec),
      updatedAt: Value(updatedAt),
    );
  }

  factory ActiveWorkoutState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActiveWorkoutState(
      workoutId: serializer.fromJson<String>(json['workoutId']),
      startedAtUtc: serializer.fromJson<String>(json['startedAtUtc']),
      accumulatedActiveSec: serializer.fromJson<int>(
        json['accumulatedActiveSec'],
      ),
      isPaused: serializer.fromJson<bool>(json['isPaused']),
      pauseStartedAtUtc: serializer.fromJson<String?>(
        json['pauseStartedAtUtc'],
      ),
      restTimerEndsAtUtc: serializer.fromJson<String?>(
        json['restTimerEndsAtUtc'],
      ),
      restTimerDurationSec: serializer.fromJson<int?>(
        json['restTimerDurationSec'],
      ),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workoutId': serializer.toJson<String>(workoutId),
      'startedAtUtc': serializer.toJson<String>(startedAtUtc),
      'accumulatedActiveSec': serializer.toJson<int>(accumulatedActiveSec),
      'isPaused': serializer.toJson<bool>(isPaused),
      'pauseStartedAtUtc': serializer.toJson<String?>(pauseStartedAtUtc),
      'restTimerEndsAtUtc': serializer.toJson<String?>(restTimerEndsAtUtc),
      'restTimerDurationSec': serializer.toJson<int?>(restTimerDurationSec),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  ActiveWorkoutState copyWith({
    String? workoutId,
    String? startedAtUtc,
    int? accumulatedActiveSec,
    bool? isPaused,
    Value<String?> pauseStartedAtUtc = const Value.absent(),
    Value<String?> restTimerEndsAtUtc = const Value.absent(),
    Value<int?> restTimerDurationSec = const Value.absent(),
    String? updatedAt,
  }) => ActiveWorkoutState(
    workoutId: workoutId ?? this.workoutId,
    startedAtUtc: startedAtUtc ?? this.startedAtUtc,
    accumulatedActiveSec: accumulatedActiveSec ?? this.accumulatedActiveSec,
    isPaused: isPaused ?? this.isPaused,
    pauseStartedAtUtc: pauseStartedAtUtc.present
        ? pauseStartedAtUtc.value
        : this.pauseStartedAtUtc,
    restTimerEndsAtUtc: restTimerEndsAtUtc.present
        ? restTimerEndsAtUtc.value
        : this.restTimerEndsAtUtc,
    restTimerDurationSec: restTimerDurationSec.present
        ? restTimerDurationSec.value
        : this.restTimerDurationSec,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ActiveWorkoutState copyWithCompanion(ActiveWorkoutStatesCompanion data) {
    return ActiveWorkoutState(
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      startedAtUtc: data.startedAtUtc.present
          ? data.startedAtUtc.value
          : this.startedAtUtc,
      accumulatedActiveSec: data.accumulatedActiveSec.present
          ? data.accumulatedActiveSec.value
          : this.accumulatedActiveSec,
      isPaused: data.isPaused.present ? data.isPaused.value : this.isPaused,
      pauseStartedAtUtc: data.pauseStartedAtUtc.present
          ? data.pauseStartedAtUtc.value
          : this.pauseStartedAtUtc,
      restTimerEndsAtUtc: data.restTimerEndsAtUtc.present
          ? data.restTimerEndsAtUtc.value
          : this.restTimerEndsAtUtc,
      restTimerDurationSec: data.restTimerDurationSec.present
          ? data.restTimerDurationSec.value
          : this.restTimerDurationSec,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActiveWorkoutState(')
          ..write('workoutId: $workoutId, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('accumulatedActiveSec: $accumulatedActiveSec, ')
          ..write('isPaused: $isPaused, ')
          ..write('pauseStartedAtUtc: $pauseStartedAtUtc, ')
          ..write('restTimerEndsAtUtc: $restTimerEndsAtUtc, ')
          ..write('restTimerDurationSec: $restTimerDurationSec, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    workoutId,
    startedAtUtc,
    accumulatedActiveSec,
    isPaused,
    pauseStartedAtUtc,
    restTimerEndsAtUtc,
    restTimerDurationSec,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActiveWorkoutState &&
          other.workoutId == this.workoutId &&
          other.startedAtUtc == this.startedAtUtc &&
          other.accumulatedActiveSec == this.accumulatedActiveSec &&
          other.isPaused == this.isPaused &&
          other.pauseStartedAtUtc == this.pauseStartedAtUtc &&
          other.restTimerEndsAtUtc == this.restTimerEndsAtUtc &&
          other.restTimerDurationSec == this.restTimerDurationSec &&
          other.updatedAt == this.updatedAt);
}

class ActiveWorkoutStatesCompanion extends UpdateCompanion<ActiveWorkoutState> {
  final Value<String> workoutId;
  final Value<String> startedAtUtc;
  final Value<int> accumulatedActiveSec;
  final Value<bool> isPaused;
  final Value<String?> pauseStartedAtUtc;
  final Value<String?> restTimerEndsAtUtc;
  final Value<int?> restTimerDurationSec;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const ActiveWorkoutStatesCompanion({
    this.workoutId = const Value.absent(),
    this.startedAtUtc = const Value.absent(),
    this.accumulatedActiveSec = const Value.absent(),
    this.isPaused = const Value.absent(),
    this.pauseStartedAtUtc = const Value.absent(),
    this.restTimerEndsAtUtc = const Value.absent(),
    this.restTimerDurationSec = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActiveWorkoutStatesCompanion.insert({
    required String workoutId,
    required String startedAtUtc,
    this.accumulatedActiveSec = const Value.absent(),
    this.isPaused = const Value.absent(),
    this.pauseStartedAtUtc = const Value.absent(),
    this.restTimerEndsAtUtc = const Value.absent(),
    this.restTimerDurationSec = const Value.absent(),
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : workoutId = Value(workoutId),
       startedAtUtc = Value(startedAtUtc),
       updatedAt = Value(updatedAt);
  static Insertable<ActiveWorkoutState> custom({
    Expression<String>? workoutId,
    Expression<String>? startedAtUtc,
    Expression<int>? accumulatedActiveSec,
    Expression<bool>? isPaused,
    Expression<String>? pauseStartedAtUtc,
    Expression<String>? restTimerEndsAtUtc,
    Expression<int>? restTimerDurationSec,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workoutId != null) 'workoutId': workoutId,
      if (startedAtUtc != null) 'startedAtUtc': startedAtUtc,
      if (accumulatedActiveSec != null)
        'accumulatedActiveSec': accumulatedActiveSec,
      if (isPaused != null) 'isPaused': isPaused,
      if (pauseStartedAtUtc != null) 'pauseStartedAtUtc': pauseStartedAtUtc,
      if (restTimerEndsAtUtc != null) 'restTimerEndsAtUtc': restTimerEndsAtUtc,
      if (restTimerDurationSec != null)
        'restTimerDurationSec': restTimerDurationSec,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActiveWorkoutStatesCompanion copyWith({
    Value<String>? workoutId,
    Value<String>? startedAtUtc,
    Value<int>? accumulatedActiveSec,
    Value<bool>? isPaused,
    Value<String?>? pauseStartedAtUtc,
    Value<String?>? restTimerEndsAtUtc,
    Value<int?>? restTimerDurationSec,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return ActiveWorkoutStatesCompanion(
      workoutId: workoutId ?? this.workoutId,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      accumulatedActiveSec: accumulatedActiveSec ?? this.accumulatedActiveSec,
      isPaused: isPaused ?? this.isPaused,
      pauseStartedAtUtc: pauseStartedAtUtc ?? this.pauseStartedAtUtc,
      restTimerEndsAtUtc: restTimerEndsAtUtc ?? this.restTimerEndsAtUtc,
      restTimerDurationSec: restTimerDurationSec ?? this.restTimerDurationSec,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workoutId.present) {
      map['workoutId'] = Variable<String>(workoutId.value);
    }
    if (startedAtUtc.present) {
      map['startedAtUtc'] = Variable<String>(startedAtUtc.value);
    }
    if (accumulatedActiveSec.present) {
      map['accumulatedActiveSec'] = Variable<int>(accumulatedActiveSec.value);
    }
    if (isPaused.present) {
      map['isPaused'] = Variable<bool>(isPaused.value);
    }
    if (pauseStartedAtUtc.present) {
      map['pauseStartedAtUtc'] = Variable<String>(pauseStartedAtUtc.value);
    }
    if (restTimerEndsAtUtc.present) {
      map['restTimerEndsAtUtc'] = Variable<String>(restTimerEndsAtUtc.value);
    }
    if (restTimerDurationSec.present) {
      map['restTimerDurationSec'] = Variable<int>(restTimerDurationSec.value);
    }
    if (updatedAt.present) {
      map['updatedAt'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActiveWorkoutStatesCompanion(')
          ..write('workoutId: $workoutId, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('accumulatedActiveSec: $accumulatedActiveSec, ')
          ..write('isPaused: $isPaused, ')
          ..write('pauseStartedAtUtc: $pauseStartedAtUtc, ')
          ..write('restTimerEndsAtUtc: $restTimerEndsAtUtc, ')
          ..write('restTimerDurationSec: $restTimerDurationSec, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MuscleGroupsTable muscleGroups = $MuscleGroupsTable(this);
  late final $EquipmentsTable equipments = $EquipmentsTable(this);
  late final $MeasurementTypesTable measurementTypes = $MeasurementTypesTable(
    this,
  );
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $ExerciseSecondaryMusclesTable exerciseSecondaryMuscles =
      $ExerciseSecondaryMusclesTable(this);
  late final $ExerciseL10nTable exerciseL10n = $ExerciseL10nTable(this);
  late final $WorkoutTagsTable workoutTags = $WorkoutTagsTable(this);
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $WorkoutTagLinksTable workoutTagLinks = $WorkoutTagLinksTable(
    this,
  );
  late final $WorkoutExercisesTable workoutExercises = $WorkoutExercisesTable(
    this,
  );
  late final $ExerciseSetsTable exerciseSets = $ExerciseSetsTable(this);
  late final $WorkoutTemplatesTable workoutTemplates = $WorkoutTemplatesTable(
    this,
  );
  late final $TemplateExercisesTable templateExercises =
      $TemplateExercisesTable(this);
  late final $TemplateSetsTable templateSets = $TemplateSetsTable(this);
  late final $BodyMeasurementsTable bodyMeasurements = $BodyMeasurementsTable(
    this,
  );
  late final $PersonalRecordsTable personalRecords = $PersonalRecordsTable(
    this,
  );
  late final $ExerciseProgressionStatesTable exerciseProgressionStates =
      $ExerciseProgressionStatesTable(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(
    this,
  );
  late final $ImportExportOperationsTable importExportOperations =
      $ImportExportOperationsTable(this);
  late final $SeedInfoTableTable seedInfoTable = $SeedInfoTableTable(this);
  late final $ActiveWorkoutStatesTable activeWorkoutStates =
      $ActiveWorkoutStatesTable(this);
  late final Index exercisesIsArchivedIdx = Index(
    'exercisesIsArchivedIdx',
    'CREATE INDEX exercisesIsArchivedIdx ON Exercises (isArchived)',
  );
  late final Index exercisesNameIdx = Index(
    'exercisesNameIdx',
    'CREATE INDEX exercisesNameIdx ON Exercises (name COLLATE NOCASE)',
  );
  late final Index workoutsDateIdx = Index(
    'workoutsDateIdx',
    'CREATE INDEX workoutsDateIdx ON Workouts (date)',
  );
  late final Index workoutsStatusIdx = Index(
    'workoutsStatusIdx',
    'CREATE INDEX workoutsStatusIdx ON Workouts (status)',
  );
  late final Index workoutsIsDeletedIdx = Index(
    'workoutsIsDeletedIdx',
    'CREATE INDEX workoutsIsDeletedIdx ON Workouts (isDeleted)',
  );
  late final Index workoutTagLinksTagIdIdx = Index(
    'workoutTagLinksTagIdIdx',
    'CREATE INDEX workoutTagLinksTagIdIdx ON WorkoutTagLinks (tagId)',
  );
  late final Index workoutExercisesWorkoutIdIdx = Index(
    'workoutExercisesWorkoutIdIdx',
    'CREATE INDEX workoutExercisesWorkoutIdIdx ON WorkoutExercises (workoutId)',
  );
  late final Index workoutExercisesExerciseIdIdx = Index(
    'workoutExercisesExerciseIdIdx',
    'CREATE INDEX workoutExercisesExerciseIdIdx ON WorkoutExercises (exerciseId)',
  );
  late final Index exerciseSetsWorkoutExerciseIdIdx = Index(
    'exerciseSetsWorkoutExerciseIdIdx',
    'CREATE INDEX exerciseSetsWorkoutExerciseIdIdx ON ExerciseSets (workoutExerciseId)',
  );
  late final Index bodyMeasurementsTypeDateIdx = Index(
    'bodyMeasurementsTypeDateIdx',
    'CREATE INDEX bodyMeasurementsTypeDateIdx ON BodyMeasurements (measurementTypeId, date)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    muscleGroups,
    equipments,
    measurementTypes,
    exercises,
    exerciseSecondaryMuscles,
    exerciseL10n,
    workoutTags,
    workouts,
    workoutTagLinks,
    workoutExercises,
    exerciseSets,
    workoutTemplates,
    templateExercises,
    templateSets,
    bodyMeasurements,
    personalRecords,
    exerciseProgressionStates,
    appSettingsTable,
    importExportOperations,
    seedInfoTable,
    activeWorkoutStates,
    exercisesIsArchivedIdx,
    exercisesNameIdx,
    workoutsDateIdx,
    workoutsStatusIdx,
    workoutsIsDeletedIdx,
    workoutTagLinksTagIdIdx,
    workoutExercisesWorkoutIdIdx,
    workoutExercisesExerciseIdIdx,
    exerciseSetsWorkoutExerciseIdIdx,
    bodyMeasurementsTypeDateIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'Exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('ExerciseSecondaryMuscles', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'Exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ExerciseL10n', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MuscleGroupsTableCreateCompanionBuilder =
    MuscleGroupsCompanion Function({
      required String id,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$MuscleGroupsTableUpdateCompanionBuilder =
    MuscleGroupsCompanion Function({
      Value<String> id,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$MuscleGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $MuscleGroupsTable, MuscleGroup> {
  $$MuscleGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExercisesTable, List<Exercise>>
  _exercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exercises,
    aliasName: 'MuscleGroups__id__Exercises__primaryMuscleGroupId',
  );

  $$ExercisesTableProcessedTableManager get exercisesRefs {
    final manager = $$ExercisesTableTableManager($_db, $_db.exercises).filter(
      (f) => f.primaryMuscleGroupId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_exercisesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ExerciseSecondaryMusclesTable,
    List<ExerciseSecondaryMuscle>
  >
  _exerciseSecondaryMusclesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseSecondaryMuscles,
        aliasName: 'MuscleGroups__id__ExerciseSecondaryMuscles__muscleGroupId',
      );

  $$ExerciseSecondaryMusclesTableProcessedTableManager
  get exerciseSecondaryMusclesRefs {
    final manager = $$ExerciseSecondaryMusclesTableTableManager(
      $_db,
      $_db.exerciseSecondaryMuscles,
    ).filter((f) => f.muscleGroupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseSecondaryMusclesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MuscleGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $MuscleGroupsTable> {
  $$MuscleGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exercisesRefs(
    Expression<bool> Function($$ExercisesTableFilterComposer f) f,
  ) {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.primaryMuscleGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseSecondaryMusclesRefs(
    Expression<bool> Function($$ExerciseSecondaryMusclesTableFilterComposer f)
    f,
  ) {
    final $$ExerciseSecondaryMusclesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseSecondaryMuscles,
          getReferencedColumn: (t) => t.muscleGroupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseSecondaryMusclesTableFilterComposer(
                $db: $db,
                $table: $db.exerciseSecondaryMuscles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MuscleGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $MuscleGroupsTable> {
  $$MuscleGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MuscleGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MuscleGroupsTable> {
  $$MuscleGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> exercisesRefs<T extends Object>(
    Expression<T> Function($$ExercisesTableAnnotationComposer a) f,
  ) {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.primaryMuscleGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseSecondaryMusclesRefs<T extends Object>(
    Expression<T> Function($$ExerciseSecondaryMusclesTableAnnotationComposer a)
    f,
  ) {
    final $$ExerciseSecondaryMusclesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseSecondaryMuscles,
          getReferencedColumn: (t) => t.muscleGroupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseSecondaryMusclesTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseSecondaryMuscles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MuscleGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MuscleGroupsTable,
          MuscleGroup,
          $$MuscleGroupsTableFilterComposer,
          $$MuscleGroupsTableOrderingComposer,
          $$MuscleGroupsTableAnnotationComposer,
          $$MuscleGroupsTableCreateCompanionBuilder,
          $$MuscleGroupsTableUpdateCompanionBuilder,
          (MuscleGroup, $$MuscleGroupsTableReferences),
          MuscleGroup,
          PrefetchHooks Function({
            bool exercisesRefs,
            bool exerciseSecondaryMusclesRefs,
          })
        > {
  $$MuscleGroupsTableTableManager(_$AppDatabase db, $MuscleGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MuscleGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MuscleGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MuscleGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MuscleGroupsCompanion(
                id: id,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => MuscleGroupsCompanion.insert(
                id: id,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MuscleGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({exercisesRefs = false, exerciseSecondaryMusclesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exercisesRefs) db.exercises,
                    if (exerciseSecondaryMusclesRefs)
                      db.exerciseSecondaryMuscles,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exercisesRefs)
                        await $_getPrefetchedData<
                          MuscleGroup,
                          $MuscleGroupsTable,
                          Exercise
                        >(
                          currentTable: table,
                          referencedTable: $$MuscleGroupsTableReferences
                              ._exercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MuscleGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).exercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.primaryMuscleGroupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseSecondaryMusclesRefs)
                        await $_getPrefetchedData<
                          MuscleGroup,
                          $MuscleGroupsTable,
                          ExerciseSecondaryMuscle
                        >(
                          currentTable: table,
                          referencedTable: $$MuscleGroupsTableReferences
                              ._exerciseSecondaryMusclesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MuscleGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseSecondaryMusclesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.muscleGroupId == item.id,
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

typedef $$MuscleGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MuscleGroupsTable,
      MuscleGroup,
      $$MuscleGroupsTableFilterComposer,
      $$MuscleGroupsTableOrderingComposer,
      $$MuscleGroupsTableAnnotationComposer,
      $$MuscleGroupsTableCreateCompanionBuilder,
      $$MuscleGroupsTableUpdateCompanionBuilder,
      (MuscleGroup, $$MuscleGroupsTableReferences),
      MuscleGroup,
      PrefetchHooks Function({
        bool exercisesRefs,
        bool exerciseSecondaryMusclesRefs,
      })
    >;
typedef $$EquipmentsTableCreateCompanionBuilder =
    EquipmentsCompanion Function({
      required String id,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$EquipmentsTableUpdateCompanionBuilder =
    EquipmentsCompanion Function({
      Value<String> id,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$EquipmentsTableReferences
    extends BaseReferences<_$AppDatabase, $EquipmentsTable, Equipment> {
  $$EquipmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExercisesTable, List<Exercise>>
  _exercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exercises,
    aliasName: 'Equipments__id__Exercises__equipmentId',
  );

  $$ExercisesTableProcessedTableManager get exercisesRefs {
    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.equipmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_exercisesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EquipmentsTableFilterComposer
    extends Composer<_$AppDatabase, $EquipmentsTable> {
  $$EquipmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exercisesRefs(
    Expression<bool> Function($$ExercisesTableFilterComposer f) f,
  ) {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.equipmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EquipmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EquipmentsTable> {
  $$EquipmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EquipmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EquipmentsTable> {
  $$EquipmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> exercisesRefs<T extends Object>(
    Expression<T> Function($$ExercisesTableAnnotationComposer a) f,
  ) {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.equipmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EquipmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EquipmentsTable,
          Equipment,
          $$EquipmentsTableFilterComposer,
          $$EquipmentsTableOrderingComposer,
          $$EquipmentsTableAnnotationComposer,
          $$EquipmentsTableCreateCompanionBuilder,
          $$EquipmentsTableUpdateCompanionBuilder,
          (Equipment, $$EquipmentsTableReferences),
          Equipment,
          PrefetchHooks Function({bool exercisesRefs})
        > {
  $$EquipmentsTableTableManager(_$AppDatabase db, $EquipmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EquipmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EquipmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EquipmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EquipmentsCompanion(
                id: id,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => EquipmentsCompanion.insert(
                id: id,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EquipmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (exercisesRefs) db.exercises],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exercisesRefs)
                    await $_getPrefetchedData<
                      Equipment,
                      $EquipmentsTable,
                      Exercise
                    >(
                      currentTable: table,
                      referencedTable: $$EquipmentsTableReferences
                          ._exercisesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$EquipmentsTableReferences(
                            db,
                            table,
                            p0,
                          ).exercisesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.equipmentId == item.id,
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

typedef $$EquipmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EquipmentsTable,
      Equipment,
      $$EquipmentsTableFilterComposer,
      $$EquipmentsTableOrderingComposer,
      $$EquipmentsTableAnnotationComposer,
      $$EquipmentsTableCreateCompanionBuilder,
      $$EquipmentsTableUpdateCompanionBuilder,
      (Equipment, $$EquipmentsTableReferences),
      Equipment,
      PrefetchHooks Function({bool exercisesRefs})
    >;
typedef $$MeasurementTypesTableCreateCompanionBuilder =
    MeasurementTypesCompanion Function({
      required String id,
      Value<String?> nameCustom,
      required String unitKind,
      required bool isBuiltIn,
      Value<bool> isArchived,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$MeasurementTypesTableUpdateCompanionBuilder =
    MeasurementTypesCompanion Function({
      Value<String> id,
      Value<String?> nameCustom,
      Value<String> unitKind,
      Value<bool> isBuiltIn,
      Value<bool> isArchived,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$MeasurementTypesTableReferences
    extends
        BaseReferences<_$AppDatabase, $MeasurementTypesTable, MeasurementType> {
  $$MeasurementTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$BodyMeasurementsTable, List<BodyMeasurement>>
  _bodyMeasurementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bodyMeasurements,
    aliasName: 'MeasurementTypes__id__BodyMeasurements__measurementTypeId',
  );

  $$BodyMeasurementsTableProcessedTableManager get bodyMeasurementsRefs {
    final manager =
        $$BodyMeasurementsTableTableManager($_db, $_db.bodyMeasurements).filter(
          (f) => f.measurementTypeId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _bodyMeasurementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MeasurementTypesTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementTypesTable> {
  $$MeasurementTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameCustom => $composableBuilder(
    column: $table.nameCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitKind => $composableBuilder(
    column: $table.unitKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bodyMeasurementsRefs(
    Expression<bool> Function($$BodyMeasurementsTableFilterComposer f) f,
  ) {
    final $$BodyMeasurementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bodyMeasurements,
      getReferencedColumn: (t) => t.measurementTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BodyMeasurementsTableFilterComposer(
            $db: $db,
            $table: $db.bodyMeasurements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MeasurementTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementTypesTable> {
  $$MeasurementTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameCustom => $composableBuilder(
    column: $table.nameCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitKind => $composableBuilder(
    column: $table.unitKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeasurementTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementTypesTable> {
  $$MeasurementTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameCustom => $composableBuilder(
    column: $table.nameCustom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitKind =>
      $composableBuilder(column: $table.unitKind, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> bodyMeasurementsRefs<T extends Object>(
    Expression<T> Function($$BodyMeasurementsTableAnnotationComposer a) f,
  ) {
    final $$BodyMeasurementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bodyMeasurements,
      getReferencedColumn: (t) => t.measurementTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BodyMeasurementsTableAnnotationComposer(
            $db: $db,
            $table: $db.bodyMeasurements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MeasurementTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementTypesTable,
          MeasurementType,
          $$MeasurementTypesTableFilterComposer,
          $$MeasurementTypesTableOrderingComposer,
          $$MeasurementTypesTableAnnotationComposer,
          $$MeasurementTypesTableCreateCompanionBuilder,
          $$MeasurementTypesTableUpdateCompanionBuilder,
          (MeasurementType, $$MeasurementTypesTableReferences),
          MeasurementType,
          PrefetchHooks Function({bool bodyMeasurementsRefs})
        > {
  $$MeasurementTypesTableTableManager(
    _$AppDatabase db,
    $MeasurementTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> nameCustom = const Value.absent(),
                Value<String> unitKind = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementTypesCompanion(
                id: id,
                nameCustom: nameCustom,
                unitKind: unitKind,
                isBuiltIn: isBuiltIn,
                isArchived: isArchived,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> nameCustom = const Value.absent(),
                required String unitKind,
                required bool isBuiltIn,
                Value<bool> isArchived = const Value.absent(),
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => MeasurementTypesCompanion.insert(
                id: id,
                nameCustom: nameCustom,
                unitKind: unitKind,
                isBuiltIn: isBuiltIn,
                isArchived: isArchived,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MeasurementTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bodyMeasurementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (bodyMeasurementsRefs) db.bodyMeasurements,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bodyMeasurementsRefs)
                    await $_getPrefetchedData<
                      MeasurementType,
                      $MeasurementTypesTable,
                      BodyMeasurement
                    >(
                      currentTable: table,
                      referencedTable: $$MeasurementTypesTableReferences
                          ._bodyMeasurementsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MeasurementTypesTableReferences(
                            db,
                            table,
                            p0,
                          ).bodyMeasurementsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.measurementTypeId == item.id,
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

typedef $$MeasurementTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementTypesTable,
      MeasurementType,
      $$MeasurementTypesTableFilterComposer,
      $$MeasurementTypesTableOrderingComposer,
      $$MeasurementTypesTableAnnotationComposer,
      $$MeasurementTypesTableCreateCompanionBuilder,
      $$MeasurementTypesTableUpdateCompanionBuilder,
      (MeasurementType, $$MeasurementTypesTableReferences),
      MeasurementType,
      PrefetchHooks Function({bool bodyMeasurementsRefs})
    >;
typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      required String createdAt,
      required String updatedAt,
      Value<bool> isDeleted,
      required String id,
      required String name,
      Value<String?> description,
      Value<String?> youtubeUrl,
      Value<String?> imageAsset,
      required String exerciseType,
      Value<String?> primaryMuscleGroupId,
      Value<String?> equipmentId,
      Value<String> effortMetric,
      Value<String?> statsMetricsJson,
      Value<bool> isBuiltIn,
      Value<bool> isArchived,
      Value<int> rowid,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<bool> isDeleted,
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String?> youtubeUrl,
      Value<String?> imageAsset,
      Value<String> exerciseType,
      Value<String?> primaryMuscleGroupId,
      Value<String?> equipmentId,
      Value<String> effortMetric,
      Value<String?> statsMetricsJson,
      Value<bool> isBuiltIn,
      Value<bool> isArchived,
      Value<int> rowid,
    });

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MuscleGroupsTable _primaryMuscleGroupIdTable(_$AppDatabase db) => db
      .muscleGroups
      .createAlias('Exercises__primaryMuscleGroupId__MuscleGroups__id');

  $$MuscleGroupsTableProcessedTableManager? get primaryMuscleGroupId {
    final $_column = $_itemColumn<String>('primaryMuscleGroupId');
    if ($_column == null) return null;
    final manager = $$MuscleGroupsTableTableManager(
      $_db,
      $_db.muscleGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _primaryMuscleGroupIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EquipmentsTable _equipmentIdTable(_$AppDatabase db) =>
      db.equipments.createAlias('Exercises__equipmentId__Equipments__id');

  $$EquipmentsTableProcessedTableManager? get equipmentId {
    final $_column = $_itemColumn<String>('equipmentId');
    if ($_column == null) return null;
    final manager = $$EquipmentsTableTableManager(
      $_db,
      $_db.equipments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_equipmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ExerciseSecondaryMusclesTable,
    List<ExerciseSecondaryMuscle>
  >
  _exerciseSecondaryMusclesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseSecondaryMuscles,
        aliasName: 'Exercises__id__ExerciseSecondaryMuscles__exerciseId',
      );

  $$ExerciseSecondaryMusclesTableProcessedTableManager
  get exerciseSecondaryMusclesRefs {
    final manager = $$ExerciseSecondaryMusclesTableTableManager(
      $_db,
      $_db.exerciseSecondaryMuscles,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseSecondaryMusclesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseL10nTable, List<ExerciseL10nData>>
  _exerciseL10nRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseL10n,
    aliasName: 'Exercises__id__ExerciseL10n__exerciseId',
  );

  $$ExerciseL10nTableProcessedTableManager get exerciseL10nRefs {
    final manager = $$ExerciseL10nTableTableManager(
      $_db,
      $_db.exerciseL10n,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseL10nRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutExercisesTable, List<WorkoutExercise>>
  _workoutExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutExercises,
    aliasName: 'Exercises__id__WorkoutExercises__exerciseId',
  );

  $$WorkoutExercisesTableProcessedTableManager get workoutExercisesRefs {
    final manager = $$WorkoutExercisesTableTableManager(
      $_db,
      $_db.workoutExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TemplateExercisesTable, List<TemplateExercise>>
  _templateExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.templateExercises,
        aliasName: 'Exercises__id__TemplateExercises__exerciseId',
      );

  $$TemplateExercisesTableProcessedTableManager get templateExercisesRefs {
    final manager = $$TemplateExercisesTableTableManager(
      $_db,
      $_db.templateExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _templateExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PersonalRecordsTable, List<PersonalRecord>>
  _personalRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personalRecords,
    aliasName: 'Exercises__id__PersonalRecords__exerciseId',
  );

  $$PersonalRecordsTableProcessedTableManager get personalRecordsRefs {
    final manager = $$PersonalRecordsTableTableManager(
      $_db,
      $_db.personalRecords,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ExerciseProgressionStatesTable,
    List<ExerciseProgressionState>
  >
  _exerciseProgressionStatesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseProgressionStates,
        aliasName: 'Exercises__id__ExerciseProgressionStates__exerciseId',
      );

  $$ExerciseProgressionStatesTableProcessedTableManager
  get exerciseProgressionStatesRefs {
    final manager = $$ExerciseProgressionStatesTableTableManager(
      $_db,
      $_db.exerciseProgressionStates,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseProgressionStatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
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

  ColumnFilters<String> get youtubeUrl => $composableBuilder(
    column: $table.youtubeUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageAsset => $composableBuilder(
    column: $table.imageAsset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseType => $composableBuilder(
    column: $table.exerciseType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effortMetric => $composableBuilder(
    column: $table.effortMetric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statsMetricsJson => $composableBuilder(
    column: $table.statsMetricsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  $$MuscleGroupsTableFilterComposer get primaryMuscleGroupId {
    final $$MuscleGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.primaryMuscleGroupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleGroupsTableFilterComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableFilterComposer get equipmentId {
    final $$EquipmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableFilterComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> exerciseSecondaryMusclesRefs(
    Expression<bool> Function($$ExerciseSecondaryMusclesTableFilterComposer f)
    f,
  ) {
    final $$ExerciseSecondaryMusclesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseSecondaryMuscles,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseSecondaryMusclesTableFilterComposer(
                $db: $db,
                $table: $db.exerciseSecondaryMuscles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> exerciseL10nRefs(
    Expression<bool> Function($$ExerciseL10nTableFilterComposer f) f,
  ) {
    final $$ExerciseL10nTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseL10n,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseL10nTableFilterComposer(
            $db: $db,
            $table: $db.exerciseL10n,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutExercisesRefs(
    Expression<bool> Function($$WorkoutExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> templateExercisesRefs(
    Expression<bool> Function($$TemplateExercisesTableFilterComposer f) f,
  ) {
    final $$TemplateExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.templateExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplateExercisesTableFilterComposer(
            $db: $db,
            $table: $db.templateExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> personalRecordsRefs(
    Expression<bool> Function($$PersonalRecordsTableFilterComposer f) f,
  ) {
    final $$PersonalRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableFilterComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseProgressionStatesRefs(
    Expression<bool> Function($$ExerciseProgressionStatesTableFilterComposer f)
    f,
  ) {
    final $$ExerciseProgressionStatesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseProgressionStates,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseProgressionStatesTableFilterComposer(
                $db: $db,
                $table: $db.exerciseProgressionStates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
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

  ColumnOrderings<String> get youtubeUrl => $composableBuilder(
    column: $table.youtubeUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageAsset => $composableBuilder(
    column: $table.imageAsset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseType => $composableBuilder(
    column: $table.exerciseType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effortMetric => $composableBuilder(
    column: $table.effortMetric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statsMetricsJson => $composableBuilder(
    column: $table.statsMetricsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  $$MuscleGroupsTableOrderingComposer get primaryMuscleGroupId {
    final $$MuscleGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.primaryMuscleGroupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableOrderingComposer get equipmentId {
    final $$EquipmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableOrderingComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get youtubeUrl => $composableBuilder(
    column: $table.youtubeUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageAsset => $composableBuilder(
    column: $table.imageAsset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exerciseType => $composableBuilder(
    column: $table.exerciseType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get effortMetric => $composableBuilder(
    column: $table.effortMetric,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statsMetricsJson => $composableBuilder(
    column: $table.statsMetricsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  $$MuscleGroupsTableAnnotationComposer get primaryMuscleGroupId {
    final $$MuscleGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.primaryMuscleGroupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentsTableAnnotationComposer get equipmentId {
    final $$EquipmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.equipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> exerciseSecondaryMusclesRefs<T extends Object>(
    Expression<T> Function($$ExerciseSecondaryMusclesTableAnnotationComposer a)
    f,
  ) {
    final $$ExerciseSecondaryMusclesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseSecondaryMuscles,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseSecondaryMusclesTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseSecondaryMuscles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> exerciseL10nRefs<T extends Object>(
    Expression<T> Function($$ExerciseL10nTableAnnotationComposer a) f,
  ) {
    final $$ExerciseL10nTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseL10n,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseL10nTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseL10n,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workoutExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutExercisesTableAnnotationComposer a) f,
  ) {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> templateExercisesRefs<T extends Object>(
    Expression<T> Function($$TemplateExercisesTableAnnotationComposer a) f,
  ) {
    final $$TemplateExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.templateExercises,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TemplateExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.templateExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> personalRecordsRefs<T extends Object>(
    Expression<T> Function($$PersonalRecordsTableAnnotationComposer a) f,
  ) {
    final $$PersonalRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseProgressionStatesRefs<T extends Object>(
    Expression<T> Function($$ExerciseProgressionStatesTableAnnotationComposer a)
    f,
  ) {
    final $$ExerciseProgressionStatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseProgressionStates,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseProgressionStatesTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseProgressionStates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({
            bool primaryMuscleGroupId,
            bool equipmentId,
            bool exerciseSecondaryMusclesRefs,
            bool exerciseL10nRefs,
            bool workoutExercisesRefs,
            bool templateExercisesRefs,
            bool personalRecordsRefs,
            bool exerciseProgressionStatesRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> youtubeUrl = const Value.absent(),
                Value<String?> imageAsset = const Value.absent(),
                Value<String> exerciseType = const Value.absent(),
                Value<String?> primaryMuscleGroupId = const Value.absent(),
                Value<String?> equipmentId = const Value.absent(),
                Value<String> effortMetric = const Value.absent(),
                Value<String?> statsMetricsJson = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                name: name,
                description: description,
                youtubeUrl: youtubeUrl,
                imageAsset: imageAsset,
                exerciseType: exerciseType,
                primaryMuscleGroupId: primaryMuscleGroupId,
                equipmentId: equipmentId,
                effortMetric: effortMetric,
                statsMetricsJson: statsMetricsJson,
                isBuiltIn: isBuiltIn,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String createdAt,
                required String updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> youtubeUrl = const Value.absent(),
                Value<String?> imageAsset = const Value.absent(),
                required String exerciseType,
                Value<String?> primaryMuscleGroupId = const Value.absent(),
                Value<String?> equipmentId = const Value.absent(),
                Value<String> effortMetric = const Value.absent(),
                Value<String?> statsMetricsJson = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                name: name,
                description: description,
                youtubeUrl: youtubeUrl,
                imageAsset: imageAsset,
                exerciseType: exerciseType,
                primaryMuscleGroupId: primaryMuscleGroupId,
                equipmentId: equipmentId,
                effortMetric: effortMetric,
                statsMetricsJson: statsMetricsJson,
                isBuiltIn: isBuiltIn,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                primaryMuscleGroupId = false,
                equipmentId = false,
                exerciseSecondaryMusclesRefs = false,
                exerciseL10nRefs = false,
                workoutExercisesRefs = false,
                templateExercisesRefs = false,
                personalRecordsRefs = false,
                exerciseProgressionStatesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseSecondaryMusclesRefs)
                      db.exerciseSecondaryMuscles,
                    if (exerciseL10nRefs) db.exerciseL10n,
                    if (workoutExercisesRefs) db.workoutExercises,
                    if (templateExercisesRefs) db.templateExercises,
                    if (personalRecordsRefs) db.personalRecords,
                    if (exerciseProgressionStatesRefs)
                      db.exerciseProgressionStates,
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
                        if (primaryMuscleGroupId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.primaryMuscleGroupId,
                                    referencedTable: $$ExercisesTableReferences
                                        ._primaryMuscleGroupIdTable(db),
                                    referencedColumn: $$ExercisesTableReferences
                                        ._primaryMuscleGroupIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (equipmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.equipmentId,
                                    referencedTable: $$ExercisesTableReferences
                                        ._equipmentIdTable(db),
                                    referencedColumn: $$ExercisesTableReferences
                                        ._equipmentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseSecondaryMusclesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          ExerciseSecondaryMuscle
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseSecondaryMusclesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseSecondaryMusclesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseL10nRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          ExerciseL10nData
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseL10nRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseL10nRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutExercisesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          WorkoutExercise
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._workoutExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (templateExercisesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          TemplateExercise
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._templateExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).templateExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (personalRecordsRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          PersonalRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._personalRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).personalRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseProgressionStatesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          ExerciseProgressionState
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseProgressionStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseProgressionStatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
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

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({
        bool primaryMuscleGroupId,
        bool equipmentId,
        bool exerciseSecondaryMusclesRefs,
        bool exerciseL10nRefs,
        bool workoutExercisesRefs,
        bool templateExercisesRefs,
        bool personalRecordsRefs,
        bool exerciseProgressionStatesRefs,
      })
    >;
typedef $$ExerciseSecondaryMusclesTableCreateCompanionBuilder =
    ExerciseSecondaryMusclesCompanion Function({
      required String exerciseId,
      required String muscleGroupId,
      Value<int> rowid,
    });
typedef $$ExerciseSecondaryMusclesTableUpdateCompanionBuilder =
    ExerciseSecondaryMusclesCompanion Function({
      Value<String> exerciseId,
      Value<String> muscleGroupId,
      Value<int> rowid,
    });

final class $$ExerciseSecondaryMusclesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExerciseSecondaryMusclesTable,
          ExerciseSecondaryMuscle
        > {
  $$ExerciseSecondaryMusclesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) => db.exercises
      .createAlias('ExerciseSecondaryMuscles__exerciseId__Exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exerciseId')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MuscleGroupsTable _muscleGroupIdTable(_$AppDatabase db) => db
      .muscleGroups
      .createAlias('ExerciseSecondaryMuscles__muscleGroupId__MuscleGroups__id');

  $$MuscleGroupsTableProcessedTableManager get muscleGroupId {
    final $_column = $_itemColumn<String>('muscleGroupId')!;

    final manager = $$MuscleGroupsTableTableManager(
      $_db,
      $_db.muscleGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_muscleGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseSecondaryMusclesTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseSecondaryMusclesTable> {
  $$ExerciseSecondaryMusclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleGroupsTableFilterComposer get muscleGroupId {
    final $$MuscleGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleGroupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleGroupsTableFilterComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSecondaryMusclesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseSecondaryMusclesTable> {
  $$ExerciseSecondaryMusclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleGroupsTableOrderingComposer get muscleGroupId {
    final $$MuscleGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleGroupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSecondaryMusclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseSecondaryMusclesTable> {
  $$ExerciseSecondaryMusclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleGroupsTableAnnotationComposer get muscleGroupId {
    final $$MuscleGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleGroupId,
      referencedTable: $db.muscleGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.muscleGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSecondaryMusclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseSecondaryMusclesTable,
          ExerciseSecondaryMuscle,
          $$ExerciseSecondaryMusclesTableFilterComposer,
          $$ExerciseSecondaryMusclesTableOrderingComposer,
          $$ExerciseSecondaryMusclesTableAnnotationComposer,
          $$ExerciseSecondaryMusclesTableCreateCompanionBuilder,
          $$ExerciseSecondaryMusclesTableUpdateCompanionBuilder,
          (ExerciseSecondaryMuscle, $$ExerciseSecondaryMusclesTableReferences),
          ExerciseSecondaryMuscle,
          PrefetchHooks Function({bool exerciseId, bool muscleGroupId})
        > {
  $$ExerciseSecondaryMusclesTableTableManager(
    _$AppDatabase db,
    $ExerciseSecondaryMusclesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseSecondaryMusclesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ExerciseSecondaryMusclesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExerciseSecondaryMusclesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<String> muscleGroupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseSecondaryMusclesCompanion(
                exerciseId: exerciseId,
                muscleGroupId: muscleGroupId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required String muscleGroupId,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseSecondaryMusclesCompanion.insert(
                exerciseId: exerciseId,
                muscleGroupId: muscleGroupId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseSecondaryMusclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false, muscleGroupId = false}) {
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
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$ExerciseSecondaryMusclesTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$ExerciseSecondaryMusclesTableReferences
                                        ._exerciseIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (muscleGroupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.muscleGroupId,
                                referencedTable:
                                    $$ExerciseSecondaryMusclesTableReferences
                                        ._muscleGroupIdTable(db),
                                referencedColumn:
                                    $$ExerciseSecondaryMusclesTableReferences
                                        ._muscleGroupIdTable(db)
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

typedef $$ExerciseSecondaryMusclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseSecondaryMusclesTable,
      ExerciseSecondaryMuscle,
      $$ExerciseSecondaryMusclesTableFilterComposer,
      $$ExerciseSecondaryMusclesTableOrderingComposer,
      $$ExerciseSecondaryMusclesTableAnnotationComposer,
      $$ExerciseSecondaryMusclesTableCreateCompanionBuilder,
      $$ExerciseSecondaryMusclesTableUpdateCompanionBuilder,
      (ExerciseSecondaryMuscle, $$ExerciseSecondaryMusclesTableReferences),
      ExerciseSecondaryMuscle,
      PrefetchHooks Function({bool exerciseId, bool muscleGroupId})
    >;
typedef $$ExerciseL10nTableCreateCompanionBuilder =
    ExerciseL10nCompanion Function({
      required String exerciseId,
      required String locale,
      required String name,
      Value<String?> description,
      Value<int> rowid,
    });
typedef $$ExerciseL10nTableUpdateCompanionBuilder =
    ExerciseL10nCompanion Function({
      Value<String> exerciseId,
      Value<String> locale,
      Value<String> name,
      Value<String?> description,
      Value<int> rowid,
    });

final class $$ExerciseL10nTableReferences
    extends
        BaseReferences<_$AppDatabase, $ExerciseL10nTable, ExerciseL10nData> {
  $$ExerciseL10nTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('ExerciseL10n__exerciseId__Exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exerciseId')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseL10nTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseL10nTable> {
  $$ExerciseL10nTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
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

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseL10nTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseL10nTable> {
  $$ExerciseL10nTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
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

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseL10nTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseL10nTable> {
  $$ExerciseL10nTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseL10nTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseL10nTable,
          ExerciseL10nData,
          $$ExerciseL10nTableFilterComposer,
          $$ExerciseL10nTableOrderingComposer,
          $$ExerciseL10nTableAnnotationComposer,
          $$ExerciseL10nTableCreateCompanionBuilder,
          $$ExerciseL10nTableUpdateCompanionBuilder,
          (ExerciseL10nData, $$ExerciseL10nTableReferences),
          ExerciseL10nData,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$ExerciseL10nTableTableManager(_$AppDatabase db, $ExerciseL10nTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseL10nTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseL10nTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseL10nTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseL10nCompanion(
                exerciseId: exerciseId,
                locale: locale,
                name: name,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required String locale,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseL10nCompanion.insert(
                exerciseId: exerciseId,
                locale: locale,
                name: name,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseL10nTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
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
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$ExerciseL10nTableReferences
                                    ._exerciseIdTable(db),
                                referencedColumn: $$ExerciseL10nTableReferences
                                    ._exerciseIdTable(db)
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

typedef $$ExerciseL10nTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseL10nTable,
      ExerciseL10nData,
      $$ExerciseL10nTableFilterComposer,
      $$ExerciseL10nTableOrderingComposer,
      $$ExerciseL10nTableAnnotationComposer,
      $$ExerciseL10nTableCreateCompanionBuilder,
      $$ExerciseL10nTableUpdateCompanionBuilder,
      (ExerciseL10nData, $$ExerciseL10nTableReferences),
      ExerciseL10nData,
      PrefetchHooks Function({bool exerciseId})
    >;
typedef $$WorkoutTagsTableCreateCompanionBuilder =
    WorkoutTagsCompanion Function({
      required String createdAt,
      required String updatedAt,
      Value<bool> isDeleted,
      required String id,
      required String name,
      Value<String> colorHex,
      Value<bool> isHidden,
      Value<int> rowid,
    });
typedef $$WorkoutTagsTableUpdateCompanionBuilder =
    WorkoutTagsCompanion Function({
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<bool> isDeleted,
      Value<String> id,
      Value<String> name,
      Value<String> colorHex,
      Value<bool> isHidden,
      Value<int> rowid,
    });

final class $$WorkoutTagsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutTagsTable, WorkoutTag> {
  $$WorkoutTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkoutTagLinksTable, List<WorkoutTagLink>>
  _workoutTagLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutTagLinks,
    aliasName: 'WorkoutTags__id__WorkoutTagLinks__tagId',
  );

  $$WorkoutTagLinksTableProcessedTableManager get workoutTagLinksRefs {
    final manager = $$WorkoutTagLinksTableTableManager(
      $_db,
      $_db.workoutTagLinks,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutTagLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutTagsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutTagsTable> {
  $$WorkoutTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutTagLinksRefs(
    Expression<bool> Function($$WorkoutTagLinksTableFilterComposer f) f,
  ) {
    final $$WorkoutTagLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutTagLinks,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTagLinksTableFilterComposer(
            $db: $db,
            $table: $db.workoutTagLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutTagsTable> {
  $$WorkoutTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutTagsTable> {
  $$WorkoutTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  Expression<T> workoutTagLinksRefs<T extends Object>(
    Expression<T> Function($$WorkoutTagLinksTableAnnotationComposer a) f,
  ) {
    final $$WorkoutTagLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutTagLinks,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTagLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutTagLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutTagsTable,
          WorkoutTag,
          $$WorkoutTagsTableFilterComposer,
          $$WorkoutTagsTableOrderingComposer,
          $$WorkoutTagsTableAnnotationComposer,
          $$WorkoutTagsTableCreateCompanionBuilder,
          $$WorkoutTagsTableUpdateCompanionBuilder,
          (WorkoutTag, $$WorkoutTagsTableReferences),
          WorkoutTag,
          PrefetchHooks Function({bool workoutTagLinksRefs})
        > {
  $$WorkoutTagsTableTableManager(_$AppDatabase db, $WorkoutTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTagsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                name: name,
                colorHex: colorHex,
                isHidden: isHidden,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String createdAt,
                required String updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                required String id,
                required String name,
                Value<String> colorHex = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTagsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                name: name,
                colorHex: colorHex,
                isHidden: isHidden,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutTagLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workoutTagLinksRefs) db.workoutTagLinks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutTagLinksRefs)
                    await $_getPrefetchedData<
                      WorkoutTag,
                      $WorkoutTagsTable,
                      WorkoutTagLink
                    >(
                      currentTable: table,
                      referencedTable: $$WorkoutTagsTableReferences
                          ._workoutTagLinksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WorkoutTagsTableReferences(
                            db,
                            table,
                            p0,
                          ).workoutTagLinksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutTagsTable,
      WorkoutTag,
      $$WorkoutTagsTableFilterComposer,
      $$WorkoutTagsTableOrderingComposer,
      $$WorkoutTagsTableAnnotationComposer,
      $$WorkoutTagsTableCreateCompanionBuilder,
      $$WorkoutTagsTableUpdateCompanionBuilder,
      (WorkoutTag, $$WorkoutTagsTableReferences),
      WorkoutTag,
      PrefetchHooks Function({bool workoutTagLinksRefs})
    >;
typedef $$WorkoutsTableCreateCompanionBuilder =
    WorkoutsCompanion Function({
      required String createdAt,
      required String updatedAt,
      Value<bool> isDeleted,
      required String id,
      required String date,
      Value<String?> name,
      Value<String> status,
      Value<String?> comment,
      Value<String?> startedAt,
      Value<String?> finishedAt,
      Value<int?> actualDurationSec,
      Value<int> rowid,
    });
typedef $$WorkoutsTableUpdateCompanionBuilder =
    WorkoutsCompanion Function({
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<bool> isDeleted,
      Value<String> id,
      Value<String> date,
      Value<String?> name,
      Value<String> status,
      Value<String?> comment,
      Value<String?> startedAt,
      Value<String?> finishedAt,
      Value<int?> actualDurationSec,
      Value<int> rowid,
    });

final class $$WorkoutsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutsTable, Workout> {
  $$WorkoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkoutTagLinksTable, List<WorkoutTagLink>>
  _workoutTagLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutTagLinks,
    aliasName: 'Workouts__id__WorkoutTagLinks__workoutId',
  );

  $$WorkoutTagLinksTableProcessedTableManager get workoutTagLinksRefs {
    final manager = $$WorkoutTagLinksTableTableManager(
      $_db,
      $_db.workoutTagLinks,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutTagLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutExercisesTable, List<WorkoutExercise>>
  _workoutExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutExercises,
    aliasName: 'Workouts__id__WorkoutExercises__workoutId',
  );

  $$WorkoutExercisesTableProcessedTableManager get workoutExercisesRefs {
    final manager = $$WorkoutExercisesTableTableManager(
      $_db,
      $_db.workoutExercises,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PersonalRecordsTable, List<PersonalRecord>>
  _personalRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personalRecords,
    aliasName: 'Workouts__id__PersonalRecords__workoutId',
  );

  $$PersonalRecordsTableProcessedTableManager get personalRecordsRefs {
    final manager = $$PersonalRecordsTableTableManager(
      $_db,
      $_db.personalRecords,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ExerciseProgressionStatesTable,
    List<ExerciseProgressionState>
  >
  _exerciseProgressionStatesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseProgressionStates,
        aliasName:
            'Workouts__id__ExerciseProgressionStates__lastCountedWorkoutId',
      );

  $$ExerciseProgressionStatesTableProcessedTableManager
  get exerciseProgressionStatesRefs {
    final manager =
        $$ExerciseProgressionStatesTableTableManager(
          $_db,
          $_db.exerciseProgressionStates,
        ).filter(
          (f) =>
              f.lastCountedWorkoutId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _exerciseProgressionStatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ActiveWorkoutStatesTable,
    List<ActiveWorkoutState>
  >
  _activeWorkoutStatesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.activeWorkoutStates,
        aliasName: 'Workouts__id__ActiveWorkoutStates__workoutId',
      );

  $$ActiveWorkoutStatesTableProcessedTableManager get activeWorkoutStatesRefs {
    final manager = $$ActiveWorkoutStatesTableTableManager(
      $_db,
      $_db.activeWorkoutStates,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _activeWorkoutStatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualDurationSec => $composableBuilder(
    column: $table.actualDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutTagLinksRefs(
    Expression<bool> Function($$WorkoutTagLinksTableFilterComposer f) f,
  ) {
    final $$WorkoutTagLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutTagLinks,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTagLinksTableFilterComposer(
            $db: $db,
            $table: $db.workoutTagLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutExercisesRefs(
    Expression<bool> Function($$WorkoutExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> personalRecordsRefs(
    Expression<bool> Function($$PersonalRecordsTableFilterComposer f) f,
  ) {
    final $$PersonalRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableFilterComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseProgressionStatesRefs(
    Expression<bool> Function($$ExerciseProgressionStatesTableFilterComposer f)
    f,
  ) {
    final $$ExerciseProgressionStatesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseProgressionStates,
          getReferencedColumn: (t) => t.lastCountedWorkoutId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseProgressionStatesTableFilterComposer(
                $db: $db,
                $table: $db.exerciseProgressionStates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> activeWorkoutStatesRefs(
    Expression<bool> Function($$ActiveWorkoutStatesTableFilterComposer f) f,
  ) {
    final $$ActiveWorkoutStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activeWorkoutStates,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActiveWorkoutStatesTableFilterComposer(
            $db: $db,
            $table: $db.activeWorkoutStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualDurationSec => $composableBuilder(
    column: $table.actualDurationSec,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualDurationSec => $composableBuilder(
    column: $table.actualDurationSec,
    builder: (column) => column,
  );

  Expression<T> workoutTagLinksRefs<T extends Object>(
    Expression<T> Function($$WorkoutTagLinksTableAnnotationComposer a) f,
  ) {
    final $$WorkoutTagLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutTagLinks,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTagLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutTagLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workoutExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutExercisesTableAnnotationComposer a) f,
  ) {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> personalRecordsRefs<T extends Object>(
    Expression<T> Function($$PersonalRecordsTableAnnotationComposer a) f,
  ) {
    final $$PersonalRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseProgressionStatesRefs<T extends Object>(
    Expression<T> Function($$ExerciseProgressionStatesTableAnnotationComposer a)
    f,
  ) {
    final $$ExerciseProgressionStatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseProgressionStates,
          getReferencedColumn: (t) => t.lastCountedWorkoutId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseProgressionStatesTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseProgressionStates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> activeWorkoutStatesRefs<T extends Object>(
    Expression<T> Function($$ActiveWorkoutStatesTableAnnotationComposer a) f,
  ) {
    final $$ActiveWorkoutStatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.activeWorkoutStates,
          getReferencedColumn: (t) => t.workoutId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActiveWorkoutStatesTableAnnotationComposer(
                $db: $db,
                $table: $db.activeWorkoutStates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutsTable,
          Workout,
          $$WorkoutsTableFilterComposer,
          $$WorkoutsTableOrderingComposer,
          $$WorkoutsTableAnnotationComposer,
          $$WorkoutsTableCreateCompanionBuilder,
          $$WorkoutsTableUpdateCompanionBuilder,
          (Workout, $$WorkoutsTableReferences),
          Workout,
          PrefetchHooks Function({
            bool workoutTagLinksRefs,
            bool workoutExercisesRefs,
            bool personalRecordsRefs,
            bool exerciseProgressionStatesRefs,
            bool activeWorkoutStatesRefs,
          })
        > {
  $$WorkoutsTableTableManager(_$AppDatabase db, $WorkoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<String?> startedAt = const Value.absent(),
                Value<String?> finishedAt = const Value.absent(),
                Value<int?> actualDurationSec = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                date: date,
                name: name,
                status: status,
                comment: comment,
                startedAt: startedAt,
                finishedAt: finishedAt,
                actualDurationSec: actualDurationSec,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String createdAt,
                required String updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                required String id,
                required String date,
                Value<String?> name = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<String?> startedAt = const Value.absent(),
                Value<String?> finishedAt = const Value.absent(),
                Value<int?> actualDurationSec = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                date: date,
                name: name,
                status: status,
                comment: comment,
                startedAt: startedAt,
                finishedAt: finishedAt,
                actualDurationSec: actualDurationSec,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutTagLinksRefs = false,
                workoutExercisesRefs = false,
                personalRecordsRefs = false,
                exerciseProgressionStatesRefs = false,
                activeWorkoutStatesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutTagLinksRefs) db.workoutTagLinks,
                    if (workoutExercisesRefs) db.workoutExercises,
                    if (personalRecordsRefs) db.personalRecords,
                    if (exerciseProgressionStatesRefs)
                      db.exerciseProgressionStates,
                    if (activeWorkoutStatesRefs) db.activeWorkoutStates,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutTagLinksRefs)
                        await $_getPrefetchedData<
                          Workout,
                          $WorkoutsTable,
                          WorkoutTagLink
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutsTableReferences
                              ._workoutTagLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutTagLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutExercisesRefs)
                        await $_getPrefetchedData<
                          Workout,
                          $WorkoutsTable,
                          WorkoutExercise
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutsTableReferences
                              ._workoutExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (personalRecordsRefs)
                        await $_getPrefetchedData<
                          Workout,
                          $WorkoutsTable,
                          PersonalRecord
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutsTableReferences
                              ._personalRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).personalRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseProgressionStatesRefs)
                        await $_getPrefetchedData<
                          Workout,
                          $WorkoutsTable,
                          ExerciseProgressionState
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutsTableReferences
                              ._exerciseProgressionStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseProgressionStatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.lastCountedWorkoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (activeWorkoutStatesRefs)
                        await $_getPrefetchedData<
                          Workout,
                          $WorkoutsTable,
                          ActiveWorkoutState
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutsTableReferences
                              ._activeWorkoutStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).activeWorkoutStatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutId == item.id,
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

typedef $$WorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutsTable,
      Workout,
      $$WorkoutsTableFilterComposer,
      $$WorkoutsTableOrderingComposer,
      $$WorkoutsTableAnnotationComposer,
      $$WorkoutsTableCreateCompanionBuilder,
      $$WorkoutsTableUpdateCompanionBuilder,
      (Workout, $$WorkoutsTableReferences),
      Workout,
      PrefetchHooks Function({
        bool workoutTagLinksRefs,
        bool workoutExercisesRefs,
        bool personalRecordsRefs,
        bool exerciseProgressionStatesRefs,
        bool activeWorkoutStatesRefs,
      })
    >;
typedef $$WorkoutTagLinksTableCreateCompanionBuilder =
    WorkoutTagLinksCompanion Function({
      required String workoutId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$WorkoutTagLinksTableUpdateCompanionBuilder =
    WorkoutTagLinksCompanion Function({
      Value<String> workoutId,
      Value<String> tagId,
      Value<int> rowid,
    });

final class $$WorkoutTagLinksTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkoutTagLinksTable, WorkoutTagLink> {
  $$WorkoutTagLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias('WorkoutTagLinks__workoutId__Workouts__id');

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<String>('workoutId')!;

    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkoutTagsTable _tagIdTable(_$AppDatabase db) =>
      db.workoutTags.createAlias('WorkoutTagLinks__tagId__WorkoutTags__id');

  $$WorkoutTagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tagId')!;

    final manager = $$WorkoutTagsTableTableManager(
      $_db,
      $_db.workoutTags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutTagLinksTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutTagLinksTable> {
  $$WorkoutTagLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutTagsTableFilterComposer get tagId {
    final $$WorkoutTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.workoutTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTagsTableFilterComposer(
            $db: $db,
            $table: $db.workoutTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutTagLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutTagLinksTable> {
  $$WorkoutTagLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutTagsTableOrderingComposer get tagId {
    final $$WorkoutTagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.workoutTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTagsTableOrderingComposer(
            $db: $db,
            $table: $db.workoutTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutTagLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutTagLinksTable> {
  $$WorkoutTagLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutTagsTableAnnotationComposer get tagId {
    final $$WorkoutTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.workoutTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutTagLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutTagLinksTable,
          WorkoutTagLink,
          $$WorkoutTagLinksTableFilterComposer,
          $$WorkoutTagLinksTableOrderingComposer,
          $$WorkoutTagLinksTableAnnotationComposer,
          $$WorkoutTagLinksTableCreateCompanionBuilder,
          $$WorkoutTagLinksTableUpdateCompanionBuilder,
          (WorkoutTagLink, $$WorkoutTagLinksTableReferences),
          WorkoutTagLink,
          PrefetchHooks Function({bool workoutId, bool tagId})
        > {
  $$WorkoutTagLinksTableTableManager(
    _$AppDatabase db,
    $WorkoutTagLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutTagLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutTagLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutTagLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> workoutId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTagLinksCompanion(
                workoutId: workoutId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String workoutId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTagLinksCompanion.insert(
                workoutId: workoutId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutTagLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutId = false, tagId = false}) {
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
                    if (workoutId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workoutId,
                                referencedTable:
                                    $$WorkoutTagLinksTableReferences
                                        ._workoutIdTable(db),
                                referencedColumn:
                                    $$WorkoutTagLinksTableReferences
                                        ._workoutIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable:
                                    $$WorkoutTagLinksTableReferences
                                        ._tagIdTable(db),
                                referencedColumn:
                                    $$WorkoutTagLinksTableReferences
                                        ._tagIdTable(db)
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

typedef $$WorkoutTagLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutTagLinksTable,
      WorkoutTagLink,
      $$WorkoutTagLinksTableFilterComposer,
      $$WorkoutTagLinksTableOrderingComposer,
      $$WorkoutTagLinksTableAnnotationComposer,
      $$WorkoutTagLinksTableCreateCompanionBuilder,
      $$WorkoutTagLinksTableUpdateCompanionBuilder,
      (WorkoutTagLink, $$WorkoutTagLinksTableReferences),
      WorkoutTagLink,
      PrefetchHooks Function({bool workoutId, bool tagId})
    >;
typedef $$WorkoutExercisesTableCreateCompanionBuilder =
    WorkoutExercisesCompanion Function({
      required String createdAt,
      required String updatedAt,
      Value<bool> isDeleted,
      required String id,
      required String workoutId,
      required String exerciseId,
      required int orderIndex,
      Value<String?> comment,
      Value<String> progressionDecision,
      Value<int> rowid,
    });
typedef $$WorkoutExercisesTableUpdateCompanionBuilder =
    WorkoutExercisesCompanion Function({
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<bool> isDeleted,
      Value<String> id,
      Value<String> workoutId,
      Value<String> exerciseId,
      Value<int> orderIndex,
      Value<String?> comment,
      Value<String> progressionDecision,
      Value<int> rowid,
    });

final class $$WorkoutExercisesTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkoutExercisesTable, WorkoutExercise> {
  $$WorkoutExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias('WorkoutExercises__workoutId__Workouts__id');

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<String>('workoutId')!;

    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('WorkoutExercises__exerciseId__Exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exerciseId')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExerciseSetsTable, List<ExerciseSet>>
  _exerciseSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseSets,
    aliasName: 'WorkoutExercises__id__ExerciseSets__workoutExerciseId',
  );

  $$ExerciseSetsTableProcessedTableManager get exerciseSetsRefs {
    final manager = $$ExerciseSetsTableTableManager($_db, $_db.exerciseSets)
        .filter(
          (f) => f.workoutExerciseId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_exerciseSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get progressionDecision => $composableBuilder(
    column: $table.progressionDecision,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> exerciseSetsRefs(
    Expression<bool> Function($$ExerciseSetsTableFilterComposer f) f,
  ) {
    final $$ExerciseSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.workoutExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSetsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get progressionDecision => $composableBuilder(
    column: $table.progressionDecision,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<String> get progressionDecision => $composableBuilder(
    column: $table.progressionDecision,
    builder: (column) => column,
  );

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> exerciseSetsRefs<T extends Object>(
    Expression<T> Function($$ExerciseSetsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.workoutExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutExercisesTable,
          WorkoutExercise,
          $$WorkoutExercisesTableFilterComposer,
          $$WorkoutExercisesTableOrderingComposer,
          $$WorkoutExercisesTableAnnotationComposer,
          $$WorkoutExercisesTableCreateCompanionBuilder,
          $$WorkoutExercisesTableUpdateCompanionBuilder,
          (WorkoutExercise, $$WorkoutExercisesTableReferences),
          WorkoutExercise,
          PrefetchHooks Function({
            bool workoutId,
            bool exerciseId,
            bool exerciseSetsRefs,
          })
        > {
  $$WorkoutExercisesTableTableManager(
    _$AppDatabase db,
    $WorkoutExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> workoutId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<String> progressionDecision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutExercisesCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                workoutId: workoutId,
                exerciseId: exerciseId,
                orderIndex: orderIndex,
                comment: comment,
                progressionDecision: progressionDecision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String createdAt,
                required String updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                required String id,
                required String workoutId,
                required String exerciseId,
                required int orderIndex,
                Value<String?> comment = const Value.absent(),
                Value<String> progressionDecision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutExercisesCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                workoutId: workoutId,
                exerciseId: exerciseId,
                orderIndex: orderIndex,
                comment: comment,
                progressionDecision: progressionDecision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutId = false,
                exerciseId = false,
                exerciseSetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseSetsRefs) db.exerciseSets,
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
                        if (workoutId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutId,
                                    referencedTable:
                                        $$WorkoutExercisesTableReferences
                                            ._workoutIdTable(db),
                                    referencedColumn:
                                        $$WorkoutExercisesTableReferences
                                            ._workoutIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (exerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseId,
                                    referencedTable:
                                        $$WorkoutExercisesTableReferences
                                            ._exerciseIdTable(db),
                                    referencedColumn:
                                        $$WorkoutExercisesTableReferences
                                            ._exerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseSetsRefs)
                        await $_getPrefetchedData<
                          WorkoutExercise,
                          $WorkoutExercisesTable,
                          ExerciseSet
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutExercisesTableReferences
                              ._exerciseSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutExerciseId == item.id,
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

typedef $$WorkoutExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutExercisesTable,
      WorkoutExercise,
      $$WorkoutExercisesTableFilterComposer,
      $$WorkoutExercisesTableOrderingComposer,
      $$WorkoutExercisesTableAnnotationComposer,
      $$WorkoutExercisesTableCreateCompanionBuilder,
      $$WorkoutExercisesTableUpdateCompanionBuilder,
      (WorkoutExercise, $$WorkoutExercisesTableReferences),
      WorkoutExercise,
      PrefetchHooks Function({
        bool workoutId,
        bool exerciseId,
        bool exerciseSetsRefs,
      })
    >;
typedef $$ExerciseSetsTableCreateCompanionBuilder =
    ExerciseSetsCompanion Function({
      required String createdAt,
      required String updatedAt,
      Value<bool> isDeleted,
      required String id,
      required String workoutExerciseId,
      required int setNumber,
      Value<bool> isCompleted,
      Value<double?> plannedWeightKg,
      Value<int?> plannedReps,
      Value<double?> actualWeightKg,
      Value<int?> actualReps,
      Value<double?> rpe,
      Value<int?> rir,
      Value<int?> plannedDurationSec,
      Value<int?> actualDurationSec,
      Value<double?> plannedDistanceM,
      Value<double?> actualDistanceM,
      Value<double?> resistance,
      Value<double?> inclinePercent,
      Value<int?> avgHeartRate,
      Value<String> side,
      Value<String?> comment,
      Value<int> rowid,
    });
typedef $$ExerciseSetsTableUpdateCompanionBuilder =
    ExerciseSetsCompanion Function({
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<bool> isDeleted,
      Value<String> id,
      Value<String> workoutExerciseId,
      Value<int> setNumber,
      Value<bool> isCompleted,
      Value<double?> plannedWeightKg,
      Value<int?> plannedReps,
      Value<double?> actualWeightKg,
      Value<int?> actualReps,
      Value<double?> rpe,
      Value<int?> rir,
      Value<int?> plannedDurationSec,
      Value<int?> actualDurationSec,
      Value<double?> plannedDistanceM,
      Value<double?> actualDistanceM,
      Value<double?> resistance,
      Value<double?> inclinePercent,
      Value<int?> avgHeartRate,
      Value<String> side,
      Value<String?> comment,
      Value<int> rowid,
    });

final class $$ExerciseSetsTableReferences
    extends BaseReferences<_$AppDatabase, $ExerciseSetsTable, ExerciseSet> {
  $$ExerciseSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutExercisesTable _workoutExerciseIdTable(_$AppDatabase db) => db
      .workoutExercises
      .createAlias('ExerciseSets__workoutExerciseId__WorkoutExercises__id');

  $$WorkoutExercisesTableProcessedTableManager get workoutExerciseId {
    final $_column = $_itemColumn<String>('workoutExerciseId')!;

    final manager = $$WorkoutExercisesTableTableManager(
      $_db,
      $_db.workoutExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PersonalRecordsTable, List<PersonalRecord>>
  _personalRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personalRecords,
    aliasName: 'ExerciseSets__id__PersonalRecords__exerciseSetId',
  );

  $$PersonalRecordsTableProcessedTableManager get personalRecordsRefs {
    final manager = $$PersonalRecordsTableTableManager(
      $_db,
      $_db.personalRecords,
    ).filter((f) => f.exerciseSetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExerciseSetsTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseSetsTable> {
  $$ExerciseSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedReps => $composableBuilder(
    column: $table.plannedReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualWeightKg => $composableBuilder(
    column: $table.actualWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualReps => $composableBuilder(
    column: $table.actualReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rir => $composableBuilder(
    column: $table.rir,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedDurationSec => $composableBuilder(
    column: $table.plannedDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualDurationSec => $composableBuilder(
    column: $table.actualDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedDistanceM => $composableBuilder(
    column: $table.plannedDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualDistanceM => $composableBuilder(
    column: $table.actualDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get resistance => $composableBuilder(
    column: $table.resistance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get inclinePercent => $composableBuilder(
    column: $table.inclinePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutExercisesTableFilterComposer get workoutExerciseId {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutExerciseId,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> personalRecordsRefs(
    Expression<bool> Function($$PersonalRecordsTableFilterComposer f) f,
  ) {
    final $$PersonalRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.exerciseSetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableFilterComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciseSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseSetsTable> {
  $$ExerciseSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedReps => $composableBuilder(
    column: $table.plannedReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualWeightKg => $composableBuilder(
    column: $table.actualWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualReps => $composableBuilder(
    column: $table.actualReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rir => $composableBuilder(
    column: $table.rir,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedDurationSec => $composableBuilder(
    column: $table.plannedDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualDurationSec => $composableBuilder(
    column: $table.actualDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedDistanceM => $composableBuilder(
    column: $table.plannedDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualDistanceM => $composableBuilder(
    column: $table.actualDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get resistance => $composableBuilder(
    column: $table.resistance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get inclinePercent => $composableBuilder(
    column: $table.inclinePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutExercisesTableOrderingComposer get workoutExerciseId {
    final $$WorkoutExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutExerciseId,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseSetsTable> {
  $$ExerciseSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get setNumber =>
      $composableBuilder(column: $table.setNumber, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedReps => $composableBuilder(
    column: $table.plannedReps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualWeightKg => $composableBuilder(
    column: $table.actualWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualReps => $composableBuilder(
    column: $table.actualReps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<int> get rir =>
      $composableBuilder(column: $table.rir, builder: (column) => column);

  GeneratedColumn<int> get plannedDurationSec => $composableBuilder(
    column: $table.plannedDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualDurationSec => $composableBuilder(
    column: $table.actualDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<double> get plannedDistanceM => $composableBuilder(
    column: $table.plannedDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualDistanceM => $composableBuilder(
    column: $table.actualDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<double> get resistance => $composableBuilder(
    column: $table.resistance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get inclinePercent => $composableBuilder(
    column: $table.inclinePercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  $$WorkoutExercisesTableAnnotationComposer get workoutExerciseId {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutExerciseId,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> personalRecordsRefs<T extends Object>(
    Expression<T> Function($$PersonalRecordsTableAnnotationComposer a) f,
  ) {
    final $$PersonalRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.exerciseSetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciseSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseSetsTable,
          ExerciseSet,
          $$ExerciseSetsTableFilterComposer,
          $$ExerciseSetsTableOrderingComposer,
          $$ExerciseSetsTableAnnotationComposer,
          $$ExerciseSetsTableCreateCompanionBuilder,
          $$ExerciseSetsTableUpdateCompanionBuilder,
          (ExerciseSet, $$ExerciseSetsTableReferences),
          ExerciseSet,
          PrefetchHooks Function({
            bool workoutExerciseId,
            bool personalRecordsRefs,
          })
        > {
  $$ExerciseSetsTableTableManager(_$AppDatabase db, $ExerciseSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> workoutExerciseId = const Value.absent(),
                Value<int> setNumber = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<double?> plannedWeightKg = const Value.absent(),
                Value<int?> plannedReps = const Value.absent(),
                Value<double?> actualWeightKg = const Value.absent(),
                Value<int?> actualReps = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<int?> rir = const Value.absent(),
                Value<int?> plannedDurationSec = const Value.absent(),
                Value<int?> actualDurationSec = const Value.absent(),
                Value<double?> plannedDistanceM = const Value.absent(),
                Value<double?> actualDistanceM = const Value.absent(),
                Value<double?> resistance = const Value.absent(),
                Value<double?> inclinePercent = const Value.absent(),
                Value<int?> avgHeartRate = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseSetsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                workoutExerciseId: workoutExerciseId,
                setNumber: setNumber,
                isCompleted: isCompleted,
                plannedWeightKg: plannedWeightKg,
                plannedReps: plannedReps,
                actualWeightKg: actualWeightKg,
                actualReps: actualReps,
                rpe: rpe,
                rir: rir,
                plannedDurationSec: plannedDurationSec,
                actualDurationSec: actualDurationSec,
                plannedDistanceM: plannedDistanceM,
                actualDistanceM: actualDistanceM,
                resistance: resistance,
                inclinePercent: inclinePercent,
                avgHeartRate: avgHeartRate,
                side: side,
                comment: comment,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String createdAt,
                required String updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                required String id,
                required String workoutExerciseId,
                required int setNumber,
                Value<bool> isCompleted = const Value.absent(),
                Value<double?> plannedWeightKg = const Value.absent(),
                Value<int?> plannedReps = const Value.absent(),
                Value<double?> actualWeightKg = const Value.absent(),
                Value<int?> actualReps = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<int?> rir = const Value.absent(),
                Value<int?> plannedDurationSec = const Value.absent(),
                Value<int?> actualDurationSec = const Value.absent(),
                Value<double?> plannedDistanceM = const Value.absent(),
                Value<double?> actualDistanceM = const Value.absent(),
                Value<double?> resistance = const Value.absent(),
                Value<double?> inclinePercent = const Value.absent(),
                Value<int?> avgHeartRate = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseSetsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                workoutExerciseId: workoutExerciseId,
                setNumber: setNumber,
                isCompleted: isCompleted,
                plannedWeightKg: plannedWeightKg,
                plannedReps: plannedReps,
                actualWeightKg: actualWeightKg,
                actualReps: actualReps,
                rpe: rpe,
                rir: rir,
                plannedDurationSec: plannedDurationSec,
                actualDurationSec: actualDurationSec,
                plannedDistanceM: plannedDistanceM,
                actualDistanceM: actualDistanceM,
                resistance: resistance,
                inclinePercent: inclinePercent,
                avgHeartRate: avgHeartRate,
                side: side,
                comment: comment,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutExerciseId = false, personalRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (personalRecordsRefs) db.personalRecords,
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
                        if (workoutExerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutExerciseId,
                                    referencedTable:
                                        $$ExerciseSetsTableReferences
                                            ._workoutExerciseIdTable(db),
                                    referencedColumn:
                                        $$ExerciseSetsTableReferences
                                            ._workoutExerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (personalRecordsRefs)
                        await $_getPrefetchedData<
                          ExerciseSet,
                          $ExerciseSetsTable,
                          PersonalRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ExerciseSetsTableReferences
                              ._personalRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExerciseSetsTableReferences(
                                db,
                                table,
                                p0,
                              ).personalRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseSetId == item.id,
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

typedef $$ExerciseSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseSetsTable,
      ExerciseSet,
      $$ExerciseSetsTableFilterComposer,
      $$ExerciseSetsTableOrderingComposer,
      $$ExerciseSetsTableAnnotationComposer,
      $$ExerciseSetsTableCreateCompanionBuilder,
      $$ExerciseSetsTableUpdateCompanionBuilder,
      (ExerciseSet, $$ExerciseSetsTableReferences),
      ExerciseSet,
      PrefetchHooks Function({bool workoutExerciseId, bool personalRecordsRefs})
    >;
typedef $$WorkoutTemplatesTableCreateCompanionBuilder =
    WorkoutTemplatesCompanion Function({
      required String createdAt,
      required String updatedAt,
      Value<bool> isDeleted,
      required String id,
      required String name,
      Value<String?> comment,
      Value<bool> isArchived,
      Value<int> rowid,
    });
typedef $$WorkoutTemplatesTableUpdateCompanionBuilder =
    WorkoutTemplatesCompanion Function({
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<bool> isDeleted,
      Value<String> id,
      Value<String> name,
      Value<String?> comment,
      Value<bool> isArchived,
      Value<int> rowid,
    });

final class $$WorkoutTemplatesTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkoutTemplatesTable, WorkoutTemplate> {
  $$WorkoutTemplatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TemplateExercisesTable, List<TemplateExercise>>
  _templateExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.templateExercises,
        aliasName: 'WorkoutTemplates__id__TemplateExercises__templateId',
      );

  $$TemplateExercisesTableProcessedTableManager get templateExercisesRefs {
    final manager = $$TemplateExercisesTableTableManager(
      $_db,
      $_db.templateExercises,
    ).filter((f) => f.templateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _templateExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutTemplatesTable> {
  $$WorkoutTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> templateExercisesRefs(
    Expression<bool> Function($$TemplateExercisesTableFilterComposer f) f,
  ) {
    final $$TemplateExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.templateExercises,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplateExercisesTableFilterComposer(
            $db: $db,
            $table: $db.templateExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutTemplatesTable> {
  $$WorkoutTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutTemplatesTable> {
  $$WorkoutTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  Expression<T> templateExercisesRefs<T extends Object>(
    Expression<T> Function($$TemplateExercisesTableAnnotationComposer a) f,
  ) {
    final $$TemplateExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.templateExercises,
          getReferencedColumn: (t) => t.templateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TemplateExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.templateExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkoutTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutTemplatesTable,
          WorkoutTemplate,
          $$WorkoutTemplatesTableFilterComposer,
          $$WorkoutTemplatesTableOrderingComposer,
          $$WorkoutTemplatesTableAnnotationComposer,
          $$WorkoutTemplatesTableCreateCompanionBuilder,
          $$WorkoutTemplatesTableUpdateCompanionBuilder,
          (WorkoutTemplate, $$WorkoutTemplatesTableReferences),
          WorkoutTemplate,
          PrefetchHooks Function({bool templateExercisesRefs})
        > {
  $$WorkoutTemplatesTableTableManager(
    _$AppDatabase db,
    $WorkoutTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTemplatesCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                name: name,
                comment: comment,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String createdAt,
                required String updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                required String id,
                required String name,
                Value<String?> comment = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTemplatesCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                name: name,
                comment: comment,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutTemplatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({templateExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (templateExercisesRefs) db.templateExercises,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (templateExercisesRefs)
                    await $_getPrefetchedData<
                      WorkoutTemplate,
                      $WorkoutTemplatesTable,
                      TemplateExercise
                    >(
                      currentTable: table,
                      referencedTable: $$WorkoutTemplatesTableReferences
                          ._templateExercisesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WorkoutTemplatesTableReferences(
                            db,
                            table,
                            p0,
                          ).templateExercisesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.templateId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutTemplatesTable,
      WorkoutTemplate,
      $$WorkoutTemplatesTableFilterComposer,
      $$WorkoutTemplatesTableOrderingComposer,
      $$WorkoutTemplatesTableAnnotationComposer,
      $$WorkoutTemplatesTableCreateCompanionBuilder,
      $$WorkoutTemplatesTableUpdateCompanionBuilder,
      (WorkoutTemplate, $$WorkoutTemplatesTableReferences),
      WorkoutTemplate,
      PrefetchHooks Function({bool templateExercisesRefs})
    >;
typedef $$TemplateExercisesTableCreateCompanionBuilder =
    TemplateExercisesCompanion Function({
      required String createdAt,
      required String updatedAt,
      Value<bool> isDeleted,
      required String id,
      required String templateId,
      required String exerciseId,
      required int orderIndex,
      Value<String?> comment,
      Value<int> rowid,
    });
typedef $$TemplateExercisesTableUpdateCompanionBuilder =
    TemplateExercisesCompanion Function({
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<bool> isDeleted,
      Value<String> id,
      Value<String> templateId,
      Value<String> exerciseId,
      Value<int> orderIndex,
      Value<String?> comment,
      Value<int> rowid,
    });

final class $$TemplateExercisesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TemplateExercisesTable,
          TemplateExercise
        > {
  $$TemplateExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutTemplatesTable _templateIdTable(_$AppDatabase db) => db
      .workoutTemplates
      .createAlias('TemplateExercises__templateId__WorkoutTemplates__id');

  $$WorkoutTemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<String>('templateId')!;

    final manager = $$WorkoutTemplatesTableTableManager(
      $_db,
      $_db.workoutTemplates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('TemplateExercises__exerciseId__Exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exerciseId')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TemplateSetsTable, List<TemplateSet>>
  _templateSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.templateSets,
    aliasName: 'TemplateExercises__id__TemplateSets__templateExerciseId',
  );

  $$TemplateSetsTableProcessedTableManager get templateSetsRefs {
    final manager = $$TemplateSetsTableTableManager($_db, $_db.templateSets)
        .filter(
          (f) => f.templateExerciseId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_templateSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TemplateExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $TemplateExercisesTable> {
  $$TemplateExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutTemplatesTableFilterComposer get templateId {
    final $$WorkoutTemplatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.workoutTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTemplatesTableFilterComposer(
            $db: $db,
            $table: $db.workoutTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> templateSetsRefs(
    Expression<bool> Function($$TemplateSetsTableFilterComposer f) f,
  ) {
    final $$TemplateSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.templateSets,
      getReferencedColumn: (t) => t.templateExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplateSetsTableFilterComposer(
            $db: $db,
            $table: $db.templateSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TemplateExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $TemplateExercisesTable> {
  $$TemplateExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutTemplatesTableOrderingComposer get templateId {
    final $$WorkoutTemplatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.workoutTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTemplatesTableOrderingComposer(
            $db: $db,
            $table: $db.workoutTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemplateExercisesTable> {
  $$TemplateExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  $$WorkoutTemplatesTableAnnotationComposer get templateId {
    final $$WorkoutTemplatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.workoutTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTemplatesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> templateSetsRefs<T extends Object>(
    Expression<T> Function($$TemplateSetsTableAnnotationComposer a) f,
  ) {
    final $$TemplateSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.templateSets,
      getReferencedColumn: (t) => t.templateExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplateSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.templateSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TemplateExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TemplateExercisesTable,
          TemplateExercise,
          $$TemplateExercisesTableFilterComposer,
          $$TemplateExercisesTableOrderingComposer,
          $$TemplateExercisesTableAnnotationComposer,
          $$TemplateExercisesTableCreateCompanionBuilder,
          $$TemplateExercisesTableUpdateCompanionBuilder,
          (TemplateExercise, $$TemplateExercisesTableReferences),
          TemplateExercise,
          PrefetchHooks Function({
            bool templateId,
            bool exerciseId,
            bool templateSetsRefs,
          })
        > {
  $$TemplateExercisesTableTableManager(
    _$AppDatabase db,
    $TemplateExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplateExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplateExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplateExercisesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemplateExercisesCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                templateId: templateId,
                exerciseId: exerciseId,
                orderIndex: orderIndex,
                comment: comment,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String createdAt,
                required String updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                required String id,
                required String templateId,
                required String exerciseId,
                required int orderIndex,
                Value<String?> comment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemplateExercisesCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                templateId: templateId,
                exerciseId: exerciseId,
                orderIndex: orderIndex,
                comment: comment,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TemplateExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                templateId = false,
                exerciseId = false,
                templateSetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (templateSetsRefs) db.templateSets,
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
                        if (templateId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.templateId,
                                    referencedTable:
                                        $$TemplateExercisesTableReferences
                                            ._templateIdTable(db),
                                    referencedColumn:
                                        $$TemplateExercisesTableReferences
                                            ._templateIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (exerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseId,
                                    referencedTable:
                                        $$TemplateExercisesTableReferences
                                            ._exerciseIdTable(db),
                                    referencedColumn:
                                        $$TemplateExercisesTableReferences
                                            ._exerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (templateSetsRefs)
                        await $_getPrefetchedData<
                          TemplateExercise,
                          $TemplateExercisesTable,
                          TemplateSet
                        >(
                          currentTable: table,
                          referencedTable: $$TemplateExercisesTableReferences
                              ._templateSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TemplateExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).templateSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.templateExerciseId == item.id,
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

typedef $$TemplateExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TemplateExercisesTable,
      TemplateExercise,
      $$TemplateExercisesTableFilterComposer,
      $$TemplateExercisesTableOrderingComposer,
      $$TemplateExercisesTableAnnotationComposer,
      $$TemplateExercisesTableCreateCompanionBuilder,
      $$TemplateExercisesTableUpdateCompanionBuilder,
      (TemplateExercise, $$TemplateExercisesTableReferences),
      TemplateExercise,
      PrefetchHooks Function({
        bool templateId,
        bool exerciseId,
        bool templateSetsRefs,
      })
    >;
typedef $$TemplateSetsTableCreateCompanionBuilder =
    TemplateSetsCompanion Function({
      required String createdAt,
      required String updatedAt,
      Value<bool> isDeleted,
      required String id,
      required String templateExerciseId,
      required int setNumber,
      Value<double?> plannedWeightKg,
      Value<int?> plannedReps,
      Value<int?> plannedDurationSec,
      Value<double?> plannedDistanceM,
      Value<String> side,
      Value<int> rowid,
    });
typedef $$TemplateSetsTableUpdateCompanionBuilder =
    TemplateSetsCompanion Function({
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<bool> isDeleted,
      Value<String> id,
      Value<String> templateExerciseId,
      Value<int> setNumber,
      Value<double?> plannedWeightKg,
      Value<int?> plannedReps,
      Value<int?> plannedDurationSec,
      Value<double?> plannedDistanceM,
      Value<String> side,
      Value<int> rowid,
    });

final class $$TemplateSetsTableReferences
    extends BaseReferences<_$AppDatabase, $TemplateSetsTable, TemplateSet> {
  $$TemplateSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TemplateExercisesTable _templateExerciseIdTable(_$AppDatabase db) =>
      db.templateExercises.createAlias(
        'TemplateSets__templateExerciseId__TemplateExercises__id',
      );

  $$TemplateExercisesTableProcessedTableManager get templateExerciseId {
    final $_column = $_itemColumn<String>('templateExerciseId')!;

    final manager = $$TemplateExercisesTableTableManager(
      $_db,
      $_db.templateExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TemplateSetsTableFilterComposer
    extends Composer<_$AppDatabase, $TemplateSetsTable> {
  $$TemplateSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedReps => $composableBuilder(
    column: $table.plannedReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedDurationSec => $composableBuilder(
    column: $table.plannedDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedDistanceM => $composableBuilder(
    column: $table.plannedDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  $$TemplateExercisesTableFilterComposer get templateExerciseId {
    final $$TemplateExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateExerciseId,
      referencedTable: $db.templateExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplateExercisesTableFilterComposer(
            $db: $db,
            $table: $db.templateExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $TemplateSetsTable> {
  $$TemplateSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedReps => $composableBuilder(
    column: $table.plannedReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedDurationSec => $composableBuilder(
    column: $table.plannedDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedDistanceM => $composableBuilder(
    column: $table.plannedDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  $$TemplateExercisesTableOrderingComposer get templateExerciseId {
    final $$TemplateExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateExerciseId,
      referencedTable: $db.templateExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplateExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.templateExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemplateSetsTable> {
  $$TemplateSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get setNumber =>
      $composableBuilder(column: $table.setNumber, builder: (column) => column);

  GeneratedColumn<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedReps => $composableBuilder(
    column: $table.plannedReps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedDurationSec => $composableBuilder(
    column: $table.plannedDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<double> get plannedDistanceM => $composableBuilder(
    column: $table.plannedDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  $$TemplateExercisesTableAnnotationComposer get templateExerciseId {
    final $$TemplateExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.templateExerciseId,
          referencedTable: $db.templateExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TemplateExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.templateExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TemplateSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TemplateSetsTable,
          TemplateSet,
          $$TemplateSetsTableFilterComposer,
          $$TemplateSetsTableOrderingComposer,
          $$TemplateSetsTableAnnotationComposer,
          $$TemplateSetsTableCreateCompanionBuilder,
          $$TemplateSetsTableUpdateCompanionBuilder,
          (TemplateSet, $$TemplateSetsTableReferences),
          TemplateSet,
          PrefetchHooks Function({bool templateExerciseId})
        > {
  $$TemplateSetsTableTableManager(_$AppDatabase db, $TemplateSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplateSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplateSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplateSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> templateExerciseId = const Value.absent(),
                Value<int> setNumber = const Value.absent(),
                Value<double?> plannedWeightKg = const Value.absent(),
                Value<int?> plannedReps = const Value.absent(),
                Value<int?> plannedDurationSec = const Value.absent(),
                Value<double?> plannedDistanceM = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemplateSetsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                templateExerciseId: templateExerciseId,
                setNumber: setNumber,
                plannedWeightKg: plannedWeightKg,
                plannedReps: plannedReps,
                plannedDurationSec: plannedDurationSec,
                plannedDistanceM: plannedDistanceM,
                side: side,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String createdAt,
                required String updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                required String id,
                required String templateExerciseId,
                required int setNumber,
                Value<double?> plannedWeightKg = const Value.absent(),
                Value<int?> plannedReps = const Value.absent(),
                Value<int?> plannedDurationSec = const Value.absent(),
                Value<double?> plannedDistanceM = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemplateSetsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                templateExerciseId: templateExerciseId,
                setNumber: setNumber,
                plannedWeightKg: plannedWeightKg,
                plannedReps: plannedReps,
                plannedDurationSec: plannedDurationSec,
                plannedDistanceM: plannedDistanceM,
                side: side,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TemplateSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({templateExerciseId = false}) {
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
                    if (templateExerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.templateExerciseId,
                                referencedTable: $$TemplateSetsTableReferences
                                    ._templateExerciseIdTable(db),
                                referencedColumn: $$TemplateSetsTableReferences
                                    ._templateExerciseIdTable(db)
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

typedef $$TemplateSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TemplateSetsTable,
      TemplateSet,
      $$TemplateSetsTableFilterComposer,
      $$TemplateSetsTableOrderingComposer,
      $$TemplateSetsTableAnnotationComposer,
      $$TemplateSetsTableCreateCompanionBuilder,
      $$TemplateSetsTableUpdateCompanionBuilder,
      (TemplateSet, $$TemplateSetsTableReferences),
      TemplateSet,
      PrefetchHooks Function({bool templateExerciseId})
    >;
typedef $$BodyMeasurementsTableCreateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      required String createdAt,
      required String updatedAt,
      Value<bool> isDeleted,
      required String id,
      required String measurementTypeId,
      required String date,
      required double valueMetric,
      Value<String> source,
      Value<int> rowid,
    });
typedef $$BodyMeasurementsTableUpdateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<bool> isDeleted,
      Value<String> id,
      Value<String> measurementTypeId,
      Value<String> date,
      Value<double> valueMetric,
      Value<String> source,
      Value<int> rowid,
    });

final class $$BodyMeasurementsTableReferences
    extends
        BaseReferences<_$AppDatabase, $BodyMeasurementsTable, BodyMeasurement> {
  $$BodyMeasurementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MeasurementTypesTable _measurementTypeIdTable(_$AppDatabase db) => db
      .measurementTypes
      .createAlias('BodyMeasurements__measurementTypeId__MeasurementTypes__id');

  $$MeasurementTypesTableProcessedTableManager get measurementTypeId {
    final $_column = $_itemColumn<String>('measurementTypeId')!;

    final manager = $$MeasurementTypesTableTableManager(
      $_db,
      $_db.measurementTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_measurementTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BodyMeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valueMetric => $composableBuilder(
    column: $table.valueMetric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  $$MeasurementTypesTableFilterComposer get measurementTypeId {
    final $$MeasurementTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.measurementTypeId,
      referencedTable: $db.measurementTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementTypesTableFilterComposer(
            $db: $db,
            $table: $db.measurementTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BodyMeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valueMetric => $composableBuilder(
    column: $table.valueMetric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  $$MeasurementTypesTableOrderingComposer get measurementTypeId {
    final $$MeasurementTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.measurementTypeId,
      referencedTable: $db.measurementTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementTypesTableOrderingComposer(
            $db: $db,
            $table: $db.measurementTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BodyMeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get valueMetric => $composableBuilder(
    column: $table.valueMetric,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  $$MeasurementTypesTableAnnotationComposer get measurementTypeId {
    final $$MeasurementTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.measurementTypeId,
      referencedTable: $db.measurementTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.measurementTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BodyMeasurementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyMeasurementsTable,
          BodyMeasurement,
          $$BodyMeasurementsTableFilterComposer,
          $$BodyMeasurementsTableOrderingComposer,
          $$BodyMeasurementsTableAnnotationComposer,
          $$BodyMeasurementsTableCreateCompanionBuilder,
          $$BodyMeasurementsTableUpdateCompanionBuilder,
          (BodyMeasurement, $$BodyMeasurementsTableReferences),
          BodyMeasurement,
          PrefetchHooks Function({bool measurementTypeId})
        > {
  $$BodyMeasurementsTableTableManager(
    _$AppDatabase db,
    $BodyMeasurementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyMeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> measurementTypeId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<double> valueMetric = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodyMeasurementsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                measurementTypeId: measurementTypeId,
                date: date,
                valueMetric: valueMetric,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String createdAt,
                required String updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                required String id,
                required String measurementTypeId,
                required String date,
                required double valueMetric,
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodyMeasurementsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                id: id,
                measurementTypeId: measurementTypeId,
                date: date,
                valueMetric: valueMetric,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BodyMeasurementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({measurementTypeId = false}) {
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
                    if (measurementTypeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.measurementTypeId,
                                referencedTable:
                                    $$BodyMeasurementsTableReferences
                                        ._measurementTypeIdTable(db),
                                referencedColumn:
                                    $$BodyMeasurementsTableReferences
                                        ._measurementTypeIdTable(db)
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

typedef $$BodyMeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyMeasurementsTable,
      BodyMeasurement,
      $$BodyMeasurementsTableFilterComposer,
      $$BodyMeasurementsTableOrderingComposer,
      $$BodyMeasurementsTableAnnotationComposer,
      $$BodyMeasurementsTableCreateCompanionBuilder,
      $$BodyMeasurementsTableUpdateCompanionBuilder,
      (BodyMeasurement, $$BodyMeasurementsTableReferences),
      BodyMeasurement,
      PrefetchHooks Function({bool measurementTypeId})
    >;
typedef $$PersonalRecordsTableCreateCompanionBuilder =
    PersonalRecordsCompanion Function({
      required String exerciseId,
      required String recordType,
      Value<double?> keyValue,
      required double value,
      required String workoutId,
      Value<String?> exerciseSetId,
      required String achievedAt,
      required String computedAt,
      Value<int> rowid,
    });
typedef $$PersonalRecordsTableUpdateCompanionBuilder =
    PersonalRecordsCompanion Function({
      Value<String> exerciseId,
      Value<String> recordType,
      Value<double?> keyValue,
      Value<double> value,
      Value<String> workoutId,
      Value<String?> exerciseSetId,
      Value<String> achievedAt,
      Value<String> computedAt,
      Value<int> rowid,
    });

final class $$PersonalRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PersonalRecordsTable, PersonalRecord> {
  $$PersonalRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('PersonalRecords__exerciseId__Exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exerciseId')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias('PersonalRecords__workoutId__Workouts__id');

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<String>('workoutId')!;

    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExerciseSetsTable _exerciseSetIdTable(_$AppDatabase db) => db
      .exerciseSets
      .createAlias('PersonalRecords__exerciseSetId__ExerciseSets__id');

  $$ExerciseSetsTableProcessedTableManager? get exerciseSetId {
    final $_column = $_itemColumn<String>('exerciseSetId');
    if ($_column == null) return null;
    final manager = $$ExerciseSetsTableTableManager(
      $_db,
      $_db.exerciseSets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseSetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get keyValue => $composableBuilder(
    column: $table.keyValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseSetsTableFilterComposer get exerciseSetId {
    final $$ExerciseSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseSetId,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSetsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get keyValue => $composableBuilder(
    column: $table.keyValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseSetsTableOrderingComposer get exerciseSetId {
    final $$ExerciseSetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseSetId,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSetsTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get keyValue =>
      $composableBuilder(column: $table.keyValue, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => column,
  );

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseSetsTableAnnotationComposer get exerciseSetId {
    final $$ExerciseSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseSetId,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalRecordsTable,
          PersonalRecord,
          $$PersonalRecordsTableFilterComposer,
          $$PersonalRecordsTableOrderingComposer,
          $$PersonalRecordsTableAnnotationComposer,
          $$PersonalRecordsTableCreateCompanionBuilder,
          $$PersonalRecordsTableUpdateCompanionBuilder,
          (PersonalRecord, $$PersonalRecordsTableReferences),
          PersonalRecord,
          PrefetchHooks Function({
            bool exerciseId,
            bool workoutId,
            bool exerciseSetId,
          })
        > {
  $$PersonalRecordsTableTableManager(
    _$AppDatabase db,
    $PersonalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<String> recordType = const Value.absent(),
                Value<double?> keyValue = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<String> workoutId = const Value.absent(),
                Value<String?> exerciseSetId = const Value.absent(),
                Value<String> achievedAt = const Value.absent(),
                Value<String> computedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalRecordsCompanion(
                exerciseId: exerciseId,
                recordType: recordType,
                keyValue: keyValue,
                value: value,
                workoutId: workoutId,
                exerciseSetId: exerciseSetId,
                achievedAt: achievedAt,
                computedAt: computedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required String recordType,
                Value<double?> keyValue = const Value.absent(),
                required double value,
                required String workoutId,
                Value<String?> exerciseSetId = const Value.absent(),
                required String achievedAt,
                required String computedAt,
                Value<int> rowid = const Value.absent(),
              }) => PersonalRecordsCompanion.insert(
                exerciseId: exerciseId,
                recordType: recordType,
                keyValue: keyValue,
                value: value,
                workoutId: workoutId,
                exerciseSetId: exerciseSetId,
                achievedAt: achievedAt,
                computedAt: computedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonalRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({exerciseId = false, workoutId = false, exerciseSetId = false}) {
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
                        if (exerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseId,
                                    referencedTable:
                                        $$PersonalRecordsTableReferences
                                            ._exerciseIdTable(db),
                                    referencedColumn:
                                        $$PersonalRecordsTableReferences
                                            ._exerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (workoutId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutId,
                                    referencedTable:
                                        $$PersonalRecordsTableReferences
                                            ._workoutIdTable(db),
                                    referencedColumn:
                                        $$PersonalRecordsTableReferences
                                            ._workoutIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (exerciseSetId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseSetId,
                                    referencedTable:
                                        $$PersonalRecordsTableReferences
                                            ._exerciseSetIdTable(db),
                                    referencedColumn:
                                        $$PersonalRecordsTableReferences
                                            ._exerciseSetIdTable(db)
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

typedef $$PersonalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalRecordsTable,
      PersonalRecord,
      $$PersonalRecordsTableFilterComposer,
      $$PersonalRecordsTableOrderingComposer,
      $$PersonalRecordsTableAnnotationComposer,
      $$PersonalRecordsTableCreateCompanionBuilder,
      $$PersonalRecordsTableUpdateCompanionBuilder,
      (PersonalRecord, $$PersonalRecordsTableReferences),
      PersonalRecord,
      PrefetchHooks Function({
        bool exerciseId,
        bool workoutId,
        bool exerciseSetId,
      })
    >;
typedef $$ExerciseProgressionStatesTableCreateCompanionBuilder =
    ExerciseProgressionStatesCompanion Function({
      required String exerciseId,
      required int stagnationCount,
      Value<String?> lastCountedWorkoutId,
      required String computedAt,
      Value<int> rowid,
    });
typedef $$ExerciseProgressionStatesTableUpdateCompanionBuilder =
    ExerciseProgressionStatesCompanion Function({
      Value<String> exerciseId,
      Value<int> stagnationCount,
      Value<String?> lastCountedWorkoutId,
      Value<String> computedAt,
      Value<int> rowid,
    });

final class $$ExerciseProgressionStatesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExerciseProgressionStatesTable,
          ExerciseProgressionState
        > {
  $$ExerciseProgressionStatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) => db.exercises
      .createAlias('ExerciseProgressionStates__exerciseId__Exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exerciseId')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkoutsTable _lastCountedWorkoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias(
        'ExerciseProgressionStates__lastCountedWorkoutId__Workouts__id',
      );

  $$WorkoutsTableProcessedTableManager? get lastCountedWorkoutId {
    final $_column = $_itemColumn<String>('lastCountedWorkoutId');
    if ($_column == null) return null;
    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _lastCountedWorkoutIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseProgressionStatesTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseProgressionStatesTable> {
  $$ExerciseProgressionStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get stagnationCount => $composableBuilder(
    column: $table.stagnationCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutsTableFilterComposer get lastCountedWorkoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastCountedWorkoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseProgressionStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseProgressionStatesTable> {
  $$ExerciseProgressionStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get stagnationCount => $composableBuilder(
    column: $table.stagnationCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutsTableOrderingComposer get lastCountedWorkoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastCountedWorkoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseProgressionStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseProgressionStatesTable> {
  $$ExerciseProgressionStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get stagnationCount => $composableBuilder(
    column: $table.stagnationCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => column,
  );

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutsTableAnnotationComposer get lastCountedWorkoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastCountedWorkoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseProgressionStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseProgressionStatesTable,
          ExerciseProgressionState,
          $$ExerciseProgressionStatesTableFilterComposer,
          $$ExerciseProgressionStatesTableOrderingComposer,
          $$ExerciseProgressionStatesTableAnnotationComposer,
          $$ExerciseProgressionStatesTableCreateCompanionBuilder,
          $$ExerciseProgressionStatesTableUpdateCompanionBuilder,
          (
            ExerciseProgressionState,
            $$ExerciseProgressionStatesTableReferences,
          ),
          ExerciseProgressionState,
          PrefetchHooks Function({bool exerciseId, bool lastCountedWorkoutId})
        > {
  $$ExerciseProgressionStatesTableTableManager(
    _$AppDatabase db,
    $ExerciseProgressionStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseProgressionStatesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ExerciseProgressionStatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExerciseProgressionStatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<int> stagnationCount = const Value.absent(),
                Value<String?> lastCountedWorkoutId = const Value.absent(),
                Value<String> computedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseProgressionStatesCompanion(
                exerciseId: exerciseId,
                stagnationCount: stagnationCount,
                lastCountedWorkoutId: lastCountedWorkoutId,
                computedAt: computedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required int stagnationCount,
                Value<String?> lastCountedWorkoutId = const Value.absent(),
                required String computedAt,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseProgressionStatesCompanion.insert(
                exerciseId: exerciseId,
                stagnationCount: stagnationCount,
                lastCountedWorkoutId: lastCountedWorkoutId,
                computedAt: computedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseProgressionStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false, lastCountedWorkoutId = false}) {
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
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$ExerciseProgressionStatesTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$ExerciseProgressionStatesTableReferences
                                        ._exerciseIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (lastCountedWorkoutId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.lastCountedWorkoutId,
                                referencedTable:
                                    $$ExerciseProgressionStatesTableReferences
                                        ._lastCountedWorkoutIdTable(db),
                                referencedColumn:
                                    $$ExerciseProgressionStatesTableReferences
                                        ._lastCountedWorkoutIdTable(db)
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

typedef $$ExerciseProgressionStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseProgressionStatesTable,
      ExerciseProgressionState,
      $$ExerciseProgressionStatesTableFilterComposer,
      $$ExerciseProgressionStatesTableOrderingComposer,
      $$ExerciseProgressionStatesTableAnnotationComposer,
      $$ExerciseProgressionStatesTableCreateCompanionBuilder,
      $$ExerciseProgressionStatesTableUpdateCompanionBuilder,
      (ExerciseProgressionState, $$ExerciseProgressionStatesTableReferences),
      ExerciseProgressionState,
      PrefetchHooks Function({bool exerciseId, bool lastCountedWorkoutId})
    >;
typedef $$AppSettingsTableTableCreateCompanionBuilder =
    AppSettingsTableCompanion Function({
      required String id,
      Value<String> unitSystem,
      Value<String> theme,
      Value<String> locale,
      Value<bool> showTags,
      Value<int> defaultRestTimerSec,
      Value<bool> restTimerAutoStart,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableTableUpdateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<String> id,
      Value<String> unitSystem,
      Value<String> theme,
      Value<String> locale,
      Value<bool> showTags,
      Value<int> defaultRestTimerSec,
      Value<bool> restTimerAutoStart,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showTags => $composableBuilder(
    column: $table.showTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultRestTimerSec => $composableBuilder(
    column: $table.defaultRestTimerSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get restTimerAutoStart => $composableBuilder(
    column: $table.restTimerAutoStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showTags => $composableBuilder(
    column: $table.showTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultRestTimerSec => $composableBuilder(
    column: $table.defaultRestTimerSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get restTimerAutoStart => $composableBuilder(
    column: $table.restTimerAutoStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => column,
  );

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<bool> get showTags =>
      $composableBuilder(column: $table.showTags, builder: (column) => column);

  GeneratedColumn<int> get defaultRestTimerSec => $composableBuilder(
    column: $table.defaultRestTimerSec,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get restTimerAutoStart => $composableBuilder(
    column: $table.restTimerAutoStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsRow,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (
            AppSettingsRow,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsTableTable,
              AppSettingsRow
            >,
          ),
          AppSettingsRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(
    _$AppDatabase db,
    $AppSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> unitSystem = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<bool> showTags = const Value.absent(),
                Value<int> defaultRestTimerSec = const Value.absent(),
                Value<bool> restTimerAutoStart = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion(
                id: id,
                unitSystem: unitSystem,
                theme: theme,
                locale: locale,
                showTags: showTags,
                defaultRestTimerSec: defaultRestTimerSec,
                restTimerAutoStart: restTimerAutoStart,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> unitSystem = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<bool> showTags = const Value.absent(),
                Value<int> defaultRestTimerSec = const Value.absent(),
                Value<bool> restTimerAutoStart = const Value.absent(),
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion.insert(
                id: id,
                unitSystem: unitSystem,
                theme: theme,
                locale: locale,
                showTags: showTags,
                defaultRestTimerSec: defaultRestTimerSec,
                restTimerAutoStart: restTimerAutoStart,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTableTable,
      AppSettingsRow,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (
        AppSettingsRow,
        BaseReferences<_$AppDatabase, $AppSettingsTableTable, AppSettingsRow>,
      ),
      AppSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$ImportExportOperationsTableCreateCompanionBuilder =
    ImportExportOperationsCompanion Function({
      required String id,
      Value<String> operationType,
      required String status,
      required int formatVersion,
      required String startedAt,
      Value<String?> finishedAt,
      Value<String?> itemCountsJson,
      Value<String?> errorSummary,
      Value<int> rowid,
    });
typedef $$ImportExportOperationsTableUpdateCompanionBuilder =
    ImportExportOperationsCompanion Function({
      Value<String> id,
      Value<String> operationType,
      Value<String> status,
      Value<int> formatVersion,
      Value<String> startedAt,
      Value<String?> finishedAt,
      Value<String?> itemCountsJson,
      Value<String?> errorSummary,
      Value<int> rowid,
    });

class $$ImportExportOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $ImportExportOperationsTable> {
  $$ImportExportOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get formatVersion => $composableBuilder(
    column: $table.formatVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemCountsJson => $composableBuilder(
    column: $table.itemCountsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorSummary => $composableBuilder(
    column: $table.errorSummary,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportExportOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportExportOperationsTable> {
  $$ImportExportOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get formatVersion => $composableBuilder(
    column: $table.formatVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemCountsJson => $composableBuilder(
    column: $table.itemCountsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorSummary => $composableBuilder(
    column: $table.errorSummary,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportExportOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportExportOperationsTable> {
  $$ImportExportOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get formatVersion => $composableBuilder(
    column: $table.formatVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemCountsJson => $composableBuilder(
    column: $table.itemCountsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorSummary => $composableBuilder(
    column: $table.errorSummary,
    builder: (column) => column,
  );
}

class $$ImportExportOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportExportOperationsTable,
          ImportExportOperation,
          $$ImportExportOperationsTableFilterComposer,
          $$ImportExportOperationsTableOrderingComposer,
          $$ImportExportOperationsTableAnnotationComposer,
          $$ImportExportOperationsTableCreateCompanionBuilder,
          $$ImportExportOperationsTableUpdateCompanionBuilder,
          (
            ImportExportOperation,
            BaseReferences<
              _$AppDatabase,
              $ImportExportOperationsTable,
              ImportExportOperation
            >,
          ),
          ImportExportOperation,
          PrefetchHooks Function()
        > {
  $$ImportExportOperationsTableTableManager(
    _$AppDatabase db,
    $ImportExportOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportExportOperationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ImportExportOperationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ImportExportOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> formatVersion = const Value.absent(),
                Value<String> startedAt = const Value.absent(),
                Value<String?> finishedAt = const Value.absent(),
                Value<String?> itemCountsJson = const Value.absent(),
                Value<String?> errorSummary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportExportOperationsCompanion(
                id: id,
                operationType: operationType,
                status: status,
                formatVersion: formatVersion,
                startedAt: startedAt,
                finishedAt: finishedAt,
                itemCountsJson: itemCountsJson,
                errorSummary: errorSummary,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> operationType = const Value.absent(),
                required String status,
                required int formatVersion,
                required String startedAt,
                Value<String?> finishedAt = const Value.absent(),
                Value<String?> itemCountsJson = const Value.absent(),
                Value<String?> errorSummary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportExportOperationsCompanion.insert(
                id: id,
                operationType: operationType,
                status: status,
                formatVersion: formatVersion,
                startedAt: startedAt,
                finishedAt: finishedAt,
                itemCountsJson: itemCountsJson,
                errorSummary: errorSummary,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportExportOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportExportOperationsTable,
      ImportExportOperation,
      $$ImportExportOperationsTableFilterComposer,
      $$ImportExportOperationsTableOrderingComposer,
      $$ImportExportOperationsTableAnnotationComposer,
      $$ImportExportOperationsTableCreateCompanionBuilder,
      $$ImportExportOperationsTableUpdateCompanionBuilder,
      (
        ImportExportOperation,
        BaseReferences<
          _$AppDatabase,
          $ImportExportOperationsTable,
          ImportExportOperation
        >,
      ),
      ImportExportOperation,
      PrefetchHooks Function()
    >;
typedef $$SeedInfoTableTableCreateCompanionBuilder =
    SeedInfoTableCompanion Function({Value<int> id, required int seedVersion});
typedef $$SeedInfoTableTableUpdateCompanionBuilder =
    SeedInfoTableCompanion Function({Value<int> id, Value<int> seedVersion});

class $$SeedInfoTableTableFilterComposer
    extends Composer<_$AppDatabase, $SeedInfoTableTable> {
  $$SeedInfoTableTableFilterComposer({
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

  ColumnFilters<int> get seedVersion => $composableBuilder(
    column: $table.seedVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeedInfoTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SeedInfoTableTable> {
  $$SeedInfoTableTableOrderingComposer({
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

  ColumnOrderings<int> get seedVersion => $composableBuilder(
    column: $table.seedVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeedInfoTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeedInfoTableTable> {
  $$SeedInfoTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seedVersion => $composableBuilder(
    column: $table.seedVersion,
    builder: (column) => column,
  );
}

class $$SeedInfoTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeedInfoTableTable,
          SeedInfoRow,
          $$SeedInfoTableTableFilterComposer,
          $$SeedInfoTableTableOrderingComposer,
          $$SeedInfoTableTableAnnotationComposer,
          $$SeedInfoTableTableCreateCompanionBuilder,
          $$SeedInfoTableTableUpdateCompanionBuilder,
          (
            SeedInfoRow,
            BaseReferences<_$AppDatabase, $SeedInfoTableTable, SeedInfoRow>,
          ),
          SeedInfoRow,
          PrefetchHooks Function()
        > {
  $$SeedInfoTableTableTableManager(_$AppDatabase db, $SeedInfoTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeedInfoTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeedInfoTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeedInfoTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> seedVersion = const Value.absent(),
              }) => SeedInfoTableCompanion(id: id, seedVersion: seedVersion),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int seedVersion,
              }) => SeedInfoTableCompanion.insert(
                id: id,
                seedVersion: seedVersion,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeedInfoTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeedInfoTableTable,
      SeedInfoRow,
      $$SeedInfoTableTableFilterComposer,
      $$SeedInfoTableTableOrderingComposer,
      $$SeedInfoTableTableAnnotationComposer,
      $$SeedInfoTableTableCreateCompanionBuilder,
      $$SeedInfoTableTableUpdateCompanionBuilder,
      (
        SeedInfoRow,
        BaseReferences<_$AppDatabase, $SeedInfoTableTable, SeedInfoRow>,
      ),
      SeedInfoRow,
      PrefetchHooks Function()
    >;
typedef $$ActiveWorkoutStatesTableCreateCompanionBuilder =
    ActiveWorkoutStatesCompanion Function({
      required String workoutId,
      required String startedAtUtc,
      Value<int> accumulatedActiveSec,
      Value<bool> isPaused,
      Value<String?> pauseStartedAtUtc,
      Value<String?> restTimerEndsAtUtc,
      Value<int?> restTimerDurationSec,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$ActiveWorkoutStatesTableUpdateCompanionBuilder =
    ActiveWorkoutStatesCompanion Function({
      Value<String> workoutId,
      Value<String> startedAtUtc,
      Value<int> accumulatedActiveSec,
      Value<bool> isPaused,
      Value<String?> pauseStartedAtUtc,
      Value<String?> restTimerEndsAtUtc,
      Value<int?> restTimerDurationSec,
      Value<String> updatedAt,
      Value<int> rowid,
    });

final class $$ActiveWorkoutStatesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ActiveWorkoutStatesTable,
          ActiveWorkoutState
        > {
  $$ActiveWorkoutStatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias('ActiveWorkoutStates__workoutId__Workouts__id');

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<String>('workoutId')!;

    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActiveWorkoutStatesTableFilterComposer
    extends Composer<_$AppDatabase, $ActiveWorkoutStatesTable> {
  $$ActiveWorkoutStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accumulatedActiveSec => $composableBuilder(
    column: $table.accumulatedActiveSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pauseStartedAtUtc => $composableBuilder(
    column: $table.pauseStartedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restTimerEndsAtUtc => $composableBuilder(
    column: $table.restTimerEndsAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restTimerDurationSec => $composableBuilder(
    column: $table.restTimerDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiveWorkoutStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActiveWorkoutStatesTable> {
  $$ActiveWorkoutStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accumulatedActiveSec => $composableBuilder(
    column: $table.accumulatedActiveSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pauseStartedAtUtc => $composableBuilder(
    column: $table.pauseStartedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restTimerEndsAtUtc => $composableBuilder(
    column: $table.restTimerEndsAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restTimerDurationSec => $composableBuilder(
    column: $table.restTimerDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiveWorkoutStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActiveWorkoutStatesTable> {
  $$ActiveWorkoutStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accumulatedActiveSec => $composableBuilder(
    column: $table.accumulatedActiveSec,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPaused =>
      $composableBuilder(column: $table.isPaused, builder: (column) => column);

  GeneratedColumn<String> get pauseStartedAtUtc => $composableBuilder(
    column: $table.pauseStartedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get restTimerEndsAtUtc => $composableBuilder(
    column: $table.restTimerEndsAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restTimerDurationSec => $composableBuilder(
    column: $table.restTimerDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiveWorkoutStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActiveWorkoutStatesTable,
          ActiveWorkoutState,
          $$ActiveWorkoutStatesTableFilterComposer,
          $$ActiveWorkoutStatesTableOrderingComposer,
          $$ActiveWorkoutStatesTableAnnotationComposer,
          $$ActiveWorkoutStatesTableCreateCompanionBuilder,
          $$ActiveWorkoutStatesTableUpdateCompanionBuilder,
          (ActiveWorkoutState, $$ActiveWorkoutStatesTableReferences),
          ActiveWorkoutState,
          PrefetchHooks Function({bool workoutId})
        > {
  $$ActiveWorkoutStatesTableTableManager(
    _$AppDatabase db,
    $ActiveWorkoutStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActiveWorkoutStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActiveWorkoutStatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ActiveWorkoutStatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> workoutId = const Value.absent(),
                Value<String> startedAtUtc = const Value.absent(),
                Value<int> accumulatedActiveSec = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
                Value<String?> pauseStartedAtUtc = const Value.absent(),
                Value<String?> restTimerEndsAtUtc = const Value.absent(),
                Value<int?> restTimerDurationSec = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActiveWorkoutStatesCompanion(
                workoutId: workoutId,
                startedAtUtc: startedAtUtc,
                accumulatedActiveSec: accumulatedActiveSec,
                isPaused: isPaused,
                pauseStartedAtUtc: pauseStartedAtUtc,
                restTimerEndsAtUtc: restTimerEndsAtUtc,
                restTimerDurationSec: restTimerDurationSec,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String workoutId,
                required String startedAtUtc,
                Value<int> accumulatedActiveSec = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
                Value<String?> pauseStartedAtUtc = const Value.absent(),
                Value<String?> restTimerEndsAtUtc = const Value.absent(),
                Value<int?> restTimerDurationSec = const Value.absent(),
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ActiveWorkoutStatesCompanion.insert(
                workoutId: workoutId,
                startedAtUtc: startedAtUtc,
                accumulatedActiveSec: accumulatedActiveSec,
                isPaused: isPaused,
                pauseStartedAtUtc: pauseStartedAtUtc,
                restTimerEndsAtUtc: restTimerEndsAtUtc,
                restTimerDurationSec: restTimerDurationSec,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActiveWorkoutStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutId = false}) {
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
                    if (workoutId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workoutId,
                                referencedTable:
                                    $$ActiveWorkoutStatesTableReferences
                                        ._workoutIdTable(db),
                                referencedColumn:
                                    $$ActiveWorkoutStatesTableReferences
                                        ._workoutIdTable(db)
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

typedef $$ActiveWorkoutStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActiveWorkoutStatesTable,
      ActiveWorkoutState,
      $$ActiveWorkoutStatesTableFilterComposer,
      $$ActiveWorkoutStatesTableOrderingComposer,
      $$ActiveWorkoutStatesTableAnnotationComposer,
      $$ActiveWorkoutStatesTableCreateCompanionBuilder,
      $$ActiveWorkoutStatesTableUpdateCompanionBuilder,
      (ActiveWorkoutState, $$ActiveWorkoutStatesTableReferences),
      ActiveWorkoutState,
      PrefetchHooks Function({bool workoutId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MuscleGroupsTableTableManager get muscleGroups =>
      $$MuscleGroupsTableTableManager(_db, _db.muscleGroups);
  $$EquipmentsTableTableManager get equipments =>
      $$EquipmentsTableTableManager(_db, _db.equipments);
  $$MeasurementTypesTableTableManager get measurementTypes =>
      $$MeasurementTypesTableTableManager(_db, _db.measurementTypes);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$ExerciseSecondaryMusclesTableTableManager get exerciseSecondaryMuscles =>
      $$ExerciseSecondaryMusclesTableTableManager(
        _db,
        _db.exerciseSecondaryMuscles,
      );
  $$ExerciseL10nTableTableManager get exerciseL10n =>
      $$ExerciseL10nTableTableManager(_db, _db.exerciseL10n);
  $$WorkoutTagsTableTableManager get workoutTags =>
      $$WorkoutTagsTableTableManager(_db, _db.workoutTags);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db, _db.workouts);
  $$WorkoutTagLinksTableTableManager get workoutTagLinks =>
      $$WorkoutTagLinksTableTableManager(_db, _db.workoutTagLinks);
  $$WorkoutExercisesTableTableManager get workoutExercises =>
      $$WorkoutExercisesTableTableManager(_db, _db.workoutExercises);
  $$ExerciseSetsTableTableManager get exerciseSets =>
      $$ExerciseSetsTableTableManager(_db, _db.exerciseSets);
  $$WorkoutTemplatesTableTableManager get workoutTemplates =>
      $$WorkoutTemplatesTableTableManager(_db, _db.workoutTemplates);
  $$TemplateExercisesTableTableManager get templateExercises =>
      $$TemplateExercisesTableTableManager(_db, _db.templateExercises);
  $$TemplateSetsTableTableManager get templateSets =>
      $$TemplateSetsTableTableManager(_db, _db.templateSets);
  $$BodyMeasurementsTableTableManager get bodyMeasurements =>
      $$BodyMeasurementsTableTableManager(_db, _db.bodyMeasurements);
  $$PersonalRecordsTableTableManager get personalRecords =>
      $$PersonalRecordsTableTableManager(_db, _db.personalRecords);
  $$ExerciseProgressionStatesTableTableManager get exerciseProgressionStates =>
      $$ExerciseProgressionStatesTableTableManager(
        _db,
        _db.exerciseProgressionStates,
      );
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
  $$ImportExportOperationsTableTableManager get importExportOperations =>
      $$ImportExportOperationsTableTableManager(
        _db,
        _db.importExportOperations,
      );
  $$SeedInfoTableTableTableManager get seedInfoTable =>
      $$SeedInfoTableTableTableManager(_db, _db.seedInfoTable);
  $$ActiveWorkoutStatesTableTableManager get activeWorkoutStates =>
      $$ActiveWorkoutStatesTableTableManager(_db, _db.activeWorkoutStates);
}
