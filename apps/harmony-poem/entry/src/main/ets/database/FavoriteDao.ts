import common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';
import { DatabaseHelper } from './DatabaseHelper';
import { Favorite } from '../model/Favorite';

export class FavoriteDao {
  static async addFavorite(context: common.UIAbilityContext, poemId: number): Promise<void> {
    const store = await DatabaseHelper.getStore(context);
    const exists = await this.isFavorite(context, poemId);
    if (exists) {
      return;
    }
    const values: relationalStore.ValuesBucket = {
      poem_id: poemId,
      note: '',
      tag: '',
      created_at: Date.now()
    };
    await store.insert('favorites', values);
  }

  static async removeFavorite(context: common.UIAbilityContext, poemId: number): Promise<void> {
    const store = await DatabaseHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('favorites');
    predicates.equalTo('poem_id', poemId);
    await store.delete(predicates);
  }

  static async isFavorite(context: common.UIAbilityContext, poemId: number): Promise<boolean> {
    const store = await DatabaseHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('favorites');
    predicates.equalTo('poem_id', poemId);
    const resultSet = await store.query(predicates, ['id']);
    const hasData = resultSet.rowCount > 0;
    resultSet.close();
    return hasData;
  }

  static async getAllFavorites(context: common.UIAbilityContext): Promise<Favorite[]> {
    const store = await DatabaseHelper.getStore(context);
    const predicates = new relationalStore.RdbPredicates('favorites');
    predicates.orderByDesc('created_at');
    const resultSet = await store.query(predicates, ['id', 'poem_id', 'note', 'tag', 'created_at']);
    const favorites: Favorite[] = [];
    while (resultSet.goToNextRow()) {
      favorites.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        poemId: resultSet.getLong(resultSet.getColumnIndex('poem_id')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        tag: resultSet.getString(resultSet.getColumnIndex('tag')),
        createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at'))
      });
    }
    resultSet.close();
    return favorites;
  }
}
