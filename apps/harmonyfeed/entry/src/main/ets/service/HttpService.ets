import http from '@ohos.net.http';
import { Constants } from '../utils/Constants';

/**
 * HTTP 请求服务
 * 封装 @ohos.net.http，用于拉取 RSS Feed 内容
 */
export class HttpService {
  private static instance: HttpService;

  private constructor() {}

  static getInstance(): HttpService {
    if (!HttpService.instance) {
      HttpService.instance = new HttpService();
    }
    return HttpService.instance;
  }

  /**
   * GET 请求，返回响应文本
   * @param url 请求地址
   * @returns 响应文本
   */
  async get(url: string): Promise<string> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: Constants.HTTP_TIMEOUT,
        readTimeout: Constants.HTTP_TIMEOUT,
        header: {
          'User-Agent': 'HarmonyFeed/1.0 (HarmonyOS; Feed Reader)',
          'Accept': 'application/rss+xml, application/atom+xml, application/xml, text/xml, */*',
        },
      });

      if (response.responseCode !== 200) {
        throw new Error(`HTTP ${response.responseCode}`);
      }

      const result = String(response.result);
      // 防止超大响应体导致 OOM（限制 5MB）
      const MAX_SIZE = 5 * 1024 * 1024;
      if (result.length > MAX_SIZE) {
        throw new Error(`响应体过大（${Math.round(result.length / 1024)}KB，限制 5MB）`);
      }
      return result;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 检测 Feed URL 是否可访问，并返回内容
   */
  async fetchFeed(url: string): Promise<string> {
    try {
      return await this.get(url);
    } catch (err) {
      throw new Error(`获取 Feed 失败: ${(err as Error).message}`);
    }
  }
}
