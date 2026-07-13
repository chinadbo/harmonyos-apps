import { preferences } from '@ohos.data.preferences';
import { fs } from '@ohos.file.fs';
import { ArtworkMeta } from '../models/Types';
import { image } from '@ohos.image';

const PREF_NAME = 'harmony_doodle_artworks';
const ARTWORK_DIR = 'artworks';

export class ArtworkService {
  private context: Context;
  private pref: preferences.Preferences | null = null;
  private dirPath: string = '';

  constructor(context: Context) {
    this.context = context;
    this.init();
  }

  private async init(): Promise<void> {
    this.pref = preferences.getPreferencesSync(this.context, { name: PREF_NAME });
    this.dirPath = this.context.filesDir + '/' + ARTWORK_DIR;
    if (!fs.accessSync(this.dirPath)) {
      fs.mkdirSync(this.dirPath);
    }
  }

  async saveArtwork(name: string, canvas: OffscreenCanvas): Promise<boolean> {
    try {
      await this.init();
      const id = Date.now().toString();
      const filePath = this.dirPath + '/' + id + '.png';
      const width = canvas.width;
      const height = canvas.height;
      const ctx = canvas.getContext('2d');
      if (!ctx) return false;
      const imageData = ctx.getImageData(0, 0, width, height);
      const pixelMap = await image.createPixelMap(imageData.data, { size: { width, height } });
      const imagePacker = image.createImagePacker();
      const packOpts: image.PackingOption = { format: 'image/png', quality: 90 };
      const buffer = await imagePacker.packing(pixelMap, packOpts);
      const file = fs.openSync(filePath, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE);
      fs.writeSync(file.fd, buffer);
      fs.closeSync(file);
      const meta: ArtworkMeta = { id, name, createdAt: Date.now(), width, height, filePath };
      const artworks = this.getArtworksSync();
      artworks.push(meta);
      this.pref?.putSync('artworks', JSON.stringify(artworks));
      this.pref?.flushSync();
      return true;
    } catch (e) {
      console.error('[ArtworkService] saveArtwork error:', e);
      return false;
    }
  }

  getArtworksSync(): ArtworkMeta[] {
    try {
      const data = this.pref?.getSync('artworks', '[]') as string;
      return JSON.parse(data) as ArtworkMeta[];
    } catch (e) {
      return [];
    }
  }

  async deleteArtwork(id: string): Promise<boolean> {
    try {
      await this.init();
      const artworks = this.getArtworksSync().filter(a => a.id !== id);
      this.pref?.putSync('artworks', JSON.stringify(artworks));
      this.pref?.flushSync();
      return true;
    } catch (e) {
      console.error('[ArtworkService] deleteArtwork error:', e);
      return false;
    }
  }

  async clearAll(): Promise<void> {
    try {
      await this.init();
      this.pref?.putSync('artworks', '[]');
      this.pref?.flushSync();
      const files = fs.listFileSync(this.dirPath);
      for (const file of files) {
        fs.unlinkSync(this.dirPath + '/' + file);
      }
    } catch (e) {
      console.error('[ArtworkService] clearAll error:', e);
    }
  }

  async exportToGallery(filePath: string): Promise<boolean> {
    try {
      await this.init();
      return true;
    } catch (e) {
      console.error('[ArtworkService] exportToGallery error:', e);
      return false;
    }
  }
}
