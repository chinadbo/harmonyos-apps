/**
 * CollectionTab.ets — 藏品库 Tab（搜索、筛选、网格/列表切换、新增入口）
 */
import router from '@ohos.router';
import { CollectItem } from '../model/CollectItem';
import { Category } from '../model/Category';
import { CategoryDao, Db } from '../model/Db';
import { ItemService } from '../service/ItemService';
import { ItemCard } from '../components/ItemCard';
import { EmptyView } from '../components/EmptyView';
import { FilterSheet } from '../components/FilterSheet';
import { Prefs } from '../common/Prefs';
import {
  ItemFilter, defaultFilter, SORT_CREATED, hasActiveFilter,
  C_TEXT, C_SUB, C_CARD, C_LINE, C_BG, C_BRAND
} from '../common/Constants';

@Component
export struct CollectionTab {
  @StorageProp('viewMode') viewMode: string = 'grid';
  @StorageProp('sortMode') @Watch('onSortModeChange') sortMode: string = SORT_CREATED;
  @StorageProp('refreshTick') @Watch('onRefresh') refreshTick: number = 0;

  @State items: CollectItem[] = [];
  @State categories: Category[] = [];
  @State filter: ItemFilter = defaultFilter();
  @State keyword: string = '';
  @State showFilter: boolean = false;
  @State loading: boolean = true;
  @State loaded: boolean = false;
  @State reqSeq: number = 0;

  aboutToAppear(): void {
    this.onSortModeChange();
  }

  onRefresh(): void {
    this.reload();
  }

  onSortModeChange(): void {
    this.filter.sort = this.sortMode;
    this.reload();
  }

  private async ensureReady(): Promise<void> {
    if (Db.isReady()) {
      return;
    }
    await Db.waitReady(4000);
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
    this.loading = this.items.length === 0;
    try {
      await this.ensureReady();
      await this.loadCategories();
      const list: CollectItem[] = await ItemService.list(this.filter);
      if (seq === this.reqSeq) {
        this.items = list;
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

  private categoryIcon(key: string): string {
    for (let i = 0; i < this.categories.length; i++) {
      if (this.categories[i].key === key) {
        return this.categories[i].icon;
      }
    }
    return '◈';
  }

  private onKeywordChange(value: string): void {
    this.keyword = value;
    this.filter.keyword = value;
    this.reload();
  }

  private onApplyFilter(result: ItemFilter): void {
    this.filter = result;
    this.keyword = result.keyword;
    AppStorage.setOrCreate<string>('sortMode', result.sort);
    Prefs.putString('sortMode', result.sort);
    this.reload();
  }

  private toggleViewMode(): void {
    const next: string = this.viewMode === 'grid' ? 'list' : 'grid';
    AppStorage.setOrCreate<string>('viewMode', next);
    Prefs.putString('viewMode', next);
  }

  private openDetail(id: number): void {
    router.pushUrl({ url: 'pages/ItemDetail', params: { id: id } }).catch(() => {});
  }

  private openAdd(): void {
    router.pushUrl({ url: 'pages/ItemEdit', params: { id: 0 } }).catch(() => {});
  }

  @Builder
  TopBar() {
    Column() {
      Row() {
        Column() {
          Text('藏品库')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(C_TEXT)
          Text('共 ' + this.items.length.toString() + ' 件藏品')
            .fontSize(12)
            .fontColor(C_SUB)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.viewMode === 'grid' ? '☰' : '▦')
          .fontSize(22)
          .fontColor(C_TEXT)
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .borderRadius(20)
          .backgroundColor(C_CARD)
          .border({ width: 1, color: C_LINE })
          .onClick(() => this.toggleViewMode())
      }
      .width('100%')

      Row() {
        Row() {
          Text('⌕')
            .fontSize(18)
            .fontColor(C_SUB)
            .margin({ left: 12, right: 6 })
          TextInput({ placeholder: '搜索名称 / 标签 / 编号', text: this.keyword })
            .layoutWeight(1)
            .height(44)
            .fontSize(14)
            .backgroundColor(Color.Transparent)
            .onChange((value: string) => this.onKeywordChange(value))
        }
        .layoutWeight(1)
        .height(44)
        .backgroundColor(C_CARD)
        .borderRadius(22)
        .border({ width: 1, color: C_LINE })
        .alignItems(VerticalAlign.Center)

        Stack({ alignContent: Alignment.TopEnd }) {
          Row() {
            Text('筛选')
              .fontSize(14)
              .fontColor(hasActiveFilter(this.filter) ? 0xFFFFFF : C_TEXT)
          }
          .height(44)
          .padding({ left: 18, right: 18 })
          .backgroundColor(hasActiveFilter(this.filter) ? C_BRAND : C_CARD)
          .borderRadius(22)
          .border({ width: 1, color: hasActiveFilter(this.filter) ? C_BRAND : C_LINE })
          .alignItems(VerticalAlign.Center)
          .onClick(() => this.showFilter = true)

          if (hasActiveFilter(this.filter)) {
            Column()
              .width(8)
              .height(8)
              .borderRadius(4)
              .backgroundColor('#E8C87A')
              .margin({ top: 6, right: 6 })
          }
        }
        .margin({ left: 10 })
      }
      .width('100%')
      .margin({ top: 14 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 8 })
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        this.TopBar()

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
        } else if (this.items.length === 0) {
          EmptyView({
            icon: '□',
            title: hasActiveFilter(this.filter) ? '没有符合条件的藏品' : '还没有藏品',
            subtitle: hasActiveFilter(this.filter) ? '换个筛选条件试试' : '点击右下角 ＋ 添加你的第一件收藏',
            actionText: hasActiveFilter(this.filter) ? '清空筛选' : '添加藏品',
            onAction: () => {
              if (hasActiveFilter(this.filter)) {
                this.onApplyFilter(defaultFilter());
              } else {
                this.openAdd();
              }
            }
          })
        } else if (this.viewMode === 'grid') {
          Grid() {
            ForEach(this.items, (item: CollectItem) => {
              GridItem() {
                ItemCard({
                  item: item,
                  categoryName: this.categoryName(item.category),
                  categoryIcon: this.categoryIcon(item.category),
                  mode: 'grid',
                  onTap: (id: number) => this.openDetail(id)
                })
              }
            }, (item: CollectItem) => item.id.toString() + '_' + item.name + '_' + item.estValue.toString() + '_' + item.imageUri + '_' + item.serial)
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .padding({ left: 16, right: 16, top: 6, bottom: 96 })
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        } else {
          List({ space: 10 }) {
            ForEach(this.items, (item: CollectItem) => {
              ListItem() {
                ItemCard({
                  item: item,
                  categoryName: this.categoryName(item.category),
                  categoryIcon: this.categoryIcon(item.category),
                  mode: 'list',
                  onTap: (id: number) => this.openDetail(id)
                })
              }
            }, (item: CollectItem) => item.id.toString() + '_' + item.name + '_' + item.estValue.toString() + '_' + item.imageUri + '_' + item.serial)
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

      FilterSheet({
        show: $showFilter,
        filter: this.filter,
        categories: this.categories,
        onApply: (result: ItemFilter) => this.onApplyFilter(result)
      })
    }
    .width('100%')
    .height('100%')
  }
}
