import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

let context: common.UIAbilityContext | null = null;
let store: preferences.Preferences | null = null;

export async function initPreferences(ctx: common.UIAbilityContext): Promise<void> {
  context = ctx;
  store = await preferences.getPreferences(ctx, 'harmonysky');
}

export function getStore(): preferences.Preferences {
  if (store === null && context !== null) {
    store = preferences.getPreferencesSync(context, { name: 'harmonysky' });
  }
  return store as preferences.Preferences;
}

export function putString(key: string, value: string): void {
  getStore().putSync(key, value);
  getStore().flush();
}

export function getString(key: string, def: string): string {
  return getStore().getSync(key, def) as string;
}

export function putNumber(key: string, value: number): void {
  getStore().putSync(key, value);
  getStore().flush();
}

export function getNumber(key: string, def: number): number {
  return getStore().getSync(key, def) as number;
}

export function putBoolean(key: string, value: boolean): void {
  getStore().putSync(key, value);
  getStore().flush();
}

export function getBoolean(key: string, def: boolean): boolean {
  return getStore().getSync(key, def) as boolean;
}
