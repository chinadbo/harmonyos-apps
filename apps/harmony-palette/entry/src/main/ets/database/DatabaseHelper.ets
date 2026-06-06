import relationalStore from '@ohos.data.relationalStore';
import { ColorModel } from '../model/ColorModel';
import { ColorConverter } from '../utils/ColorConverter';

export class DatabaseHelper {
  private static store: relationalStore.RdbStore | null = null;
  private static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'HarmonyPalette.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };
  private static readonly TABLE_SQL: string = 'CREATE TABLE IF NOT EXISTS favorites (' +
    'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
    'name TEXT, ' +
    'argb INTEGER NOT NULL, ' +
    'hex TEXT NOT NULL, ' +
    'red INTEGER NOT NULL, ' +
    'green INTEGER NOT NULL, ' +
    'blue INTEGER NOT NULL, ' +
    'alpha INTEGER NOT NULL, ' +
    'hue REAL NOT NULL, ' +
    'saturation REAL NOT NULL, ' +
    'value REAL NOT NULL, ' +
    'createdAt INTEGER NOT NULL' +
    ')';

  static init(context: Context): Promise<void> {
    if (this.store !== null) {
      return Promise.resolve();
    }
    return new Promise((resolve, reject) => {
      relationalStore.getRdbStore(context, this.STORE_CONFIG, (error: BusinessError, store: relationalStore.RdbStore) => {
        if (error) {
          reject(error);
          return;
        }
        store.executeSql(this.TABLE_SQL, [], (tableError?: BusinessError) => {
          if (tableError) {
            reject(tableError);
            return;
          }
          this.store = store;
          resolve();
        });
      });
    });
  }

  static getStore(): relationalStore.RdbStore {
    if (this.store === null) {
      throw new Error('DatabaseHelper.init must be called before database access.');
    }
    return this.store;
  }

  static saveFavorite(color: ColorModel): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      name: color.name,
      argb: color.argb,
      hex: color.hex,
      red: color.red,
      green: color.green,
      blue: color.blue,
      alpha: color.alpha,
      hue: color.hue,
      saturation: color.saturation,
      value: color.value,
      createdAt: Date.now()
    };
    return new Promise((resolve, reject) => {
      this.getStore().insert('favorites', values, (error: BusinessError, rowId: number) => {
        if (error) {
          reject(error);
          return;
        }
        resolve(rowId);
      });
    });
  }

  static listFavorites(): Promise<Array<ColorModel>> {
    return new Promise((resolve, reject) => {
      this.getStore().querySql('SELECT * FROM favorites ORDER BY createdAt DESC', [], (error: BusinessError, resultSet: relationalStore.ResultSet) => {
        if (error) {
          reject(error);
          return;
        }
        const colors: Array<ColorModel> = [];
        try {
          while (resultSet.goToNextRow()) {
            const color: ColorModel = ColorConverter.fromRgba(
              resultSet.getLong(resultSet.getColumnIndex('red')),
              resultSet.getLong(resultSet.getColumnIndex('green')),
              resultSet.getLong(resultSet.getColumnIndex('blue')),
              resultSet.getLong(resultSet.getColumnIndex('alpha')),
              resultSet.getString(resultSet.getColumnIndex('name'))
            );
            color.id = resultSet.getLong(resultSet.getColumnIndex('id'));
            color.createdAt = resultSet.getLong(resultSet.getColumnIndex('createdAt'));
            colors.push(color);
          }
          resultSet.close();
          resolve(colors);
        } catch (readError) {
          resultSet.close();
          reject(readError);
        }
      });
    });
  }

  static deleteFavorite(id: number): Promise<void> {
    return new Promise((resolve, reject) => {
      const predicates = new relationalStore.RdbPredicates('favorites');
      predicates.equalTo('id', id);
      this.getStore().delete(predicates, (error: BusinessError) => {
        if (error) {
          reject(error);
          return;
        }
        resolve();
      });
    });
  }

  static existsByHex(hex: string): Promise<boolean> {
    return new Promise((resolve, reject) => {
      this.getStore().querySql('SELECT COUNT(1) AS total FROM favorites WHERE hex = ?', [hex], (error: BusinessError, resultSet: relationalStore.ResultSet) => {
        if (error) {
          reject(error);
          return;
        }
        let exists: boolean = false;
        try {
          if (resultSet.goToFirstRow()) {
            exists = resultSet.getLong(resultSet.getColumnIndex('total')) > 0;
          }
          resultSet.close();
          resolve(exists);
        } catch (readError) {
          resultSet.close();
          reject(readError);
        }
      });
    });
  }
}

interface BusinessError {
  code: number;
  message: string;
}

type Context = Record<string, object>;
