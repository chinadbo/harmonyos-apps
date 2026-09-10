import relationalStore from '@ohos.data.relationalStore';
import { ChartRecord } from './ChartDataModel';

const STORE_CONFIG = {
  name: 'harmonyInsight.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

const CREATE_TABLE_SQL = `
  CREATE TABLE IF NOT EXISTS chart_records (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    data TEXT NOT NULL,
    config TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  )
`;

const CREATE_INDEX_SQL = `
  CREATE INDEX IF NOT EXISTS idx_updated_at ON chart_records(updated_at DESC)
`;

/**
 * 关系型数据库辅助类
 * 管理图表历史记录的增删改查
 */
export class RDBHelper {
  private static store: relationalStore.RdbStore | null = null;

  /**
   * 初始化数据库
   */
  static async init(context: any): Promise<void> {
    if (this.store) return;

    try {
      this.store = await relationalStore.getRdbStore(context, STORE_CONFIG);
      await this.store.executeSql(CREATE_TABLE_SQL);
      await this.store.executeSql(CREATE_INDEX_SQL);
      console.info('RDBHelper', 'Database initialized successfully');
    } catch (err) {
      console.error('RDBHelper', `Init failed: ${JSON.stringify(err)}`);
      throw err;
    }
  }

  /**
   * 保存图表记录
   */
  static async saveRecord(record: ChartRecord): Promise<void> {
    if (!this.store) throw new Error('Database not initialized');

    const values = new relationalStore.ValuesBucket();
    values.putString('id', record.id);
    values.putString('name', record.name);
    values.putString('type', record.type);
    values.putString('data', record.data);
    values.putString('config', record.config);
    values.putLong('created_at', record.createdAt);
    values.putLong('updated_at', record.updatedAt);

    try {
      const existing = await this.getRecordById(record.id);
      if (existing) {
        await this.store.update(values, {
          table: 'chart_records',
          where: `id = '${record.id}'`
        });
      } else {
        await this.store.insert('chart_records', values);
      }
      console.info('RDBHelper', `Record saved: ${record.name}`);
    } catch (err) {
      console.error('RDBHelper', `Save failed: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 根据 ID 获取图表记录
   */
  static async getRecordById(id: string): Promise<ChartRecord | null> {
    if (!this.store) return null;

    try {
      const result = await this.store.querySql(
        'SELECT * FROM chart_records WHERE id = ?',
        [id]
      );

      if (result.rowCount > 0) {
        result.goToFirstRow();
        return this.rowToRecord(result);
      }
      return null;
    } catch (err) {
      console.error('RDBHelper', `GetById failed: ${JSON.stringify(err)}`);
      return null;
    }
  }

  /**
   * 获取所有图表记录（按更新时间倒序）
   */
  static async getAllRecords(limit: number = 50): Promise<ChartRecord[]> {
    if (!this.store) return [];

    try {
      const result = await this.store.querySql(
        'SELECT * FROM chart_records ORDER BY updated_at DESC LIMIT ?',
        [limit]
      );

      const records: ChartRecord[] = [];
      for (let i = 0; i < result.rowCount; i++) {
        result.goToRow(i);
        records.push(this.rowToRecord(result));
      }
      return records;
    } catch (err) {
      console.error('RDBHelper', `GetAll failed: ${JSON.stringify(err)}`);
      return [];
    }
  }

  /**
   * 删除图表记录
   */
  static async deleteRecord(id: string): Promise<void> {
    if (!this.store) return;

    try {
      await this.store.delete({
        table: 'chart_records',
        where: `id = '${id}'`
      });
      console.info('RDBHelper', `Record deleted: ${id}`);
    } catch (err) {
      console.error('RDBHelper', `Delete failed: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 清空所有记录
   */
  static async clearAll(): Promise<void> {
    if (!this.store) return;

    try {
      await this.store.delete({
        table: 'chart_records',
        where: '1 = 1'
      });
      console.info('RDBHelper', 'All records cleared');
    } catch (err) {
      console.error('RDBHelper', `Clear failed: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 将数据库行转换为 ChartRecord
   */
  private static rowToRecord(result: relationalStore.ResultSet): ChartRecord {
    return {
      id: result.getString(result.getColumnIndex('id')),
      name: result.getString(result.getColumnIndex('name')),
      type: result.getString(result.getColumnIndex('type')) as any,
      data: result.getString(result.getColumnIndex('data')),
      config: result.getString(result.getColumnIndex('config')),
      createdAt: result.getLong(result.getColumnIndex('created_at')),
      updatedAt: result.getLong(result.getColumnIndex('updated_at'))
    };
  }

  /**
   * 获取记录总数
   */
  static async getCount(): Promise<number> {
    if (!this.store) return 0;

    try {
      const result = await this.store.querySql('SELECT COUNT(*) as cnt FROM chart_records');
      if (result.rowCount > 0) {
        result.goToFirstRow();
        return result.getLong(result.getColumnIndex('cnt'));
      }
      return 0;
    } catch {
      return 0;
    }
  }
}
