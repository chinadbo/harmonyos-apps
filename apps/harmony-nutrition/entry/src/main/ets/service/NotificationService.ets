export class NotificationService {
  private enabled: boolean = true
  private reminderHour: number = 20
  private reminderMinute: number = 0

  setEnabled(enabled: boolean): void {
    this.enabled = enabled
  }

  isEnabled(): boolean {
    return this.enabled
  }

  setReminderTime(hour: number, minute: number): void {
    this.reminderHour = hour
    this.reminderMinute = minute
  }

  getReminderText(): string {
    let hour = `${this.reminderHour}`.padStart(2, '0')
    let minute = `${this.reminderMinute}`.padStart(2, '0')
    return this.enabled ? `Daily reminder at ${hour}:${minute}` : 'Reminders disabled'
  }

  buildDailyMessage(remainingCalories: number): string {
    if (!this.enabled) {
      return 'Notifications are disabled'
    }
    if (remainingCalories > 0) {
      return `You can still consume ${remainingCalories.toFixed(0)} kcal today.`
    }
    return 'You have reached today\'s calorie goal.'
  }
}
