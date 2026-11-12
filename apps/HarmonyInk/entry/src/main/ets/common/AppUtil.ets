import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';
import vibrator from '@ohos.vibrator';
import promptAction from '@ohos.promptAction';
import hilog from '@ohos.hilog';
import { Constants } from './Constants';

const DOMAIN: number = 0x0000;
const TAG: string = 'HarmonyInk-util';

/** 用户可配置项（保存于 preferences） */
export interface AppSettings {
  animSpeed: number;
  brushWidth: number;
  vibrateEnabled: boolean;
}

export class SettingsUtil {
  static defaultSettings(): AppSettings {
    const settings: AppSettings = {
      animSpeed: Constants.ANIM_SPEED_DEFAULT,
      brushWidth: Constants.BRUSH_WIDTH_DEFAULT,
      vibrateEnabled: Constants.VIBRATE_DEFAULT
    };
    return settings;
  }

  static async load(context: common.UIAbilityContext): Promise<AppSettings> {
    const result: AppSettings = SettingsUtil.defaultSettings();
    try {
      const store: preferences.Preferences = await preferences.getPreferences(context, Constants.PREF_NAME);
      result.animSpeed = await store.get(Constants.KEY_ANIM_SPEED, Constants.ANIM_SPEED_DEFAULT) as number;
      result.brushWidth = await store.get(Constants.KEY_BRUSH_WIDTH, Constants.BRUSH_WIDTH_DEFAULT) as number;
      result.vibrateEnabled = await store.get(Constants.KEY_VIBRATE, Constants.VIBRATE_DEFAULT) as boolean;
    } catch (err) {
      hilog.warn(DOMAIN, TAG, 'load settings failed: %{public}s', JSON.stringify(err));
    }
    return result;
  }

  static async save(context: common.UIAbilityContext, settings: AppSettings): Promise<void> {
    try {
      const store: preferences.Preferences = await preferences.getPreferences(context, Constants.PREF_NAME);
      await store.put(Constants.KEY_ANIM_SPEED, settings.animSpeed);
      await store.put(Constants.KEY_BRUSH_WIDTH, settings.brushWidth);
      await store.put(Constants.KEY_VIBRATE, settings.vibrateEnabled);
      await store.flush();
    } catch (err) {
      hilog.warn(DOMAIN, TAG, 'save settings failed: %{public}s', JSON.stringify(err));
    }
  }
}

export class HapticUtil {
  /** 一笔写对时的轻触反馈，错误静默降级 */
  static tick(enabled: boolean): void {
    if (!enabled) {
      return;
    }
    try {
      vibrator.startVibration(
        { type: 'time', duration: 28 },
        { id: 0, usage: 'touch' }
      ).catch((err: Error) => {
        hilog.debug(DOMAIN, TAG, 'vibrate skipped: %{public}s', err.message);
      });
    } catch (err) {
      hilog.debug(DOMAIN, TAG, 'vibrator unavailable');
    }
  }
}

export class ToastUtil {
  static show(message: string): void {
    try {
      promptAction.showToast({ message: message, duration: 1600 });
    } catch (err) {
      hilog.debug(DOMAIN, TAG, 'toast failed');
    }
  }
}

export class DateUtil {
  static pad2(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  static dateKey(date: Date): string {
    return `${date.getFullYear()}-${DateUtil.pad2(date.getMonth() + 1)}-${DateUtil.pad2(date.getDate())}`;
  }

  static todayKey(): string {
    return DateUtil.dateKey(new Date());
  }

  static dayKeyOffset(offsetDays: number): string {
    const d = new Date();
    d.setHours(12, 0, 0, 0);
    d.setDate(d.getDate() + offsetDays);
    return DateUtil.dateKey(d);
  }

  static dayOfMonth(key: string): number {
    const parts: string[] = key.split('-');
    return parts.length === 3 ? Number(parts[2]) : 0;
  }

  static formatDateTime(timestamp: number): string {
    const d = new Date(timestamp);
    return `${d.getMonth() + 1}月${d.getDate()}日 ${DateUtil.pad2(d.getHours())}:${DateUtil.pad2(d.getMinutes())}`;
  }

  static formatDate(timestamp: number): string {
    const d = new Date(timestamp);
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`;
  }

  static weekdayCN(date: Date): string {
    const names: string[] = ['日', '一', '二', '三', '四', '五', '六'];
    return `星期${names[date.getDay()]}`;
  }

  static greeting(): string {
    const hour = new Date().getHours();
    if (hour < 6) {
      return '夜深了，注意休息';
    }
    if (hour < 11) {
      return '早上好，提笔练字吧';
    }
    if (hour < 14) {
      return '中午好，来写几个字';
    }
    if (hour < 18) {
      return '下午好，静心临帖';
    }
    return '晚上好，温故知新';
  }
}
