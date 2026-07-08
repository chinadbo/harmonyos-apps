import preferences from '@ohos.data.preferences';

interface AppSettings {
  thresholdDb: number;
  calibrationOffset: number;
  theme: string;
  alertEnabled: boolean;
  vibrationEnabled: boolean;
}

class SettingsRepository {
  private pref: preferences.Preferences | null = null;
  private readonly prefName: string = 'harmony_decibel_settings';

  async init(): Promise<void> {
    try {
      this.pref = await preferences.getPreferences(getContext(), this.prefName);
      console.info('Preferences initialized');
    } catch (err) {
      console.error('Failed to initialize preferences:', err);
    }
  }

  async getSettings(): Promise<AppSettings> {
    if (!this.pref) {
      return this.getDefaultSettings();
    }
    try {
      const threshold = await this.pref.get('thresholdDb', 85);
      const calibration = await this.pref.get('calibrationOffset', 0);
      const theme = await this.pref.get('theme', 'light');
      const alertEnabled = await this.pref.get('alertEnabled', true);
      const vibrationEnabled = await this.pref.get('vibrationEnabled', true);
      return {
        thresholdDb: typeof threshold === 'number' ? threshold : 85,
        calibrationOffset: typeof calibration === 'number' ? calibration : 0,
        theme: typeof theme === 'string' ? theme : 'light',
        alertEnabled: typeof alertEnabled === 'boolean' ? alertEnabled : true,
        vibrationEnabled: typeof vibrationEnabled === 'boolean' ? vibrationEnabled : true
      };
    } catch (err) {
      console.error('Failed to get settings:', err);
      return this.getDefaultSettings();
    }
  }

  async saveSettings(settings: AppSettings): Promise<void> {
    if (!this.pref) return;
    try {
      await this.pref.put('thresholdDb', settings.thresholdDb);
      await this.pref.put('calibrationOffset', settings.calibrationOffset);
      await this.pref.put('theme', settings.theme);
      await this.pref.put('alertEnabled', settings.alertEnabled);
      await this.pref.put('vibrationEnabled', settings.vibrationEnabled);
      await this.pref.flush();
      console.info('Settings saved');
    } catch (err) {
      console.error('Failed to save settings:', err);
    }
  }

  private getDefaultSettings(): AppSettings {
    return {
      thresholdDb: 85,
      calibrationOffset: 0,
      theme: 'light',
      alertEnabled: true,
      vibrationEnabled: true
    };
  }
}

export { AppSettings, SettingsRepository };
export default new SettingsRepository();
