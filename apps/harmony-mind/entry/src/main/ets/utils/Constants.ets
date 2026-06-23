export class Constants {
  static readonly PREFERENCES_NAME: string = 'harmonymind_preferences';
  static readonly META_KEY: string = 'mind_map_meta';
  static readonly SETTINGS_KEY: string = 'app_settings';
  static readonly STORAGE_DIR: string = 'mindmaps';
  static readonly FILE_EXTENSION: string = '.json';
  static readonly DEFAULT_TITLE: string = '新建脑图';
  static readonly DEFAULT_CHILD_TEXT: string = '新节点';
  static readonly DEFAULT_THEME_DARK: boolean = false;
  static readonly NODE_WIDTH: number = 172;
  static readonly NODE_HEIGHT: number = 52;
  static readonly HORIZONTAL_GAP: number = 220;
  static readonly VERTICAL_GAP: number = 24;
  static readonly ROOT_X: number = 0;
  static readonly ROOT_Y: number = 0;
  static readonly MIN_SCALE: number = 0.5;
  static readonly MAX_SCALE: number = 2.4;
  static readonly SCALE_STEP: number = 0.1;
  static readonly HIT_PADDING: number = 10;
  static readonly COLOR_PALETTE: Array<string> = [
    '#FF5B8FF9',
    '#FF61DDAA',
    '#FF65789B',
    '#FFF6BD16',
    '#FF7262FD',
    '#FFF08BB4'
  ];
}
