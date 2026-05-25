export interface SpeedRecord {
  id: number
  timestamp: number
  downloadSpeed: number   // Mbps
  uploadSpeed: number     // Mbps
  ping: number            // ms
  jitter: number          // ms
  networkType: string     // WiFi/4G/5G/Unknown
  serverHost: string
}

export enum SpeedTestPhase {
  IDLE = 'IDLE',
  PING = 'PING',
  DOWNLOAD = 'DOWNLOAD',
  UPLOAD = 'UPLOAD',
  DONE = 'DONE'
}
