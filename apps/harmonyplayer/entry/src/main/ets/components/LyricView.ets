import { LyricLine } from '../model/LyricLine';

@Component
export struct LyricView {
  @Prop lines: LyricLine[] = [];
  @StorageProp('currentLyricIndex') @Watch('syncScroll') currentIndex: number = 0;
  private scroller: Scroller = new Scroller();

  syncScroll(): void {
    if (this.lines.length === 0) {
      return;
    }
    this.scroller.scrollToIndex(Math.max(this.currentIndex, 0));
  }

  build() {
    List({ scroller: this.scroller, space: 12 }) {
      ForEach(this.lines, (line: LyricLine, index: number) => {
        ListItem() {
          Text(line.text || '...')
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontSize(index === this.currentIndex ? 18 : 14)
            .fontColor(index === this.currentIndex ? '#222222' : '#999999')
            .fontWeight(index === this.currentIndex ? FontWeight.Bold : FontWeight.Regular)
            .padding({ top: 4, bottom: 4 })
        }
      }, (line: LyricLine) => `${line.timeMs}-${line.text}`)
    }
    .width('100%')
    .height(220)
    .scrollBar(BarState.Off)
  }
}
