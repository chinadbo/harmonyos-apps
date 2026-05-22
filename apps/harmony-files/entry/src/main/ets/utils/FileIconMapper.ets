import {
  IMAGE_EXTENSIONS,
  VIDEO_EXTENSIONS,
  AUDIO_EXTENSIONS,
  DOC_EXTENSIONS,
  CODE_EXTENSIONS,
  ARCHIVE_EXTENSIONS
} from '../model/FileConstants';

export function getIconType(extension: string, isDirectory: boolean): string {
  if (isDirectory) {
    return 'folder';
  }
  const ext = extension.toLowerCase();
  if (IMAGE_EXTENSIONS.includes(ext)) {
    return 'image';
  }
  if (VIDEO_EXTENSIONS.includes(ext)) {
    return 'video';
  }
  if (AUDIO_EXTENSIONS.includes(ext)) {
    return 'audio';
  }
  if (ext === 'pdf') {
    return 'pdf';
  }
  if (['doc', 'docx'].includes(ext)) {
    return 'word';
  }
  if (['xls', 'xlsx'].includes(ext)) {
    return 'excel';
  }
  if (['ppt', 'pptx'].includes(ext)) {
    return 'ppt';
  }
  if (CODE_EXTENSIONS.includes(ext)) {
    return 'code';
  }
  if (ARCHIVE_EXTENSIONS.includes(ext)) {
    return 'archive';
  }
  if (['txt', 'log', 'csv'].includes(ext)) {
    return 'text';
  }
  return 'unknown';
}
