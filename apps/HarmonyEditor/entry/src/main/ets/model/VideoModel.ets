import fs from '@ohos.file.fs';
import media from '@ohos.multimedia.media';
import { FilterType } from '../common/constants';

export interface VideoInfo {
  uri: string;
  name: string;
  durationMs: number;
  width: number;
  height: number;
  frameRate: number;
  format: string;
  fileSize: number;
  thumbnailUri: string;
  dateAdded: number;
  filterType: FilterType;
  filterIntensity: number;
}

export interface GalleryVideoItem extends VideoInfo {
  selected: boolean;
}

export async function extractVideoInfo(uri: string): Promise<VideoInfo> {
  let extractor: media.AVMetadataExtractor | undefined;
  let file: fs.File | undefined;
  try {
    extractor = await media.createAVMetadataExtractor();
    file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    extractor.fd = file.fd;
    const metadata: Record<string, string> = await extractor.fetchMetadata();
    const durationMs: number = parseMetadataNumber(metadata, ['duration', 'video_duration']);
    const width: number = parseMetadataNumber(metadata, ['video_width', 'width']);
    const height: number = parseMetadataNumber(metadata, ['video_height', 'height']);
    const frameRate: number = parseMetadataNumber(metadata, ['frame_rate', 'video_frame_rate']);
    const format: string = metadata['mime_type'] ?? metadata['format'] ?? 'video/mp4';
    const stat = fs.statSync(uri);
    return {
      uri,
      name: extractFileName(uri),
      durationMs,
      width,
      height,
      frameRate,
      format,
      fileSize: stat.size,
      thumbnailUri: uri,
      dateAdded: Date.now(),
      filterType: FilterType.NONE,
      filterIntensity: 0
    };
  } catch (_error) {
    return {
      uri,
      name: extractFileName(uri),
      durationMs: 0,
      width: 0,
      height: 0,
      frameRate: 0,
      format: 'video/mp4',
      fileSize: 0,
      thumbnailUri: uri,
      dateAdded: Date.now(),
      filterType: FilterType.NONE,
      filterIntensity: 0
    };
  } finally {
    try {
      if (file) {
        fs.closeSync(file);
      }
    } catch (_error) {
    }
    try {
      await extractor?.release();
    } catch (_error) {
    }
  }
}

export function createGalleryVideoItem(info: VideoInfo): GalleryVideoItem {
  return {
    ...info,
    selected: false
  };
}

export function extractFileName(uri: string): string {
  const segments: Array<string> = uri.split('/');
  if (segments.length === 0) {
    return uri;
  }
  return segments[segments.length - 1];
}

function parseMetadataNumber(metadata: Record<string, string>, keys: Array<string>): number {
  for (const key of keys) {
    const value: string | undefined = metadata[key];
    if (!value) {
      continue;
    }
    const parsed: number = Number(value);
    if (!Number.isNaN(parsed)) {
      return parsed;
    }
  }
  return 0;
}
