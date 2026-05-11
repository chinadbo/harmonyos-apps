import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import photoAccessHelper from '@ohos.file.photoAccessHelper';

export class ImageService {
  private static instance?: ImageService;

  static getInstance(): ImageService {
    if (!ImageService.instance) {
      ImageService.instance = new ImageService();
    }
    return ImageService.instance;
  }

  private async ensureDirectory(context: common.UIAbilityContext): Promise<string> {
    const imageDirectory = `${context.filesDir}/images`;
    try {
      fs.accessSync(imageDirectory);
    } catch (_error) {
      fs.mkdirSync(imageDirectory);
    }
    return imageDirectory;
  }

  private fileName(uri: string): string {
    const lastIndex = uri.lastIndexOf('/');
    if (lastIndex === -1) {
      return `photo_${Date.now()}.jpg`;
    }
    const rawName = uri.slice(lastIndex + 1).split('?')[0];
    return rawName.length > 0 ? rawName : `photo_${Date.now()}.jpg`;
  }

  async pickAndCopyImages(context: common.UIAbilityContext, maxSelectNumber: number = 3): Promise<string[]> {
    const picker = new photoAccessHelper.PhotoViewPicker();
    const result = await picker.select({
      MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
      maxSelectNumber
    });
    const selectedUris: string[] = result.photoUris ?? [];
    if (selectedUris.length === 0) {
      return [];
    }

    const imageDirectory = await this.ensureDirectory(context);
    const copiedPaths: string[] = [];
    for (let index = 0; index < selectedUris.length; index++) {
      const sourceUri = selectedUris[index];
      const targetPath = `${imageDirectory}/${Date.now()}_${index}_${this.fileName(sourceUri)}`;
      await fs.copyFile(sourceUri, targetPath);
      copiedPaths.push(targetPath);
    }
    return copiedPaths;
  }
}

export const imageService = ImageService.getInstance();
