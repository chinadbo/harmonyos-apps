import http from '@ohos.net.http';
import { DailyWeather, HourlyWeather, WeatherCondition, WeatherModel } from '../model/WeatherModel';

class WeatherService {
  async fetchWeather(city: string): Promise<WeatherModel> {
    const httpRequest = http.createHttp();
    const encodedCity: string = encodeURIComponent(city.trim());
    const url: string = `https://wttr.in/${encodedCity}?format=j2`;

    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.STRING,
        readTimeout: 10000,
        connectTimeout: 10000,
        header: {
          'Accept': 'application/json'
        }
      });

      const raw = typeof response.result === 'string' ? response.result : JSON.stringify(response.result);
      const json = JSON.parse(raw);
      return this.parseWeather(city, json);
    } finally {
      httpRequest.destroy();
    }
  }

  private parseWeather(city: string, json: Record<string, Object>): WeatherModel {
    const model = new WeatherModel();
    model.city = city;
    model.updatedAt = this.formatUpdateTime();

    const nearest = Array.isArray(json['nearest_area']) ? json['nearest_area'][0] as Record<string, Object> : undefined;
    const areaName = nearest && Array.isArray(nearest['areaName']) ? nearest['areaName'][0] as Record<string, string> : undefined;
    const region = nearest && Array.isArray(nearest['region']) ? nearest['region'][0] as Record<string, string> : undefined;
    const country = nearest && Array.isArray(nearest['country']) ? nearest['country'][0] as Record<string, string> : undefined;

    model.city = areaName?.['value'] ?? city;
    model.region = region?.['value'] ?? '';
    model.country = country?.['value'] ?? '';
    model.current = this.parseCurrentCondition(json['current_condition']);
    model.daily = this.parseDaily(json['weather']);
    return model;
  }

  private parseCurrentCondition(source: Object | undefined): WeatherCondition {
    const current = new WeatherCondition();
    const item = Array.isArray(source) ? source[0] as Record<string, string | Array<Record<string, string>>> : undefined;
    if (!item) {
      return current;
    }

    current.tempC = item['temp_C'] as string ?? '--';
    current.feelsLikeC = item['FeelsLikeC'] as string ?? '--';
    current.humidity = item['humidity'] as string ?? '--';
    current.windspeedKmph = item['windspeedKmph'] as string ?? '--';
    current.winddir16Point = item['winddir16Point'] as string ?? '--';
    current.visibility = item['visibility'] as string ?? '--';
    current.uvIndex = item['uvIndex'] as string ?? '--';
    current.weatherCode = item['weatherCode'] as string ?? '113';

    const descArray = item['weatherDesc'] as Array<Record<string, string>>;
    current.description = Array.isArray(descArray) && descArray.length > 0 ? descArray[0]['value'] ?? 'Unknown' : 'Unknown';
    return current;
  }

  private parseDaily(source: Object | undefined): Array<DailyWeather> {
    if (!Array.isArray(source)) {
      return [];
    }

    return source.map((item: Object) => {
      const record = item as Record<string, string | Array<Object>>;
      const daily = new DailyWeather();
      daily.date = record['date'] as string ?? '';
      daily.maxtempC = record['maxtempC'] as string ?? '--';
      daily.mintempC = record['mintempC'] as string ?? '--';
      daily.uvIndex = record['uvIndex'] as string ?? '--';
      daily.hourly = this.parseHourly(record['hourly']);
      return daily;
    });
  }

  private parseHourly(source: Object | undefined): Array<HourlyWeather> {
    if (!Array.isArray(source)) {
      return [];
    }

    return source.map((item: Object) => {
      const record = item as Record<string, string | Array<Record<string, string>>>;
      const hourly = new HourlyWeather();
      hourly.time = record['time'] as string ?? '0';
      hourly.tempC = record['tempC'] as string ?? '--';
      hourly.weatherCode = record['weatherCode'] as string ?? '113';
      hourly.humidity = record['humidity'] as string ?? '--';
      hourly.chanceofrain = record['chanceofrain'] as string ?? '0';
      const descArray = record['weatherDesc'] as Array<Record<string, string>>;
      hourly.description = Array.isArray(descArray) && descArray.length > 0 ? descArray[0]['value'] ?? 'Unknown' : 'Unknown';
      return hourly;
    });
  }

  private formatUpdateTime(): string {
    const date = new Date();
    const hour = `${date.getHours()}`.padStart(2, '0');
    const minute = `${date.getMinutes()}`.padStart(2, '0');
    return `${hour}:${minute}`;
  }
}

export default new WeatherService();
