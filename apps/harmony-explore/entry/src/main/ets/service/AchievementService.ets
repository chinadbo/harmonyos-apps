import common from '@ohos.app.ability.common'
import { AchievementModel, AchievementRuleModel } from '../model/AchievementModel'
import { NotificationIds } from '../utils/Constants'
import { DatabaseService } from './DatabaseService'
import { NotificationService } from './NotificationService'

export class AchievementService {
  private static instance: AchievementService = new AchievementService()
  private readonly databaseService: DatabaseService = DatabaseService.getInstance()
  private readonly notificationService: NotificationService = NotificationService.getInstance()
  private readonly notifiedIds: Set<string> = new Set<string>()

  static getInstance(): AchievementService {
    return AchievementService.instance
  }

  async getAchievements(context: common.UIAbilityContext): Promise<AchievementModel[]> {
    const rules: AchievementRuleModel[] = await this.loadRules(context)
    const metrics: Record<string, number> = await this.databaseService.getAchievementMetrics()
    const latestUnlockedAt: number = await this.databaseService.getLatestCheckInAt()
    return rules.map((rule: AchievementRuleModel) => {
      const currentValue: number = metrics[rule.metric] ?? 0
      const unlocked: boolean = currentValue >= rule.threshold
      return {
        id: rule.id,
        name: rule.name,
        desc: rule.desc,
        icon: rule.icon,
        threshold: rule.threshold,
        unlocked,
        unlockedAt: unlocked ? latestUnlockedAt : 0
      }
    })
  }

  async evaluateAndNotify(context: common.UIAbilityContext): Promise<AchievementModel[]> {
    const achievements: AchievementModel[] = await this.getAchievements(context)
    let index: number = 0
    for (const achievement of achievements) {
      if (achievement.unlocked && !this.notifiedIds.has(achievement.id)) {
        this.notifiedIds.add(achievement.id)
        await this.notificationService.publishBasicText(
          NotificationIds.ACHIEVEMENT_BASE + index,
          `解锁成就：${achievement.name}`,
          achievement.desc
        )
      }
      index++
    }
    return achievements
  }

  private async loadRules(context: common.UIAbilityContext): Promise<AchievementRuleModel[]> {
    const content: Uint8Array = await context.resourceManager.getRawFileContent('achievements.json')
    const source: string = new TextDecoder().decode(content)
    return JSON.parse(source) as AchievementRuleModel[]
  }
}
