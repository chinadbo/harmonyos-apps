export class AppStorageKeys {
  static readonly NAV_PATH_STACK: string = 'navPathStack'
  static readonly ACTIVE_PET_ID: string = 'activePetId'
  static readonly ACTIVE_PET_NAME: string = 'activePetName'
  static readonly TODAY_FEED_COUNT: string = 'todayFeedCount'
  static readonly NEXT_FEED_TIME: string = 'nextFeedTime'
  static readonly ACTIVE_REMINDERS: string = 'activeReminders'
  static readonly DATA_VERSION: string = 'dataVersion'
}

export interface ActiveReminder {
  reminderId: number
  title: string
  timeText: string
  reminderType: string
}
