@Component
export struct ScanFrame {
  @State private lineOffset: number = 0
  private readonly frameSize: number = 260

  aboutToAppear(): void {
    this.playAnimation()
  }

  private playAnimation(): void {
    animateTo({ duration: 1800, curve: Curve.EaseInOut, iterations: -1, playMode: PlayMode.Alternate }, () => {
      this.lineOffset = this.frameSize - 28
    })
  }

  @Builder
  private Corner(rotation: number): void {
    Column() {
      Row()
        .width(28)
        .height(4)
        .backgroundColor('#22FFFFFF')
      Row()
        .width(4)
        .height(28)
        .backgroundColor('#22FFFFFF')
    }
    .width(28)
    .height(28)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .rotate({ angle: rotation })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width(this.frameSize)
        .height(this.frameSize)
        .border({ width: 1, color: '#33FFFFFF' })
        .backgroundColor('#08000000')

      this.Corner(0)
      this.Corner(90)
        .position({ x: this.frameSize - 28, y: 0 })
      this.Corner(270)
        .position({ x: 0, y: this.frameSize - 28 })
      this.Corner(180)
        .position({ x: this.frameSize - 28, y: this.frameSize - 28 })

      Row()
        .width(this.frameSize - 24)
        .height(3)
        .margin({ left: 12 })
        .backgroundColor('#FF3B82F6')
        .shadow({ radius: 12, color: '#663B82F6', offsetX: 0, offsetY: 0 })
        .position({ x: 0, y: 12 + this.lineOffset })
    }
    .width(this.frameSize)
    .height(this.frameSize)
  }
}
