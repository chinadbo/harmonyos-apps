export class UserProfile {
  id: string = 'default-user'
  name: string = 'Harmony User'
  age: number = 28
  gender: string = 'Female'
  heightCm: number = 165
  weightKg: number = 58
  targetWeightKg: number = 56
  dailyCalorieGoal: number = 1800
  dailyProteinGoal: number = 95
  dailyCarbGoal: number = 210
  dailyFatGoal: number = 55
  dailyWaterGoalMl: number = 2000
  activityLevel: string = 'Moderate'
  reminderEnabled: boolean = true

  constructor(init?: Partial<UserProfile>) {
    Object.assign(this, init)
  }

  bodyMassIndex(): number {
    let meterHeight = this.heightCm / 100
    return Number((this.weightKg / (meterHeight * meterHeight)).toFixed(1))
  }
}
