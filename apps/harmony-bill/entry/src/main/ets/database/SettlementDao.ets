import relationalStore from '@ohos.data.relationalStore';
import { DatabaseHelper } from './DatabaseHelper';
import { Settlement, SettlementDetail } from '../model/Settlement';

export class SettlementDao {
  private helper: DatabaseHelper = DatabaseHelper.getInstance();

  async replaceByGroupId(groupId: number, settlements: Settlement[]): Promise<void> {
    await this.deleteByGroupId(groupId);
    const store = await this.helper.getStore();
    for (const settlement of settlements) {
      const values: relationalStore.ValuesBucket = {
        group_id: groupId,
        from_member_id: settlement.fromMemberId,
        to_member_id: settlement.toMemberId,
        amount: settlement.amount,
        is_paid: settlement.isPaid,
        paid_at: settlement.paidAt
      };
      await store.insert('settlements', values);
    }
  }

  async deleteByGroupId(groupId: number): Promise<void> {
    const store = await this.helper.getStore();
    const predicates = new relationalStore.RdbPredicates('settlements');
    predicates.equalTo('group_id', groupId);
    await store.delete(predicates);
  }

  async updatePaid(settlementId: number, isPaid: number): Promise<void> {
    const store = await this.helper.getStore();
    const values: relationalStore.ValuesBucket = {
      is_paid: isPaid,
      paid_at: isPaid === 1 ? Date.now() : 0
    };
    const predicates = new relationalStore.RdbPredicates('settlements');
    predicates.equalTo('id', settlementId);
    await store.update(values, predicates);
  }

  async getByGroupId(groupId: number): Promise<SettlementDetail[]> {
    const store = await this.helper.getStore();
    const sql = `SELECT s.id, s.group_id, s.from_member_id, s.to_member_id, s.amount, s.is_paid, s.paid_at,
      fm.name AS from_member_name, fm.color_index AS from_color_index,
      tm.name AS to_member_name, tm.color_index AS to_color_index
      FROM settlements s
      LEFT JOIN members fm ON s.from_member_id = fm.id
      LEFT JOIN members tm ON s.to_member_id = tm.id
      WHERE s.group_id = ?
      ORDER BY s.is_paid ASC, s.amount DESC, s.id ASC`;
    const resultSet = await store.querySql(sql, [groupId.toString()]);
    const list: SettlementDetail[] = [];
    if (resultSet.goToFirstRow()) {
      do {
        list.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          groupId: resultSet.getLong(resultSet.getColumnIndex('group_id')),
          fromMemberId: resultSet.getLong(resultSet.getColumnIndex('from_member_id')),
          toMemberId: resultSet.getLong(resultSet.getColumnIndex('to_member_id')),
          amount: resultSet.getLong(resultSet.getColumnIndex('amount')),
          isPaid: resultSet.getLong(resultSet.getColumnIndex('is_paid')),
          paidAt: resultSet.getLong(resultSet.getColumnIndex('paid_at')),
          fromMemberName: resultSet.getString(resultSet.getColumnIndex('from_member_name')),
          fromColorIndex: resultSet.getLong(resultSet.getColumnIndex('from_color_index')),
          toMemberName: resultSet.getString(resultSet.getColumnIndex('to_member_name')),
          toColorIndex: resultSet.getLong(resultSet.getColumnIndex('to_color_index'))
        });
      } while (resultSet.goToNextRow());
    }
    resultSet.close();
    return list;
  }
}
