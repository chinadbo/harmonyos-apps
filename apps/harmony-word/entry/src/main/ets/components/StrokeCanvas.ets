interface StrokePath {
  path: string
}

interface CharacterStrokeMap {
  [key: string]: StrokePath[]
}

const STROKE_MAP: CharacterStrokeMap = {
  '永': [
    { path: 'M110 30 L110 180' },
    { path: 'M70 72 L145 72' },
    { path: 'M110 72 Q90 95 75 125' },
    { path: 'M110 72 Q135 98 155 122' },
    { path: 'M110 118 L80 160' },
    { path: 'M110 118 L145 168' }
  ],
  '春': [
    { path: 'M55 52 L165 52' },
    { path: 'M70 84 L150 84' },
    { path: 'M95 28 L75 162' },
    { path: 'M125 28 L145 162' },
    { path: 'M60 122 L160 122' },
    { path: 'M72 162 L150 162' }
  ],
  '和': [
    { path: 'M72 34 L72 176' },
    { path: 'M42 72 L102 72' },
    { path: 'M112 42 L162 42' },
    { path: 'M137 42 L137 176' },
    { path: 'M112 102 L162 102' },
    { path: 'M112 176 L162 176' }
  ],
  '学': [
    { path: 'M62 46 L158 46' },
    { path: 'M88 26 L72 76' },
    { path: 'M132 26 L148 76' },
    { path: 'M78 92 L142 92' },
    { path: 'M70 120 L150 120' },
    { path: 'M110 92 L110 176' }
  ],
  '山': [
    { path: 'M60 54 L60 176' },
    { path: 'M110 32 L110 176' },
    { path: 'M160 54 L160 176' },
    { path: 'M60 176 L160 176' }
  ],
  '清': [
    { path: 'M58 48 L84 78' },
    { path: 'M50 106 L82 106' },
    { path: 'M64 106 L52 172' },
    { path: 'M104 52 L164 52' },
    { path: 'M104 92 L164 92' },
    { path: 'M104 132 L164 132' },
    { path: 'M132 52 L132 172' }
  ]
}

@Component
export struct StrokeCanvas {
  word: string = '永'
  @State private visibleStrokeCount: number = 0
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  aboutToAppear(): void {
    setTimeout(() => {
      this.restart()
    }, 60)
  }

  private getStrokes(): StrokePath[] {
    return STROKE_MAP[this.word] || STROKE_MAP['永']
  }

  private restart(): void {
    this.visibleStrokeCount = 0
    this.draw()
    this.playStroke(0)
  }

  private playStroke(index: number): void {
    if (index >= this.getStrokes().length) {
      return
    }
    animateTo({ duration: 420, curve: Curve.EaseInOut }, () => {
      this.visibleStrokeCount = index + 1
    })
    setTimeout(() => {
      this.draw()
      this.playStroke(index + 1)
    }, 460)
  }

  private draw(): void {
    const size = 220
    this.context2D.clearRect(0, 0, size, size)
    this.context2D.fillStyle = '#FFFFFF'
    this.context2D.fillRect(0, 0, size, size)
    this.context2D.strokeStyle = '#E5E7EB'
    this.context2D.lineWidth = 1
    this.context2D.strokeRect(10, 10, 200, 200)

    for (let index = 0; index < this.visibleStrokeCount; index++) {
      const stroke = this.getStrokes()[index]
      this.context2D.strokeStyle = '#2563EB'
      this.context2D.lineWidth = 8
      this.context2D.lineCap = 'round'
      this.context2D.lineJoin = 'round'
      const path = new Path2D(stroke.path)
      this.context2D.stroke(path)
    }
  }

  build() {
    Column({ space: 12 }) {
      Canvas(this.context2D)
        .width(220)
        .height(220)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
      Button('重播笔顺')
        .fontSize(14)
        .backgroundColor('#2563EB')
        .onClick(() => {
          this.restart()
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
