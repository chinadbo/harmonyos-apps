import abilityAccessCtrl from '@ohos.abilityAccessCtrl'
import common from '@ohos.app.ability.common'
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import vibrator from '@ohos.vibrator'
import DatabaseService from '../service/DatabaseService'
import qrService from '../service/QRService'
import { ScanFrame } from '../components/ScanFrame'
import { ROUTES, STORAGE_KEYS } from '../utils/Constants'

// NOTE: customScan is from @ohos.scanBarcode / ScanKit; using a type-safe fallback pattern
// to handle environments where the exact module path may differ.
// The scan functionality uses XComponent surface + customScan APIs as documented in API 12+.
let customScanModule: {
  init: (viewControl: object) => void;
  start: (viewControl: object, callback: (err: object, result: object) => void) => void;
  stop: () => void;
  release: () => void;
  setTorch?: (on: boolean) => void;
} | null = null

try {
  // Try loading customScan - path varies by SDK version
  // API 12+: @ohos.scanBarcode provides customScan
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const scanModule = require('@ohos.scanBarcode')
  customScanModule = scanModule.customScan ?? scanModule.default?.customScan ?? null
} catch (_e) {
  customScanModule = null
}

@Component
export default struct ScanPage {
  @State private hasPermission: boolean = false
  @State private flashEnabled: boolean = false
  @State private scanReady: boolean = false
  @StorageProp(STORAGE_KEYS.SCAN_RESULT) @Watch('onScanResultChange') private scanResultPayload: string = ''
  private context = getContext(this) as common.UIAbilityContext
  private surfaceId: string = ''

  async aboutToAppear(): Promise<void> {
    await DatabaseService.init(this.context)
  }

  async onPageShow(): Promise<void> {
    await this.requestCameraPermission()
    if (this.hasPermission && this.surfaceId) {
      this.initScanner()
    }
  }

  onPageHide(): void {
    this.stopScanner()
  }

  onScanResultChange(): void {
    if (this.scanResultPayload.length > 0) {
      this.handleScanResult(this.scanResultPayload)
    }
  }

  private async requestCameraPermission(): Promise<void> {
    const manager = abilityAccessCtrl.createAtManager()
    const result = await manager.requestPermissionsFromUser(this.context, ['ohos.permission.CAMERA'])
    this.hasPermission = result.authResults.length > 0 && result.authResults[0] === 0
    if (!this.hasPermission) {
      promptAction.showToast({ message: '请先授予相机权限' })
    }
  }

  private initScanner(): void {
    if (this.scanReady || !customScanModule) {
      return
    }
    try {
      const viewControl = { surfaceId: this.surfaceId, width: 0, height: 0 }
      customScanModule.init(viewControl)
      this.scanReady = true
      customScanModule.start(viewControl, (_err: object, result: object) => {
        const res = result as Record<string, object>
        const value = String(res?.['originalValue'] ?? '')
        if (!value) {
          return
        }
        AppStorage.setOrCreate(STORAGE_KEYS.SCAN_RESULT, value)
      })
    } catch (_error) {
      promptAction.showToast({ message: '扫码初始化失败，请检查设备是否支持' })
    }
  }

  private stopScanner(): void {
    if (!this.scanReady || !customScanModule) {
      return
    }
    try {
      customScanModule.stop()
    } catch (_e) { /* ignore */ }
    try {
      customScanModule.release()
    } catch (_e) { /* ignore */ }
    this.scanReady = false
  }

  private handleScanResult(rawText: string): void {
    if (!rawText) {
      return
    }
    AppStorage.setOrCreate(STORAGE_KEYS.SCAN_RESULT, '')
    try {
      vibrator.startVibration({ type: 'time', duration: 120 }, { id: 0, usage: 'alarm' })
    } catch (_error) {
      // vibration not critical
    }
    // Async record creation and navigation
    qrService.createRecord('scan', rawText)
    const record = qrService.createRecord('scan', rawText)
    DatabaseService.insert(record).then((id: number) => {
      record.id = id
      AppStorage.setOrCreate(STORAGE_KEYS.HISTORY_REFRESH, Date.now())
      router.pushUrl({
        url: ROUTES.RESULT,
        params: {
          record: JSON.stringify(record)
        }
      }).catch(() => { /* ignore navigation error */ })
    }).catch(() => { /* ignore db error */ })
  }

  private toggleFlash(): void {
    this.flashEnabled = !this.flashEnabled
    if (!customScanModule) {
      return
    }
    try {
      if (customScanModule.setTorch) {
        customScanModule.setTorch(this.flashEnabled)
      }
    } catch (_error) {
      promptAction.showToast({ message: '当前设备不支持手电筒控制' })
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Stack({ alignContent: Alignment.Center }) {
          if (this.hasPermission) {
            XComponent({ id: 'HarmonyQRScanSurface', type: 'surface' })
              .width('100%')
              .height('100%')
              .onLoad((event) => {
                this.surfaceId = event?.surfaceId ?? ''
                if (this.surfaceId && !this.scanReady) {
                  this.initScanner()
                }
              })
          } else {
            Column({ space: 12 }) {
              Text('需要相机权限以开始扫码')
                .fontSize(18)
                .fontColor(Color.White)
              Button('重新授权')
                .type(ButtonType.Capsule)
                .onClick(async () => {
                  await this.requestCameraPermission()
                  if (this.hasPermission && this.surfaceId) {
                    this.initScanner()
                  }
                })
            }
          }

          Column({ space: 24 }) {
            Text('将二维码放入框内自动识别')
              .fontSize(18)
              .fontColor(Color.White)
            ScanFrame()
          }
        }
        .width('100%')
        .layoutWeight(1)

        Row({ space: 16 }) {
          Button('历史')
            .layoutWeight(1)
            .height(48)
            .type(ButtonType.Capsule)
            .backgroundColor('#331E293B')
            .fontColor(Color.White)
            .onClick(() => {
              AppStorage.setOrCreate('main_tab_index', 2)
            })

          Button(this.flashEnabled ? '关闭手电筒' : '打开手电筒')
            .layoutWeight(1)
            .height(48)
            .type(ButtonType.Capsule)
            .backgroundColor('#FF0A59F7')
            .fontColor(Color.White)
            .onClick(() => {
              this.toggleFlash()
            })

          Button('去生成')
            .layoutWeight(1)
            .height(48)
            .type(ButtonType.Capsule)
            .backgroundColor('#331E293B')
            .fontColor(Color.White)
            .onClick(() => {
              AppStorage.setOrCreate('main_tab_index', 1)
            })
        }
        .padding({ left: 20, right: 20, top: 16, bottom: 24 })
        .backgroundColor('#CC020617')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}
