export class DayStats {
  date: string
  total: number
  goal: number

  constructor(date: string = '', total: number = 0, goal: number = 2000) {
    this.date = date
    this.total = total
    this.goal = goal
  }
}

export class WeekStats {
  items: DayStats[]
  weeklyAverage: number
  completionRate: number
  totalIntake: number

  constructor(items: DayStats[] = [], weeklyAverage: number = 0, completionRate: number = 0, totalIntake: number = 0) {
    this.items = items
    this.weeklyAverage = weeklyAverage
    this.completionRate = completionRate
    this.totalIntake = totalIntake
  }
}
