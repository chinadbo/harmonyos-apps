import { AppStorageKeyName, createStorage, getOrCreateStorage } from '@ohos.appstorage';

/**
 * 主题管理器（暗色/浅色切换）
 */
export class ThemeManager {
  private static THEME_KEY: AppStorageKeyName = 'app_theme';
  private static storage = getOrCreateStorage<{ theme: 'light' | 'dark' }>(createStorage({ theme: 'light' }));

  /**
   * 获取当前主题
   */
  static get current(): 'light' | 'dark' {
    return this.storage.get(this.THEME_KEY) ?? 'light';
  }

  /**
   * 设置主题
   */
  static setTheme(theme: 'light' | 'dark'): void {
    this.storage.set(this.THEME_KEY, theme);
  }

  /**
   * 切换主题
   */
  static toggle(): void {
    this.setTheme(this.current === 'light' ? 'dark' : 'light');
  }

  /**
   * 获取主题颜色
   */
  static get colors(): Record<string, string> {
    if (this.current === 'dark') {
      return {
        background: '#1A1A1A',
        surface: '#2D2D2D',
        primary: '#5B8FF9',
        text: '#FFFFFF',
        textSecondary: '#AAAAAA',
        border: '#333333',
        card: '#2D2D2D',
        accent: '#5AD8A6'
      };
    }
    return {
      background: '#FFFFFF',
      surface: '#F5F5F5',
      primary: '#5B8FF9',
      text: '#1A1A1A',
      textSecondary: '#666666',
      border: '#E8E8E8',
      card: '#FFFFFF',
      accent: '#5AD8A6'
    };
  }

  /**
   * 获取状态栏样式
   */
  static get statusBarStyle(): 'dark-content' | 'light-content' {
    return this.current === 'dark' ? 'light-content' : 'dark-content';
  }
}
