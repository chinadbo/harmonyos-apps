export class Constants {
  static readonly DB_NAME: string = 'harmony_fridge.db';
  static readonly FOOD_TABLE: string = 'food_items';
  static readonly SHOPPING_TABLE: string = 'shopping_entries';

  static readonly ALL_CATEGORY: string = '全部';
  static readonly CATEGORIES: string[] = [
    '蔬果',
    '肉类海鲜',
    '奶制品',
    '饮料',
    '调味品',
    '零食',
    '其他'
  ];
  static readonly STORAGE_AREAS: string[] = ['冷藏', '冷冻', '常温'];
  static readonly DEFAULT_UNITS: string[] = ['份', '个', '盒', '袋', '瓶', '克', '千克'];

  static readonly EXPIRED_DAYS: number = 0;
  static readonly URGENT_DAYS: number = 3;
  static readonly WARNING_DAYS: number = 7;

  static readonly ROUTE_ITEM_EDIT: string = 'ItemEditPage';

  static readonly PREFS_WIDGET: string = 'harmony_fridge_widget';
  static readonly PREFS_EXPIRING_COUNT: string = 'widgetExpiringCount';
  static readonly PREFS_EXPIRED_COUNT: string = 'widgetExpiredCount';
  static readonly PREFS_UPDATED_AT: string = 'widgetUpdatedAt';

  static readonly STORAGE_THEME: string = 'appTheme';
  static readonly STORAGE_NOTIFICATION: string = 'notificationEnabled';
  static readonly STORAGE_EXPIRED: string = 'expiredCount';
  static readonly STORAGE_EXPIRING: string = 'expiringSoonCount';
  static readonly STORAGE_TOTAL: string = 'totalFoodCount';
}
