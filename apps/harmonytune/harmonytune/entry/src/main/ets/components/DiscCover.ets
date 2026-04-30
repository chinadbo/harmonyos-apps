@ComponentV2
export struct DiscCover {
  @Prop coverPath: string = '';
  @Prop isPlaying: boolean = false;
  @State rotateAngle: number = 0;

  aboutToAppear(): void {
    this.startRotate();
  }

  private startRotate(): void {
    animateTo({
      duration: 12000,
      curve: Curve.Linear,
      iterations: -1,
      playMode: PlayMode.Normal
    }, () => {
      this.rotateAngle = this.isPlaying ? 360 : this.rotateAngle;
    });
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(280)
        .height(280)
        .fill('#1A1E2C')
        .shadow({ radius: 30, color: '#66000000', offsetX: 0, offsetY: 12 })
      Circle()
        .width(238)
        .height(238)
        .fill('#0F1322')
        .border({ width: 10, color: '#2D3555' })
        .rotate({ angle: this.isPlaying ? this.rotateAngle : 0 })
      Stack({ alignContent: Alignment.Center }) {
        if (this.coverPath) {
          Image(this.coverPath)
            .width(170)
            .height(170)
            .borderRadius(18)
            .objectFit(ImageFit.Cover)
        } else {
          Column({ space: 10 }) {
            Text('♪')
              .fontSize(72)
              .fontColor('#FFFFFF')
            Text('HarmonyTune')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#D8DEFF')
          }
        }
      }
      .width(180)
      .height(180)
      .backgroundColor('#202746')
      .borderRadius(20)
      Circle()
        .width(34)
        .height(34)
        .fill('#E8ECFF')
      Circle()
        .width(10)
        .height(10)
        .fill('#394063')
    }
    .width('100%')
    .height(320)
  }
}
