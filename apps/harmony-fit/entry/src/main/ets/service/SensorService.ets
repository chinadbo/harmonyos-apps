import sensor from '@ohos.sensor'

export class SensorService {
  private static instance: SensorService = new SensorService()
  private todaySteps: number = 0
  private baselineSteps: number = -1
  private activeSensorId: number = -1
  private isListening: boolean = false
  private stepCallback?: (steps: number) => void
  private baselineDate: string = ''

  private constructor() {
  }

  static getInstance(): SensorService {
    return SensorService.instance
  }

  startListening(): void {
    this.ensureTodayBaseline()
    if (this.isListening) {
      return
    }
    if (this.trySubscribe(sensor.SensorId.PEDOMETER)) {
      return
    }
    this.trySubscribe(sensor.SensorId.STEP_DETECTOR)
  }

  stopListening(): void {
    if (!this.isListening || this.activeSensorId < 0) {
      return
    }
    try {
      sensor.off(this.activeSensorId)
    } catch (error) {
      console.error(`Sensor off failed: ${JSON.stringify(error)}`)
    }
    this.isListening = false
    this.activeSensorId = -1
  }

  getTodaySteps(): number {
    this.ensureTodayBaseline()
    return this.todaySteps
  }

  setStepCallback(cb: (steps: number) => void): void {
    this.stepCallback = cb
  }

  getListeningState(): boolean {
    return this.isListening
  }

  private trySubscribe(sensorId: number): boolean {
    try {
      sensor.on(sensorId, (data: Record<string, Object>) => {
        this.handleSensorData(sensorId, data)
      }, {
        interval: 1000000000
      })
      this.activeSensorId = sensorId
      this.isListening = true
      return true
    } catch (error) {
      console.error(`Sensor subscribe failed: ${JSON.stringify(error)}`)
      return false
    }
  }

  private handleSensorData(sensorId: number, data: Record<string, Object>): void {
    this.ensureTodayBaseline()
    const values = data.values as Array<number>
    if (values === undefined || values.length === 0) {
      return
    }
    if (sensorId === sensor.SensorId.PEDOMETER) {
      const total = Number(values[0])
      if (this.baselineSteps < 0) {
        this.baselineSteps = total
      }
      const current = total - this.baselineSteps
      this.todaySteps = current > 0 ? current : 0
    } else {
      this.todaySteps += 1
    }
    if (this.stepCallback !== undefined) {
      this.stepCallback(this.todaySteps)
    }
  }

  private ensureTodayBaseline(): void {
    const today = this.getDateString()
    if (this.baselineDate === today) {
      return
    }
    this.baselineDate = today
    this.baselineSteps = -1
    this.todaySteps = 0
  }

  private getDateString(): string {
    const now = new Date()
    const year = now.getFullYear()
    const month = `${now.getMonth() + 1}`.padStart(2, '0')
    const day = `${now.getDate()}`.padStart(2, '0')
    return `${year}-${month}-${day}`
  }
}
