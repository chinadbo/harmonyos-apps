export const APP_NAME: string = 'HarmonyEditor';
export const DB_NAME: string = 'harmony_editor.db';
export const MAX_SEGMENT_SELECT_COUNT: number = 10;
export const DEFAULT_EXPORT_PROGRESS_STEP: number = 5;

export const TABLES = {
  PROJECTS: 'projects',
  VIDEO_SEGMENTS: 'video_segments',
  AUDIO_TRACKS: 'audio_tracks',
  SETTINGS: 'settings'
} as const;

export const ROUTES = {
  PROJECT_LIST: 'pages/ProjectListPage',
  VIDEO_PICKER: 'pages/VideoPickerPage',
  EDITOR: 'pages/EditorPage',
  FILTER_PANEL: 'pages/FilterPanelPage',
  EXPORT: 'pages/ExportPage',
  SETTINGS: 'pages/SettingsPage'
} as const;

export const PERMISSIONS = {
  READ_MEDIA: 'ohos.permission.READ_MEDIA',
  WRITE_MEDIA: 'ohos.permission.WRITE_MEDIA'
} as const;

export const SETTING_KEYS = {
  DEFAULT_EXPORT_RESOLUTION: 'default_export_resolution',
  DEFAULT_EXPORT_FORMAT: 'default_export_format',
  AUTO_SAVE_ENABLED: 'auto_save_enabled'
} as const;

export enum FilterType {
  NONE = 'none',
  BLACK_WHITE = 'black_white',
  SEPIA = 'sepia',
  WARM = 'warm',
  COOL = 'cool',
  HIGH_CONTRAST = 'high_contrast',
  SOFT_FOCUS = 'soft_focus',
  VINTAGE = 'vintage',
  CINEMATIC = 'cinematic'
}

export enum ExportResolution {
  RES_720P = '720p',
  RES_1080P = '1080p',
  RES_ORIGINAL = 'original'
}

export enum ExportFormat {
  FORMAT_MP4 = 'mp4',
  FORMAT_MOV = 'mov'
}

export interface FilterPreset {
  type: FilterType;
  label: string;
  description: string;
  previewColor: string;
}

export interface ExportOption {
  label: string;
  value: string;
}

export const FILTER_PRESETS: Array<FilterPreset> = [
  { type: FilterType.BLACK_WHITE, label: 'Black & White', description: 'Classic monochrome contrast.', previewColor: '#94A3B8' },
  { type: FilterType.SEPIA, label: 'Sepia', description: 'Warm vintage brown tint.', previewColor: '#B45309' },
  { type: FilterType.WARM, label: 'Warm', description: 'Golden tones for cozy scenes.', previewColor: '#F97316' },
  { type: FilterType.COOL, label: 'Cool', description: 'Blue tint for crisp footage.', previewColor: '#0EA5E9' },
  { type: FilterType.HIGH_CONTRAST, label: 'High Contrast', description: 'Punchy blacks and highlights.', previewColor: '#6366F1' },
  { type: FilterType.SOFT_FOCUS, label: 'Soft Focus', description: 'Gentle blur and bloom.', previewColor: '#EC4899' },
  { type: FilterType.VINTAGE, label: 'Vintage', description: 'Retro faded film look.', previewColor: '#A16207' },
  { type: FilterType.CINEMATIC, label: 'Cinematic', description: 'Letterbox-inspired dramatic tone.', previewColor: '#7C3AED' }
];

export const EXPORT_RESOLUTION_OPTIONS: Array<ExportOption> = [
  { label: '720p', value: ExportResolution.RES_720P },
  { label: '1080p', value: ExportResolution.RES_1080P },
  { label: 'Original', value: ExportResolution.RES_ORIGINAL }
];

export const EXPORT_FORMAT_OPTIONS: Array<ExportOption> = [
  { label: 'MP4', value: ExportFormat.FORMAT_MP4 },
  { label: 'MOV', value: ExportFormat.FORMAT_MOV }
];

export const TIMELINE_MIN_GAP_MS: number = 500;
