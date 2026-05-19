import common from '@ohos.app.ability.common';
import http from '@ohos.net.http';
import { PreferencesHelper } from '../data/PreferencesHelper';

export interface ExchangeRatesPayload {
  base: string;
  timestamp: number;
  source: string;
  rates: Record<string, number>;
}

export class ExchangeRateService {
  private static readonly ENDPOINT: string = 'https://api.exchangerate-api.com/v4/latest/CNY';
  private static readonly CACHE_KEY: string = 'exchange_rates_payload';
  private static readonly CACHE_TTL: number = 24 * 60 * 60 * 1000;
  private static readonly SUPPORTED: Array<string> = ['CNY', 'USD', 'EUR', 'JPY', 'GBP', 'KRW', 'HKD', 'SGD', 'AUD'];

  static getSupportedCurrencies(): Array<string> {
    return this.SUPPORTED.slice();
  }

  static async getRates(context: common.UIAbilityContext, forceRefresh: boolean = false): Promise<ExchangeRatesPayload> {
    const cached: ExchangeRatesPayload = await PreferencesHelper.getJson<ExchangeRatesPayload>(context, this.CACHE_KEY, {
      base: 'CNY',
      timestamp: 0,
      source: 'none',
      rates: { 'CNY': 1 }
    });

    if (!forceRefresh && this.isUsable(cached) && Date.now() - cached.timestamp < this.CACHE_TTL) {
      return cached;
    }

    try {
      const remote: ExchangeRatesPayload = await this.fetchRemoteRates();
      await PreferencesHelper.putJson(context, this.CACHE_KEY, remote);
      return remote;
    } catch (error) {
      if (this.isUsable(cached)) {
        return {
          base: cached.base,
          timestamp: cached.timestamp,
          source: 'cache',
          rates: cached.rates
        };
      }
      const fallback: ExchangeRatesPayload = await this.readFallback(context);
      await PreferencesHelper.putJson(context, this.CACHE_KEY, fallback);
      return fallback;
    }
  }

  private static async fetchRemoteRates(): Promise<ExchangeRatesPayload> {
    const client: http.HttpRequest = http.createHttp();
    try {
      const response: http.HttpResponse = await client.request(this.ENDPOINT, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 10000,
        readTimeout: 10000,
        header: {
          'Accept': 'application/json'
        }
      });
      const body: Record<string, Object> = JSON.parse(String(response.result));
      const rates: Record<string, number> = this.pickSupported(body.rates as Record<string, number>);
      return {
        base: 'CNY',
        timestamp: Date.now(),
        source: 'network',
        rates: rates
      };
    } finally {
      client.destroy();
    }
  }

  private static async readFallback(context: common.UIAbilityContext): Promise<ExchangeRatesPayload> {
    const rawData: Uint8Array = await context.resourceManager.getRawFileContent('fallback_rates.json');
    const text: string = this.decode(rawData);
    const payload: ExchangeRatesPayload = JSON.parse(text) as ExchangeRatesPayload;
    return {
      base: 'CNY',
      timestamp: payload.timestamp || Date.now(),
      source: 'fallback',
      rates: this.pickSupported(payload.rates)
    };
  }

  private static pickSupported(source: Record<string, number>): Record<string, number> {
    const result: Record<string, number> = { 'CNY': 1 };
    for (let i: number = 0; i < this.SUPPORTED.length; i += 1) {
      const currency: string = this.SUPPORTED[i];
      if (currency === 'CNY') {
        result[currency] = 1;
        continue;
      }
      const value: number = Number(source[currency]);
      if (!isFinite(value) || value <= 0) {
        throw new Error('汇率数据缺失');
      }
      result[currency] = value;
    }
    return result;
  }

  private static decode(bytes: Uint8Array): string {
    let text: string = '';
    for (let i: number = 0; i < bytes.length; i += 1) {
      text += String.fromCharCode(bytes[i]);
    }
    return text;
  }

  private static isUsable(payload: ExchangeRatesPayload): boolean {
    if (!payload || !payload.rates) {
      return false;
    }
    for (let i: number = 0; i < this.SUPPORTED.length; i += 1) {
      if (!payload.rates[this.SUPPORTED[i]]) {
        return false;
      }
    }
    return true;
  }
}
