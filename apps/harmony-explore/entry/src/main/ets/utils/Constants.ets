export class DbTables {
  static readonly SPOTS: string = 'spots'
  static readonly CHECK_INS: string = 'check_ins'
  static readonly PHOTOS: string = 'photos'
}

export class DbConfig {
  static readonly DB_NAME: string = 'harmonyexplore.db'
}

export class RouteNames {
  static readonly EXPLORE_MAP: string = 'explore_map'
  static readonly CHECKIN_LIST: string = 'checkin_list'
  static readonly CHECKIN_DETAIL: string = 'checkin_detail'
  static readonly ADD_SPOT: string = 'add_spot'
  static readonly ACHIEVEMENT: string = 'achievement'
  static readonly STATISTICS: string = 'statistics'
}

export class NotificationIds {
  static readonly ACHIEVEMENT_BASE: number = 1000
}

export class StatisticsConstants {
  static readonly RECENT_DAYS: number = 7
}
