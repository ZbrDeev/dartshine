class InvalidOrmDatabse extends Error {
  InvalidOrmDatabse();

  @override
  String toString() {
    return 'Expect for an ORM database such as Sqlite or Postgresql.';
  }
}
