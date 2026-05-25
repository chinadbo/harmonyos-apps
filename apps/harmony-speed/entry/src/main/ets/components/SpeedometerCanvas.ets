@Component
export struct SpeedometerCanvas {
  @Prop @Watch('onSpeedChange') currentSpeed: number = 0
  @Prop maxSpeed: number = 200
  @Prop @Watch('onPhaseChange') phase: string = 'IDLE'
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  private getArcColor(speed: number): string {
    if (speed <= 50) { return '#4CAF50' }
    if (speed <= 100) { return '#FFC107' }
    return '#F44336'
  }

  onSpeedChange(): void {
    this.drawGauge()
  }

  onPhaseChange(): void {
    this.drawGauge()
  }

  private drawGauge(): void {
    const w = this.ctx.width
    const h = this.ctx.height
    const cx = w / 2
    const cy = h * 0.85
    const radius = Math.min(w, h) * 0.7

    this.ctx.clearRect(0, 0, w, h)

    // Background arc (gray)
    this.ctx.beginPath()
    this.ctx.strokeStyle = '#333344'
    this.ctx.lineWidth = 14
    this.ctx.arc(cx, cy, radius, Math.PI, 2 * Math.PI)
    this.ctx.stroke()

    // Speed arc (colored)
    const ratio = Math.min(this.currentSpeed / this.maxSpeed, 1)
    const endAngle = Math.PI + Math.PI * ratio
    this.ctx.beginPath()
    this.ctx.strokeStyle = this.getArcColor(this.currentSpeed)
    this.ctx.lineWidth = 14
    this.ctx.arc(cx, cy, radius, Math.PI, endAngle)
    this.ctx.stroke()

    // Speed value text
    this.ctx.fillStyle = '#FFFFFF'
    this.ctx.font = 'bold 36px sans-serif'
    this.ctx.textAlign = 'center'
    this.ctx.textBaseline = 'bottom'
    this.ctx.fillText(this.currentSpeed.toFixed(1), cx, cy - 10)

    // Unit text
    this.ctx.fillStyle = '#9E9E9E'
    this.ctx.font = '16px sans-serif'
    this.ctx.fillText('Mbps', cx, cy + 10)

    // Phase text
    this.ctx.fillStyle = '#9E9E9E'
    this.ctx.font = '14px sans-serif'
    this.ctx.textBaseline = 'top'
    let phaseText = ''
    switch (this.phase) {
      case 'IDLE': phaseText = '点击开始测速'; break
      case 'PING': phaseText = '检测延迟中...'; break
      case 'DOWNLOAD': phaseText = '测试下载速度...'; break
      case 'UPLOAD': phaseText = '测试上传速度...'; break
      case 'DONE': phaseText = '测速完成'; break
      default: phaseText = ''
    }
    this.ctx.fillText(phaseText, cx, cy + 20)
  }

  build() {
    Canvas(this.ctx)
      .width(280)
      .height(160)
      .backgroundColor('#1E1E2E')
      .borderRadius(12)
      .onReady(() => {
        this.drawGauge()
      })
      .onAreaChange((_oldVal: Area, _newVal: Area) => {
        this.drawGauge()
      })
  }
}
