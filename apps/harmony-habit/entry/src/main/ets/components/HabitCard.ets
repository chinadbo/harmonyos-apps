import { HabitModel } from '../model/HabitModel';
import { COLOR_PALETTE, WEEKDAY_LABELS } from '../common/Constants';
import { DateUtils } from '../common/DateUtils';
import { StreakBadge } from './StreakBadge';

@Component
export struct HabitCard {
  @Prop habit: HabitModel;
  @Prop completed: boolean = false;
  @Prop streak: number = 0;
  onToggle?: (habitId: number) => void;
  onEdit?: (habitId: number) => void;
  onView?: (habitId: number) => void;

  private weekdaySummary(): string {
    let labels: string[] = [];
    for (let index = 0; index < 7; index++) {
      if (this.habit.targetDays.charAt(index) === '1') {
        labels.push(WEEKDAY_LABELS[index]);
      }
    }
    return labels.length === 7 ? '每天' : labels.join(' / ');
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Row({ space: 10 }) {
          Text(this.habit.icon)
            .fontSize(28)
          Column({ space: 4 }) {
            Text(this.habit.name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E2430')
            Text(this.weekdaySummary())
              .fontSize(12)
              .fontColor('#667085')
          }
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)

        StreakBadge({
          count: this.streak,
          color: COLOR_PALETTE[this.habit.colorIndex % COLOR_PALETTE.length]
        })
      }

      Row() {
        Column({ space: 2 }) {
          Text(this.completed ? '今天已完成' : `今日${DateUtils.isHabitScheduled(this.habit.targetDays, DateUtils.today()) ? '待打卡' : '休息日'}`)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.completed ? '#12B76A' : '#344054')
          if (this.habit.reminderTime) {
            Text(`提醒 ${this.habit.reminderTime}`)
              .fontSize(12)
              .fontColor('#98A2B3')
          }
        }
        .layoutWeight(1)

        Row({ space: 8 }) {
          Button('详情')
            .height(34)
            .fontSize(13)
            .backgroundColor('#F2F4F7')
            .fontColor('#344054')
            .onClick(() => {
              this.onView?.(this.habit.id);
            })
          Button('编辑')
            .height(34)
            .fontSize(13)
            .backgroundColor('#EFF4FF')
            .fontColor('#1D4ED8')
            .onClick(() => {
              this.onEdit?.(this.habit.id);
            })
          Button(this.completed ? '撤销' : '打卡')
            .height(34)
            .fontSize(13)
            .backgroundColor(this.completed ? '#FFE4E8' : COLOR_PALETTE[this.habit.colorIndex % COLOR_PALETTE.length])
            .fontColor(this.completed ? '#C01048' : '#FFFFFF')
            .onClick(() => {
              this.onToggle?.(this.habit.id);
            })
        }
      }
      .alignItems(VerticalAlign.Center)
    }
    .padding(16)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .shadow({ radius: 20, color: '#0F17280F', offsetX: 0, offsetY: 8 })
  }
}
