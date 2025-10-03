import 'package:dartshine/src/orm/db_type.dart';
import 'package:dartshine/src/orm/types.dart';
import 'package:postgres/postgres.dart';
import 'package:sqlite3/sqlite3.dart';

// TODO: HANDLE POSTGRESQL DATABASE

abstract class Query<T extends Query<T>> {
  StringBuffer queryMaker = StringBuffer();

  T where(String query) {
    queryMaker.write(" WHERE ");
    queryMaker.write(query);

    return this as T;
  }

  T orderBy(String query) {
    queryMaker.write(" ORDER BY ");
    queryMaker.write(query);

    return this as T;
  }
}

mixin DeleteQuery<T extends DeleteQuery<T>> {
  StringBuffer deleteQueryMaker = StringBuffer();

  T returning(List<String> query) {
    deleteQueryMaker.write(" RETURNING ");

    for (var i = 0; i < query.length; ++i) {
      if (i >= query.length - 1) {
        deleteQueryMaker.write(" $query[i];");
      } else {
        deleteQueryMaker.write(" $query[i],");
      }
    }

    return this as T;
  }
}

mixin SelectQuery<T extends SelectQuery<T>> {
  StringBuffer selectQueryMaker = StringBuffer();

  T column(List<String> query) {
    for (int i = 0; i < query.length; ++i) {
      if (i >= query.length - 1) {
        selectQueryMaker.write("$query[i]");
      } else {
        selectQueryMaker.write("$query[i],");
      }
    }

    return this as T;
  }

  T all() {
    selectQueryMaker.write(" * ");

    return this as T;
  }
}

class InsertQuery<T extends InsertQuery<T>> {
  StringBuffer insertQueryMaker = StringBuffer();
  List<String> keys = [];
  List<String> values = [];
  List<OrmTypes> types = [];

  T value(String key, String value, OrmTypes type) {
    keys.add(key);
    values.add(value);
    types.add(type);

    return this as T;
  }

  T returning(List<String> query) {
    insertQueryMaker.write(" RETURNING ");

    for (var i = 0; i < query.length; ++i) {
      if (i >= query.length - 1) {
        insertQueryMaker.write(" $query[i];");
      } else {
        insertQueryMaker.write(" $query[i],");
      }
    }

    return this as T;
  }
}

mixin UpdateQuery<T extends UpdateQuery<T>> {
  StringBuffer updateQueryMaker = StringBuffer();
  List<String> keys = [];
  List<String> values = [];
  List<OrmTypes> types = [];

  T set(String key, String value, OrmTypes type) {
    keys.add(key);
    values.add(value);
    types.add(type);

    return this as T;
  }

  T returning(List<String> query) {
    updateQueryMaker.write(" RETURNING ");

    for (var i = 0; i < query.length; ++i) {
      if (i >= query.length - 1) {
        updateQueryMaker.write(" $query[i];");
      } else {
        updateQueryMaker.write(" $query[i],");
      }
    }

    return this as T;
  }
}

class Delete extends Query<Delete> with DeleteQuery<Delete> {
  final String tableName;
  final DbType dbType;
  Connection? postgresqlDb;
  Database? sqliteDb;

  Delete(
      {required this.tableName,
      required this.dbType,
      this.sqliteDb,
      this.postgresqlDb});

  void execute() {
    if (dbType == DbType.sqlite) {
      sqliteDb?.execute(
          "DELETE FROM $tableName ${queryMaker.toString()} ${deleteQueryMaker.toString()};");
    } else if (dbType == DbType.postgresql) {
      postgresqlDb?.execute("DELETE FROM $tableName ${queryMaker.toString()};");
    }
  }
}

class Get extends Query<Get> with SelectQuery<Get> {
  final String tableName;
  final DbType dbType;
  Connection? postgresqlDb;
  Database? sqliteDb;

  Get(
      {required this.tableName,
      required this.dbType,
      this.sqliteDb,
      this.postgresqlDb});

  Future<Map<String, dynamic>> fetchOne() async {
    Map<String, dynamic> result = {};

    if (dbType == DbType.sqlite) {
      final rows = sqliteDb?.select(
          "SELECT ${selectQueryMaker.toString()} FROM $tableName ${queryMaker.toString()};");

      for (final row in rows![0].entries) {
        result[row.key] = row.value;
      }
    } else if (dbType == DbType.postgresql) {
      final rows = await postgresqlDb?.execute(
          "SELECT ${selectQueryMaker.toString()} FROM $tableName ${queryMaker.toString()};");

      for (final row in rows!) {
        result[row.toString()] = row[0];
      }
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> fetchAll() async {
    List<Map<String, dynamic>> results = [];

    if (dbType == DbType.sqlite) {
      final rows = sqliteDb?.select(
          "SELECT ${selectQueryMaker.toString()} FROM $tableName ${queryMaker.toString()};");

      for (final row in rows!) {
        Map<String, dynamic> result = {};

        for (final rowMap in row.entries) {
          result[rowMap.key] = rowMap.value;
        }

        results.add(result);
      }
    } else if (dbType == DbType.postgresql) {
      // TODO: HANDLE POSTGRESQL MULTIPLE RESULT QUERY
    }

    return results;
  }
}

class Insert extends InsertQuery<Insert> {
  final String tableName;
  final DbType dbType;
  Connection? postgresqlDb;
  Database? sqliteDb;
  StringBuffer queryDataString = StringBuffer();

  Insert(
      {required this.tableName,
      required this.dbType,
      this.postgresqlDb,
      this.sqliteDb});

  void putKeyValueData() {
    StringBuffer keysString = StringBuffer("(");
    StringBuffer valuesString = StringBuffer("(");

    for (var i = 0; i < keys.length; ++i) {
      keysString.write(keys[i]);

      if (types[i] == OrmTypes.string) {
        valuesString.write("'$values[i]'");
      } else {
        valuesString.write(values[i]);
      }

      if (i < keys.length - 1) {
        keysString.write(",");
        valuesString.write(",");
      }
    }

    queryDataString
        .write("${keysString.toString()} VALUES ${valuesString.toString()}");
  }

  void execute() {
    putKeyValueData();

    if (dbType == DbType.sqlite) {
      sqliteDb?.execute("INSERT INTO $tableName ${queryDataString.toString()}");
    }
  }

  Map<String, dynamic> fetchOne() {
    putKeyValueData();

    Map<String, dynamic> result = {};

    if (dbType == DbType.sqlite) {
      final rows = sqliteDb?.select(
          "INSERT INTO $tableName ${queryDataString.toString()} RETURNING ${queryDataString.toString()}");

      for (final row in rows![0].entries) {
        result[row.key] = row.value;
      }
    }

    return result;
  }

  List<Map<String, dynamic>> fetchAll() {
    putKeyValueData();

    List<Map<String, dynamic>> results = [];

    if (dbType == DbType.sqlite) {
      final rows = sqliteDb?.select(
          "INSERT INTO $tableName ${queryDataString.toString()} RETURNING ${queryDataString.toString()}");

      for (final row in rows!) {
        Map<String, dynamic> result = {};

        for (final rowMap in row.entries) {
          result[rowMap.key] = rowMap.value;
        }

        results.add(result);
      }
    }

    return results;
  }
}

class Update extends Query<Update> with UpdateQuery<Update> {
  final String tableName;
  final DbType dbType;
  Connection? postgresqlDb;
  Database? sqliteDb;
  StringBuffer queryDataString = StringBuffer();

  Update(
      {required this.tableName,
      required this.dbType,
      this.postgresqlDb,
      this.sqliteDb});

  void putKeyValueData() {
    for (var i = 0; i < keys.length; ++i) {
      queryDataString.write("$keys[i] = $values[i]");

      if (i < keys.length - 1) {
        queryDataString.write(",");
      }
    }
  }

  void execute() {
    putKeyValueData();

    if (dbType == DbType.sqlite) {
      sqliteDb?.execute(
          "UPDATE $tableName SET ${queryDataString.toString()} ${updateQueryMaker.toString()};");
    }
  }

  Map<String, dynamic> fetchOne() {
    Map<String, dynamic> result = {};

    if (dbType == DbType.sqlite) {
      final rows = sqliteDb?.select(
          "UPDATE $tableName SET ${queryDataString.toString()} ${updateQueryMaker.toString()} RETURNING ${updateQueryMaker.toString()};");

      for (final row in rows![0].entries) {
        result[row.key] = row.value;
      }
    }

    return result;
  }

  List<Map<String, dynamic>> fetchAll() {
    List<Map<String, dynamic>> results = [];

    if (dbType == DbType.sqlite) {
      final rows = sqliteDb?.select(
          "UPDATE $tableName SET ${queryDataString.toString()} ${updateQueryMaker.toString()} RETURNING ${updateQueryMaker.toString()};");

      for (final row in rows!) {
        Map<String, dynamic> result = {};

        for (final rowMap in row.entries) {
          result[rowMap.key] = rowMap.value;
        }

        results.add(result);
      }
    }

    return results;
  }
}
