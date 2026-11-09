import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { GachaRecord, GachaPool } from '../model/GachaModels';
import { PRESET_POOLS, DEMO_PULLS, DemoPull } from '../model/PresetPools';
import { dayAgoStr } from '../common/Format';

const SQL_CREATE_POOLS: string = `
CREATE TABLE IF NOT EXISTS pools (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  pool_type INTEGER NOT NULL,
  up_name TEXT,
  start_date TEXT,
  end_date TEXT,
  is_current INTEGER DEFAULT 0,
  builtin INTEGER DEFAULT 0
)`;

const SQL_CREATE_RECORDS: string = `
CREATE TABLE IF NOT EXISTS gacha_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  pool_id INTEGER NOT NULL,
  star INTEGER NOT NULL,
  item_name TEXT NOT NULL,
  pull_no INTEGER,
  record_date TEXT NOT NULL,
  created_at INTEGER NOT NULL
)`;

const DB_NAME: string = 'harmony_gacha.db';

export class GachaDb {
  private static initTask: Promise<GachaDb> | null = null;
  private rdb: relationalStore.RdbStore | null = null;
  private memPools: GachaPool[] = [];
  private memRecords: GachaRecord[] = [];
  private memPoolSeq: number = 1;
  private memRecordSeq: number = 1;

  private constructor() {
  }

  public static ensure(context: common.Context): Promise<GachaDb> {
    if (GachaDb.initTask === null) {
      GachaDb.initTask = GachaDb.create(context);
    }
    return GachaDb.initTask;
  }

  private static async create(context: common.Context): Promise<GachaDb> {
    const db = new GachaDb();
    try {
      const config: relationalStore.StoreConfig = {
        name: DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      };
      const rdb = await relationalStore.getRdbStore(context, config);
      await rdb.executeSql(SQL_CREATE_POOLS);
      await rdb.executeSql(SQL_CREATE_RECORDS);
      db.rdb = rdb;
    } catch (e) {
      db.rdb = null;
    }
    try {
      await db.seedIfNeeded();
    } catch (e) {
      // 种子数据写入失败时降级：不抛出，App 以空库或内存模式继续可用
    }
    return db;
  }

  public isMemoryMode(): boolean {
    return this.rdb === null;
  }

  private async seedIfNeeded(): Promise<void> {
    const pools = await this.getPools();
    if (pools.length > 0) {
      return;
    }
    const ids: number[] = [];
    for (const spec of PRESET_POOLS) {
      const id = await this.insertPoolRaw(spec.name, spec.poolType, spec.upName, '', '', spec.isCurrent, true);
      ids.push(id);
    }
    const now = Date.now();
    const sorted = DEMO_PULLS.slice().sort((a: DemoPull, b: DemoPull) => b.dayOffset - a.dayOffset);
    let idx = 0;
    for (const pull of sorted) {
      const poolId = ids[pull.poolIndex];
      const date = dayAgoStr(pull.dayOffset);
      const createdAt = now - pull.dayOffset * 86400000 + idx;
      await this.insertRaw(poolId, pull.star, pull.itemName, pull.pullNo, date, createdAt);
      idx++;
    }
  }

  public async getPools(): Promise<GachaPool[]> {
    if (this.rdb !== null) {
      const rs = await this.rdb.querySql(
        'SELECT id, name, pool_type, up_name, start_date, end_date, is_current, builtin FROM pools ORDER BY is_current DESC, builtin DESC, id ASC', []);
      const list: GachaPool[] = [];
      while (rs.goToNextRow()) {
        const p = new GachaPool();
        p.id = rs.getLong(rs.getColumnIndex('id'));
        p.name = rs.getString(rs.getColumnIndex('name'));
        p.poolType = rs.getLong(rs.getColumnIndex('pool_type'));
        const upIdx = rs.getColumnIndex('up_name');
        p.upName = rs.isColumnNull(upIdx) ? '' : rs.getString(upIdx);
        const sdIdx = rs.getColumnIndex('start_date');
        p.startDate = rs.isColumnNull(sdIdx) ? '' : rs.getString(sdIdx);
        const edIdx = rs.getColumnIndex('end_date');
        p.endDate = rs.isColumnNull(edIdx) ? '' : rs.getString(edIdx);
        p.isCurrent = rs.getLong(rs.getColumnIndex('is_current')) === 1;
        p.builtin = rs.getLong(rs.getColumnIndex('builtin')) === 1;
        list.push(p);
      }
      rs.close();
      return list;
    }
    return this.memPools.slice();
  }

  public async addPool(name: string, poolType: number, upName: string,
    startDate: string, endDate: string, makeCurrent: boolean): Promise<number> {
    return this.insertPoolRaw(name, poolType, upName, startDate, endDate, makeCurrent, false);
  }

  private async insertPoolRaw(name: string, poolType: number, upName: string,
    startDate: string, endDate: string, makeCurrent: boolean, builtin: boolean): Promise<number> {
    let id = 0;
    if (this.rdb !== null) {
      const bucket: relationalStore.ValuesBucket = {
        'name': name,
        'pool_type': poolType,
        'up_name': upName,
        'start_date': startDate,
        'end_date': endDate,
        'is_current': 0,
        'builtin': builtin ? 1 : 0
      };
      id = await this.rdb.insert('pools', bucket);
    } else {
      const p = new GachaPool();
      id = this.memPoolSeq;
      this.memPoolSeq++;
      p.id = id;
      p.name = name;
      p.poolType = poolType;
      p.upName = upName;
      p.startDate = startDate;
      p.endDate = endDate;
      p.builtin = builtin;
      p.isCurrent = false;
      this.memPools.push(p);
    }
    if (makeCurrent) {
      await this.setCurrentPool(id);
    }
    return id;
  }

  public async updatePool(pool: GachaPool): Promise<void> {
    if (this.rdb !== null) {
      await this.rdb.executeSql(
        'UPDATE pools SET name = ?, pool_type = ?, up_name = ?, start_date = ?, end_date = ? WHERE id = ?',
        [pool.name, pool.poolType, pool.upName, pool.startDate, pool.endDate, pool.id]);
      return;
    }
    for (const p of this.memPools) {
      if (p.id === pool.id) {
        p.name = pool.name;
        p.poolType = pool.poolType;
        p.upName = pool.upName;
        p.startDate = pool.startDate;
        p.endDate = pool.endDate;
      }
    }
  }

  public async deletePool(poolId: number): Promise<void> {
    if (this.rdb !== null) {
      await this.rdb.executeSql('DELETE FROM gacha_records WHERE pool_id = ?', [poolId]);
      await this.rdb.executeSql('DELETE FROM pools WHERE id = ?', [poolId]);
      return;
    }
    this.memRecords = this.memRecords.filter((r: GachaRecord) => r.poolId !== poolId);
    this.memPools = this.memPools.filter((p: GachaPool) => p.id !== poolId);
  }

  public async setCurrentPool(poolId: number): Promise<void> {
    if (this.rdb !== null) {
      await this.rdb.executeSql('UPDATE pools SET is_current = 0', []);
      await this.rdb.executeSql('UPDATE pools SET is_current = 1 WHERE id = ?', [poolId]);
      return;
    }
    for (const p of this.memPools) {
      p.isCurrent = p.id === poolId;
    }
  }

  public async getAllRecords(): Promise<GachaRecord[]> {
    if (this.rdb !== null) {
      const rs = await this.rdb.querySql(
        'SELECT id, pool_id, star, item_name, pull_no, record_date, created_at FROM gacha_records ORDER BY created_at ASC, id ASC', []);
      const list: GachaRecord[] = [];
      while (rs.goToNextRow()) {
        const r = new GachaRecord();
        r.id = rs.getLong(rs.getColumnIndex('id'));
        r.poolId = rs.getLong(rs.getColumnIndex('pool_id'));
        r.star = rs.getLong(rs.getColumnIndex('star'));
        r.itemName = rs.getString(rs.getColumnIndex('item_name'));
        const pnIdx = rs.getColumnIndex('pull_no');
        r.pullNo = rs.isColumnNull(pnIdx) ? 0 : rs.getLong(pnIdx);
        r.recordDate = rs.getString(rs.getColumnIndex('record_date'));
        r.createdAt = rs.getLong(rs.getColumnIndex('created_at'));
        list.push(r);
      }
      rs.close();
      return list;
    }
    return this.memRecords.slice();
  }

  public async insertRecord(poolId: number, star: number, itemName: string,
    pullNo: number, recordDate: string): Promise<number> {
    return this.insertRaw(poolId, star, itemName, pullNo, recordDate, Date.now());
  }

  private async insertRaw(poolId: number, star: number, itemName: string,
    pullNo: number, recordDate: string, createdAt: number): Promise<number> {
    if (this.rdb !== null) {
      const bucket: relationalStore.ValuesBucket = {
        'pool_id': poolId,
        'star': star,
        'item_name': itemName,
        'pull_no': pullNo,
        'record_date': recordDate,
        'created_at': createdAt
      };
      return await this.rdb.insert('gacha_records', bucket);
    }
    const r = new GachaRecord();
    r.id = this.memRecordSeq;
    this.memRecordSeq++;
    r.poolId = poolId;
    r.star = star;
    r.itemName = itemName;
    r.pullNo = pullNo;
    r.recordDate = recordDate;
    r.createdAt = createdAt;
    this.memRecords.push(r);
    return r.id;
  }

  public async deleteRecord(recordId: number): Promise<void> {
    if (this.rdb !== null) {
      await this.rdb.executeSql('DELETE FROM gacha_records WHERE id = ?', [recordId]);
      return;
    }
    this.memRecords = this.memRecords.filter((r: GachaRecord) => r.id !== recordId);
  }

  public async clearRecords(): Promise<void> {
    if (this.rdb !== null) {
      await this.rdb.executeSql('DELETE FROM gacha_records', []);
      return;
    }
    this.memRecords = [];
  }
}
