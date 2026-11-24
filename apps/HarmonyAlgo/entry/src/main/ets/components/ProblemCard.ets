import { Problem } from '../model/Problem';
import { STATUS_DONE, STATUS_MASTERED } from '../model/Record';
import { Theme } from '../common/Theme';
import { DiffBadge } from './DiffBadge';

/** 题目列表项卡片 */
@Component
export struct ProblemCard {
  @Prop problem: Problem = new Problem(0, '', '', 1, '', '', '', '', '');
  @Prop status: number = 0;
  @Prop favorite: boolean = false;
  @Prop wrongCount: number = 0;
  onTap: () => void = () => {
  };

  build() {
    Column() {
      Row() {
        Text(this.problem.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.text)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if (this.favorite) {
          Text('★')
            .fontSize(16)
            .fontColor(Theme.star)
            .margin({ left: 6 })
        }
      }
      .width('100%')

      Row() {
        DiffBadge({ difficulty: this.problem.difficulty })
        Text(this.problem.category)
          .fontSize(12)
          .fontColor(Theme.subText)
          .margin({ left: 8 })
        if (this.wrongCount > 0) {
          Text('错 ' + this.wrongCount + ' 次')
            .fontSize(11)
            .fontColor(Theme.danger)
            .margin({ left: 8 })
        }
        Blank()
        if (this.status === STATUS_MASTERED) {
          Text('已掌握')
            .fontSize(11)
            .fontColor(Theme.success)
            .backgroundColor('#E7F9EF')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(6)
        } else if (this.status === STATUS_DONE) {
          Text('已做')
            .fontSize(11)
            .fontColor(Theme.warning)
            .backgroundColor('#FFF3E0')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(6)
        }
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .alignItems(HorizontalAlign.Start)
    .padding(14)
    .width('100%')
    .backgroundColor(Theme.card)
    .borderRadius(14)
    .onClick(() => {
      this.onTap();
    })
  }
}
