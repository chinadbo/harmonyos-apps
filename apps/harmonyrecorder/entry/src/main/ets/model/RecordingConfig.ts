export interface RecordingConfig {
  resolution: '720p' | '1080p' | 'native';
  frameRate: 30 | 60;
  enableAudio: boolean;
  countdownSeconds: 3 | 5 | 10 | 0;
  enableAnnotation: boolean;
}

export const DEFAULT_RECORDING_CONFIG: RecordingConfig = {
  resolution: '1080p',
  frameRate: 30,
  enableAudio: true,
  countdownSeconds: 3,
  enableAnnotation: true
};
