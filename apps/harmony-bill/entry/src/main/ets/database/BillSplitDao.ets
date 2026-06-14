import relationalStore from '@ohos.data.relationalStore';
import { DatabaseHelper } from './DatabaseHelper';
import { BillSplit, BillSplitDetail } from '../model/BillSplit';

export class BillSplitDao {
  private helper: DatabaseHelper = DatabaseHelper.getInstance();

  async createMany(billId: number, splits: Array<{ memberId: number; amount: number }>): Promise<void> {
    const store = await this.helper.getStore();
    for (const split of splits) {
      const values: relationalStore.ValuesBucket = {
        bill_id: billId,
        member_id: split.memberId,
        amount: split.amount
      };
      await store.insert('bill_splits', values);
    }
  }

  async deleteByBillId(billId: number): Promise<void> {
    const store = await this.helper.getStore();
    const predicates = new relationalStore.RdbPredicates('bill_splits');
    predicates.equalTo('bill_id', billId);
    await store.delete(predicates);
  }

  async getByBillId(billId: number): Promise<BillSplitDetail[]> {
    const store = await this.helper.getStore();
    const sql = `SELECT bs.id, bs.bill_id, bs.member_id, bs.amount, m.name AS member_name, m.color_index
      FROM bill_splits bs
      LEFT JOIN members m ON bs.member_id = m.id
      WHERE bs.bill_id = ?
      ORDER BY bs.id ASC`;
    const resultSet = await store.querySql(sql, [billId.toString()]);
    const list: BillSplitDetail[] = [];
    if (resultSet.goToFirstRow()) {
      do {
        list.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          billId: resultSet.getLong(resultSet.getColumnIndex('bill_id')),
          memberId: resultSet.getLong(resultSet.getColumnIndex('member_id')),
          amount: resultSet.getLong(resultSet.getColumnIndex('amount')),
          memberName: resultSet.getString(resultSet.getColumnIndex('member_name')),
          colorIndex: resultSet.getLong(resultSet.getColumnIndex('color_index'))
        });
      } while (resultSet.goToNextRow());
    }
    resultSet.close();
    return list;
  }

  async getPlainByGroupBills(billIds: number[]): Promise<BillSplit[]> {
    if (billIds.length === 0) {
      return [];
    }
    const store = await this.helper.getStore();
    const placeholders = billIds.map(() => '?').join(',');
    const sql = `SELECT id, bill_id, member_id, amount FROM bill_splits WHERE bill_id IN (${placeholders})`;
    const resultSet = await store.querySql(sql, billIds.map((id) => id.toString()));
    const list: BillSplit[] = [];
    if (resultSet.goToFirstRow()) {
      do {
        list.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          billId: resultSet.getLong(resultSet.getColumnIndex('bill_id')),
          memberId: resultSet.getLong(resultSet.getColumnIndex('member_id')),
          amount: resultSet.getLong(resultSet.getColumnIndex('amount'))
        });
      } while (resultSet.goToNextRow());
    }
    resultSet.close();
    return list;
  }
}
