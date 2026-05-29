import common from '@ohos.app.ability.common'
import { AchievementModel } from '../model/AchievementModel'
import { AchievementBadge } from '../components/AchievementBadge'
import { AchievementService } from '../service/AchievementService'

@Component
export struct AchievementPage {
  @StorageLink('abilityContext') abilityContext: common.UIAbilityContext | null = null
  @Watch('onRefreshChanged') @StorageLink('refreshToken') refreshToken: number = 0
  @State private achievements: AchievementModel[] = []
  private readonly achievementService: AchievementService = AchievementService.getInstance()

  aboutToAppear(): void {
    this.loadAchievements()
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text($r('app.string.title_achievement_wall'))
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .width('100%')
        if (this.achievements.length === 0) {
          Column() {
            Text($r('app.string.empty_achievement'))
              .fontSize(14)
              .fontColor('#8A8A8A')
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
        } else {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.achievements, (item: AchievementModel) => {
              AchievementBadge({ achievement: item })
                .margin({ bottom: 12 })
            }, (item: AchievementModel) => item.id)
          }
          .width('100%')
        }
      }
      .padding(16)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  private onRefreshChanged(): void {
    this.loadAchievements()
  }

  private async loadAchievements(): Promise<void> {
    if (!this.abilityContext) {
      this.achievements = []
      return
    }
    this.achievements = await this.achievementService.getAchievements(this.abilityContext)
  }
}
