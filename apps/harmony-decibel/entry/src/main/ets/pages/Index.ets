import { DecibelAnalyzer, DecibelStats } from '../analysis/DecibelAnalyzer'
import audioCaptureManager from '../capture/AudioCaptureManager'
import measurementRepository, { MeasurementSession } from '../data/MeasurementRepository'
import settingsRepository, { AppSettings } from '../data/SettingsRepository'
import thresholdAlertService from '../services/ThresholdAlertService'
import { DecibelDisplay } from '../components/DecibelDisplay'
import { ControlPanel } from '../components/ControlPanel'

@Entry
@Component
struct Index {
  @State stats: DecibelStats = { current: 0, average: 0, max: 0, min: 0, sampleCount: 0 }
  @State isCapturing: boolean = false
  @State canSave: boolean = false
  @State noiseLabel: string = 'Ready'
  @State noiseColor: string = '#757575'
  @State history: number[] = []
  @State thresholdDb: number = 85
  @State settings: AppSettings = {
    thresholdDb: 85,
    calibrationOffset: 0,
    theme: 'light',
    alertEnabled: true,
    vibrationEnabled: true
  }

  private sessionStartTime: number = 0
  private analyzer: DecibelAnalyzer = new DecibelAnalyzer()

  aboutToAppear() {
    this.init()
  }

  aboutToDisappear() {
    this.stopCapture()
  }

  async init(): Promise<void> {
    await measurementRepository.init()
    await settingsRepository.init()
    await thresholdAlertService.init()
    const savedSettings = await settingsRepository.getSettings()
    this.settings = savedSettings
    this.thresholdDb = savedSettings.thresholdDb
    this.analyzer.setCalibrationOffset(savedSettings.calibrationOffset)
    await audioCaptureManager.init()
    audioCaptureManager.setOnDataCallback((buffer: ArrayBuffer) => {
      const db = this.analyzer.processBuffer(buffer)
      this.stats = this.analyzer.getStats()
      this.history = this.analyzer.getHistory()
      const levelInfo = this.analyzer.getNoiseLevelDescription(db)
      this.noiseLabel = levelInfo.label
      this.noiseColor = levelInfo.color

      if (this.settings.alertEnabled && db > this.thresholdDb) {
        thresholdAlertService.triggerAlert(this.settings.vibrationEnabled)
      }
    })
  }

  async startCapture(): Promise<void> {
    if (this.isCapturing) return
    this.sessionStartTime = Date.now()
    this.canSave = false
    const success = await audioCaptureManager.start()
    if (success) {
      this.isCapturing = true
    }
  }

  async stopCapture(): Promise<void> {
    if (!this.isCapturing) return
    await audioCaptureManager.stop()
    this.isCapturing = false
    if (this.stats.sampleCount > 0) {
      this.canSave = true
    }
  }

  resetCapture(): void {
    this.analyzer.reset()
    this.stats = { current: 0, average: 0, max: 0, min: 0, sampleCount: 0 }
    this.history = []
    this.noiseLabel = 'Ready'
    this.noiseColor = '#757575'
    this.canSave = false
  }

  async saveSession(): Promise<void> {
    if (!this.canSave || this.stats.sampleCount === 0) return
    const now = Date.now()
    const session: Omit<MeasurementSession, 'id'> = {
      startTime: this.sessionStartTime,
      endTime: now,
      duration: Math.floor((now - this.sessionStartTime) / 1000),
      avgDb: this.stats.average,
      maxDb: this.stats.max,
      minDb: this.stats.min,
      sampleCount: this.stats.sampleCount
    }
    await measurementRepository.insertSession(session)
    this.canSave = false
  }

  build() {
    Column() {
      // Header
      Row() {
        Text('HarmonyDecibel')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary'))
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Center)

      // Decibel display
      DecibelDisplay({
        stats: this.stats,
        noiseLabel: this.noiseLabel,
        noiseColor: this.noiseColor
      })

      // History curve canvas
      Canvas(this.context)
        .width('100%')
        .height(120)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)
        .margin({ top: 12, left: 16, right: 16 })
        .onReady(() => {
          this.drawHistoryCurve(this.context)
        })

      // Control panel
      ControlPanel({
        isCapturing: this.isCapturing,
        canSave: this.canSave,
        thresholdDb: this.thresholdDb,
        currentDb: this.stats.current,
        onStart: () => this.startCapture(),
        onStop: () => this.stopCapture(),
        onReset: () => this.resetCapture(),
        onSave: () => this.saveSession()
      })
      .margin({ top: 12, left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }

  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true))

  private drawHistoryCurve(context: CanvasRenderingContext2D): void {
    const width = 600
    const height = 120
    const padding = 20

    context.clearRect(0, 0, width, height)

    // Draw grid lines
    context.strokeStyle = '#E0E0E0'
    context.lineWidth = 1
    for (let i = 0; i <= 4; i++) {
      const y = padding + (height - 2 * padding) * i / 4
      context.beginPath()
      context.moveTo(padding, y)
      context.lineTo(width - padding, y)
      context.stroke()
    }

    // Draw curve
    if (this.history.length > 1) {
      context.strokeStyle = this.noiseColor
      context.lineWidth = 2
      context.beginPath()

      const minDb = 30
      const maxDb = 120
      const xStep = (width - 2 * padding) / this.maxHistorySize

      for (let i = 0; i < this.history.length; i++) {
        const x = padding + i * xStep
        const normalized = (this.history[i] - minDb) / (maxDb - minDb)
        const y = height - padding - normalized * (height - 2 * padding)
        if (i === 0) {
          context.moveTo(x, y)
        } else {
          context.lineTo(x, y)
        }
      }
      context.stroke()
    }
  }

  private readonly maxHistorySize: number = 600
}
