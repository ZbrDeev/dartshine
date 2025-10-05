enum OrmTypes {
  int,
  string,
}

String ormTypeToString(OrmTypes type) {
  switch (type) {
    case OrmTypes.int:
      return 'INTEGER';
    case OrmTypes.string:
      return 'TEXT';
  }
}
