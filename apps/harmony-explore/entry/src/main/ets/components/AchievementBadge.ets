import { AchievementModel } from '../model/AchievementModel'
import { DateUtils } from '../utils/DateUtils'

@Component
export struct AchievementBadge {
  @Prop achievement: AchievementModel

  build() {
    Column({ space: 10 }) {
      Text(this.achievement.icon)
        .fontSize(32)
      Text(this.achievement.name)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.achievement.unlocked ? '#182431' : '#9A9A9A')
      Text(this.achievement.desc)
        .fontSize(12)
        .fontColor(this.achievement.unlocked ? '#666666' : '#B0B0B0')
        .textAlign(TextAlign.Center)
        .maxLines(2)
      Text(this.achievement.unlocked ? '解锁于 ' + DateUtils.formatDate(this.achievement.unlockedAt) : '需打卡 ' + this.achievement.threshold + ' 次')
        .fontSize(11)
        .fontColor(this.achievement.unlocked ? '#0A59F7' : '#B0B0B0')
        .textAlign(TextAlign.Center)
    }
    .width('47%')
    .padding(16)
    .backgroundColor(this.achievement.unlocked ? '#FFFFFF' : '#F2F3F5')
    .borderRadius(20)
    .opacity(this.achievement.unlocked ? 1 : 0.65)
  }
}
