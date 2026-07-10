import { HistoryItem } from '../components/HistoryItem';
import { EmptyState } from '../components/EmptyState';
import { DatabaseService } from '../service/DatabaseService';
import { TranslateRecord } from '../model/TranslateRecord';
import { promptAction } from '@ohos.promptAction';

@Component
export struct FavoritesView {
  @State records: TranslateRecord[] = [];
  @State isLoading: boolean = false;

  aboutToAppear(): void {
    this.loadRecords();
  }

  build() {
    Column() {
      Row() {
        Text('收藏夹')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      if (this.records.length === 0) {
        EmptyState({ message: '暂无收藏', icon: '⭐' })
      } else {
        List() {
          ForEach(this.records, (record: TranslateRecord) => {
            ListItem() {
              HistoryItem({
                record: record,
                onDelete: () => this.deleteRecord(record.id),
                onFavorite: () => this.toggleFavorite(record),
                onTap: () => this.showDetail(record)
              })
            }
          }, (record: TranslateRecord) => record.id.toString())
        }
        .width('100%')
        .padding(16)
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  private async loadRecords(): Promise<void> {
    this.isLoading = true;
    try {
      const context = getContext(this) as Context;
      const db = new DatabaseService(context);
      await db.init();
      this.records = await db.queryFavorites();
      db.close();
    } catch (e) {
      console.error('Failed to load favorites:', e);
    } finally {
      this.isLoading = false;
    }
  }

  private async deleteRecord(id: number): Promise<void> {
    try {
      const context = getContext(this) as Context;
      const db = new DatabaseService(context);
      await db.init();
      await db.delete(id);
      db.close();
      await this.loadRecords();
      promptAction.showToast({ message: '已删除' });
    } catch (e) {
      console.error('Failed to delete favorite:', e);
    }
  }

  private async toggleFavorite(record: TranslateRecord): Promise<void> {
    try {
      const context = getContext(this) as Context;
      const db = new DatabaseService(context);
      await db.init();
      await db.updateFavorite(record.id, !record.isFavorite);
      db.close();
      await this.loadRecords();
      promptAction.showToast({ message: '已取消收藏' });
    } catch (e) {
      console.error('Failed to update favorite:', e);
    }
  }

  private showDetail(record: TranslateRecord): void {
    promptAction.showToast({ message: '长按可查看更多' });
  }
}
