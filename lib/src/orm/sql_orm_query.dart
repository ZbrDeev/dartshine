import 'package:dartshine/src/orm/db_type.dart';
import 'package:postgresql2/postgresql.dart';
import 'package:sqlite3/sqlite3.dart';

abstract class Query<T extends Query<T>> {
  final StringBuffer _queryMaker = StringBuffer();

  T where(String query) {
    _queryMaker.write(" WHERE ");
    _queryMaker.write(query);

    return this as T;
  }

  T orderBy(String query) {
    _queryMaker.write(" ORDER BY ");
    _queryMaker.write(query);

    return this as T;
  }
}

mixin DeleteQuery<T extends DeleteQuery<T>> {
  final StringBuffer _deleteQueryMaker = StringBuffer();

  T returning(List<String> query) {
    _deleteQueryMaker.write(" RETURNING ${query.join(",")}");

    return this as T;
  }
}

mixin SelectQuery<T extends SelectQuery<T>> {
  final StringBuffer _selectQueryMaker = StringBuffer();

  T column(List<String> query) {
    _selectQueryMaker.write(query.join(","));

    return this as T;
  }

  T all() {
    _selectQueryMaker.write(" * ");

    return this as T;
  }
}

class InsertQuery<T extends InsertQuery<T>> {
  final StringBuffer _insertQueryMaker = StringBuffer();
  final List<String> _keys = [];
  final List<String> _values = [];

  T value(String key, dynamic value) {
    _keys.add(key);
    _values.add(value is String ? "'$value'" : value);

    return this as T;
  }

  T returning(List<String> query) {
    _insertQueryMaker.write(" RETURNING ${query.join(",")}");

    return this as T;
  }
}

mixin UpdateQuery<T extends UpdateQuery<T>> {
  final StringBuffer _updateQueryMaker = StringBuffer();
  final List<String> _keys = [];
  final List<String> _values = [];

  T set(String key, dynamic value) {
    _keys.add(key);
    _values.add(value is String ? "'$value'" : value);

    return this as T;
  }

  T returning(List<String> query) {
    _updateQueryMaker.write(" RETURNING ${query.join(",")}");

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
      sqliteDb!.execute(
          "DELETE FROM $tableName ${_queryMaker.toString()} ${_deleteQueryMaker.toString()}");
    } else if (dbType == DbType.postgresql) {
      postgresqlDb!.execute(
          "DELETE FROM $tableName ${_queryMaker.toString()} ${_deleteQueryMaker.toString()}");
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
      final rows = sqliteDb!.select(
          "SELECT ${_selectQueryMaker.toString()} FROM $tableName ${_queryMaker.toString()}");

      for (final row in rows[0].entries) {
        result[row.key] = row.value;
      }
    } else if (dbType == DbType.postgresql) {
      postgresqlDb!
          .query(
              "SELECT ${_selectQueryMaker.toString()} FROM $tableName ${_queryMaker.toString()}")
          .single
          .then((row) {
        result = row.toMap();
      });
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> fetchAll() async {
    List<Map<String, dynamic>> results = [];

    if (dbType == DbType.sqlite) {
      final rows = sqliteDb!.select(
          "SELECT ${_selectQueryMaker.toString()} FROM $tableName ${_queryMaker.toString()}");

      for (final row in rows) {
        Map<String, dynamic> result = {};

        for (final rowMap in row.entries) {
          result[rowMap.key] = rowMap.value;
        }

        results.add(result);
      }
    } else if (dbType == DbType.postgresql) {
      postgresqlDb!
          .query(
              "SELECT ${_selectQueryMaker.toString()} FROM $tableName ${_queryMaker.toString()}")
          .toList()
          .then((rows) {
        for (final row in rows) {
          results.add(row.toMap());
        }
      });
    }

    return results;
  }
}

class Insert extends InsertQuery<Insert> {
  final String tableName;
  final DbType dbType;
  Connection? postgresqlDb;
  Database? sqliteDb;
  final StringBuffer _queryDataString = StringBuffer();

  Insert(
      {required this.tableName,
      required this.dbType,
      this.postgresqlDb,
      this.sqliteDb});

  void putKeyValueData() {
    StringBuffer valuesString = StringBuffer();

    for (var i = 0; i < _keys.length; ++i) {
      valuesString.write(_values[i]);

      if (i < _keys.length - 1) {
        valuesString.write(",");
      }
    }

    _queryDataString
        .write("(${_keys.join(",")}) VALUES (${valuesString.toString()})");
  }

  void execute() async {
    putKeyValueData();

    if (dbType == DbType.sqlite) {
      sqliteDb!
          .execute("INSERT INTO $tableName ${_queryDataString.toString()}");
    } else if (dbType == DbType.postgresql) {
      await postgresqlDb!
          .execute("INSERT INTO $tableName ${_queryDataString.toString()}");
    }
  }

  Map<String, dynamic> fetchOne() {
    putKeyValueData();

    Map<String, dynamic> result = {};

    if (dbType == DbType.sqlite) {
      final rows = sqliteDb!.select(
          "INSERT INTO $tableName ${_queryDataString.toString()} RETURNING ${_queryDataString.toString()}");

      for (final row in rows[0].entries) {
        result[row.key] = row.value;
      }
    } else if (dbType == DbType.postgresql) {
      postgresqlDb!
          .query(
              "INSERT INTO $tableName ${_queryDataString.toString()} RETURNING ${_queryDataString.toString()}")
          .single
          .then((row) {
        result = row.toMap();
      });
    }

    return result;
  }

  List<Map<String, dynamic>> fetchAll() {
    putKeyValueData();

    List<Map<String, dynamic>> results = [];

    if (dbType == DbType.sqlite) {
      final rows = sqliteDb!.select(
          "INSERT INTO $tableName ${_queryDataString.toString()} RETURNING ${_queryDataString.toString()}");

      for (final row in rows) {
        Map<String, dynamic> result = {};

        for (final rowMap in row.entries) {
          result[rowMap.key] = rowMap.value;
        }

        results.add(result);
      }
    } else if (dbType == DbType.postgresql) {
      postgresqlDb!
          .query(
              "INSERT INTO $tableName ${_queryDataString.toString()} RETURNING ${_queryDataString.toString()}")
          .toList()
          .then((rows) {
        for (final row in rows) {
          results.add(row.toMap());
        }
      });
    }

    return results;
  }
}

class Update extends Query<Update> with UpdateQuery<Update> {
  final String tableName;
  final DbType dbType;
  Connection? postgresqlDb;
  Database? sqliteDb;
  final StringBuffer _queryDataString = StringBuffer();

  Update(
      {required this.tableName,
      required this.dbType,
      this.postgresqlDb,
      this.sqliteDb});

  void putKeyValueData() {
    for (var i = 0; i < _keys.length; ++i) {
      _queryDataString.write("${_keys[i]} = ${_values[i]}");

      if (i < _keys.length - 1) {
        _queryDataString.write(",");
      }
    }
  }

  void execute() async {
    putKeyValueData();

    if (dbType == DbType.sqlite) {
      sqliteDb!.execute(
          "UPDATE $tableName SET ${_queryDataString.toString()} ${_updateQueryMaker.toString()}");
    } else if (dbType == DbType.postgresql) {
      await postgresqlDb!.execute(
          "UPDATE $tableName SET ${_queryDataString.toString()} ${_updateQueryMaker.toString()}");
    }
  }

  Map<String, dynamic> fetchOne() {
    Map<String, dynamic> result = {};

    if (dbType == DbType.sqlite) {
      final rows = sqliteDb!.select(
          "UPDATE $tableName SET ${_queryDataString.toString()} ${_updateQueryMaker.toString()} RETURNING ${_updateQueryMaker.toString()}");

      for (final row in rows[0].entries) {
        result[row.key] = row.value;
      }
    } else if (dbType == DbType.postgresql) {
      postgresqlDb!
          .query(
              "UPDATE $tableName SET ${_queryDataString.toString()} ${_updateQueryMaker.toString()} RETURNING ${_updateQueryMaker.toString()}")
          .single
          .then((row) {
        result = row.toMap();
      });
    }
    return result;
  }

  List<Map<String, dynamic>> fetchAll() {
    List<Map<String, dynamic>> results = [];

    if (dbType == DbType.sqlite) {
      final rows = sqliteDb!.select(
          "UPDATE $tableName SET ${_queryDataString.toString()} ${_updateQueryMaker.toString()} RETURNING ${_updateQueryMaker.toString()}");

      for (final row in rows) {
        Map<String, dynamic> result = {};

        for (final rowMap in row.entries) {
          result[rowMap.key] = rowMap.value;
        }

        results.add(result);
      }
    } else if (dbType == DbType.postgresql) {
      postgresqlDb!
          .query(
              "UPDATE $tableName SET ${_queryDataString.toString()} ${_updateQueryMaker.toString()} RETURNING ${_updateQueryMaker.toString()}")
          .toList()
          .then((rows) {
        for (final row in rows) {
          results.add(row.toMap());
        }
      });
    }

    return results;
  }
}
