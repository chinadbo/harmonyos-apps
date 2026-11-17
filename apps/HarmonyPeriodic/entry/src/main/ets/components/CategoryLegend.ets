import { getCategoryColor } from '../model/Element';

interface LegendEntry {
  key: string;
  label: string;
}

const LEGEND_ENTRIES: LegendEntry[] = [
  { key: 'alkali-metal', label: '碱金属' },
  { key: 'alkaline-earth', label: '碱土金属' },
  { key: 'transition', label: '过渡金属' },
  { key: 'post-transition', label: '后过渡金属' },
  { key: 'metalloid', label: '类金属' },
  { key: 'nonmetal', label: '非金属' },
  { key: 'halogen', label: '卤素' },
  { key: 'noble-gas', label: '稀有气体' },
  { key: 'lanthanide', label: '镧系' },
  { key: 'actinide', label: '锕系' }
];

@Component
export struct CategoryLegend {
  build() {
    Scroll() {
      Row({ space: 12 }) {
        ForEach(LEGEND_ENTRIES, (entry: LegendEntry) => {
          Row({ space: 4 }) {
            Row()
              .width(8)
              .height(8)
              .borderRadius(4)
              .backgroundColor(getCategoryColor(entry.key))
            Text(entry.label)
              .fontSize(10)
              .fontColor('#99000000')
              .maxLines(1)
          }
        }, (entry: LegendEntry) => entry.key)
      }
      .padding({ right: 4 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(18)
  }
}
