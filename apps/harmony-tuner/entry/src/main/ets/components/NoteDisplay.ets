import { TunerResult } from '../tuner/TunerEngine';

@Component
export struct NoteDisplay {
  @Prop result: TunerResult | null = null;

  build() {
    Column() {
      if (this.result) {
        Text(`${this.result.note}${this.result.octave}`)
          .fontSize(80)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getNoteColor())

        Text(`${this.result.frequency.toFixed(1)} Hz`)
          .fontSize(24)
          .fontColor('#666666')
          .margin({ top: 8 })

        Text(`${this.result.cents > 0 ? '+' : ''}${this.result.cents.toFixed(1)} cents`)
          .fontSize(32)
          .fontColor(this.getCentsColor())
          .margin({ top: 4 })
      } else {
        Text('—')
          .fontSize(80)
          .fontColor('#CCCCCC')

        Text('Play a note')
          .fontSize(24)
          .fontColor('#999999')
          .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(20)
    .alignItems(HorizontalAlign.Center)
  }

  private getNoteColor(): ResourceColor {
    if (!this.result) return '#999999';
    return this.result.isInTune ? '#4CAF50' : '#333333';
  }

  private getCentsColor(): ResourceColor {
    if (!this.result) return '#999999';
    const absCents = Math.abs(this.result.cents);
    if (absCents <= 5) return '#4CAF50';
    if (absCents <= 20) return '#FFC107';
    return '#F44336';
  }
}
