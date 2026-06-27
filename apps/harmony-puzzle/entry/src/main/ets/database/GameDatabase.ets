import relationalStore from '@ohos.data.relationalStore'
import type { GameRecord } from '../model/GameRecord'

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'HarmonyPuzzle.db',
  securityLevel: relationalStore.SecurityLevel.S1
}

const CREATE_TABLE_SQL = 'CREATE TABLE IF NOT EXISTS game_records (id INTEGER PRIMARY KEY AUTOINCREMENT, difficulty INTEGER NOT NULL, time_seconds INTEGER NOT NULL, steps INTEGER NOT NULL, completed_at TEXT NOT NULL, is_best INTEGER NOT NULL DEFAULT 0)'

export class GameDatabase {
  private static store: relationalStore.RdbStore | null = null
  private static initializing: Promise<relationalStore.RdbStore> | null = null

  static async getStore(context: Context): Promise<relationalStore.RdbStore> {
    if (GameDatabase.store) {
      return GameDatabase.store
    }
    if (!GameDatabase.initializing) {
      GameDatabase.initializing = relationalStore.getRdbStore(context, STORE_CONFIG)
        .then(async (store: relationalStore.RdbStore) => {
          await store.executeSql(CREATE_TABLE_SQL)
          GameDatabase.store = store
          return store
        })
    }
    return GameDatabase.initializing
  }

  static async insertRecord(context: Context, record: GameRecord): Promise<boolean> {
    const store = await GameDatabase.getStore(context)
    const values = {
      difficulty: record.difficulty,
      time_seconds: record.timeSeconds,
      steps: record.steps,
      completed_at: record.completedAt,
      is_best: 0
    }
    await store.insert('game_records', values)
    const bestRecord = await GameDatabase.getBestRecord(context, record.difficulty)
    const isBest = !!bestRecord && bestRecord.timeSeconds === record.timeSeconds && bestRecord.steps === record.steps && bestRecord.completedAt === record.completedAt
    if (isBest) {
      await store.executeSql('UPDATE game_records SET is_best = CASE WHEN difficulty = ? AND id = (SELECT id FROM game_records WHERE difficulty = ? ORDER BY time_seconds ASC, steps ASC, completed_at ASC LIMIT 1) THEN 1 WHEN difficulty = ? THEN 0 ELSE is_best END', [record.difficulty, record.difficulty, record.difficulty])
    }
    return isBest
  }

  static async getBestRecord(context: Context, difficulty: number): Promise<GameRecord | null> {
    const store = await GameDatabase.getStore(context)
    const predicates = new relationalStore.RdbPredicates('game_records')
    predicates.equalTo('difficulty', difficulty)
    predicates.orderByAsc('time_seconds')
    predicates.orderByAsc('steps')
    predicates.orderByAsc('completed_at')
    predicates.limitAs(0, 1)
    const resultSet = await store.query(predicates)
    const records = GameDatabase.readRecords(resultSet)
    resultSet.close()
    return records.length > 0 ? records[0] : null
  }

  static async getBestRecords(context: Context): Promise<Record<number, GameRecord | null>> {
    const summary: Record<number, GameRecord | null> = {
      3: null,
      4: null,
      5: null
    }
    summary[3] = await GameDatabase.getBestRecord(context, 3)
    summary[4] = await GameDatabase.getBestRecord(context, 4)
    summary[5] = await GameDatabase.getBestRecord(context, 5)
    return summary
  }

  static async getLeaderboard(context: Context): Promise<GameRecord[]> {
    const store = await GameDatabase.getStore(context)
    const predicates = new relationalStore.RdbPredicates('game_records')
    predicates.orderByDesc('is_best')
    predicates.orderByAsc('time_seconds')
    predicates.orderByAsc('steps')
    predicates.orderByDesc('completed_at')
    predicates.limitAs(0, 50)
    const resultSet = await store.query(predicates)
    const records = GameDatabase.readRecords(resultSet)
    resultSet.close()
    return records
  }

  private static readRecords(resultSet: relationalStore.ResultSet): GameRecord[] {
    const records: GameRecord[] = []
    if (resultSet.rowCount === 0) {
      return records
    }
    resultSet.goToFirstRow()
    do {
      records.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        difficulty: resultSet.getLong(resultSet.getColumnIndex('difficulty')),
        timeSeconds: resultSet.getLong(resultSet.getColumnIndex('time_seconds')),
        steps: resultSet.getLong(resultSet.getColumnIndex('steps')),
        completedAt: resultSet.getString(resultSet.getColumnIndex('completed_at')),
        isBest: resultSet.getLong(resultSet.getColumnIndex('is_best'))
      })
    } while (resultSet.goToNextRow())
    return records
  }
}
