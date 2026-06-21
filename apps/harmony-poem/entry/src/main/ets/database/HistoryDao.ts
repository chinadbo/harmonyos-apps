import common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';
import { DatabaseHelper } from './DatabaseHelper';

export class HistoryDao {
  static async recordView(context: common.UIAbilityContext, poemId: number): Promise<void> {
    const store = await DatabaseHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('reading_history');
    predicates.equalTo('poem_id', poemId);
    const resultSet = await store.query(predicates, ['id', 'view_count']);
    const now = Date.now();
    if (resultSet.goToFirstRow()) {
      const viewCount = resultSet.getLong(resultSet.getColumnIndex('view_count')) + 1;
      const updateBucket: relationalStore.ValuesBucket = {
        view_count: viewCount,
        last_viewed: now
      };
      resultSet.close();
      await store.update(updateBucket, predicates);
      return;
    }
    resultSet.close();
    const values: relationalStore.ValuesBucket = {
      poem_id: poemId,
      view_count: 1,
      last_viewed: now
    };
    await store.insert('reading_history', values);
  }
}
