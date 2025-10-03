import 'package:dartshine/src/orm/db_type.dart';
import 'package:dartshine/src/orm/sql_orm_query.dart';
import 'package:dartshine/src/orm/types.dart';
import 'package:postgres/postgres.dart';
import 'package:sqlite3/sqlite3.dart';

class Orm {
  final String tableName;
  final List<Map<String, dynamic>> fields;
  DbType? dbType;
  Database? sqliteDb;
  Connection? postgresqlDb;

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

    for (int i = 0; i < fields.length; i++) {
      Map<String, dynamic> field = fields[i];

      if (field['field_name'] is String) {
        createQuery.write("${field['field_name']} ");
      }

      if (field['type'] is OrmTypes) {
        createQuery.write("${ormTypeToString(field['type'])} ");
      }

      if (field['primary_key'] == true) {
        createQuery.write('PRIMARY KEY ');
      }

      if (field['autoincrement'] == true) {
        createQuery.write('AUTOINCREMENT ');
      }

      if (i < fields.length - 1) {
        createQuery.write(',');
      }
    }

    createQuery.write(');');

    sqliteDb?.execute(createQuery.toString());
  }

  void createPostgresqlTable() {
    final StringBuffer createQuery = StringBuffer();

    createQuery.write('CREATE TABLE IF NOT EXISTS $tableName (');

    for (int i = 0; i < fields.length; i++) {
      Map<String, dynamic> field = fields[i];

      if (field['field_name'] is String) {
        createQuery.write("${field['field_name']} ");
      }

      if (field['type'] is OrmTypes) {
        createQuery.write("${ormTypeToString(field['type'])} ");
      }

      if (field['primary_key'] == true) {
        createQuery.write('PRIMARY KEY ');
      }

      if (field['autoincrement'] == true) {
        createQuery.write('AUTOINCREMENT ');
      }

      if (i < fields.length - 1) {
        createQuery.write(',');
      }
    }

    createQuery.write(');');

    postgresqlDb?.execute(createQuery.toString());
  }

  Get get() {
    if (dbType == DbType.sqlite) {
      return Get(tableName: tableName, dbType: dbType!, sqliteDb: sqliteDb);
    }

    return Get(
        tableName: tableName, dbType: dbType!, postgresqlDb: postgresqlDb);
  }

  Insert insert() {
    if (dbType == DbType.sqlite) {
      return Insert(tableName: tableName, dbType: dbType!, sqliteDb: sqliteDb);
    }

    return Insert(
        tableName: tableName, dbType: dbType!, postgresqlDb: postgresqlDb);
  }

  Update update() {
    if (dbType == DbType.sqlite) {
      return Update(tableName: tableName, dbType: dbType!, sqliteDb: sqliteDb);
    }

    return Update(
        tableName: tableName, dbType: dbType!, postgresqlDb: postgresqlDb);
  }

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
  DbType type = DbType.sqlite;
  String name = '';

  // For PostgreSQL connection
  String host = '';
  String database = '';
  String username = '';
  String password = '';
  int port = 0;

  Future<void> fillOrm() async {
    if (type == DbType.sqlite) {
      Database sqliteDb = sqlite3.open(name);

      for (Orm orm in orms) {
        orm.dbType = type;
        orm.sqliteDb = sqliteDb;
        orm.createSqliteTable();
      }
    } else if (type == DbType.postgresql) {
      final postgresqlDb = await Connection.open(Endpoint(
          host: host,
          database: database,
          username: username,
          password: password,
          port: port));

      for (Orm orm in orms) {
        orm.dbType = type;
        orm.postgresqlDb = postgresqlDb;
        orm.createPostgresqlTable();
      }
    }
  }
}
