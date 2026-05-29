export interface AchievementModel {
  id: string
  name: string
  desc: string
  icon: string
  threshold: number
  unlocked: boolean
  unlockedAt: number
}

export interface AchievementRuleModel {
  id: string
  name: string
  desc: string
  icon: string
  threshold: number
  metric: string
}
