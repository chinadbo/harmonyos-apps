export const DATABASE_NAME: string = 'harmony_express.db';
export const PACKAGE_TABLE: string = 'packages';
export const TRACKING_EVENT_TABLE: string = 'tracking_events';
export const MOCK_DATA_FILE: string = 'mock_data.json';

export const ROUTES = {
  HOME: 'HomeIndex',
  ADD_PACKAGE: 'AddPackage',
  TRACKING_DETAIL: 'TrackingDetail',
  HISTORY_LIST: 'HistoryList',
  SETTINGS: 'SettingsPage'
};

export interface CourierDefinition {
  code: string;
  name: string;
  patterns: RegExp[];
}

export const COURIER_DEFINITIONS: CourierDefinition[] = [
  { code: 'SF', name: '顺丰速运', patterns: [/^SF\d{10,15}$/i, /^SFEXP/i] },
  { code: 'JD', name: '京东物流', patterns: [/^JD/i, /^JDX/i, /^JDVA/i] },
  { code: 'YT', name: '圆通速递', patterns: [/^YT/i, /^YTO/i] },
  { code: 'ZT', name: '中通快递', patterns: [/^ZT/i, /^ZTO/i] },
  { code: 'YD', name: '韵达速递', patterns: [/^YD/i, /^YD\d{10,15}$/i] },
  { code: 'EMS', name: '中国邮政 EMS', patterns: [/^EMS/i, /^[A-Z]{2}\d{9}CN$/i] },
  { code: 'STO', name: '申通快递', patterns: [/^ST/i, /^STO/i] },
  { code: 'BEST', name: '百世快递', patterns: [/^BEST/i, /^HTKY/i] },
  { code: 'DBL', name: '德邦快递', patterns: [/^DBL/i, /^DPK/i] },
  { code: 'ANE', name: '安能物流', patterns: [/^ANE/i] },
  { code: 'JT', name: '极兔速递', patterns: [/^JT/i, /^JT\d{10,16}$/i] },
  { code: 'DK', name: '丹鸟', patterns: [/^DK/i, /^DANNIAO/i] }
];

export const STATUS_LABELS: Record<number, string> = {
  0: '待查询',
  1: '运输中',
  2: '派送中',
  3: '已签收',
  4: '异常',
  5: '退回中'
};

export const STATUS_COLORS: Record<number, string> = {
  0: '#8A94A6',
  1: '#3F8CFF',
  2: '#FF9F1C',
  3: '#22C55E',
  4: '#F04438',
  5: '#7A5AF8'
};

export const MOCK_LOCATIONS: string[] = [
  '深圳转运中心',
  '广州分拨中心',
  '上海青浦分拣中心',
  '杭州余杭配送站',
  '北京顺义中转场',
  '武汉汉阳营业部'
];
