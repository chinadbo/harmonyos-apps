import { SpeedTestPhase, SpeedRecord } from '../model/SpeedRecord'
import { speedTestService } from '../service/SpeedTestService'
import { networkService } from '../service/NetworkService'
import { speedDb } from '../database/SpeedDatabase'
import { SpeedometerCanvas } from '../components/SpeedometerCanvas'
import { NetworkInfoCard } from '../components/NetworkInfoCard'
import { SpeedResultCard } from '../components/SpeedResultCard'

@Component
export struct HomeView {
  @State phase: SpeedTestPhase = SpeedTestPhase.IDLE
  @State currentSpeed: number = 0
  @State downloadSpeed: number = 0
  @State uploadSpeed: number = 0
  @State ping: number = 0
  @State jitter: number = 0
  @State networkType: string = 'Unknown'
  @State localIP: string = ''
  @State wifiSSID: string = ''
  @State showResult: boolean = false
  @StorageLink('lastSpeedRecord') lastRecord: string = ''

  async aboutToAppear() {
    this.networkType = await networkService.getNetworkType()
    this.localIP = await networkService.getLocalIP()
    if (this.networkType === 'WiFi') {
      this.wifiSSID = await networkService.getWifiSSID()
    }
  }

  private async startTest() {
    this.phase = SpeedTestPhase.PING
    this.currentSpeed = 0
    this.showResult = false

    try {
      // Phase 1: Ping
      const pingResult = await speedTestService.pingTest()
      this.ping = pingResult.ping
      this.jitter = pingResult.jitter

      // Phase 2: Download
      this.phase = SpeedTestPhase.DOWNLOAD
      this.currentSpeed = 0
      const dl = await speedTestService.downloadTest((speed: number) => {
        this.currentSpeed = speed
      })
      this.downloadSpeed = dl
      this.currentSpeed = dl

      // Phase 3: Upload
      this.phase = SpeedTestPhase.UPLOAD
      this.currentSpeed = 0
      const ul = await speedTestService.uploadTest()
      this.uploadSpeed = ul
      this.currentSpeed = ul

      // Done
      this.phase = SpeedTestPhase.DONE
      this.showResult = true

      // Save to DB
      const record: SpeedRecord = {
        id: 0,
        timestamp: Date.now(),
        downloadSpeed: this.downloadSpeed,
        uploadSpeed: this.uploadSpeed,
        ping: this.ping,
        jitter: this.jitter,
        networkType: this.networkType,
        serverHost: 'speed.cloudflare.com'
      }
      await speedDb.insertRecord(record)

      // Update AppStorage for widget
      AppStorage.set('lastSpeedRecord', JSON.stringify(record))
      this.lastRecord = JSON.stringify(record)
    } catch (err) {
      this.phase = SpeedTestPhase.IDLE
      this.showResult = false
    }
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        // Title
        Text('HarmonySpeed')
          .fontSize(24)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: 16 })

        // Speedometer
        SpeedometerCanvas({
          currentSpeed: this.currentSpeed,
          maxSpeed: 200,
          phase: this.phase
        })

        // Network info
        NetworkInfoCard({
          networkType: this.networkType,
          localIP: this.localIP,
          wifiSSID: this.wifiSSID
        })
          .width('100%')

        // Start button (IDLE or DONE)
        if (this.phase === SpeedTestPhase.IDLE || this.phase === SpeedTestPhase.DONE) {
          Button(this.phase === SpeedTestPhase.DONE ? '重新测速' : '开始测速')
            .width(200)
            .height(52)
            .fontSize(18)
            .fontColor('#FFFFFF')
            .backgroundColor('#2196F3')
            .borderRadius(26)
            .onClick(() => {
              this.startTest()
            })
        }

        // Testing status
        if (this.phase === SpeedTestPhase.PING ||
          this.phase === SpeedTestPhase.DOWNLOAD ||
          this.phase === SpeedTestPhase.UPLOAD) {
          Text(this.getStatusText())
            .fontSize(14)
            .fontColor('#9E9E9E')
        }

        // Result card
        if (this.showResult) {
          SpeedResultCard({
            downloadSpeed: this.downloadSpeed,
            uploadSpeed: this.uploadSpeed,
            ping: this.ping,
            jitter: this.jitter
          })
            .width('100%')
        }
      }
      .padding({ left: 16, right: 16, bottom: 24 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#12121E')
  }

  private getStatusText(): string {
    switch (this.phase) {
      case SpeedTestPhase.PING: return '正在检测延迟...'
      case SpeedTestPhase.DOWNLOAD: return `下载测速中... ${this.currentSpeed.toFixed(1)} Mbps`
      case SpeedTestPhase.UPLOAD: return `上传测速中... ${this.currentSpeed.toFixed(1)} Mbps`
      default: return ''
    }
  }
}
