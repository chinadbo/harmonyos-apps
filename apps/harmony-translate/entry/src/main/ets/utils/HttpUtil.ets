import { http } from '@ohos.net.http';

export class HttpUtil {
  static request(url: string): Promise<string> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();
      httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: { 'Content-Type': 'application/json' },
        readTimeout: 10000,
        connectTimeout: 10000
      }, (err, data) => {
        if (!err && data.responseCode === 200) {
          resolve(data.result.toString());
        } else {
          reject(err ? err.message : `HTTP ${data.responseCode}`);
        }
      });
    });
  }
}
