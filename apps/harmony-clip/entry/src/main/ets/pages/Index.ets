import pasteboard from '@ohos.pasteboard';
import promptAction from '@ohos.promptAction';
import { ClipEntry, ClipType, ClipDataSource } from '../model/ClipEntry';
import { ClipService } from '../service/ClipService';
import { ClipItem } from '../components/ClipItem';
import { EmptyState } from '../components/EmptyState';

type FilterTab = 'all' | ClipType;

interface TabItem {
  key: FilterTab;
  label: string;
}

const TABS: TabItem[] = [
  { key: 'all', label: '全部' },
  { key: ClipType.TEXT, label: '文本' },
  { key: ClipType.URL, label: '链接' },
  { key: ClipType.EMAIL, label: '邮箱' },
  { key: ClipType.PHONE, label: '手机' },
  { key: ClipType.JSON, label: 'JSON' },
];

@Entry
@Component
struct Index {
  @State private searchKeyword: string = '';
  @State private activeTab: FilterTab = 'all';
  @State private isSearching: boolean = false;
  @State private isLoading: boolean = false;

  private allDataSource: ClipDataSource = new ClipDataSource();
  private filteredDataSource: ClipDataSource = new ClipDataSource();
  private service: ClipService = ClipService.getInstance();
  @StorageProp('navStack') private navStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.loadData();
  }

  private async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      await this.service.loadHistory(this.allDataSource);
      this.applyFilter();
    } catch (err) {
      promptAction.showToast({ message: '加载失败', duration: 1500 });
    } finally {
      this.isLoading = false;
    }
  }

  private applyFilter(): void {
    const all = this.allDataSource.getAll();
    const filtered = this.service.filterByType(all, this.activeTab);
    this.filteredDataSource.setData(filtered);
  }

  private async handleSearch(keyword: string): Promise<void> {
    this.searchKeyword = keyword;
    this.isSearching = keyword.trim().length > 0;
    if (this.isSearching) {
      await this.service.searchHistory(keyword, this.allDataSource);
    } else {
      await this.service.loadHistory(this.allDataSource);
    }
    this.applyFilter();
  }

  private async onPasteContent(content: string): Promise<void> {
    if (!content || content.trim().length === 0) {
      promptAction.showToast({ message: '剪贴板为空', duration: 1500 });
      return;
    }
    try {
      const context = getContext(this) as Context;
      const entry = await this.service.saveFromPasteboard(content, context);
      if (entry) {
        await this.loadData();
        promptAction.showToast({ message: '已保存到历史记录', duration: 1500 });
      } else {
        promptAction.showToast({ message: '已是最新记录，无需重复保存', duration: 1800 });
      }
    } catch (err) {
      promptAction.showToast({ message: '保存失败', duration: 1500 });
    }
  }

  private async onFavoriteToggle(id: number, current: boolean): Promise<void> {
    try {
      await this.service.toggleFavorite(id, current);
      await this.loadData();
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
      this.filteredDataSource.deleteItem(index);
      // Remove from allDataSource too
      const allList = this.allDataSource.getAll();
      const allIdx = allList.findIndex(e => e.id === id);
      if (allIdx >= 0) {
        this.allDataSource.deleteItem(allIdx);
      }
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

  @Builder
  private TabBar() {
    Scroll() {
      Row({ space: 8 }) {
        ForEach(TABS, (tab: TabItem) => {
          Text(tab.label)
            .fontSize(13)
            .fontColor(this.activeTab === tab.key ? '#FFFFFF' : '#182431')
            .backgroundColor(this.activeTab === tab.key ? '#007DFF' : '#F1F3F5')
            .borderRadius(16)
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .onClick(() => {
              this.activeTab = tab.key;
              this.applyFilter();
            })
        }, (tab: TabItem) => tab.key)
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  build() {
    Navigation(this.navStack) {
      Column() {
        // Search bar
        Row({ space: 8 }) {
          Search({
            value: this.searchKeyword,
            placeholder: '搜索剪贴板历史…',
          })
            .layoutWeight(1)
            .height(40)
            .backgroundColor('#F1F3F5')
            .placeholderColor('#99182431')
            .searchIcon({ size: 16, color: '#99182431' })
            .onChange((val: string) => {
              this.handleSearch(val);
            })
            .onSubmit((val: string) => {
              this.handleSearch(val);
            })

          // PasteButton: reads clipboard with zero READ_PASTEBOARD permission
          PasteButton({
            icon: PasteIconStyle.LINES,
            text: PasteDescription.PASTE,
            buttonType: ButtonType.Normal,
          })
            .height(40)
            .borderRadius(8)
            .backgroundColor('#007DFF')
            .fontColor('#FFFFFF')
            .fontSize(14)
            .onPaste((value: PasteButtonOnPasteEvent) => {
              const pasteData = value.pasteData;
              if (pasteData) {
                const text = pasteData.getPrimaryText();
                if (text) {
                  this.onPasteContent(text);
                } else {
                  promptAction.showToast({ message: '剪贴板为空或非文本内容', duration: 1500 });
                }
              }
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 8 })

        // Type filter tabs
        this.TabBar()

        Divider()
          .height(1)
          .color('#1A182431')
          .margin({ top: 8 })

        // List
        if (this.filteredDataSource.totalCount() === 0 && !this.isLoading) {
          if (this.isSearching) {
            EmptyState({
              title: '未找到相关记录',
              description: '换个关键词试试',
            })
          } else {
            EmptyState({
              title: '暂无记录',
              description: '点击上方粘贴按钮读取剪贴板内容',
            })
          }
        } else {
          List({ space: 8 }) {
            LazyForEach(this.filteredDataSource, (item: ClipEntry, index: number) => {
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
            }, (item: ClipEntry) => `${item.id}_${item.isFavorite}`)
          }
          .layoutWeight(1)
          .padding({ left: 16, right: 16, top: 8, bottom: 16 })
          .divider({ strokeWidth: 0 })
        }
      }
      .height('100%')
      .backgroundColor('#F1F3F5')
    }
    .title('剪贴板')
    .titleMode(NavigationTitleMode.Mini)
    .menus([
      {
        value: '收藏夹',
        icon: $r('sys.media.ohos_ic_public_favor'),
        action: () => {
          this.navStack.pushPathByName('Favorites', null);
        }
      },
      {
        value: '设置',
        icon: $r('sys.media.ohos_ic_public_settings'),
        action: () => {
          this.navStack.pushPathByName('Settings', null);
        }
      }
    ])
    .hideBackButton(true)
    .backgroundColor('#F1F3F5')
  }
}
