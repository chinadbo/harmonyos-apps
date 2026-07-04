import dataPreferences from '@ohos.data.preferences';
import { TorchMode, TorchSettings, DEFAULT_SETTINGS } from '../models/TorchMode';

const PREFERENCES_NAME = 'torch_settings';
const KEY_VIBRATION = 'vibration_enabled';
const KEY_KEEP_SCREEN_ON = 'keep_screen_on';
const KEY_DEFAULT_MODE = 'default_mode';
const KEY_STROBE_FREQ = 'strobe_frequency';
const KEY_SCREEN_BRIGHTNESS = 'screen_brightness';

export default class PreferenceUtil {
  private static preference: dataPreferences.Preferences | null = null;

  static async init(): Promise<void> {
    if (!PreferenceUtil.preference) {
      try {
        PreferenceUtil.preference = await dataPreferences.getPreferences(getContext(), PREFERENCES_NAME);
      } catch (err) {
        console.error('Failed to get preferences: ' + JSON.stringify(err));
      }
    }
  }

  static async saveSettings(settings: TorchSettings): Promise<void> {
    await PreferenceUtil.init();
    if (!PreferenceUtil.preference) return;
    try {
      await PreferenceUtil.preference.put(KEY_VIBRATION, settings.vibrationEnabled);
      await PreferenceUtil.preference.put(KEY_KEEP_SCREEN_ON, settings.keepScreenOn);
      await PreferenceUtil.preference.put(KEY_DEFAULT_MODE, settings.defaultMode);
      await PreferenceUtil.preference.put(KEY_STROBE_FREQ, settings.strobeFrequency);
      await PreferenceUtil.preference.put(KEY_SCREEN_BRIGHTNESS, settings.screenBrightness);
      await PreferenceUtil.preference.flush();
    } catch (err) {
      console.error('Failed to save settings: ' + JSON.stringify(err));
    }
  }

  static async loadSettings(): Promise<TorchSettings> {
    await PreferenceUtil.init();
    if (!PreferenceUtil.preference) {
      return { ...DEFAULT_SETTINGS };
    }
    try {
      const vibration = await PreferenceUtil.preference.get(KEY_VIBRATION, DEFAULT_SETTINGS.vibrationEnabled);
      const keepScreenOn = await PreferenceUtil.preference.get(KEY_KEEP_SCREEN_ON, DEFAULT_SETTINGS.keepScreenOn);
      const defaultMode = await PreferenceUtil.preference.get(KEY_DEFAULT_MODE, DEFAULT_SETTINGS.defaultMode) as string;
      const strobeFreq = await PreferenceUtil.preference.get(KEY_STROBE_FREQ, DEFAULT_SETTINGS.strobeFrequency);
      const brightness = await PreferenceUtil.preference.get(KEY_SCREEN_BRIGHTNESS, DEFAULT_SETTINGS.screenBrightness);

      return {
        vibrationEnabled: vibration as boolean,
        keepScreenOn: keepScreenOn as boolean,
        defaultMode: defaultMode as TorchMode,
        strobeFrequency: strobeFreq as number,
        screenBrightness: brightness as number
      };
    } catch (err) {
      console.error('Failed to load settings: ' + JSON.stringify(err));
      return { ...DEFAULT_SETTINGS };
    }
  }

  static async clear(): Promise<void> {
    await PreferenceUtil.init();
    if (!PreferenceUtil.preference) return;
    try {
      await PreferenceUtil.preference.clear();
    } catch (err) {
      console.error('Failed to clear preferences: ' + JSON.stringify(err));
    }
  }
}
