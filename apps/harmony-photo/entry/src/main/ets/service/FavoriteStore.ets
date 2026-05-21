import relationalStore from '@ohos.data.relationalStore'

export class FavoriteStore {
  private static store: relationalStore.RdbStore | null = null

  static async init(context: Context): Promise<void> {
    if (FavoriteStore.store) {
      return
    }
    let config: relationalStore.StoreConfig = {
      name: 'favorite_store.db',
      securityLevel: relationalStore.SecurityLevel.S1
    }
    FavoriteStore.store = await relationalStore.getRdbStore(context, config)
    await FavoriteStore.store.executeSql(
      'CREATE TABLE IF NOT EXISTS favorites (id INTEGER PRIMARY KEY AUTOINCREMENT, uri TEXT NOT NULL UNIQUE, added_at INTEGER NOT NULL)'
    )
  }

  static async addFavorite(uri: string): Promise<void> {
    if (!FavoriteStore.store) {
      return
    }
    let values: relationalStore.ValuesBucket = {
      'uri': uri,
      'added_at': Date.now()
    }
    try {
      await FavoriteStore.store.insert('favorites', values)
    } catch (err) {
      console.error(`addFavorite error: ${JSON.stringify(err)}`)
    }
  }

  static async removeFavorite(uri: string): Promise<void> {
    if (!FavoriteStore.store) {
      return
    }
    let predicates = new relationalStore.RdbPredicates('favorites')
    predicates.equalTo('uri', uri)
    await FavoriteStore.store.delete(predicates)
  }

  static async getFavorites(): Promise<string[]> {
    if (!FavoriteStore.store) {
      return []
    }
    let resultSet = await FavoriteStore.store.querySql(
      'SELECT uri FROM favorites ORDER BY added_at DESC'
    )
    let results: string[] = []
    while (resultSet.goToNextRow()) {
      results.push(resultSet.getString(0))
    }
    resultSet.close()
    return results
  }

  static async isFavorite(uri: string): Promise<boolean> {
    if (!FavoriteStore.store) {
      return false
    }
    let resultSet = await FavoriteStore.store.querySql(
      'SELECT COUNT(1) FROM favorites WHERE uri = ?',
      [uri]
    )
    let exists = false
    if (resultSet.goToNextRow()) {
      exists = resultSet.getLong(0) > 0
    }
    resultSet.close()
    return exists
  }
}
