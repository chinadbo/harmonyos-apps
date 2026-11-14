import { Palette, Utils } from '../common/Constants';

@Component
export struct SeasonHeader {
  season: string = '春';
  year: number = 2026;
  count: number = 6;

  build() {
    Row({ space: 12 }) {
      Text(this.season)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .width(42)
        .height(42)
        .textAlign(TextAlign.Center)
        .backgroundColor(Utils.seasonColor(this.season))
        .borderRadius(21)

      Column({ space: 3 }) {
        Text(this.year + ' · ' + Utils.seasonEn(this.season))
          .fontSize(9)
          .letterSpacing(2)
          .fontColor(Palette.INK_FAINT)
        Text(this.season + '季 · ' + this.count + ' 个节气')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(Palette.INK)
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Row({ space: 4 }) {
        ForEach([0, 1, 2], (item: number) => {
          Row()
            .width(5)
            .height(5)
            .borderRadius(3)
            .backgroundColor(Utils.seasonColor(this.season))
            .opacity(0.25 + item * 0.25)
        }, (item: number) => this.season + '-dot-' + item)
      }
    }
    .width('100%')
    .padding({ left: 4, right: 4, top: 14, bottom: 8 })
  }
}
