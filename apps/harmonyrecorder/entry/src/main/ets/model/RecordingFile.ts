export interface RecordingFile {
  id: string;
  name: string;
  path: string;
  thumbnailPath: string;
  duration: number;
  size: number;
  createdAt: string;
  gifPath?: string;
}
