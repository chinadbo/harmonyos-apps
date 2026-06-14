import relationalStore from '@ohos.data.relationalStore';
import { DatabaseHelper } from './DatabaseHelper';
import { Group, GroupSummary } from '../model/Group';

export class GroupDao {
  private helper: DatabaseHelper = DatabaseHelper.getInstance();

  async create(name: string, scene: string): Promise<number> {
    const store = await this.helper.getStore();
    const values: relationalStore.ValuesBucket = {
      name,
      scene,
      created_at: Date.now(),
      is_settled: 0
    };
    return await store.insert('groups', values);
  }

  async updateSettled(groupId: number, isSettled: number): Promise<void> {
    const store = await this.helper.getStore();
    const values: relationalStore.ValuesBucket = { is_settled: isSettled };
    const predicates = new relationalStore.RdbPredicates('groups');
    predicates.equalTo('id', groupId);
    await store.update(values, predicates);
  }

  async getById(groupId: number): Promise<Group | null> {
    const store = await this.helper.getStore();
    const predicates = new relationalStore.RdbPredicates('groups');
    predicates.equalTo('id', groupId);
    const resultSet = await store.query(predicates, ['id', 'name', 'scene', 'created_at', 'is_settled']);
    const groups = this.readGroups(resultSet);
    resultSet.close();
    return groups.length > 0 ? groups[0] : null;
  }

  async getAllSummaries(): Promise<GroupSummary[]> {
    const store = await this.helper.getStore();
    const sql = `SELECT g.id, g.name, g.scene, g.created_at, g.is_settled,
      (SELECT COUNT(1) FROM members m WHERE m.group_id = g.id) AS member_count,
      (SELECT COUNT(1) FROM bills b WHERE b.group_id = g.id) AS bill_count,
      COALESCE((SELECT SUM(b2.amount) FROM bills b2 WHERE b2.group_id = g.id), 0) AS total_amount
      FROM groups g
      ORDER BY g.created_at DESC`;
    const resultSet = await store.querySql(sql);
    const summaries: GroupSummary[] = [];
    if (resultSet.goToFirstRow()) {
      do {
        summaries.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          scene: resultSet.getString(resultSet.getColumnIndex('scene')),
          createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at')),
          isSettled: resultSet.getLong(resultSet.getColumnIndex('is_settled')),
          memberCount: resultSet.getLong(resultSet.getColumnIndex('member_count')),
          billCount: resultSet.getLong(resultSet.getColumnIndex('bill_count')),
          totalAmount: resultSet.getLong(resultSet.getColumnIndex('total_amount'))
        });
      } while (resultSet.goToNextRow());
    }
    resultSet.close();
    return summaries;
  }

  private readGroups(resultSet: relationalStore.ResultSet): Group[] {
    const groups: Group[] = [];
    if (resultSet.goToFirstRow()) {
      do {
        groups.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          scene: resultSet.getString(resultSet.getColumnIndex('scene')),
          createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at')),
          isSettled: resultSet.getLong(resultSet.getColumnIndex('is_settled'))
        });
      } while (resultSet.goToNextRow());
    }
    return groups;
  }
}
