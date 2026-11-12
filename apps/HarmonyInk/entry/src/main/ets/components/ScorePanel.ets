import { AppTheme } from '../common/Theme';
import { Constants } from '../common/Constants';
import { ProgressRing } from './ProgressRing';

/** 评分结果面板：总分 + 三维得分 + 再练/下一字 */
@Component
export struct ScorePanel {
  @Prop score: number = 0;
  @Prop charText: string = '';
  @Prop pinyin: string = '';
  @Prop orderRate: number = 0;
  @Prop directionRate: number = 0;
  @Prop coverageRate: number = 0;
  @Prop mistakes: number = 0;
  @Prop durationSec: number = 0;
  @Prop previousBest: number = 0;
  onRetry: () => void = () => {
  };
  onNext: () => void = () => {
  };
  onBack: () => void = () => {
  };

  private isNewRecord(): boolean {
    return this.score > this.previousBest && this.previousBest >= 0 && this.score > 0;
  }

  @Builder
  dimensionRow(title: string, value: number, color: string) {
    Row({ space: 10 }) {
      Text(title)
        .fontSize(13)
        .fontColor(AppTheme.INK_LIGHT)
        .width(48)
      Progress({ value: value, total: 100, type: ProgressType.Linear })
        .height(7)
        .layoutWeight(1)
        .color(color)
        .backgroundColor(AppTheme.CARD_ALT)
      Text(`${Math.round(value)}%`)
        .fontSize(12)
        .fontColor(AppTheme.INK_FAINT)
        .width(42)
        .textAlign(TextAlign.End)
    }
    .width('100%')
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#8C1F1B16')

      Column({ space: 16 }) {
        Row({ space: 16 }) {
          ProgressRing({ percent: this.score, size: 92, ringWidth: 9, label: '总分' })
          Column({ space: 6 }) {
            Text(this.isNewRecord() ? '刷新最佳 · 练习完成' : '练习完成')
              .fontSize(13)
              .fontColor(this.isNewRecord() ? AppTheme.GOLD : AppTheme.INK_FAINT)
            Row({ space: 10 }) {
              Text(this.charText)
                .fontSize(42)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppTheme.INK)
              Text(this.pinyin)
                .fontSize(16)
                .fontColor(AppTheme.INK_LIGHT)
            }
            Text(Constants.scoreLabel(this.score))
              .fontSize(15)
              .fontColor(AppTheme.scoreColor(this.score))
              .fontWeight(FontWeight.Medium)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')

        Column({ space: 10 }) {
          this.dimensionRow('顺序', this.orderRate, AppTheme.ACCENT)
          this.dimensionRow('方向', this.directionRate, AppTheme.GOLD)
          this.dimensionRow('覆盖', this.coverageRate, AppTheme.GREEN)
        }
        .width('100%')
        .padding(14)
        .backgroundColor(AppTheme.CARD_ALT)
        .borderRadius(14)

        Row({ space: 22 }) {
          Column({ space: 3 }) {
            Text(`${this.durationSec} 秒`)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(AppTheme.INK)
            Text('用时')
              .fontSize(11)
              .fontColor(AppTheme.INK_FAINT)
          }
          Column({ space: 3 }) {
            Text(`${this.mistakes}`)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.mistakes === 0 ? AppTheme.GREEN : AppTheme.ACCENT)
            Text('重试')
              .fontSize(11)
              .fontColor(AppTheme.INK_FAINT)
          }
          Column({ space: 3 }) {
            Text(this.previousBest > 0 ? `${this.previousBest}` : '—')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(AppTheme.INK)
            Text('此前最佳')
              .fontSize(11)
              .fontColor(AppTheme.INK_FAINT)
          }
        }
        .width('100%')

        Row({ space: 12 }) {
          Button('再练一次')
            .layoutWeight(1)
            .type(ButtonType.Capsule)
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor(AppTheme.ACCENT)
            .onClick(() => {
              this.onRetry();
            })
          Button('下一字')
            .layoutWeight(1)
            .type(ButtonType.Capsule)
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor(AppTheme.INK)
            .onClick(() => {
              this.onNext();
            })
        }
        .width('100%')

        Text('返回上一页')
          .fontSize(13)
          .fontColor(AppTheme.INK_FAINT)
          .padding(4)
          .onClick(() => {
            this.onBack();
          })
      }
      .width('88%')
      .constraintSize({ maxWidth: 420 })
      .padding(24)
      .backgroundColor(AppTheme.CARD)
      .borderRadius(24)
      .shadow({ radius: 24, color: '#33000000', offsetY: 8 })
    }
    .width('100%')
    .height('100%')
  }
}
