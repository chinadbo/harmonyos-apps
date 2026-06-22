import router from '@ohos.router';
import { Goal } from '../model/GoalModel';
import { DateUtils } from '../utils/DateUtils';
import { RingProgress } from './RingProgress';

@Component
export struct GoalCard {
  @Prop goal: Goal;
  @Prop showActions: boolean = true;
  onCheckIn?: (goalId: number) => void;
  onEdit?: (goalId: number) => void;

  private statusText(): string {
    switch (this.goal.status) {
      case 'completed':
        return '已完成';
      case 'paused':
        return '已暂停';
      case 'not_started':
        return '未开始';
      default:
        return '进行中';
    }
  }

  private periodText(): string {
    switch (this.goal.period) {
      case 'week':
        return '周目标';
      case 'quarter':
        return '季度目标';
      case 'year':
        return '年度目标';
      default:
        return '月目标';
    }
  }

  build() {
    Row({ space: 16 }) {
      RingProgress({
        progress: this.goal.progress,
        size: 92,
        strokeWidth: 10,
        color: this.goal.color,
        backgroundColor: '#E7ECF5',
        label: '进度'
      })
      Column({ space: 10 }) {
        Row() {
          Text(this.goal.title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#18202A')
            .layoutWeight(1)
          Text(this.statusText())
            .fontSize(12)
            .fontColor(this.goal.color)
            .backgroundColor(`${this.goal.color}22`)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .borderRadius(12)
        }
        .width('100%')

        Text(this.goal.description.length > 0 ? this.goal.description : '专注今天的小步前进，让长期目标自然达成。')
          .fontSize(13)
          .fontColor('#5E6B7A')
          .maxLines(2)

        Row({ space: 8 }) {
          Text(this.periodText())
            .fontSize(12)
            .fontColor('#5E6B7A')
          Text(`· 截止 ${DateUtils.formatMonthDay(this.goal.deadline)}`)
            .fontSize(12)
            .fontColor('#5E6B7A')
          Text(`· KR ${this.goal.keyResultCount}`)
            .fontSize(12)
            .fontColor('#5E6B7A')
        }

        if (this.showActions) {
          Row({ space: 8 }) {
            Button('查看详情')
              .height(34)
              .fontSize(13)
              .backgroundColor(this.goal.color)
              .onClick(() => {
                AppStorage.SetOrCreate('selectedGoalId', this.goal.id);
                router.pushUrl({
                  url: 'pages/GoalDetailPage',
                  params: { goalId: this.goal.id }
                });
              })
            Button('今日回顾')
              .height(34)
              .fontSize(13)
              .backgroundColor('#EDF2FF')
              .fontColor('#4C7DFF')
              .onClick(() => {
                if (this.onCheckIn) {
                  this.onCheckIn(this.goal.id);
                }
              })
            Button('编辑')
              .height(34)
              .fontSize(13)
              .backgroundColor('#F3F5F8')
              .fontColor('#18202A')
              .onClick(() => {
                if (this.onEdit) {
                  this.onEdit(this.goal.id);
                }
              })
          }
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({ radius: 12, color: '#12000000', offsetX: 0, offsetY: 6 })
  }
}
