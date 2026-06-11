export class DailyGoal {
  amount: number
  reminderEnabled: boolean
  startHour: number
  endHour: number
  intervalMinutes: number

  constructor(
    amount: number = 2000,
    reminderEnabled: boolean = false,
    startHour: number = 9,
    endHour: number = 21,
    intervalMinutes: number = 120
  ) {
    this.amount = amount
    this.reminderEnabled = reminderEnabled
    this.startHour = startHour
    this.endHour = endHour
    this.intervalMinutes = intervalMinutes
  }
}
