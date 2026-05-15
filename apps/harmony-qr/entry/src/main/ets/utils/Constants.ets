import { QRRecord } from '../model/QRRecord'

export const ROUTES = {
  MAIN: 'pages/MainPage',
  SCAN: 'pages/ScanPage',
  GENERATE: 'pages/GeneratePage',
  HISTORY: 'pages/HistoryPage',
  RESULT: 'pages/ResultPage'
}

export const STORAGE_KEYS = {
  SCAN_RESULT: 'scan_result_payload',
  HISTORY_REFRESH: 'history_refresh_flag',
  MAIN_TAB_INDEX: 'main_tab_index'
}

export const PRESET_COLORS: string[] = [
  '#000000',
  '#0A59F7',
  '#14B866',
  '#F97316',
  '#EF4444',
  '#7C3AED'
]

export const DEFAULT_RECORD = new QRRecord({
  id: 0,
  type: 'scan',
  content: '',
  contentType: 'text',
  color: '#000000',
  bgColor: '#FFFFFF',
  isFavorite: 0,
  createdAt: 0
})

export const DEFAULT_QR_SIZE: number = 220
export const MIN_QR_SIZE: number = 150
export const MAX_QR_SIZE: number = 300
export const DB_NAME: string = 'harmonyqr.db'
export const TABLE_NAME: string = 'qr_records'
