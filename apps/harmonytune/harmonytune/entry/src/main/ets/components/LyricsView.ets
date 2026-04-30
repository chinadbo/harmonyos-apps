import { FormatUtils } from '../utils/FormatUtils';

@ComponentV2
export struct LyricsView {
  @Prop lyrics: string[] = [];
  @Prop currentTime: number = 0;
  @Prop duration: number = 1;

  private currentLineIndex(): number {
    if (!this.lyrics.length) {
      return 0;
    }
    const progress = Math.min(0.999, this.currentTime / Math.max(1, this.duration));
    return Math.min(this.lyrics.length - 1, Math.floor(progress * this.lyrics.length));
  }

  build() {
    const activeIndex = this.currentLineIndex();
    Column({ space: 12 }) {
      Row() {
        Text($r('app.string.player_placeholder_lyrics'))
          .fontSize(12)
          .fontColor('#8D95B8')
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Text(`${FormatUtils.formatDuration(this.currentTime)} / ${FormatUtils.formatDuration(this.duration)}`)
        .fontSize(11)
        .fontColor('#69708F')

      List({ space: 10 }) {
        ForEach(this.lyrics, (line: string, index: number) => {
          ListItem() {
            Text(line)
              .width('100%')
              .fontSize(index === activeIndex ? 20 : 16)
              .fontWeight(index === activeIndex ? FontWeight.Bold : FontWeight.Regular)
              .fontColor(index === activeIndex ? '#FFFFFF' : '#7F87A8')
              .textAlign(TextAlign.Center)
              .opacity(index === activeIndex ? 1 : 0.68)
          }
        })
      }
      .width('100%')
      .height(240)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 12, bottom: 12 })
  }
}
