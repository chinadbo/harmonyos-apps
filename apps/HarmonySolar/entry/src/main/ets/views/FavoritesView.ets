import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { Favorite, FavoriteItem } from '../model/Favorite';
import { SolarTerm } from '../model/SolarTerm';
import { SolarTermData } from '../engine/SolarTermData';
import { DbHelper } from '../common/DbHelper';
import { Palette, Utils } from '../common/Constants';

@Component
export struct FavoritesView {
  onOpenTerm: (termId: string) => void = (termId: string) => {
  };
  @StorageLink('favVersion') @Watch('onFavChanged') favVersion: number = 0;
  @State items: FavoriteItem[] = [];
  @State loading: boolean = true;

  aboutToAppear(): void {
    this.loadFavorites();
  }

  private onFavChanged(): void {
    this.loadFavorites();
  }

  private async loadFavorites(): Promise<void> {
    try {
      const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      const favorites: Favorite[] = await DbHelper.getFavorites(context);
      const list: FavoriteItem[] = [];
      for (let i: number = 0; i < favorites.length; i++) {
        const term: SolarTerm | undefined = SolarTermData.getById(favorites[i].termId);
        if (term !== undefined) {
          const item: FavoriteItem = {
            termId: favorites[i].termId,
            savedAt: favorites[i].savedAt,
            name: term.name,
            en: term.en,
            season: term.season,
            date: term.date
          };
          list.push(item);
        }
      }
      this.items = list;
    } catch (err) {
      console.error('load favorites failed: ' + String(err));
    }
    this.loading = false;
  }

  private async removeItem(item: FavoriteItem): Promise<void> {
    try {
      const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      await DbHelper.removeFavorite(context, item.termId);
      AppStorage.setOrCreate('favVersion', Date.now());
      promptAction.showToast({ message: '已移除「' + item.name + '」', duration: 1500 });
    } catch (err) {
      promptAction.showToast({ message: '移除失败，请稍后重试', duration: 1800 });
    }
  }

  private savedText(savedAt: number): string {
    const d: Date = new Date(savedAt);
    return (d.getMonth() + 1) + '月' + d.getDate() + '日收藏';
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 3 }) {
          Text('我的收藏')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(Palette.INK)
          Text('收藏喜欢的节气，随时回看三候与民俗')
            .fontSize(10)
            .fontColor(Palette.INK_FAINT)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.items.length + ' 个')
          .fontSize(10)
          .fontColor(Palette.GOLD)
          .backgroundColor('#F6EDDD')
          .borderRadius(9)
          .padding({ left: 9, right: 9, top: 3, bottom: 3 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      if (this.loading) {
        Row() {
          LoadingProgress()
            .width(22)
            .height(22)
            .color(Palette.GOLD)
          Text('正在读取收藏…')
            .fontSize(11)
            .fontColor(Palette.INK_FAINT)
            .margin({ left: 8 })
        }
        .width('100%')
        .height(84)
        .justifyContent(FlexAlign.Center)
      } else if (this.items.length === 0) {
        Column({ space: 8 }) {
          Text('空')
            .fontSize(20)
            .fontColor(Palette.INK_FAINT)
            .width(48)
            .height(48)
            .textAlign(TextAlign.Center)
            .border({ width: 1, color: '#DCD1BE' })
            .borderRadius(24)
          Text('还没有收藏的节气')
            .fontSize(12)
            .fontColor(Palette.INK_SOFT)
          Text('在节气详情页点击「收藏此节气」即可收入此处')
            .fontSize(10)
            .fontColor(Palette.INK_FAINT)
        }
        .width('100%')
        .padding({ top: 24, bottom: 24 })
        .justifyContent(FlexAlign.Center)
        .border({ width: 1, color: '#E5DAC7', style: BorderStyle.Dashed })
        .borderRadius(18)
      } else {
        ForEach(this.items, (item: FavoriteItem) => {
          Row({ space: 10 }) {
            Row({ space: 12 }) {
              Column({ space: 1 }) {
                Text(item.season)
                  .fontSize(15)
                  .fontColor(Color.White)
                Text('SEASON')
                  .fontSize(5)
                  .letterSpacing(0.5)
                  .fontColor('#DDFFFFFF')
              }
              .width(42)
              .height(42)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(Utils.seasonColor(item.season))
              .borderRadius(10)

              Column({ space: 3 }) {
                Row({ space: 6 }) {
                  Text(item.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Palette.INK)
                  Text(item.en)
                    .fontSize(8)
                    .fontColor(Palette.INK_FAINT)
                    .maxLines(1)
                    .layoutWeight(1)
                }
                .width('100%')

                Text(Utils.momentFromIso(item.date) + ' 交节 · ' + this.savedText(item.savedAt))
                  .fontSize(10)
                  .fontColor(Palette.INK_FAINT)
                  .maxLines(1)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .layoutWeight(1)
            .onClick(() => {
              this.onOpenTerm(item.termId);
            })

            Text('移除')
              .fontSize(10)
              .fontColor(Palette.SEAL_RED)
              .border({ width: 1, color: '#E8C4BD' })
              .borderRadius(10)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .onClick(() => {
                this.removeItem(item);
              })
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Palette.CARD_BG)
          .borderRadius(16)
          .border({ width: 1, color: '#F2EBDD' })
        }, (item: FavoriteItem) => 'fav-' + item.termId)
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Palette.CARD_BG)
    .borderRadius(22)
    .border({ width: 1, color: '#F2EBDD' })
  }
}
