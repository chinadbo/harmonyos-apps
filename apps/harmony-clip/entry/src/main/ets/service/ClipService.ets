import pasteboard from '@ohos.pasteboard';
import promptAction from '@ohos.promptAction';
import { ClipDatabase } from '../database/ClipDatabase';
import { ClipDetector } from './ClipDetector';
import { ClipEntry, ClipType, ClipDataSource } from '../model/ClipEntry';

export class ClipService {
  private static instance: ClipService | null = null;
  private db: ClipDatabase = ClipDatabase.getInstance();

  private constructor() {}

  static getInstance(): ClipService {
    if (!ClipService.instance) {
      ClipService.instance = new ClipService();
    }
    return ClipService.instance;
  }

  async saveFromPasteboard(content: string, context: Context): Promise<ClipEntry | null> {
    if (!content || content.trim().length === 0) {
      return null;
    }

    const isDuplicate = await this.db.existsByContent(content);
    if (isDuplicate) {
      return null;
    }

    const type = ClipDetector.detect(content);
    const isPrivate = ClipDetector.isPrivate(content);
    const previewText = ClipDetector.buildPreview(content, isPrivate);

    const entry: Omit<ClipEntry, 'id'> = {
      content,
      type,
      isPrivate,
      isFavorite: false,
      createTime: Date.now(),
      previewText,
    };

    const id = await this.db.insertClip(entry);
    return { id, ...entry };
  }

  async loadHistory(dataSource: ClipDataSource): Promise<void> {
    const list = await this.db.queryHistory();
    dataSource.setData(list);
  }

  async searchHistory(keyword: string, dataSource: ClipDataSource): Promise<void> {
    if (!keyword || keyword.trim().length === 0) {
      await this.loadHistory(dataSource);
      return;
    }
    const list = await this.db.searchByKeyword(keyword.trim());
    dataSource.setData(list);
  }

  async loadFavorites(dataSource: ClipDataSource): Promise<void> {
    const list = await this.db.queryFavorites();
    dataSource.setData(list);
  }

  async copyToClipboard(content: string, context: Context): Promise<void> {
    const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, content);
    const systemPasteboard = pasteboard.getSystemPasteboard();
    await systemPasteboard.setData(pasteData);
    promptAction.showToast({ message: '已复制到剪贴板', duration: 1500 });
  }

  async toggleFavorite(id: number, current: boolean): Promise<void> {
    await this.db.toggleFavorite(id, !current);
  }

  async deleteById(id: number): Promise<void> {
    await this.db.deleteById(id);
  }

  async clearHistory(): Promise<void> {
    await this.db.clearAllHistory();
  }

  async cleanExpired(retentionDays: number): Promise<void> {
    await this.db.cleanExpired(retentionDays);
  }

  filterByType(allData: ClipEntry[], type: ClipType | 'all'): ClipEntry[] {
    if (type === 'all') {
      return allData;
    }
    return allData.filter(e => e.type === type);
  }
}
