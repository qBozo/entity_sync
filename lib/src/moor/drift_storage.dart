part of 'drift.dart';

/// Responsible for local storage through Drift
class DriftStorage<TProxy extends ProxyMixin<DataClass>>
    implements Storage<TProxy> {
  /// The Drift database that we are syncing with
  final GeneratedDatabase database;

  /// The Drift table that we are syncing with
  final SyncableTable table;

  /// The flag column of the table
  late Column flagColumn;

  /// The proxy factory
  final ProxyFactory proxyFactory;

  DriftStorage(this.table, this.database, this.proxyFactory) {
    /// Get the flag column on the table
    flagColumn = table.shouldSync;
  }

  @override
  Future<Iterable<TProxy>> getInstancesToSync() async {
    final toSyncInstances =
        await (database.select(table.actualTable() as TableInfo<Table, DataClass>)
              ..where((t) => flagColumn.equals(true)))
            .get();

    return toSyncInstances.map((e) => proxyFactory.fromInstance(e) as TProxy);
  }

  @override
  Future<TProxy?> get({dynamic remoteKey, dynamic localKey}) async {
    DataClass? instance;
    if (remoteKey != null) {
      instance = await (database.select(table.actualTable() as TableInfo<Table, DataClass>)
            ..where((t) => table.remoteKeyColumn().equals(remoteKey)))
          .getSingle();
    } else if (localKey != null) {
      instance = await (database.select(table.actualTable() as TableInfo<Table, DataClass>)
            ..where((t) => table.localKeyColumn().equals(localKey)))
          .getSingle();
    }

    if (instance == null) {
      return null;
    }

    return proxyFactory.fromInstance(instance) as TProxy;
  }

  @override
  Future<StorageResult<TProxy>> insert(TProxy instance,
      {dynamic remoteKey, dynamic localKey}) async {
    await database.into(table.actualTable() as TableInfo<Table, DataClass>).insert(instance);
    return StorageResult<TProxy>(true);
  }

  @override
  Future<StorageResult<TProxy>> update(TProxy instance,
      {dynamic remoteKey, dynamic localKey}) async {
    final localInstance = await get(remoteKey: remoteKey, localKey: localKey);

    if (localInstance != null) {
      await (database.update(table.actualTable() as TableInfo<Table, DataClass>)
            ..where((t) =>
                table.localKeyColumn().equals(localInstance.getLocalKey())))
          .write(instance);
    } else {
      throw ArgumentError('Could not find a local instance');
    }

    return StorageResult<TProxy>(true);
  }
}
