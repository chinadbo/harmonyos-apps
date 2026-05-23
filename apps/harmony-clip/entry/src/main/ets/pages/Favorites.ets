import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ClipEntry, ClipDataSource } from '../model/ClipEntry';
import { ClipService } from '../service/ClipService';
import { ClipItem } from '../components/ClipItem';
import { EmptyState } from '../components/EmptyState';

@Entry
@Component
struct Favorites {
  @State private isLoading: boolean = false;
  private dataSource: ClipDataSource = new ClipDataSource();
  private service: ClipService = ClipService.getInstance();

  aboutToAppear(): void {
    this.loadFavorites();
  }

  private async loadFavorites(): Promise<void> {
    this.isLoading = true;
    try {
      await this.service.loadFavorites(this.dataSource);
    } catch (err) {
      promptAction.showToast({ message: '加载收藏失败', duration: 1500 });
    } finally {
      this.isLoading = false;
    }
  }

  private async onFavoriteToggle(id: number, current: boolean): Promise<void> {
    try {
      await this.service.toggleFavorite(id, current);
      await this.loadFavorites();
    } catch (err) {
      promptAction.showToast({ message: '操作失败', duration: 1500 });
    }
  }

  private async onCopy(content: string): Promise<void> {
    const context = getContext(this) as Context;
    await this.service.copyToClipboard(content, context);
  }

  private async onDelete(id: number, index: number): Promise<void> {
    try {
      await this.service.deleteById(id);
      this.dataSource.deleteItem(index);
    } catch (err) {
      promptAction.showToast({ message: '删除失败', duration: 1500 });
    }
  }

  @Builder
  private DeleteButton(id: number, index: number) {
    Button('删除')
      .width(80)
      .height('100%')
      .backgroundColor('#FA2A2D')
      .fontColor('#FFFFFF')
      .fontSize(14)
      .borderRadius({ topRight: 12, bottomRight: 12 })
      .onClick(() => {
        this.onDelete(id, index);
      })
  }

  build() {
    Navigation() {
      Column() {
        if (this.dataSource.totalCount() === 0 && !this.isLoading) {
          EmptyState({
            title: '暂无收藏',
            description: '在历史记录中点击星标收藏重要内容',
          })
        } else {
          List({ space: 8 }) {
            LazyForEach(this.dataSource, (item: ClipEntry, index: number) => {
              ListItem() {
                ClipItem({
                  entry: item,
                  onFavoriteToggle: (id: number, current: boolean) => {
                    this.onFavoriteToggle(id, current);
                  },
                  onCopy: (content: string) => {
                    this.onCopy(content);
                  },
                })
              }
              .swipeAction({
                end: {
                  builder: () => { this.DeleteButton(item.id, index) },
                  onAction: () => {
                    this.onDelete(item.id, index);
                  },
                  actionAreaDistance: 80,
                }
              })
            }, (item: ClipEntry) => `fav_${item.id}_${item.isFavorite}`)
          }
          .layoutWeight(1)
          .padding({ left: 16, right: 16, top: 8, bottom: 16 })
          .divider({ strokeWidth: 0 })
        }
      }
      .height('100%')
      .backgroundColor('#F1F3F5')
    }
    .title('收藏夹')
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor('#F1F3F5')
  }
}
