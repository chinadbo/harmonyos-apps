/**
 * 走子历史侧边栏
 */
import { Move, Color } from '../model/Types';

@Component
export struct MoveHistory {
  @Prop history: Move[];

  private buildRows(): string[] {
    const rows: string[] = [];
    for (let i = 0; i < this.history.length; i += 2) {
      const no = Math.floor(i / 2) + 1;
      const white = this.history[i].san ?? '';
      const black = (i + 1 < this.history.length) ? (this.history[i + 1].san ?? '') : '';
      rows.push(`${no}. ${white}  ${black}`);
    }
    return rows;
  }

  build() {
    Column() {
      Text('走子记录')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#666666')
        .margin({ bottom: 6 })
      List({ space: 2 }) {
        ForEach(this.buildRows(), (line: string, idx: number) => {
          ListItem() {
            Text(line)
              .fontSize(13)
              .fontColor('#333333')
              .width('100%')
          }
        }, (line: string) => line)
      }
      .layoutWeight(1)
      .divider({ strokeWidth: 0.5, color: '#EEEEEE' })
    }
    .padding(8)
    .backgroundColor('#FAFAFA')
    .borderRadius(8)
  }
}
