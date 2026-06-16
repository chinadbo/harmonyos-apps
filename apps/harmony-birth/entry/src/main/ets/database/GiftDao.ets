import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { Gift, GiftRecord, GiftStatus } from '../model/Gift';
import { DatabaseHelper } from './DatabaseHelper';

export class GiftDao {
  static async getByContactId(context: common.Context, contactId: number): Promise<Gift[]> {
    let store = await DatabaseHelper.getRdbStore(context);
    let predicates = new relationalStore.RdbPredicates('gifts');
    predicates.equalTo('contact_id', contactId);
    predicates.orderByDesc('created_at');
    let resultSet = await store.query(predicates, ['id', 'contact_id', 'name', 'price', 'url', 'note', 'status', 'created_at']);
    let result = this.mapGifts(resultSet);
    resultSet.close();
    return result;
  }

  static async insert(context: common.Context, gift: Gift): Promise<number> {
    let store = await DatabaseHelper.getRdbStore(context);
    let bucket: relationalStore.ValuesBucket = {
      contact_id: gift.contactId,
      name: gift.name,
      price: gift.price,
      url: gift.url,
      note: gift.note,
      status: gift.status,
      created_at: gift.createdAt ?? Date.now()
    };
    return Number(await store.insert('gifts', bucket));
  }

  static async update(context: common.Context, gift: Gift): Promise<void> {
    if (!gift.id) {
      return;
    }
    let store = await DatabaseHelper.getRdbStore(context);
    let bucket: relationalStore.ValuesBucket = {
      name: gift.name,
      price: gift.price,
      url: gift.url,
      note: gift.note,
      status: gift.status
    };
    let predicates = new relationalStore.RdbPredicates('gifts');
    predicates.equalTo('id', gift.id);
    await store.update(bucket, predicates);
  }

  static async updateStatus(context: common.Context, id: number, status: GiftStatus): Promise<void> {
    let store = await DatabaseHelper.getRdbStore(context);
    let predicates = new relationalStore.RdbPredicates('gifts');
    predicates.equalTo('id', id);
    await store.update({ status }, predicates);
  }

  static async remove(context: common.Context, id: number): Promise<void> {
    let store = await DatabaseHelper.getRdbStore(context);
    let predicates = new relationalStore.RdbPredicates('gifts');
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  static async removeByContactId(context: common.Context, contactId: number): Promise<void> {
    let store = await DatabaseHelper.getRdbStore(context);
    let predicates = new relationalStore.RdbPredicates('gifts');
    predicates.equalTo('contact_id', contactId);
    await store.delete(predicates);
  }

  private static mapGifts(resultSet: relationalStore.ResultSet): Gift[] {
    let gifts: Gift[] = [];
    if (resultSet.rowCount <= 0) {
      return gifts;
    }
    let idIndex = resultSet.getColumnIndex('id');
    let contactIdIndex = resultSet.getColumnIndex('contact_id');
    let nameIndex = resultSet.getColumnIndex('name');
    let priceIndex = resultSet.getColumnIndex('price');
    let urlIndex = resultSet.getColumnIndex('url');
    let noteIndex = resultSet.getColumnIndex('note');
    let statusIndex = resultSet.getColumnIndex('status');
    let createdAtIndex = resultSet.getColumnIndex('created_at');
    resultSet.goToFirstRow();
    for (let row = 0; row < resultSet.rowCount; row++) {
      if (row > 0) {
        resultSet.goToNextRow();
      }
      gifts.push(new GiftRecord({
        id: resultSet.getLong(idIndex),
        contactId: resultSet.getLong(contactIdIndex),
        name: resultSet.getString(nameIndex),
        price: resultSet.getDouble(priceIndex),
        url: resultSet.getString(urlIndex),
        note: resultSet.getString(noteIndex),
        status: resultSet.getString(statusIndex) as GiftStatus,
        createdAt: resultSet.getLong(createdAtIndex)
      }));
    }
    return gifts;
  }
}
