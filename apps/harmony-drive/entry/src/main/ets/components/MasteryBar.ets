/**
 * 章节掌握度条：名称 + 已答/正确统计 + 进度条按正确率着色
 */
import { ChapterMastery } from '../data/StatsHelper'

function emptyMastery(): ChapterMastery {
  return { name: '', answered: 0, correct: 0, rate: 0 }
}

@Component
export struct MasteryBar {
  @Prop mastery: ChapterMastery = emptyMastery()
  @Prop showRate: boolean = true

  private barColor(): string {
    if (this.mastery.rate >= 85) {
      return '#16A34A'
    }
    if (this.mastery.rate >= 60) {
      return '#F59E0B'
    }
    return '#DC2626'
  }

  build() {
    Column() {
      Row() {
        Text(this.mastery.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2937')
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if (this.showRate) {
          Text(`${this.mastery.answered} 题 · 正确率 ${this.mastery.rate}%`)
            .fontSize(12)
            .fontColor('#6B7280')
        } else {
          Text(`已做 ${this.mastery.answered} 题`)
            .fontSize(12)
            .fontColor('#6B7280')
        }
      }
      .width('100%')

      Progress({
        value: this.showRate ? this.mastery.rate : this.mastery.answered,
        total: 100,
        type: ProgressType.Linear
      })
        .style({ strokeWidth: 8 })
        .color(this.barColor())
        .width('100%')
        .margin({ top: 8 })
        .borderRadius(4)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }
}
