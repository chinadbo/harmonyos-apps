import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

export const THEME_GOLD: number = 0;
export const THEME_BLUE: number = 1;

const PREFS_NAME: string = 'gacha_prefs';
const KEY_THEME: string = 'theme';

export class GachaColors {
  bg: string = '';
  card: string = '';
  cardDeep: string = '';
  primary: string = '';
  primaryDim: string = '';
  gold: string = '';
  purple: string = '';
  blue: string = '';
  textMain: string = '';
  textSub: string = '';
  border: string = '';
  danger: string = '';
  track: string = '';

  constructor(bg: string, card: string, cardDeep: string, primary: string, primaryDim: string,
    gold: string, purple: string, blue: string, textMain: string, textSub: string,
    border: string, danger: string, track: string) {
    this.bg = bg;
    this.card = card;
    this.cardDeep = cardDeep;
    this.primary = primary;
    this.primaryDim = primaryDim;
    this.gold = gold;
    this.purple = purple;
    this.blue = blue;
    this.textMain = textMain;
    this.textSub = textSub;
    this.border = border;
    this.danger = danger;
    this.track = track;
  }
}

export function colorsOf(theme: number): GachaColors {
  if (theme === THEME_BLUE) {
    return new GachaColors('#0E1520', '#1A2433', '#212D3F', '#5B8DEF', '#33507F',
      '#F3C64B', '#9E8BF0', '#69A6F2', '#EAF1FB', '#8CA0B8',
      '#2C3A4E', '#E06C5A', '#243045');
  }
  return new GachaColors('#141210', '#221E18', '#2C261C', '#E8B542', '#8A6E2C',
    '#FFD24A', '#B487E8', '#6E9CD2', '#F5EFE2', '#A89F8C',
    '#3A3428', '#E06C5A', '#312B21');
}

export class ThemeOption {
  value: number = 0;
  name: string = '';
  desc: string = '';
  swatch: string = '';

  constructor(value: number, name: string, desc: string, swatch: string) {
    this.value = value;
    this.name = name;
    this.desc = desc;
    this.swatch = swatch;
  }
}

export const THEME_OPTIONS: ThemeOption[] = [
  new ThemeOption(THEME_GOLD, '欧皇金', '暖金色调，出货时的配色', '#E8B542'),
  new ThemeOption(THEME_BLUE, '非酋蓝', '冷静蓝色调，保持心态平稳', '#5B8DEF')
];

export async function loadThemePref(context: common.Context): Promise<number> {
  try {
    const opt: preferences.Options = { name: PREFS_NAME };
    const p = await preferences.getPreferences(context, opt);
    const v = p.getSync(KEY_THEME, 0);
    if (typeof v === 'number') {
      return v;
    }
    return THEME_GOLD;
  } catch (e) {
    return THEME_GOLD;
  }
}

export async function saveThemePref(context: common.Context, theme: number): Promise<void> {
  try {
    const opt: preferences.Options = { name: PREFS_NAME };
    const p = await preferences.getPreferences(context, opt);
    p.putSync(KEY_THEME, theme);
    p.flush();
  } catch (e) {
  }
}
