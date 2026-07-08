import relationalStore from '@ohos.data.relationalStore';

interface MeasurementSession {
  id: number;
  startTime: number;
  endTime: number;
  duration: number;
  avgDb: number;
  maxDb: number;
  minDb: number;
  sampleCount: number;
}

class MeasurementRepository {
  private store: relationalStore.RdbStore | null = null;
  private readonly dbName: string = 'decibel_db.db';

  async init(): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: this.dbName,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    try {
      this.store = await relationalStore.getRdbStore(getContext(), config);
      await this.createTables();
      console.info('RDB store initialized');
    } catch (err) {
      console.error('Failed to initialize RDB store:', err);
    }
  }

  private async createTables(): Promise<void> {
    if (!this.store) return;
    const createSessionTable = `
      CREATE TABLE IF NOT EXISTS measurement_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        avg_db REAL NOT NULL,
        max_db REAL NOT NULL,
        min_db REAL NOT NULL,
        sample_count INTEGER NOT NULL
      )
    `;
    try {
      await this.store.execute(createSessionTable);
      console.info('Tables created');
    } catch (err) {
      console.error('Failed to create tables:', err);
    }
  }

  async insertSession(session: Omit<MeasurementSession, 'id'>): Promise<number> {
    if (!this.store) return -1;
    try {
      const valueBucket: relationalStore.ValuesBucket = {
        start_time: session.startTime,
        end_time: session.endTime,
        duration: session.duration,
        avg_db: session.avgDb,
        max_db: session.maxDb,
        min_db: session.minDb,
        sample_count: session.sampleCount
      };
      const id = await this.store.insert('measurement_sessions', valueBucket);
      console.info('Session inserted, id:', id);
      return id;
    } catch (err) {
      console.error('Failed to insert session:', err);
      return -1;
    }
  }

  async getAllSessions(): Promise<MeasurementSession[]> {
    if (!this.store) return [];
    try {
      const predicates = new relationalStore.RdbPredicates('measurement_sessions');
      predicates.orderByDesc('start_time');
      const resultSet = await this.store.query(predicates);
      const sessions: MeasurementSession[] = [];
      while (resultSet.goToNextRow()) {
        sessions.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          startTime: resultSet.getLong(resultSet.getColumnIndex('start_time')),
          endTime: resultSet.getLong(resultSet.getColumnIndex('end_time')),
          duration: resultSet.getLong(resultSet.getColumnIndex('duration')),
          avgDb: resultSet.getDouble(resultSet.getColumnIndex('avg_db')),
          maxDb: resultSet.getDouble(resultSet.getColumnIndex('max_db')),
          minDb: resultSet.getDouble(resultSet.getColumnIndex('min_db')),
          sampleCount: resultSet.getLong(resultSet.getColumnIndex('sample_count'))
        });
      }
      resultSet.close();
      return sessions;
    } catch (err) {
      console.error('Failed to query sessions:', err);
      return [];
    }
  }

  async deleteSession(id: number): Promise<void> {
    if (!this.store) return;
    try {
      const predicates = new relationalStore.RdbPredicates('measurement_sessions');
      predicates.equalTo('id', id);
      await this.store.delete(predicates);
      console.info('Session deleted, id:', id);
    } catch (err) {
      console.error('Failed to delete session:', err);
    }
  }

  async close(): Promise<void> {
    if (this.store) {
      try {
        await this.store.close();
        this.store = null;
        console.info('RDB store closed');
      } catch (err) {
        console.error('Failed to close RDB store:', err);
      }
    }
  }
}

export { MeasurementSession, MeasurementRepository };
export default new MeasurementRepository();
