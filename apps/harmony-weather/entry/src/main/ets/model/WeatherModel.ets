export class WeatherCondition {
  tempC: string = '--';
  feelsLikeC: string = '--';
  humidity: string = '--';
  windspeedKmph: string = '--';
  winddir16Point: string = '--';
  visibility: string = '--';
  uvIndex: string = '--';
  description: string = 'Unknown';
  weatherCode: string = '113';
}

export class HourlyWeather {
  time: string = '0';
  tempC: string = '--';
  weatherCode: string = '113';
  description: string = 'Unknown';
  humidity: string = '--';
  chanceofrain: string = '0';
}

export class DailyWeather {
  date: string = '';
  maxtempC: string = '--';
  mintempC: string = '--';
  uvIndex: string = '--';
  hourly: Array<HourlyWeather> = [];
}

export class WeatherModel {
  city: string = '';
  region: string = '';
  country: string = '';
  current: WeatherCondition = new WeatherCondition();
  daily: Array<DailyWeather> = [];
  updatedAt: string = '';
}
