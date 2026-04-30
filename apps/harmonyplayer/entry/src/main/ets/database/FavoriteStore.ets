import relationalStore from '@ohos.data.relationalStore';
import { DBHelper } from './DBHelper';

export class FavoriteStore {
  async addFavorite(songUri: string): Promise<void> {
    const values: relationalStore.ValuesBucket = {
      song_uri: songUri,
      added_at: Date.now()
    };
    await DBHelper.getInstance().getRdb().insert('favorites', values);
  }

  async removeFavorite(songUri: string): Promise<void> {
    const predicates = new relationalStore.RdbPredicates('favorites');
    predicates.equalTo('song_uri', songUri);
    await DBHelper.getInstance().getRdb().delete(predicates);
  }

  async isFavorite(songUri: string): Promise<boolean> {
    const predicates = new relationalStore.RdbPredicates('favorites');
    predicates.equalTo('song_uri', songUri);
    const resultSet = await DBHelper.getInstance().getRdb().query(predicates, ['song_uri']);
    const count: number = resultSet.rowCount;
    resultSet.close();
    return count > 0;
  }

  async getAllFavorites(): Promise<string[]> {
    const predicates = new relationalStore.RdbPredicates('favorites');
    predicates.orderByDesc('added_at');
    const resultSet = await DBHelper.getInstance().getRdb().query(predicates, ['song_uri']);
    const result: string[] = [];
    while (resultSet.goToNextRow()) {
      result.push(resultSet.getString(resultSet.getColumnIndex('song_uri')));
    }
    resultSet.close();
    return result;
  }
}
