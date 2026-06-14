import relationalStore from '@ohos.data.relationalStore';
import { DatabaseHelper } from './DatabaseHelper';
import { Bill, BillWithPayer } from '../model/Bill';

export class BillDao {
  private helper: DatabaseHelper = DatabaseHelper.getInstance();

  async create(bill: Bill): Promise<number> {
    const store = await this.helper.getStore();
    const values: relationalStore.ValuesBucket = {
      group_id: bill.groupId,
      title: bill.title,
      amount: bill.amount,
      payer_id: bill.payerId,
      category: bill.category,
      split_type: bill.splitType,
      created_at: bill.createdAt,
      note: bill.note
    };
    return await store.insert('bills', values);
  }

  async deleteById(billId: number): Promise<void> {
    const store = await this.helper.getStore();
    const predicates = new relationalStore.RdbPredicates('bills');
    predicates.equalTo('id', billId);
    await store.delete(predicates);
  }

  async getById(billId: number): Promise<Bill | null> {
    const store = await this.helper.getStore();
    const predicates = new relationalStore.RdbPredicates('bills');
    predicates.equalTo('id', billId);
    const resultSet = await store.query(predicates, ['id', 'group_id', 'title', 'amount', 'payer_id', 'category', 'split_type', 'created_at', 'note']);
    const list = this.readBills(resultSet);
    resultSet.close();
    return list.length > 0 ? list[0] : null;
  }

  async getByGroupId(groupId: number): Promise<BillWithPayer[]> {
    const store = await this.helper.getStore();
    const sql = `SELECT b.id, b.group_id, b.title, b.amount, b.payer_id, b.category, b.split_type, b.created_at, b.note, m.name AS payer_name
      FROM bills b
      LEFT JOIN members m ON b.payer_id = m.id
      WHERE b.group_id = ?
      ORDER BY b.created_at DESC, b.id DESC`;
    const resultSet = await store.querySql(sql, [groupId.toString()]);
    const list: BillWithPayer[] = [];
    if (resultSet.goToFirstRow()) {
      do {
        list.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          groupId: resultSet.getLong(resultSet.getColumnIndex('group_id')),
          title: resultSet.getString(resultSet.getColumnIndex('title')),
          amount: resultSet.getLong(resultSet.getColumnIndex('amount')),
          payerId: resultSet.getLong(resultSet.getColumnIndex('payer_id')),
          category: resultSet.getString(resultSet.getColumnIndex('category')),
          splitType: resultSet.getString(resultSet.getColumnIndex('split_type')),
          createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at')),
          note: resultSet.getString(resultSet.getColumnIndex('note')),
          payerName: resultSet.getString(resultSet.getColumnIndex('payer_name'))
        });
      } while (resultSet.goToNextRow());
    }
    resultSet.close();
    return list;
  }

  async getPlainByGroupId(groupId: number): Promise<Bill[]> {
    const store = await this.helper.getStore();
    const predicates = new relationalStore.RdbPredicates('bills');
    predicates.equalTo('group_id', groupId);
    const resultSet = await store.query(predicates, ['id', 'group_id', 'title', 'amount', 'payer_id', 'category', 'split_type', 'created_at', 'note']);
    const list = this.readBills(resultSet);
    resultSet.close();
    return list;
  }

  private readBills(resultSet: relationalStore.ResultSet): Bill[] {
    const bills: Bill[] = [];
    if (resultSet.goToFirstRow()) {
      do {
        bills.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          groupId: resultSet.getLong(resultSet.getColumnIndex('group_id')),
          title: resultSet.getString(resultSet.getColumnIndex('title')),
          amount: resultSet.getLong(resultSet.getColumnIndex('amount')),
          payerId: resultSet.getLong(resultSet.getColumnIndex('payer_id')),
          category: resultSet.getString(resultSet.getColumnIndex('category')),
          splitType: resultSet.getString(resultSet.getColumnIndex('split_type')),
          createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at')),
          note: resultSet.getString(resultSet.getColumnIndex('note'))
        });
      } while (resultSet.goToNextRow());
    }
    return bills;
  }
}
