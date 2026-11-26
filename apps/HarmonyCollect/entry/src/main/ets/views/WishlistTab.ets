/**
 * WishlistTab.ets — 心愿单 Tab（含“已入手”快捷操作）
 */
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { WishItem } from '../model/WishItem';
import { Category } from '../model/Category';
import { CategoryDao, Db } from '../model/Db';
import { WishService, AcquireResult } from '../service/WishService';
import { WishCard } from '../components/WishCard';
import { EmptyView } from '../components/EmptyView';
import { Prefs } from '../common/Prefs';
import { bumpRefresh, C_TEXT, C_SUB, C_BG, C_BRAND, C_LINE, C_CARD, C_SUCCESS } from '../common/Constants';

@Component
export struct WishlistTab {
  @StorageLink('showAcquired') @Watch('onShowAcquiredChange') showAcquired: boolean = false;
  @StorageProp('refreshTick') @Watch('onRefresh') refreshTick: number = 0;

  @State wishes: WishItem[] = [];
  @State categories: Category[] = [];
  @State loading: boolean = true;
  @State loaded: boolean = false;
  @State reqSeq: number = 0;

  aboutToAppear(): void {
    this.reload();
  }

  onRefresh(): void {
    this.reload();
  }

  onShowAcquiredChange(): void {
    Prefs.putBoolean('showAcquired', this.showAcquired);
    this.reload();
  }

  private async loadCategories(): Promise<void> {
    if (this.categories.length > 0) {
      return;
    }
    this.categories = await CategoryDao.queryAll();
  }

  private async reload(): Promise<void> {
    this.reqSeq++;
    const seq: number = this.reqSeq;
    this.loading = this.wishes.length === 0;
    try {
      if (!Db.isReady()) {
        await Db.waitReady(4000);
      }
      await this.loadCategories();
      const list: WishItem[] = await WishService.list(this.showAcquired);
      if (seq === this.reqSeq) {
        this.wishes = list;
        this.loading = false;
        this.loaded = true;
      }
    } catch (err) {
      if (seq === this.reqSeq) {
        this.loading = false;
        this.loaded = true;
      }
    }
  }

  private categoryName(key: string): string {
    for (let i = 0; i < this.categories.length; i++) {
      if (this.categories[i].key === key) {
        return this.categories[i].name;
      }
    }
    return '其他';
  }

  private wantedCount(): number {
    let count: number = 0;
    for (let i = 0; i < this.wishes.length; i++) {
      if (this.wishes[i].status === 0) {
        count++;
      }
    }
    return count;
  }

  private findWish(id: number): WishItem | null {
    for (let i = 0; i < this.wishes.length; i++) {
      if (this.wishes[i].id === id) {
        return this.wishes[i];
      }
    }
    return null;
  }

  private async acquire(id: number): Promise<void> {
    const wish: WishItem | null = this.findWish(id);
    if (wish === null) {
      return;
    }
    const result: AcquireResult = await WishService.acquire(wish);
    promptAction.showToast({ message: result.message });
    if (result.ok) {
      bumpRefresh();
      this.reload();
    }
  }

  private openEdit(id: number): void {
    router.pushUrl({ url: 'pages/WishEdit', params: { id: id } }).catch(() => {});
  }

  private openAdd(): void {
    router.pushUrl({ url: 'pages/WishEdit', params: { id: 0 } }).catch(() => {});
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Row() {
          Column() {
            Text('心愿单')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(C_TEXT)
            Text(this.loaded ? '待实现 ' + this.wantedCount().toString() + ' 个心愿' : '加载中…')
              .fontSize(12)
              .fontColor(C_SUB)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Row() {
            Text('含已入手')
              .fontSize(12)
              .fontColor(C_SUB)
              .margin({ right: 6 })
            Toggle({ type: ToggleType.Switch, isOn: this.showAcquired })
              .selectedColor(C_SUCCESS)
              .onChange((isOn: boolean) => {
                this.showAcquired = isOn;
              })
          }
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 14, bottom: 10 })

        if (this.loading) {
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
              .color(C_BRAND)
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.wishes.length === 0) {
          EmptyView({
            icon: '♡',
            title: '心愿单是空的',
            subtitle: '把想收藏的好物记下来，随时追踪目标价位',
            actionText: '添加心愿',
            onAction: () => this.openAdd()
          })
        } else {
          List({ space: 10 }) {
            ForEach(this.wishes, (wish: WishItem) => {
              ListItem() {
                WishCard({
                  wish: wish,
                  categoryName: this.categoryName(wish.category),
                  onTap: (id: number) => this.openEdit(id),
                  onAcquire: (id: number) => { this.acquire(id); }
                })
              }
            }, (wish: WishItem) => wish.id.toString() + '_' + wish.name + '_' + wish.status.toString())
          }
          .padding({ left: 16, right: 16, top: 6, bottom: 96 })
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(C_BG)

      Button('＋')
        .fontSize(28)
        .fontColor(0xFFFFFF)
        .width(60)
        .height(60)
        .borderRadius(30)
        .backgroundColor(C_BRAND)
        .shadow({ radius: 12, color: '#33B0743B', offsetY: 4 })
        .margin({ right: 20, bottom: 24 })
        .onClick(() => this.openAdd())
    }
    .width('100%')
    .height('100%')
  }
}
