import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';
import { Element, loadElements, getCategoryColor } from '../model/Element';
import { dbHelper } from '../utils/db';

const DOMAIN: number = 0x0000;
const TAG: string = 'FavoritesPage';

interface DetailParams {
  atomicNumber: number;
}

@Entry
@Component
struct FavoritesPage {
  @State favorites: Element[] = [];
  @State loading: boolean = true;
  @State errorMessage: string = '';
  private elementsCache: Element[] = [];
  private initialized: boolean = false;
  private started: boolean = false;
  private removingNumbers: Set<number> = new Set<number>();

  aboutToAppear(): void {
    this.loadFavorites();
  }

  onPageShow(): void {
    if (this.started) {
      this.loadFavorites();
    }
    this.started = true;
  }

  private async loadFavorites(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      if (!this.initialized) {
        await dbHelper.init(context);
        this.elementsCache = await loadElements(context);
        this.initialized = true;
      }
      const atomicNumbers: number[] = await dbHelper.getFavoriteAtomicNumbers();
      const list: Element[] = [];
      for (const atomicNumber of atomicNumbers) {
        const element: Element | null = this.findById(atomicNumber);
        if (element !== null) {
          list.push(element);
        }
      }
      this.favorites = list;
      this.errorMessage = '';
    } catch (err) {
      this.errorMessage = '收藏数据加载失败，请重试';
      hilog.error(DOMAIN, TAG, 'load favorites failed: %{public}s', JSON.stringify(err));
    } finally {
      this.loading = false;
    }
  }

  private findById(atomicNumber: number): Element | null {
    for (const element of this.elementsCache) {
      if (element.atomicNumber === atomicNumber) {
        return element;
      }
    }
    return null;
  }

  private async removeFavorite(element: Element): Promise<void> {
    if (this.removingNumbers.has(element.atomicNumber)) {
      return;
    }
    this.removingNumbers.add(element.atomicNumber);
    try {
      await dbHelper.removeFavorite(element.atomicNumber);
      const remaining: Element[] = [];
      for (const item of this.favorites) {
        if (item.atomicNumber !== element.atomicNumber) {
          remaining.push(item);
        }
      }
      this.favorites = remaining;
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'remove favorite failed: %{public}s', JSON.stringify(err));
    } finally {
      this.removingNumbers.delete(element.atomicNumber);
    }
  }

  private openDetail(element: Element): void {
    const params: DetailParams = { atomicNumber: element.atomicNumber };
    router.pushUrl({ url: 'pages/ElementDetail', params: params }).catch((err: Error) => {
      hilog.error(DOMAIN, TAG, 'open detail failed: %{public}s', err.message);
    });
  }

  build() {
    Column() {
      this.Header()
      if (this.loading) {
        Column({ space: 8 }) {
          LoadingProgress()
            .width(36)
            .height(36)
            .color('#0A59F7')
          Text('正在加载收藏')
            .fontSize(13)
            .fontColor('#99000000')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.errorMessage.length > 0) {
        Column({ space: 12 }) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#99000000')
          Button('重新加载', { type: ButtonType.Normal })
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#0A59F7')
            .borderRadius(10)
            .onClick(() => {
              this.loading = true;
              this.loadFavorites();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.favorites.length === 0) {
        this.EmptyState()
      } else {
        List({ space: 10 }) {
          ForEach(this.favorites, (element: Element) => {
            ListItem() {
              this.FavoriteItem(element)
            }
            .swipeAction({ end: this.DeleteAction.bind(this, element) })
          }, (element: Element) => element.atomicNumber.toString())
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 14, right: 14, top: 4, bottom: 16 })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }

  @Builder
  Header() {
    Row() {
      Text('返回')
        .fontSize(14)
        .fontColor('#0A59F7')
        .padding({ left: 4, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          router.back();
        })
      Column({ space: 2 }) {
        Text('我的收藏')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E6000000')
        if (this.favorites.length > 0) {
          Text('共 ' + this.favorites.length.toString() + ' 个元素 · 左滑可取消收藏')
            .fontSize(11)
            .fontColor('#99000000')
        }
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
    }
    .width('100%')
    .padding({ left: 10, right: 14, top: 10, bottom: 8 })
  }

  @Builder
  FavoriteItem(element: Element) {
    Row({ space: 12 }) {
      Column() {
        Text(element.atomicNumber.toString())
          .fontSize(10)
          .fontColor('#B3000000')
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 6 })
        Text(element.symbol)
          .fontSize(element.symbol.length > 2 ? 15 : 19)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E6000000')
          .width('100%')
          .textAlign(TextAlign.Center)
          .maxLines(1)
      }
      .width(52)
      .height(52)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(getCategoryColor(element.category))
      .borderRadius(10)
      .border({ width: 0.5, color: '#26000000' })

      Column({ space: 3 }) {
        Text(element.nameZh + ' · ' + element.nameEn)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#E6000000')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text('第 ' + element.period.toString() + ' 周期 · ' +
          element.atomicMass.toString() + ' u')
          .fontSize(12)
          .fontColor('#99000000')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('取消收藏')
        .fontSize(12)
        .fontColor('#E84026')
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor('#FDECE9')
        .borderRadius(12)
        .onClick((event: ClickEvent) => {
          event.stopPropagation();
          this.removeFavorite(element);
        })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .onClick(() => {
      this.openDetail(element);
    })
  }

  @Builder
  DeleteAction(element: Element) {
    Row() {
      Text('取消收藏')
        .fontSize(13)
        .fontColor('#FFFFFF')
      }
    .width(88)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#E84026')
    .borderRadius(12)
    .margin({ left: 8 })
    .onClick(() => {
      this.removeFavorite(element);
    })
  }

  @Builder
  EmptyState() {
    Column({ space: 14 }) {
      Text('暂无收藏')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#66000000')
      Text('在元素详情页点击「收藏该元素」，即可在这里快速查看')
        .fontSize(13)
        .fontColor('#99000000')
        .textAlign(TextAlign.Center)
        .lineHeight(20)
        .padding({ left: 32, right: 32 })
      Button('前往元素周期表', { type: ButtonType.Normal })
        .fontSize(14)
        .fontColor('#0A59F7')
        .backgroundColor('#EAF1FE')
        .borderRadius(12)
        .height(40)
        .padding({ left: 20, right: 20 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}
