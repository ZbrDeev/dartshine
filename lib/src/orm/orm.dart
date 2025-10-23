import 'package:dartshine/src/orm/db_type.dart';
import 'package:dartshine/src/orm/sql_orm_query.dart';
import 'package:postgresql2/postgresql.dart';
import 'package:sqlite3/sqlite3.dart';

abstract class OrmField {
  final String fieldName;
  final bool nullable;
  final bool unique;
  final String? defaultValue;

  OrmField(
      {required this.fieldName,
      this.nullable = false,
      this.unique = false,
      this.defaultValue});

  String toSqlite();

  String toPostgresql();
}

/// What if the parent table is deleted
enum ForeignKeyOnDelete { cascade, restrict, setNull }

/// Foreign Key Type
class ForeignKeyOrmField extends OrmField {
  final Orm foreignKey;
  final ForeignKeyOnDelete? onDelete;

  late String alterTable;

  ForeignKeyOrmField(
      {required super.fieldName,
      required this.foreignKey,
      this.onDelete,
      super.nullable = false,
      super.unique = false});

  @override
  String toSqlite() {
    StringBuffer buffer = StringBuffer();
    StringBuffer alterTableBuffer = StringBuffer();

    alterTableBuffer
        .write("($fieldName) REFERENCES ${foreignKey.tableName}(id)");

    if (onDelete != null) {
      switch (onDelete!) {
        case ForeignKeyOnDelete.cascade:
          alterTableBuffer.write("ON DELETE CASCADE");
          break;

        case ForeignKeyOnDelete.restrict:
          alterTableBuffer.write("ON DELETE RESTRICT");
          break;

        case ForeignKeyOnDelete.setNull:
          alterTableBuffer.write("ON DELETE SET NULL");
          break;
      }
    }

    alterTable = alterTableBuffer.toString();

    buffer.write("$fieldName INTEGER ");

    if (nullable) {
      buffer.write("NOT NULL ");
    }

    if (unique) {
      buffer.write("UNIQUE ");
    }

    return buffer.toString();
  }

  @override
  String toPostgresql() {
    StringBuffer buffer = StringBuffer();
    StringBuffer alterTableBuffer = StringBuffer();

    alterTableBuffer.write(
        "ADD CONSTRAINT fk_${fieldName}_to_${foreignKey.tableName} FOREIGN KEY ($fieldName) REFERENCES ${foreignKey.tableName} (id) ");

    if (onDelete != null) {
      switch (onDelete!) {
        case ForeignKeyOnDelete.cascade:
          alterTableBuffer.write("ON DELETE CASCADE");
          break;

        case ForeignKeyOnDelete.restrict:
          alterTableBuffer.write("ON DELETE RESTRICT");
          break;

        case ForeignKeyOnDelete.setNull:
          alterTableBuffer.write("ON DELETE SET NULL");
          break;
      }
    }

    alterTableBuffer.write(";");
    alterTable = alterTableBuffer.toString();

    buffer.write("$fieldName INTEGER ");

    if (nullable) {
      buffer.write("NOT NULL ");
    }

    if (unique) {
      buffer.write("UNIQUE ");
    }

    return buffer.toString();
  }
}

/// Integer Type
class IntegerOrmField extends OrmField {
  final bool autoincrement;

  IntegerOrmField(
      {required super.fieldName,
      this.autoincrement = false,
      super.nullable = false,
      super.unique = false,
      super.defaultValue});

  @override
  String toSqlite() {
    StringBuffer buffer = StringBuffer();

    buffer.write("$fieldName INTEGER ");

    if (autoincrement) {
      buffer.write("AUTOINCREMENT ");
    }

    if (nullable) {
      buffer.write("NOT NULL ");
    }

    if (unique) {
      buffer.write("UNIQUE ");
    }

    if (defaultValue != null) {
      buffer.write("DEFAULT ${defaultValue!}");
    }

    return buffer.toString();
  }

  @override
  String toPostgresql() {
    StringBuffer buffer = StringBuffer();

    if (autoincrement) {
      buffer.write("$fieldName SERIAL ");
    } else {
      buffer.write("$fieldName INTEGER ");
    }

    if (nullable) {
      buffer.write("NOT NULL ");
    }

    if (unique) {
      buffer.write("UNIQUE ");
    }

    if (defaultValue != null) {
      buffer.write("DEFAULT ${defaultValue!}");
    }

    return buffer.toString();
  }
}

/// Float Type
class FloatOrmField extends OrmField {
  FloatOrmField(
      {required super.fieldName,
      super.nullable,
      super.unique,
      super.defaultValue});

  @override
  String toSqlite() {
    StringBuffer buffer = StringBuffer();

    buffer.write("$fieldName REAL ");

    if (nullable) {
      buffer.write("NOT NULL ");
    }

    if (unique) {
      buffer.write("UNIQUE ");
    }

    if (defaultValue != null) {
      buffer.write("DEFAULT ${defaultValue!}");
    }

    return buffer.toString();
  }

  @override
  String toPostgresql() {
    StringBuffer buffer = StringBuffer();

    buffer.write("$fieldName FLOAT ");

    if (nullable) {
      buffer.write("NOT NULL ");
    }

    if (unique) {
      buffer.write("UNIQUE ");
    }

    if (defaultValue != null) {
      buffer.write("DEFAULT ${defaultValue!}");
    }

    return buffer.toString();
  }
}

/// Char with maximul length Type
class CharOrmField extends OrmField {
  final int maxLength;

  CharOrmField(
      {required super.fieldName,
      this.maxLength = 255,
      super.nullable,
      super.unique,
      super.defaultValue});

  @override
  String toSqlite() {
    StringBuffer buffer = StringBuffer();

    buffer.write("$fieldName VARCHAR($maxLength) ");

    if (nullable) {
      buffer.write("NOT NULL ");
    }

    if (unique) {
      buffer.write("UNIQUE ");
    }

    if (defaultValue != null) {
      buffer.write("DEFAULT '${defaultValue!}'");
    }

    return buffer.toString();
  }

  @override
  String toPostgresql() {
    StringBuffer buffer = StringBuffer();

    buffer.write("$fieldName VARCHAR($maxLength) ");

    if (nullable) {
      buffer.write("NOT NULL ");
    }

    if (unique) {
      buffer.write("UNIQUE ");
    }

    if (defaultValue != null) {
      buffer.write("DEFAULT '${defaultValue!}'");
    }

    return buffer.toString();
  }
}

/// Text Type
class TextOrmField extends OrmField {
  TextOrmField(
      {required super.fieldName,
      super.nullable,
      super.unique,
      super.defaultValue});

  @override
  String toSqlite() {
    StringBuffer buffer = StringBuffer();

    buffer.write("$fieldName TEXT ");

    if (nullable) {
      buffer.write("NOT NULL ");
    }

    if (unique) {
      buffer.write("UNIQUE ");
    }

    if (defaultValue != null) {
      buffer.write("DEFAULT '${defaultValue!}'");
    }

    return buffer.toString();
  }

  @override
  String toPostgresql() {
    StringBuffer buffer = StringBuffer();

    buffer.write("$fieldName TEXT ");

    if (nullable) {
      buffer.write("NOT NULL ");
    }

    if (unique) {
      buffer.write("UNIQUE ");
    }

    if (defaultValue != null) {
      buffer.write("DEFAULT '${defaultValue!}'");
    }

    return buffer.toString();
  }
}

/// Boolean Type
class BooleanOrmField extends OrmField {
  BooleanOrmField(
      {required super.fieldName, super.nullable = false, super.defaultValue});

  @override
  String toSqlite() {
    StringBuffer buffer = StringBuffer();

    buffer.write("$fieldName INTEGER ");

    if (nullable) {
      buffer.write("NOT NULL ");
    }

    if (defaultValue != null) {
      buffer.write("DEFAULT ${defaultValue!}");
    }

    return buffer.toString();
  }

  @override
  String toPostgresql() {
    StringBuffer buffer = StringBuffer();

    buffer.write("$fieldName BOOLEAN ");

    if (nullable) {
      buffer.write("NOT NULL ");
    }

    if (defaultValue != null) {
      buffer.write("DEFAULT '${defaultValue!}'");
    }

    return buffer.toString();
  }
}

/// TIMESTAMP Type
class DateTimeOrmField extends OrmField {
  final bool autoNow;

  DateTimeOrmField(
      {required super.fieldName, this.autoNow = false, super.nullable = false});

  @override
  String toSqlite() {
    StringBuffer buffer = StringBuffer();

    buffer.write("$fieldName DATETIME ");

    if (nullable) {
      buffer.write("NOT NULL ");
    }

    if (autoNow) {
      buffer.write("DEFAULT CURRENT_TIMESTAMP ");
    }

    return buffer.toString();
  }

  @override
  String toPostgresql() {
    StringBuffer buffer = StringBuffer();

    buffer.write("$fieldName TIMESTAMP ");

    if (nullable) {
      buffer.write("NOT NULL ");
    }

    if (autoNow) {
      buffer.write("DEFAULT NOW() ");
    }

    return buffer.toString();
  }
}

/// DATE Type
class DateOrmField extends OrmField {
  final bool autoNow;

  DateOrmField(
      {required super.fieldName, this.autoNow = false, super.nullable});

  @override
  String toSqlite() {
    StringBuffer buffer = StringBuffer();

    buffer.write("$fieldName DATE ");

    if (nullable) {
      buffer.write("NOT NULL ");
    }

    if (autoNow) {
      buffer.write("DEFAULT CURRENT_DATE ");
    }

    return buffer.toString();
  }

  @override
  String toPostgresql() {
    StringBuffer buffer = StringBuffer();

    buffer.write("$fieldName DATE ");

    if (nullable) {
      buffer.write("NOT NULL ");
    }

    if (autoNow) {
      buffer.write("DEFAULT CURRENT_DATE ");
    }

    return buffer.toString();
  }
}

class Orm {
  /// Table name of the orm class
  final String tableName;

  /// Fields for the table
  final List<OrmField> fields;

  /// For Database type
  DbType? dbType;

  /// For SQLite connection
  Database? sqliteDb;

  /// For PostgreSQL connection
  Connection? postgresqlDb;

  final List<String> _alterTable = [];

  Orm(
      {required this.tableName,
      required this.fields,
      DbType? databaseType,
      this.sqliteDb,
      this.postgresqlDb}) {
    if (databaseType != null) {
      dbType = databaseType;
    } else {
      dbType = DbType.sqlite;
    }
  }

  void createSqliteTable() {
    final StringBuffer createQuery = StringBuffer();

    createQuery.write('CREATE TABLE IF NOT EXISTS $tableName (');
    createQuery.write('id INTEGER PRIMARY KEY AUTOINCREMENT');

    if (fields.isNotEmpty) {
      createQuery.write(',');
    }

    for (int i = 0; i < fields.length; i++) {
      OrmField field = fields[i];

      createQuery.write(field.toSqlite());

      if (field is ForeignKeyOrmField) {
        _alterTable.add(field.alterTable);
      }

      if (i < fields.length - 1) {
        createQuery.write(',');
      }
    }

    for (String alterTable in _alterTable) {
      createQuery.write(', FOREIGN KEY $alterTable');
    }

    createQuery.write(');');

    sqliteDb!.execute(createQuery.toString());
  }

  void createPostgresqlTable() {
    final StringBuffer createQuery = StringBuffer();

    createQuery.write('CREATE TABLE IF NOT EXISTS $tableName (');
    createQuery.write('id SERIAL PRIMARY KEY');

    if (fields.isNotEmpty) {
      createQuery.write(',');
    }

    for (int i = 0; i < fields.length; i++) {
      OrmField field = fields[i];

      createQuery.write(field.toPostgresql());

      if (field is ForeignKeyOrmField) {
        _alterTable.add(field.alterTable);
      }

      if (i < fields.length - 1) {
        createQuery.write(',');
      }
    }

    createQuery.write(');');

    postgresqlDb!.execute(createQuery.toString());
  }

  void createPostgresqlAlterTable() {
    for (String alterTable in _alterTable) {
      postgresqlDb!.execute(alterTable);
    }
  }

  /// Get data from the table
  Get get() {
    if (dbType == DbType.sqlite) {
      return Get(tableName: tableName, dbType: dbType!, sqliteDb: sqliteDb);
    }

    return Get(
        tableName: tableName, dbType: dbType!, postgresqlDb: postgresqlDb);
  }

  /// Insert data into the table
  Insert insert() {
    if (dbType == DbType.sqlite) {
      return Insert(tableName: tableName, dbType: dbType!, sqliteDb: sqliteDb);
    }

    return Insert(
        tableName: tableName, dbType: dbType!, postgresqlDb: postgresqlDb);
  }

  /// Update data in the table
  Update update() {
    if (dbType == DbType.sqlite) {
      return Update(tableName: tableName, dbType: dbType!, sqliteDb: sqliteDb);
    }

    return Update(
        tableName: tableName, dbType: dbType!, postgresqlDb: postgresqlDb);
  }

  /// Delete data from the table
  Delete delete() {
    if (dbType == DbType.sqlite) {
      return Delete(tableName: tableName, dbType: dbType!, sqliteDb: sqliteDb);
    }

    return Delete(
        tableName: tableName, dbType: dbType!, postgresqlDb: postgresqlDb);
  }
}

class DartshineOrm {
  List<Orm> orms = [];

  /// Database type
  DbType type = DbType.sqlite;

  /// For SQLite connection
  String name = '';

  /// For PostgreSQL connection
  String host = '';
  String database = '';
  String username = '';
  String password = '';
  int port = 0;

  void _executeSqliteSettings(Database sqliteDb) {
    sqliteDb.execute("PRAGMA foreign_keys = ON;");
  }

  Future<void> fillOrm() async {
    if (type == DbType.sqlite) {
      Database sqliteDb = sqlite3.open(name);
      _executeSqliteSettings(sqliteDb);

      for (Orm orm in orms) {
        orm.dbType = type;
        orm.sqliteDb = sqliteDb;
        orm.createSqliteTable();
      }
    } else if (type == DbType.postgresql) {
      final postgresqlDb =
          await connect("postgres://$username:$password@$host:$port/$database");

      for (Orm orm in orms) {
        orm.dbType = type;
        orm.postgresqlDb = postgresqlDb;
        orm.createPostgresqlTable();
      }

      for (Orm orm in orms) {
        if (orm._alterTable.isNotEmpty) {
          orm.createPostgresqlAlterTable();
        }
      }
    }
  }
}
