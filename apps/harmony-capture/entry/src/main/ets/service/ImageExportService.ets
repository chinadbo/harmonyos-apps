import componentSnapshot from '@ohos.arkui.componentSnapshot';
import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import common from '@ohos.app.ability.common';
import HistoryDbService from './HistoryDbService';
import { HistoryRecord } from '../model/HistoryRecord';

export interface ExportResult {
  savedPath: string
  thumbnailUri: string
}

export class ImageExportService {
  async exportAndSave(componentId: string, context: common.UIAbilityContext, sourcePath: string): Promise<ExportResult> {
    const pixelMap = await this.captureComponent(componentId);
    const helper = photoAccessHelper.getPhotoAccessHelper(context);
    // P0-1 fix: createAsset extension should be file extension, not filename
    // P0-2 fix: correct createAsset signature — (PhotoType, extension, CreateOptions?)
    const createOptions: photoAccessHelper.CreateOptions = {
      title: `HarmonyCapture_${Date.now()}`
    };
    const asset = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png', createOptions);
    const assetUri = asset.uri;
    // P0-1 fix: use asset.open() instead of helper.openAsset() (removed in API 12+)
    const fd = await asset.open('rw');
    const imagePacker = image.createImagePacker();
    let packed: ArrayBuffer | null = null;
    try {
      // P0-3 fix: packing() returns ArrayBuffer directly, no .buffer property
      packed = await imagePacker.packing(pixelMap, { format: 'image/png', quality: 100 });
      fs.writeSync(fd, packed);
    } finally {
      fs.closeSync(fd);
      imagePacker.release();
    }
    const result: ExportResult = {
      savedPath: assetUri,
      thumbnailUri: assetUri
    };
    const record: HistoryRecord = {
      imagePath: sourcePath,
      savedPath: result.savedPath,
      thumbnailUri: result.thumbnailUri,
      createdAt: Date.now()
    };
    await HistoryDbService.insertRecord(record);
    return result;
  }

  private captureComponent(componentId: string): Promise<image.PixelMap> {
    return new Promise((resolve, reject) => {
      componentSnapshot.get(componentId, (error: Error, pixelMap: image.PixelMap) => {
        if (error) {
          reject(error);
          return;
        }
        resolve(pixelMap);
      });
    });
  }
}

export default new ImageExportService();
