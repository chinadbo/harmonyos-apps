import geoLocationManager from '@ohos.geoLocationManager';
import { CityModel } from '../model/CityModel';

class LocationService {
  async getCurrentCity(): Promise<CityModel> {
    const fallbackCity = this.createFallbackCity();
    const enabled = await geoLocationManager.isLocationEnabled();
    if (!enabled) {
      return fallbackCity;
    }

    try {
      const location = await geoLocationManager.getCurrentLocation();
      const latitude = Number((location as Record<string, Object>)['latitude']);
      const longitude = Number((location as Record<string, Object>)['longitude']);
      if (Number.isNaN(latitude) || Number.isNaN(longitude)) {
        return fallbackCity;
      }

      fallbackCity.name = this.coordinateLabel(latitude, longitude);
      fallbackCity.region = 'Current Location';
      fallbackCity.country = '';
      fallbackCity.latitude = latitude;
      fallbackCity.longitude = longitude;
      return fallbackCity;
    } catch (error) {
      return fallbackCity;
    }
  }

  private coordinateLabel(latitude: number, longitude: number): string {
    const lat = latitude.toFixed(2);
    const lon = longitude.toFixed(2);
    return `${lat},${lon}`;
  }

  private createFallbackCity(): CityModel {
    const city = new CityModel();
    city.id = Date.now();
    city.name = 'Beijing';
    city.region = 'Default';
    city.country = 'China';
    city.latitude = 39.90;
    city.longitude = 116.40;
    city.isCurrentLocation = true;
    return city;
  }
}

export default new LocationService();
