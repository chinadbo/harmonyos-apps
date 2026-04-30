import relationalStore from '@ohos.data.relationalStore';
import { DBHelper } from './DBHelper';

export class HistoryStore {
  async addHistory(songUri: string): Promise<void> {
    const values: relationalStore.ValuesBucket = {
      song_uri: songUri,
      played_at: Date.now()
    };
    await DBHelper.getInstance().getRdb().insert('history', values);
  }

  async getRecentHistory(limit: number): Promise<string[]> {
    const predicates = new relationalStore.RdbPredicates('history');
    predicates.orderByDesc('played_at');
    predicates.limitAs(limit);
    const resultSet = await DBHelper.getInstance().getRdb().query(predicates, ['song_uri']);
    const result: string[] = [];
    while (resultSet.goToNextRow()) {
      result.push(resultSet.getString(resultSet.getColumnIndex('song_uri')));
    }
    resultSet.close();
    return result;
  }
}
