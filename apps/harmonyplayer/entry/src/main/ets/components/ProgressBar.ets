@Component
export struct ProgressBar {
  @Prop currentTime: number = 0;
  @Prop totalTime: number = 0;
  @Prop onSeek: (value: number) => void = () => {};

  private formatTime(value: number): string {
    const totalSeconds: number = Math.floor(value / 1000);
    const minutes: number = Math.floor(totalSeconds / 60);
    const seconds: number = totalSeconds % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  build() {
    Column({ space: 8 }) {
      Slider({ value: this.currentTime, min: 0, max: Math.max(this.totalTime, 1), step: 1000, style: SliderStyle.InSet })
        .blockColor('#007DFF')
        .trackColor('#D9D9D9')
        .selectedColor('#007DFF')
        .onChange((value: number) => {
          this.onSeek(value);
        })
      Row() {
        Text(this.formatTime(this.currentTime))
          .fontSize(12)
          .fontColor('#666666')
        Blank()
        Text(this.formatTime(this.totalTime))
          .fontSize(12)
          .fontColor('#666666')
      }
      .width('100%')
    }
    .width('100%')
  }
}
