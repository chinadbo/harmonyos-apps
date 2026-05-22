import fs from '@ohos.file.fs';
import { FileItem } from '../model/FileItem';
import { getIconType } from '../utils/FileIconMapper';
import {
  IMAGE_EXTENSIONS,
  VIDEO_EXTENSIONS,
  AUDIO_EXTENSIONS,
  DOC_EXTENSIONS
} from '../model/FileConstants';

function getMimeType(extension: string, isDirectory: boolean): string {
  if (isDirectory) {
    return 'inode/directory';
  }
  const ext = extension.toLowerCase();
  if (IMAGE_EXTENSIONS.includes(ext)) {
    return `image/${ext === 'jpg' ? 'jpeg' : ext}`;
  }
  if (VIDEO_EXTENSIONS.includes(ext)) {
    return `video/${ext}`;
  }
  if (AUDIO_EXTENSIONS.includes(ext)) {
    return `audio/${ext}`;
  }
  if (ext === 'pdf') {
    return 'application/pdf';
  }
  if (['doc', 'docx'].includes(ext)) {
    return 'application/msword';
  }
  if (['xls', 'xlsx'].includes(ext)) {
    return 'application/vnd.ms-excel';
  }
  if (['ppt', 'pptx'].includes(ext)) {
    return 'application/vnd.ms-powerpoint';
  }
  if (['json', 'xml', 'yaml', 'yml'].includes(ext)) {
    return `application/${ext}`;
  }
  if (['js', 'ts'].includes(ext)) {
    return 'text/javascript';
  }
  if (['txt', 'md', 'sh'].includes(ext)) {
    return 'text/plain';
  }
  return 'application/octet-stream';
}

function buildFileItem(name: string, path: string, stat: fs.Stat): FileItem {
  const isDirectory = stat.isDirectory();
  const dotIndex = name.lastIndexOf('.');
  const extension = (!isDirectory && dotIndex > 0) ? name.substring(dotIndex + 1).toLowerCase() : '';
  return {
    name,
    path,
    isDirectory,
    size: stat.size,
    mtime: stat.mtime,
    extension,
    mimeType: getMimeType(extension, isDirectory),
    iconType: getIconType(extension, isDirectory)
  };
}

export class FileService {
  private static instance: FileService;

  private constructor() {}

  static getInstance(): FileService {
    if (!FileService.instance) {
      FileService.instance = new FileService();
    }
    return FileService.instance;
  }

  async listDirectory(dirPath: string): Promise<FileItem[]> {
    const names: string[] = fs.listFileSync(dirPath, { recursion: false, listNum: 0 });
    const items: FileItem[] = [];
    for (const name of names) {
      const fullPath = `${dirPath}/${name}`;
      try {
        const stat = fs.statSync(fullPath);
        items.push(buildFileItem(name, fullPath, stat));
      } catch (e) {
        // skip files that can't be stat'd (permission denied, broken links, etc.)
      }
    }
    return items;
  }

  async renameFile(srcPath: string, newName: string): Promise<void> {
    const lastSlash = srcPath.lastIndexOf('/');
    const parentDir = srcPath.substring(0, lastSlash);
    const destPath = `${parentDir}/${newName}`;
    await fs.rename(srcPath, destPath);
  }

  async deleteFile(path: string, isDir: boolean): Promise<void> {
    if (isDir) {
      await fs.rmdir(path);
    } else {
      await fs.unlink(path);
    }
  }

  async createDirectory(parentPath: string, name: string): Promise<void> {
    await fs.mkdir(`${parentPath}/${name}`);
  }

  async copyFile(src: string, dest: string): Promise<void> {
    await fs.copy(src, dest);
  }

  async moveFile(src: string, dest: string): Promise<void> {
    await fs.moveFile(src, dest, 0);
  }

  async readTextFile(path: string): Promise<string> {
    const maxBytes = 51200;
    const file = await fs.open(path, fs.OpenMode.READ_ONLY);
    try {
      const buffer = new ArrayBuffer(maxBytes);
      const bytesRead = await fs.read(file.fd, buffer);
      const uint8 = new Uint8Array(buffer, 0, bytesRead as number);
      let result = '';
      for (let i = 0; i < uint8.length; i++) {
        result += String.fromCharCode(uint8[i]);
      }
      return result;
    } finally {
      await fs.close(file.fd);
    }
  }

  getRootDirectories(context: Context): Array<{ name: string; path: string }> {
    return [
      { name: 'Downloads', path: context.filesDir + '/Downloads' },
      { name: 'Documents', path: context.filesDir + '/Documents' },
      { name: 'Cache', path: context.cacheDir }
    ];
  }
}
