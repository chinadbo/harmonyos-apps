import { SolarTerm, emptySolarTerm } from '../model/SolarTerm';
import { Palette, Utils } from '../common/Constants';

@Component
export struct TermCard {
  term: SolarTerm = emptySolarTerm();
  showYear: boolean = false;
  onTap: (term: SolarTerm) => void = (term: SolarTerm) => {
  };

  private momentText(): string {
    if (this.term.id === '') {
      return '';
    }
    const d: Date = new Date(this.term.date);
    const monthDay: string = (d.getMonth() + 1) + '月' + d.getDate() + '日';
    const time: string = Utils.pad2(d.getHours()) + ':' + Utils.pad2(d.getMinutes());
    if (this.showYear) {
      return d.getFullYear() + '年' + monthDay + ' ' + time;
    }
    return monthDay + ' ' + time;
  }

  build() {
    Row({ space: 12 }) {
      Column({ space: 2 }) {
        Text(Utils.pad2(new Date(this.term.date).getDate()))
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor(Utils.seasonColor(this.term.season))
        Text((new Date(this.term.date).getMonth() + 1) + '月')
          .fontSize(10)
          .fontColor(Palette.INK_FAINT)
      }
      .width(46)
      .alignItems(HorizontalAlign.Center)

      Column({ space: 5 }) {
        Row({ space: 8 }) {
          Text(this.term.name)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor(Palette.INK)
            .letterSpacing(1)
          Text(this.term.en)
            .fontSize(9)
            .letterSpacing(0.6)
            .fontColor(Palette.INK_FAINT)
            .maxLines(1)
            .layoutWeight(1)
        }
        .width('100%')

        Row({ space: 8 }) {
          Text(this.term.season)
            .fontSize(10)
            .fontColor(Utils.seasonColor(this.term.season))
            .backgroundColor(Utils.seasonSoft(this.term.season))
            .borderRadius(6)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          Text(this.momentText() + ' 交节')
            .fontSize(11)
            .fontColor(Palette.INK_SOFT)
        }
        .width('100%')

        Text(this.term.description)
          .fontSize(11)
          .fontColor(Palette.INK_FAINT)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('›')
        .fontSize(20)
        .fontColor(Palette.INK_FAINT)
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 13, bottom: 13 })
    .backgroundColor(Palette.CARD_BG)
    .borderRadius(18)
    .border({ width: 1, color: '#F2EBDD' })
    .onClick(() => {
      this.onTap(this.term);
    })
  }
}
