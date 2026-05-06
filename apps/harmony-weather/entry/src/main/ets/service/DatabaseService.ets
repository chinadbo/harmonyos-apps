import common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';
import { CityModel } from '../model/CityModel';

class DatabaseService {
  private store?: relationalStore.RdbStore;
  private readonly config: relationalStore.StoreConfig = {
    name: 'harmonyweather.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.store) {
      return;
    }

    this.store = await relationalStore.getRdbStore(context, this.config);
    await this.store.executeSql(
      'CREATE TABLE IF NOT EXISTS cities(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, region TEXT, country TEXT, latitude REAL, longitude REAL, isCurrentLocation INTEGER)'
    );
  }

  async queryCities(): Promise<Array<CityModel>> {
    if (!this.store) {
      return [];
    }

    const resultSet = await this.store.querySql('SELECT * FROM cities ORDER BY isCurrentLocation DESC, id DESC');
    const cities: Array<CityModel> = [];
    if (resultSet.goToFirstRow()) {
      do {
        const city = new CityModel();
        city.id = resultSet.getLong(0);
        city.name = resultSet.getString(1);
        city.region = resultSet.getString(2);
        city.country = resultSet.getString(3);
        city.latitude = resultSet.getDouble(4);
        city.longitude = resultSet.getDouble(5);
        city.isCurrentLocation = resultSet.getLong(6) === 1;
        cities.push(city);
      } while (resultSet.goToNextRow());
    }
    resultSet.close();
    return cities;
  }

  async saveCity(city: CityModel): Promise<void> {
    if (!this.store) {
      return;
    }

    const values: relationalStore.ValuesBucket = {
      name: city.name,
      region: city.region,
      country: city.country,
      latitude: city.latitude,
      longitude: city.longitude,
      isCurrentLocation: city.isCurrentLocation ? 1 : 0
    };
    await this.store.insert('cities', values);
  }

  async removeCity(id: number): Promise<void> {
    if (!this.store) {
      return;
    }
    const predicates = new relationalStore.RdbPredicates('cities');
    predicates.equalTo('id', id);
    await this.store.delete(predicates);
  }
}

export default new DatabaseService();
