/**
 * Logger.ets — 统一 hilog 封装
 */
import hilog from '@ohos.hilog';

const DOMAIN: number = 0x0100;
const APP_TAG: string = 'Collect';

export class Logger {
  static debug(tag: string, msg: string): void {
    hilog.debug(DOMAIN, APP_TAG, '[%{public}s] %{public}s', tag, msg);
  }

  static info(tag: string, msg: string): void {
    hilog.info(DOMAIN, APP_TAG, '[%{public}s] %{public}s', tag, msg);
  }

  static warn(tag: string, msg: string): void {
    hilog.warn(DOMAIN, APP_TAG, '[%{public}s] %{public}s', tag, msg);
  }

  static error(tag: string, msg: string): void {
    hilog.error(DOMAIN, APP_TAG, '[%{public}s] %{public}s', tag, msg);
  }

  static errorOf(tag: string, err: Error): void {
    hilog.error(DOMAIN, APP_TAG, '[%{public}s] %{public}s', tag, err.message);
  }
}
