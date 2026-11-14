import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import { SolarTerm, emptySolarTerm } from '../model/SolarTerm';
import { SolarTermData } from '../engine/SolarTermData';
import { DbHelper } from '../common/DbHelper';
import { Palette, Utils } from '../common/Constants';

@Component
export struct TermDetailView {
  termId: string = '';
  onBack: () => void = () => {
  };
  @State term: SolarTerm = emptySolarTerm();
  @State favorite: boolean = false;

  aboutToAppear(): void {
    const term: SolarTerm | undefined = SolarTermData.getById(this.termId);
    if (term !== undefined) {
      this.term = term;
    }
    this.loadFavorite();
  }

  private async loadFavorite(): Promise<void> {
    try {
      const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      this.favorite = await DbHelper.isFavorite(context, this.termId);
    } catch (err) {
      console.error('load favorite failed: ' + String(err));
    }
  }

  private async toggleFavorite(): Promise<void> {
    try {
      const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      const next: boolean = await DbHelper.toggleFavorite(context, this.termId);
      this.favorite = next;
      AppStorage.setOrCreate('favVersion', Date.now());
      promptAction.showToast({
        message: next ? ('已收藏「' + this.term.name + '」') : ('已取消收藏「' + this.term.name + '」'),
        duration: 1500
      });
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      promptAction.showToast({ message: '操作失败：' + error.message, duration: 2000 });
    }
  }

  @Builder
  SectionTitle(title: string, en: string) {
    Row({ space: 8 }) {
      Row()
        .width(3)
        .height(16)
        .backgroundColor(Utils.seasonColor(this.term.season))
        .borderRadius(2)
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Palette.INK)
      Text(en)
        .fontSize(8)
        .letterSpacing(1.5)
        .fontColor(Palette.INK_FAINT)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  Chip(text: string, fg: string, bg: string) {
    Text(text)
      .fontSize(11)
      .fontColor(fg)
      .backgroundColor(bg)
      .borderRadius(8)
      .padding({ left: 9, right: 9, top: 4, bottom: 4 })
      .margin({ right: 6, bottom: 6 })
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 14 }) {
          Column({ space: 14 }) {
            Row() {
              Row({ space: 4 }) {
                Text('‹')
                  .fontSize(20)
                  .fontColor(Color.White)
                Text('返回')
                  .fontSize(12)
                  .fontColor(Color.White)
              }
              .padding({ left: 12, right: 14, top: 5, bottom: 5 })
              .backgroundColor('#33FFFFFF')
              .borderRadius(16)
              .onClick(() => {
                this.onBack();
              })

              Blank()

              Row({ space: 4 }) {
                Text(this.favorite ? '★' : '☆')
                  .fontSize(15)
                  .fontColor(Color.White)
                Text(this.favorite ? '已收藏' : '收藏')
                  .fontSize(12)
                  .fontColor(Color.White)
              }
              .padding({ left: 12, right: 14, top: 5, bottom: 5 })
              .backgroundColor('#33FFFFFF')
              .borderRadius(16)
              .onClick(() => {
                this.toggleFavorite();
              })
            }
            .width('100%')

            Row() {
              Column({ space: 6 }) {
                Text(this.term.season + '季 · ' + this.term.year + ' · 二十四节气')
                  .fontSize(10)
                  .letterSpacing(2)
                  .fontColor('#DDFFFFFF')
                Text(this.term.name)
                  .fontSize(42)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Color.White)
                  .letterSpacing(4)
                Text(this.term.en.toUpperCase())
                  .fontSize(10)
                  .letterSpacing(1.4)
                  .fontColor('#CCFFFFFF')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Column({ space: 2 }) {
                Text(Utils.pad2(new Date(this.term.date).getDate()))
                  .fontSize(28)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Color.White)
                Text((new Date(this.term.date).getMonth() + 1) + '月')
                  .fontSize(10)
                  .fontColor('#CCFFFFFF')
              }
              .width(56)
              .height(56)
              .justifyContent(FlexAlign.Center)
              .border({ width: 1.5, color: '#66FFFFFF' })
              .borderRadius(28)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            Row({ space: 8 }) {
              Text('交节 ' + Utils.termMoment(this.term))
                .fontSize(10)
                .fontColor(Color.White)
                .backgroundColor('#2AFFFFFF')
                .borderRadius(10)
                .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              Blank()
              Text(Utils.seasonEn(this.term.season))
                .fontSize(10)
                .fontColor('#CCFFFFFF')
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
          .borderRadius(26)
          .linearGradient({
            angle: 160,
            colors: [[Utils.seasonDeep(this.term.season), 0.0], [Utils.seasonColor(this.term.season), 1.0]]
          })

          Column({ space: 8 }) {
            Text(this.term.description)
              .fontSize(14)
              .lineHeight(25)
              .fontColor(Palette.INK)
              .width('100%')
            Row({ space: 6 }) {
              Text(this.term.season + '季')
                .fontSize(10)
                .fontColor(Utils.seasonColor(this.term.season))
                .backgroundColor(Utils.seasonSoft(this.term.season))
                .borderRadius(6)
                .padding({ left: 7, right: 7, top: 2, bottom: 2 })
              Text('二十四节气 · ' + this.term.year)
                .fontSize(10)
                .fontColor(Palette.INK_FAINT)
            }
            .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(18)
          .backgroundColor(Palette.CARD_BG)
          .borderRadius(20)
          .border({ width: 1, color: '#F2EBDD' })

          Column({ space: 12 }) {
            this.SectionTitle('三候', 'THREE PENTADS')
            ForEach(this.term.yuxiang, (item: string, index: number) => {
              Row({ space: 12 }) {
                Column({ space: 1 }) {
                  Text('' + (index + 1))
                    .fontSize(13)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Color.White)
                  Text(Utils.HOU_LABELS[index])
                    .fontSize(7)
                    .fontColor('#DDFFFFFF')
                }
                .width(38)
                .height(38)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Utils.seasonColor(this.term.season))
                .borderRadius(19)
                .opacity(index === 0 ? 1.0 : (index === 1 ? 0.8 : 0.62))

                Column({ space: 2 }) {
                  Text(item)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Palette.INK)
                  Text(Utils.HOU_LABELS[index] + ' · 第 ' + (index * 5 + 1) + '—' + (index * 5 + 5) + ' 日')
                    .fontSize(10)
                    .fontColor(Palette.INK_FAINT)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
            }, (item: string) => this.term.id + '-detail-hou-' + item)
            Text('古人将每节气分为三候，每候五日，以物候变化感知时令流转。')
              .fontSize(10)
              .lineHeight(18)
              .fontColor(Palette.INK_FAINT)
              .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(18)
          .backgroundColor(Palette.CARD_BG)
          .borderRadius(20)
          .border({ width: 1, color: '#F2EBDD' })

          Column({ space: 12 }) {
            this.SectionTitle('民俗', 'CUSTOMS')
            ForEach(this.term.customs, (item: string, index: number) => {
              Row({ space: 10 }) {
                Text('' + (index + 1 < 10 ? '0' + (index + 1) : '' + (index + 1)))
                  .fontSize(11)
                  .fontColor(Palette.GOLD)
                  .width(24)
                Text(item)
                  .fontSize(13)
                  .lineHeight(21)
                  .fontColor(Palette.INK)
                  .layoutWeight(1)
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)
            }, (item: string) => this.term.id + '-custom-' + item)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(18)
          .backgroundColor(Palette.CARD_BG)
          .borderRadius(20)
          .border({ width: 1, color: '#F2EBDD' })

          Column({ space: 12 }) {
            this.SectionTitle('养生', 'HEALTH TIPS')
            ForEach(this.term.healthTips, (item: string, index: number) => {
              Row({ space: 10 }) {
                Row()
                  .width(6)
                  .height(6)
                  .borderRadius(3)
                  .backgroundColor(Utils.seasonColor(this.term.season))
                  .margin({ top: 7 })
                Text(item)
                  .fontSize(13)
                  .lineHeight(21)
                  .fontColor(Palette.INK)
                  .layoutWeight(1)
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)
            }, (item: string) => this.term.id + '-health-' + item)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(18)
          .backgroundColor('#F5F8F1')
          .borderRadius(20)

          Column({ space: 8 }) {
            Row() {
              Text('诗词')
                .fontSize(10)
                .letterSpacing(2)
                .fontColor(Palette.GOLD)
              Blank()
              Text(this.term.poem.author)
                .fontSize(11)
                .fontColor(Palette.INK_SOFT)
            }
            .width('100%')
            Text('《' + this.term.poem.title + '》')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.INK)
            Text(this.term.poem.content)
              .fontSize(14)
              .lineHeight(26)
              .fontColor(Palette.INK_SOFT)
              .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(18)
          .backgroundColor('#F7F1E6')
          .borderRadius(20)

          Row({ space: 12 }) {
            Column({ space: 8 }) {
              Row({ space: 6 }) {
                Text('宜')
                  .fontSize(12)
                  .fontColor(Color.White)
                  .width(22)
                  .height(22)
                  .textAlign(TextAlign.Center)
                  .borderRadius(11)
                  .backgroundColor(Utils.seasonColor('春'))
                Text('SUIT')
                  .fontSize(8)
                  .letterSpacing(1)
                  .fontColor(Utils.seasonColor('春'))
              }
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.term.suitable, (item: string) => {
                  this.Chip(item, '#3F7550', '#EAF2E9')
                }, (item: string) => this.term.id + '-detail-suit-' + item)
              }
              .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .padding(12)
            .backgroundColor('#F5F8F1')
            .borderRadius(16)

            Column({ space: 8 }) {
              Row({ space: 6 }) {
                Text('忌')
                  .fontSize(12)
                  .fontColor(Color.White)
                  .width(22)
                  .height(22)
                  .textAlign(TextAlign.Center)
                  .borderRadius(11)
                  .backgroundColor(Palette.SEAL_RED)
                Text('AVOID')
                  .fontSize(8)
                  .letterSpacing(1)
                  .fontColor(Palette.SEAL_RED)
              }
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.term.taboos, (item: string) => {
                  this.Chip(item, '#8B3A31', '#FAECE8')
                }, (item: string) => this.term.id + '-detail-avoid-' + item)
              }
              .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .padding(12)
            .backgroundColor('#FBF1EE')
            .borderRadius(16)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)

          Text('数据为内置 2026—2027 年节气交接时刻，仅供文化参考。')
            .fontSize(10)
            .fontColor(Palette.INK_FAINT)
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ top: 4, bottom: 90 })
        }
        .padding({ left: 18, right: 18, top: 14 })
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      Row() {
        Row({ space: 6 }) {
          Text(this.favorite ? '★' : '☆')
            .fontSize(16)
            .fontColor(this.favorite ? Palette.GOLD : Color.White)
          Text(this.favorite ? '已收藏 · 点击取消' : '收藏此节气')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.favorite ? Palette.GOLD : Color.White)
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.favorite ? Palette.GOLD_SOFT : Utils.seasonColor(this.term.season))
        .borderRadius(24)
        .border({ width: this.favorite ? 1 : 0, color: Palette.GOLD })
        .onClick(() => {
          this.toggleFavorite();
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 8, bottom: 22 })
      .backgroundColor(Palette.PAGE_BG)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Palette.PAGE_BG)
  }
}
