@Component
export struct TimerDisplay {
  @Link elapsedSeconds: number
  @Link @Watch('onResetSignalChange') resetSignal: number
  @Prop @Watch('onRunningChange') running: boolean
  @State intervalId: number = -1
  @State lastResetSignal: number = 0

  aboutToAppear() {
    this.lastResetSignal = this.resetSignal
    this.onRunningChange()
  }

  aboutToDisappear() {
    this.stopTimer()
  }

  private onResetSignalChange(): void {
    if (this.resetSignal !== this.lastResetSignal) {
      this.lastResetSignal = this.resetSignal
      this.elapsedSeconds = 0
    }
  }

  private onRunningChange(): void {
    if (this.running) {
      this.startTimer()
    } else {
      this.stopTimer()
    }
  }

  private startTimer(): void {
    if (!this.running || this.intervalId !== -1) {
      return
    }
    this.intervalId = setInterval(() => {
      if (this.running) {
        this.elapsedSeconds += 1
      }
    }, 1000)
  }

  private stopTimer(): void {
    if (this.intervalId === -1) {
      return
    }
    clearInterval(this.intervalId)
    this.intervalId = -1
  }

  private formatTime(totalSeconds: number): string {
    const minutes = Math.floor(totalSeconds / 60)
    const seconds = totalSeconds % 60
    const minuteText = minutes < 10 ? `0${minutes}` : `${minutes}`
    const secondText = seconds < 10 ? `0${seconds}` : `${seconds}`
    return `${minuteText}:${secondText}`
  }

  build() {
    Text(`Time: ${this.formatTime(this.elapsedSeconds)}`)
      .fontSize(18)
      .fontWeight(FontWeight.Medium)
      .fontColor('#182431')
  }
}
