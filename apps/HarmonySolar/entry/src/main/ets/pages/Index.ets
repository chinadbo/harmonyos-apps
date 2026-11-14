import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import { SolarTermData } from '../engine/SolarTermData';
import { ReminderService } from '../common/ReminderService';
import { Palette } from '../common/Constants';
import { HomeView } from '../views/HomeView';
import { TimelineView } from '../views/TimelineView';
import { LunarConvertView } from '../views/LunarConvertView';
import { RemindView } from '../views/RemindView';
import { FavoritesView } from '../views/FavoritesView';
import { TermDetailView } from '../views/TermDetailView';

@Entry
@Component
struct Index {
  @State ready: boolean = false;
  @State currentIndex: number = 0;
  @State detailTermId: string = '';
  private controller: TabsController = new TabsController();

  aboutToAppear(): void {
    AppStorage.setOrCreate('favVersion', 0);
    this.bootstrap();
  }

  private async bootstrap(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    try {
      await SolarTermData.init(context);
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      console.error('init solar term data failed: ' + error.message);
    }
    this.ready = true;
    ReminderService.notifyDue(context).catch((err: BusinessError) => {
      console.warn('notify due failed: ' + err.message);
    });
  }

  private openTerm(termId: string): void {
    this.detailTermId = termId;
  }

  private closeTerm(): void {
    this.detailTermId = '';
  }

  private openTimeline(): void {
    this.currentIndex = 1;
    this.controller.changeIndex(1);
  }

  @Builder
  TabBar(index: number, title: string, en: string) {
    Column({ space: 3 }) {
      Text(en)
        .fontSize(7)
        .letterSpacing(1.2)
        .fontColor(this.currentIndex === index ? Palette.GOLD : Palette.INK_FAINT)
      Text(title)
        .fontSize(13)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? Palette.INK : Palette.INK_SOFT)
      Row()
        .width(this.currentIndex === index ? 16 : 4)
        .height(2)
        .borderRadius(1)
        .backgroundColor(this.currentIndex === index ? Palette.GOLD : '#DCD1BE')
    }
    .width('100%')
    .height(58)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ProfileContent() {
    Scroll() {
      Column({ space: 14 }) {
        Row() {
          Column({ space: 4 }) {
            Text('我的')
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.INK)
            Text('收藏 · 提醒 · 关于')
              .fontSize(10)
              .letterSpacing(1)
              .fontColor(Palette.INK_FAINT)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text('我')
            .fontSize(18)
            .fontColor(Palette.SEAL_RED)
            .width(40)
            .height(40)
            .textAlign(TextAlign.Center)
            .border({ width: 2, color: Palette.SEAL_RED })
            .borderRadius(6)
        }
        .width('100%')
        .padding({ top: 4, bottom: 2 })

        RemindView()

        FavoritesView({
          onOpenTerm: (termId: string) => {
            this.openTerm(termId);
          }
        })

        Column({ space: 8 }) {
          Row({ space: 8 }) {
            Text('HarmonySolar')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.INK)
            Text('v1.0.0')
              .fontSize(9)
              .fontColor(Palette.INK_FAINT)
            Blank()
            Text('二十四节气')
              .fontSize(9)
              .letterSpacing(1)
              .fontColor(Palette.GOLD)
          }
          .width('100%')
          Divider().color('#EFE5D3')
          Text('内置 2026—2027 年二十四节气数据，纯 ArkTS 农历算法，RDB 本地收藏，Preferences 记录提醒开关。完全离线运行，不收集任何个人信息。')
            .fontSize(10)
            .lineHeight(18)
            .fontColor(Palette.INK_SOFT)
            .width('100%')
          Text('节气时刻与民俗内容仅供文化参考。')
            .fontSize(9)
            .fontColor(Palette.INK_FAINT)
            .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(16)
        .backgroundColor('#F7F1E6')
        .borderRadius(18)

        Row()
          .width('100%')
          .height(80)
      }
      .padding({ left: 18, right: 18, top: 14 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(Palette.PAGE_BG)
  }

  build() {
    Stack() {
      if (!this.ready) {
        Column({ space: 14 }) {
          LoadingProgress()
            .width(36)
            .height(36)
            .color(Palette.GOLD)
          Text('正在载入二十四节气…')
            .fontSize(12)
            .fontColor(Palette.INK_SOFT)
          Text('HarmonySolar')
            .fontSize(10)
            .letterSpacing(3)
            .fontColor(Palette.INK_FAINT)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Palette.PAGE_BG)
      } else {
        Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
          TabContent() {
            HomeView({
              onOpenTerm: (termId: string) => {
                this.openTerm(termId);
              },
              onOpenTimeline: () => {
                this.openTimeline();
              }
            })
          }
          .tabBar(this.TabBar(0, '今日', 'TODAY'))

          TabContent() {
            TimelineView({
              onOpenTerm: (termId: string) => {
                this.openTerm(termId);
              }
            })
          }
          .tabBar(this.TabBar(1, '节气轴', 'TIMELINE'))

          TabContent() {
            LunarConvertView()
          }
          .tabBar(this.TabBar(2, '换算', 'LUNAR'))

          TabContent() {
            this.ProfileContent()
          }
          .tabBar(this.TabBar(3, '我的', 'MINE'))
        }
        .width('100%')
        .height('100%')
        .barHeight(58)
        .barBackgroundColor(Palette.PAGE_BG)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
      }

      if (this.detailTermId !== '') {
        TermDetailView({
          termId: this.detailTermId,
          onBack: () => {
            this.closeTerm();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Palette.PAGE_BG)
  }
}
