import http from '@ohos.net.http'

const DOWNLOAD_URL = 'https://speed.cloudflare.com/__down?bytes=5000000'
const PING_URL = 'https://1.1.1.1/cdn-cgi/trace'
const UPLOAD_URL = 'https://speed.cloudflare.com/__up'
const PING_COUNT = 5

export interface PingResult {
  ping: number  // ms average
  jitter: number  // ms stddev
}

export class SpeedTestService {
  async pingTest(): Promise<PingResult> {
    const rtts: number[] = []
    for (let i = 0; i < PING_COUNT; i++) {
      const httpReq = http.createHttp()
      const start = Date.now()
      try {
        await httpReq.request(PING_URL, {
          method: http.RequestMethod.GET,
          connectTimeout: 5000,
          readTimeout: 5000
        })
        const rtt = Date.now() - start
        rtts.push(rtt)
      } catch (e) {
        rtts.push(999)
      } finally {
        httpReq.destroy()
      }
    }
    const avg = rtts.reduce((a, b) => a + b, 0) / rtts.length
    const variance = rtts.reduce((acc, v) => acc + Math.pow(v - avg, 2), 0) / rtts.length
    const jitter = Math.sqrt(variance)
    return {
      ping: Math.round(avg),
      jitter: Math.round(jitter)
    }
  }

  async downloadTest(onProgress: (speed: number) => void): Promise<number> {
    const httpReq = http.createHttp()
    const start = Date.now()
    try {
      const response = await httpReq.request(DOWNLOAD_URL, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 30000
      })
      const elapsed = Date.now() - start
      // response.result may be string or ArrayBuffer
      let bytes = 0
      if (response.result instanceof ArrayBuffer) {
        bytes = response.result.byteLength
      } else if (typeof response.result === 'string') {
        bytes = response.result.length
      }
      if (bytes === 0) {
        // Estimate from 5MB
        bytes = 5000000
      }
      const durationSec = elapsed / 1000
      const speedMbps = (bytes * 8) / durationSec / 1_000_000
      onProgress(parseFloat(speedMbps.toFixed(2)))
      return parseFloat(speedMbps.toFixed(2))
    } catch (e) {
      return 0
    } finally {
      httpReq.destroy()
    }
  }

  async uploadTest(): Promise<number> {
    const httpReq = http.createHttp()
    // Generate 2MB random data
    const uploadSize = 2 * 1024 * 1024
    const buffer = new ArrayBuffer(uploadSize)
    const view = new Uint8Array(buffer)
    for (let i = 0; i < uploadSize; i++) {
      view[i] = Math.floor(Math.random() * 256)
    }
    const start = Date.now()
    try {
      await httpReq.request(UPLOAD_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/octet-stream',
          'Content-Length': String(uploadSize)
        },
        extraData: buffer,
        connectTimeout: 10000,
        readTimeout: 30000
      })
      const elapsed = Date.now() - start
      const durationSec = elapsed / 1000
      const speedMbps = (uploadSize * 8) / durationSec / 1_000_000
      return parseFloat(speedMbps.toFixed(2))
    } catch (e) {
      return 0
    } finally {
      httpReq.destroy()
    }
  }
}

export const speedTestService = new SpeedTestService()
