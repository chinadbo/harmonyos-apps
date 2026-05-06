import common from '@ohos.app.ability.common';
import router from '@ohos.router';
import { CityModel } from '../model/CityModel';
import { DailyWeather, HourlyWeather, WeatherModel } from '../model/WeatherModel';
import DatabaseService from '../service/DatabaseService';
import LocationService from '../service/LocationService';
import WeatherService from '../service/WeatherService';

class WeatherViewModel {
  weather: WeatherModel = new WeatherModel();
  cities: Array<CityModel> = [];
  selectedCity: string = 'Beijing';
  loading: boolean = false;
  loadingText: string = 'Loading weather...';
  errorMessage: string = '';

  async init(context: common.UIAbilityContext): Promise<void> {
    await DatabaseService.init(context);
    const cities = await DatabaseService.queryCities();
    if (cities.length === 0) {
      const currentCity = await LocationService.getCurrentCity();
      await DatabaseService.saveCity(currentCity);
      this.cities = [currentCity];
      this.selectedCity = currentCity.name;
    } else {
      this.cities = cities;
      this.selectedCity = cities[0].name;
    }

    await this.refreshWeather(this.selectedCity);
  }

  async refreshWeather(city: string): Promise<void> {
    this.loading = true;
    this.loadingText = `Refreshing ${city}...`;
    this.errorMessage = '';
    try {
      this.weather = await WeatherService.fetchWeather(city);
      this.selectedCity = this.weather.city;
    } catch (error) {
      this.errorMessage = 'Unable to fetch weather data.';
    } finally {
      this.loading = false;
    }
  }

  async addCity(keyword: string): Promise<void> {
    const cityName = keyword.trim();
    if (!cityName) {
      return;
    }

    const city = new CityModel();
    city.id = Date.now();
    city.name = cityName;
    city.region = 'Manual';
    city.country = '';
    city.latitude = 0;
    city.longitude = 0;
    city.isCurrentLocation = false;
    await DatabaseService.saveCity(city);
    this.cities = await DatabaseService.queryCities();
    await this.refreshWeather(cityName);
  }

  async deleteCity(city: CityModel): Promise<void> {
    await DatabaseService.removeCity(city.id);
    this.cities = await DatabaseService.queryCities();
    if (this.cities.length > 0) {
      await this.refreshWeather(this.cities[0].name);
    }
  }

  openForecast(): void {
    router.pushUrl({
      url: 'pages/ForecastPage',
      params: {
        weather: JSON.stringify(this.weather)
      }
    });
  }

  openCityList(): void {
    router.pushUrl({
      url: 'pages/CityListPage'
    });
  }

  currentHourly(): Array<HourlyWeather> {
    return this.weather.daily.length > 0 ? this.weather.daily[0].hourly : [];
  }

  forecastList(): Array<DailyWeather> {
    return this.weather.daily;
  }
}

export default new WeatherViewModel();
