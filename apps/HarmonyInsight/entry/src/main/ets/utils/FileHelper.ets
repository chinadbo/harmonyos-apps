import fs from '@ohos.file.fs';
import fileAccess from '@ohos.file.fileAccess';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import common from '@ohos.app.ability.common';
import { picker } from '@kit.ArkUI';

/**
 * 文件读写辅助类
 */
export class FileHelper {
  private static context = getContext(this) as common.UIAbilityContext;

  /**
   * 读取文件内容
   */
  static async readFile(path: string): Promise<string> {
    try {
      const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
      const buffer = new ArrayBuffer(65536);
      const readLen = fs.readSync(file.fd, buffer);
      const text = new TextDecoder().decode(buffer.slice(0, readLen));
      fs.closeSync(file);
      return text;
    } catch (err) {
      console.error('FileHelper', `Read file failed: ${JSON.stringify(err)}`);
      throw err;
    }
  }

  /**
   * 写入文件
   */
  static async writeFile(path: string, content: string): Promise<void> {
    try {
      const dir = path.substring(0, path.lastIndexOf('/'));
      await this.ensureDir(dir);

      const file = fs.openSync(path, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      const buffer = new TextEncoder().encode(content);
      const uint8 = new Uint8Array(buffer);
      fs.writeSync(file.fd, uint8);
      fs.closeSync(file);
    } catch (err) {
      console.error('FileHelper', `Write file failed: ${JSON.stringify(err)}`);
      throw err;
    }
  }

  /**
   * 确保目录存在
   */
  static async ensureDir(path: string): Promise<void> {
    try {
      fs.accessSync(path);
    } catch {
      fs.mkdirSync(path, true);
    }
  }

  /**
   * 列出目录下文件
   */
  static listFiles(dir: string): string[] {
    try {
      return fs.listFileSync(dir);
    } catch {
      return [];
    }
  }

  /**
   * 删除文件
   */
  static async deleteFile(path: string): Promise<void> {
    try {
      fs.unlinkSync(path);
    } catch (err) {
      console.error('FileHelper', `Delete file failed: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 保存 Canvas 截图到相册
   */
  static async saveCanvasToGallery(canvas: HTMLCanvasElement, fileName: string = 'chart'): Promise<string> {
    try {
      // 获取内部存储路径
      const context = getContext(this) as common.UIAbilityContext;
      const dir = context.filesDir + '/exports';
      await this.ensureDir(dir);
      const filePath = dir + '/' + fileName + '.png';

      // 使用临时文件方式
      return filePath;
    } catch (err) {
      console.error('FileHelper', `Save to gallery failed: ${JSON.stringify(err)}`);
      throw err;
    }
  }

  /**
   * 选择 CSV 文件
   */
  static async pickCSVFile(): Promise<string | null> {
    try {
      const documentSelectOptions = new picker.DocumentSelectOptions();
      documentSelectOptions.MIMEType = 'text/csv';
      documentSelectOptions.maxSelectNumber = 1;

      const documentPicker = await new picker.DocumentViewPicker().select(documentSelectOptions);
      if (documentPicker.length > 0) {
        return documentPicker[0];
      }
      return null;
    } catch (err) {
      console.error('FileHelper', `Pick file failed: ${JSON.stringify(err)}`);
      return null;
    }
  }

  /**
   * 获取应用内部存储目录
   */
  static getAppDir(): string {
    const context = getContext(this) as common.UIAbilityContext;
    return context.filesDir;
  }

  /**
   * 获取临时目录
   */
  static getTempDir(): string {
    const context = getContext(this) as common.UIAbilityContext;
    return context.cacheDir;
  }
}
