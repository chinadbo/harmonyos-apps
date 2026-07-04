export enum TorchMode {
  STEADY = 'STEADY',
  SOS = 'SOS',
  STROBE = 'STROBE',
  SCREEN = 'SCREEN'
}

export interface TorchSettings {
  vibrationEnabled: boolean;
  keepScreenOn: boolean;
  defaultMode: TorchMode;
  strobeFrequency: number;
  screenBrightness: number;
}

export const DEFAULT_SETTINGS: TorchSettings = {
  vibrationEnabled: true,
  keepScreenOn: false,
  defaultMode: TorchMode.STEADY,
  strobeFrequency: 5,
  screenBrightness: 80
};

export const MODE_LABELS: Record<TorchMode, string> = {
  [TorchMode.STEADY]: '常亮',
  [TorchMode.SOS]: 'SOS',
  [TorchMode.STROBE]: '频闪',
  [TorchMode.SCREEN]: '屏幕补光'
};

export const MODE_ICONS: Record<TorchMode, string> = {
  [TorchMode.STEADY]: '🔦',
  [TorchMode.SOS]: '🆘',
  [TorchMode.STROBE]: '⚡',
  [TorchMode.SCREEN]: '💡'
};
