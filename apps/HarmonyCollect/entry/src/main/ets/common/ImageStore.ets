/**
 * ImageStore.ets — 图片选择与沙箱持久化
 * PhotoViewPicker 返回的 photoUri 仅可临时读取，必须拷贝到 filesDir/images/ 后才能长期使用。
 */
import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { Logger } from './Logger';

const TAG: string = 'ImageStore';
const IMAGE_DIR: string = 'images';

export class ImageStore {
  /** 打开系统相册选择图片，自动拷贝到沙箱并返回本地路径数组 */
  static async pickAndCopy(context: common.UIAbilityContext, max: number): Promise<string[]> {
    const result: string[] = [];
    try {
      const options: picker.PhotoSelectOptions = new picker.PhotoSelectOptions();
      options.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = max < 1 ? 1 : max;
      const photoPicker: picker.PhotoViewPicker = new picker.PhotoViewPicker();
      const selectResult: picker.PhotoSelectResult = await photoPicker.select(options);
      const uris: string[] = selectResult.photoUris ?? [];
      for (let i = 0; i < uris.length; i++) {
        const local: string = ImageStore.copyToSandbox(context, uris[i]);
        if (local.length > 0) {
          result.push(local);
        }
      }
    } catch (err) {
      Logger.error(TAG, 'pickAndCopy failed: ' + JSON.stringify(err));
    }
    return result;
  }

  /** 将单个 photoUri 拷贝到沙箱，返回本地绝对路径（失败返回空串） */
  static copyToSandbox(context: common.UIAbilityContext, uri: string): string {
    let sourceFd: number = -1;
    try {
      const dir: string = ImageStore.ensureImageDir(context);
      const ext: string = ImageStore.extOf(uri);
      const name: string = 'img_' + Date.now() + '_' + Math.floor(Math.random() * 100000).toString() + ext;
      const dest: string = dir + '/' + name;
      const file: fs.File = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      sourceFd = file.fd;
      fs.copyFileSync(sourceFd, dest);
      fs.closeSync(file);
      sourceFd = -1;
      Logger.info(TAG, 'copied to ' + dest);
      return dest;
    } catch (err) {
      Logger.error(TAG, 'copyToSandbox failed: ' + JSON.stringify(err));
      if (sourceFd >= 0) {
        try {
          fs.closeSync(sourceFd);
        } catch (e) {
          // ignore
        }
      }
      return '';
    }
  }

  /** 确保沙箱图片目录存在，返回其绝对路径 */
  static ensureImageDir(context: common.UIAbilityContext): string {
    const dir: string = context.filesDir + '/' + IMAGE_DIR;
    if (!fs.accessSync(dir)) {
      fs.mkdirSync(dir);
    }
    return dir;
  }

  /** 展示用图片地址：补 file:// 前缀 */
  static toDisplaySrc(path: string): string {
    if (path.length === 0) {
      return '';
    }
    if (path.startsWith('file://') || path.startsWith('http')) {
      return path;
    }
    return 'file://' + path;
  }

  /** 删除沙箱内图片（尽力而为，不影响主流程） */
  static deleteFile(path: string): void {
    if (path.length === 0) {
      return;
    }
    try {
      if (fs.accessSync(path)) {
        fs.unlinkSync(path);
      }
    } catch (err) {
      Logger.warn(TAG, 'deleteFile failed: ' + JSON.stringify(err));
    }
  }

  /** 从 uri 推断图片扩展名 */
  private static extOf(uri: string): string {
    const clean: string = uri.split('?')[0];
    const dot: number = clean.lastIndexOf('.');
    if (dot < 0) {
      return '.jpg';
    }
    const ext: string = clean.substring(dot).toLowerCase();
    const allow: string[] = ['.png', '.jpg', '.jpeg', '.webp', '.bmp', '.gif', '.heic'];
    if (allow.indexOf(ext) >= 0) {
      return ext;
    }
    return '.jpg';
  }
}
