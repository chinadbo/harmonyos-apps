/**
 * ItemDetail.ets — 藏品详情页（大图 + 全字段 + 编辑 / 删除）
 */
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { CollectItem } from '../model/CollectItem';
import { Category } from '../model/Category';
import { CategoryDao, Db } from '../model/Db';
import { ItemService } from '../service/ItemService';
import { ImageStore } from '../common/ImageStore';
import { Format } from '../common/Format';
import { PageHeader } from '../components/PageHeader';
import { EmptyView } from '../components/EmptyView';
import { bumpRefresh, categoryColor, conditionColor, C_BG, C_CARD, C_LINE, C_TEXT, C_SUB, C_BRAND, C_DANGER, C_SUCCESS } from '../common/Constants';

interface DetailParams {
  id: number;
}

@Entry
@Component
struct ItemDetail {
  @State item: CollectItem = new CollectItem();
  @State categoryName: string = '';
  @State categoryIcon: string = '◈';
  @State loaded: boolean = false;
  @State notFound: boolean = false;
  @State itemId: number = 0;
  @State deleting: boolean = false;

  aboutToAppear(): void {
    this.itemId = this.readId();
    this.load();
  }

  onPageShow(): void {
    if (this.itemId > 0) {
      this.load();
    }
  }

  private readId(): number {
    try {
      const params = router.getParams() as Record<string, Object>;
      const id = params['id'];
      if (typeof id === 'number') {
        return id;
      }
      return 0;
    } catch (err) {
      return 0;
    }
  }

  private async load(): Promise<void> {
    if (this.itemId <= 0) {
      this.notFound = true;
      this.loaded = true;
      return;
    }
    try {
      if (!Db.isReady()) {
        await Db.waitReady(4000);
      }
      const item: CollectItem | null = await ItemService.detail(this.itemId);
      if (item === null) {
        this.notFound = true;
        this.loaded = true;
        return;
      }
      this.item = item;
      const category: Category | null = await CategoryDao.getByKey(item.category);
      if (category !== null) {
        this.categoryName = category.name;
        this.categoryIcon = category.icon;
      } else {
        this.categoryName = '其他';
      }
      this.loaded = true;
    } catch (err) {
      this.notFound = true;
      this.loaded = true;
    }
  }

  private edit(): void {
    router.pushUrl({ url: 'pages/ItemEdit', params: { id: this.itemId } }).catch(() => {});
  }

  private remove(): void {
    if (this.deleting) {
      return;
    }
    this.deleting = true;
    promptAction.showDialog({
      title: '删除藏品',
      message: '确定删除「' + this.item.name + '」吗？删除后无法恢复。',
      buttons: [
        { text: '取消', color: '#8A8175' },
        { text: '删除', color: C_DANGER }
      ]
    }).then(async (res) => {
      if (res.index !== 1) {
        this.deleting = false;
        return;
      }
      const ok: boolean = await ItemService.remove(this.itemId);
      this.deleting = false;
      if (ok) {
        bumpRefresh();
        promptAction.showToast({ message: '已删除' });
        router.back();
      } else {
        promptAction.showToast({ message: '删除失败' });
      }
    });
  }

  private gainColor(): string {
    const gain: number = this.item.estValue - this.item.acquirePrice;
    if (gain > 0) {
      return C_SUCCESS;
    }
    if (gain < 0) {
      return C_DANGER;
    }
    return C_SUB;
  }

  private gainText(): string {
    const gain: number = this.item.estValue - this.item.acquirePrice;
    const sign: string = gain > 0 ? '+' : '';
    return sign + Format.money(gain);
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor(C_SUB)
        .width(80)
      Text(value.length > 0 ? value : '—')
        .fontSize(14)
        .fontColor(C_TEXT)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding({ top: 11, bottom: 11 })
  }

  @Builder
  Banner() {
    if (this.item.imageUri.length > 0) {
      Image(ImageStore.toDisplaySrc(this.item.imageUri))
        .width('100%')
        .height(260)
        .objectFit(ImageFit.Cover)
        .borderRadius(18)
        .backgroundColor(C_LINE)
    } else {
      Stack() {
        Column()
          .width('100%')
          .height(200)
          .borderRadius(18)
          .backgroundColor(categoryColor(this.item.category) + '1A')
        Column() {
          Text(this.categoryIcon)
            .fontSize(64)
            .fontColor(categoryColor(this.item.category) + '99')
          Text('暂无图片')
            .fontSize(12)
            .fontColor(C_SUB)
            .margin({ top: 10 })
        }
      }
      .width('100%')
    }
  }

  @Builder
  ValueCard() {
    Row() {
      Column() {
        Text('当前估值')
          .fontSize(11)
          .fontColor(C_SUB)
        Text(Format.money(this.item.estValue))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(C_BRAND)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Text('入手价格')
          .fontSize(11)
          .fontColor(C_SUB)
        Text(Format.money(this.item.acquirePrice))
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(C_TEXT)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.End)

      if (this.item.acquirePrice > 0) {
        Text(this.gainText())
          .fontSize(12)
          .fontColor(0xFFFFFF)
          .backgroundColor(this.gainColor())
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .borderRadius(10)
          .margin({ left: 12 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(C_CARD)
    .borderRadius(18)
    .border({ width: 1, color: C_LINE })
    .alignItems(VerticalAlign.Center)
  }

  build() {
    Column() {
      PageHeader({
        title: '藏品详情',
        subtitle: this.categoryName,
        showBack: true,
        actionText: this.loaded && !this.notFound ? '编辑' : '',
        onAction: () => this.edit(),
        onBack: () => router.back()
      })

      if (!this.loaded) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(C_BRAND)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.notFound) {
        EmptyView({
          icon: '✕',
          title: '藏品不存在',
          subtitle: '可能已被删除',
          actionText: '返回',
          onAction: () => router.back()
        })
      } else {
        Scroll() {
          Column({ space: 14 }) {
            this.Banner()

            Column() {
              Text(this.item.name)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(C_TEXT)
                .width('100%')
              Row() {
                Text(this.categoryName)
                  .fontSize(11)
                  .fontColor(0xFFFFFF)
                  .backgroundColor(categoryColor(this.item.category))
                  .padding({ left: 9, right: 9, top: 3, bottom: 3 })
                  .borderRadius(8)
                Text(this.item.condition)
                  .fontSize(11)
                  .fontColor(conditionColor(this.item.condition))
                  .backgroundColor(conditionColor(this.item.condition) + '1A')
                  .padding({ left: 9, right: 9, top: 3, bottom: 3 })
                  .borderRadius(8)
                  .margin({ left: 8 })
              }
              .width('100%')
              .margin({ top: 10 })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding(16)
            .backgroundColor(C_CARD)
            .borderRadius(18)
            .border({ width: 1, color: C_LINE })

            this.ValueCard()

            Column() {
              this.InfoRow('入手日期', this.item.acquireDate)
              Divider().color(C_LINE)
              this.InfoRow('成色', this.item.condition)
              Divider().color(C_LINE)
              this.InfoRow('编号 / 版本', this.item.serial)
              Divider().color(C_LINE)
              this.InfoRow('添加时间', Format.timestampToStr(this.item.createdAt))
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 4, bottom: 4 })
            .backgroundColor(C_CARD)
            .borderRadius(18)
            .border({ width: 1, color: C_LINE })

            if (this.item.tagList().length > 0) {
              Column() {
                Text('标签')
                  .fontSize(12)
                  .fontColor(C_SUB)
                  .width('100%')
                Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
                  ForEach(this.item.tagList(), (tag: string) => {
                    Text('#' + tag)
                      .fontSize(12)
                      .fontColor(C_BRAND)
                      .backgroundColor(C_BRAND + '1A')
                      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                      .borderRadius(12)
                      .margin({ right: 8, top: 8 })
                  }, (tag: string) => tag)
                }
                .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor(C_CARD)
              .borderRadius(18)
              .border({ width: 1, color: C_LINE })
            }

            if (this.item.remark.length > 0) {
              Column() {
                Text('备注')
                  .fontSize(12)
                  .fontColor(C_SUB)
                  .width('100%')
                Text(this.item.remark)
                  .fontSize(14)
                  .fontColor(C_TEXT)
                  .lineHeight(21)
                  .width('100%')
                  .margin({ top: 8 })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(C_CARD)
              .borderRadius(18)
              .border({ width: 1, color: C_LINE })
            }

            Button(this.deleting ? '删除中…' : '删除藏品')
              .width('100%')
              .height(46)
              .fontSize(15)
              .fontColor(C_DANGER)
              .backgroundColor('#1AB34A3C')
              .borderRadius(23)
              .margin({ top: 4 })
              .onClick(() => this.remove())

            Column().height(20)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 6 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(C_BG)
  }
}
