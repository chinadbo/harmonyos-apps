import router from '@ohos.router';
import { Theme } from '../model/Theme';

@Entry
@Component
struct TimesTablePage {
  @State selRow: number = -1;
  @State selCol: number = -1;

  build() {
    Column({ space: 14 }) {
      Column({ space: 4 }) {
        Text($r('app.string.title_times_table'))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.TEXT_DARK)
        Text('点击单元格，高亮对应的整行与整列')
          .fontSize(12)
          .fontColor(Theme.TEXT_SECONDARY)
      }
      .width('100%')

      Column({ space: 6 }) {
        Row() {
          Text('×')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT_SECONDARY)
            .layoutWeight(1)
            .height(32)
            .textAlign(TextAlign.Center)
          ForEach(this.columns(), (c: number) => {
            Text(`${c}`)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.selCol === c ? Color.White : Theme.PRIMARY)
              .layoutWeight(1)
              .height(32)
              .textAlign(TextAlign.Center)
              .borderRadius(8)
              .backgroundColor(this.selCol === c ? Theme.PRIMARY : Theme.PRIMARY_LIGHT)
          }, (c: number) => `h_${c}`)
        }
        .width('100%')

        ForEach(this.rows(), (r: number) => {
          Row() {
            Text(`${r}`)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.selRow === r ? Color.White : Theme.PRIMARY)
              .layoutWeight(1)
              .height(36)
              .textAlign(TextAlign.Center)
              .borderRadius(8)
              .backgroundColor(this.selRow === r ? Theme.PRIMARY : Theme.PRIMARY_LIGHT)

            ForEach(this.columns(), (c: number) => {
              Text(`${r * c}`)
                .fontSize(13)
                .fontWeight(this.isHighlighted(r, c) ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.isCross(r, c) ? Theme.PRIMARY : Theme.TEXT_DARK)
                .layoutWeight(1)
                .height(36)
                .textAlign(TextAlign.Center)
                .borderRadius(8)
                .backgroundColor(this.cellBackground(r, c))
                .onClick(() => {
                  this.toggleSelect(r, c);
                })
            }, (c: number) => `c_${r}_${c}`)
          }
          .width('100%')
        }, (r: number) => `r_${r}`)
      }
      .width('100%')
      .padding(10)
      .borderRadius(16)
      .backgroundColor(Color.White)

      if (this.selRow > 0 && this.selCol > 0) {
        Column({ space: 6 }) {
          Text(this.formulaText())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.PRIMARY)
          Text(`口诀：${this.rhymeText()}`)
            .fontSize(14)
            .fontColor(Theme.TEXT_SECONDARY)
        }
        .width('100%')
        .padding(16)
        .borderRadius(16)
        .backgroundColor(Color.White)
        .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
      }

      Blank()

      Row({ space: 10 }) {
        Text('返回')
          .fontSize(14)
          .fontColor(Theme.TEXT_SECONDARY)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .borderRadius(12)
          .backgroundColor(Color.White)
          .onClick(() => {
            router.back();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(Theme.BG)
  }

  private rows(): number[] {
    const list: number[] = [];
    for (let i: number = 1; i <= 9; i++) {
      list.push(i);
    }
    return list;
  }

  private columns(): number[] {
    const list: number[] = [];
    for (let i: number = 1; i <= 9; i++) {
      list.push(i);
    }
    return list;
  }

  private toggleSelect(r: number, c: number): void {
    if (this.selRow === r && this.selCol === c) {
      this.selRow = -1;
      this.selCol = -1;
    } else {
      this.selRow = r;
      this.selCol = c;
    }
  }

  private isCross(r: number, c: number): boolean {
    return this.selRow === r || this.selCol === c;
  }

  private isHighlighted(r: number, c: number): boolean {
    return this.selRow === r && this.selCol === c;
  }

  private cellBackground(r: number, c: number): ResourceColor {
    if (this.selRow === r && this.selCol === c) {
      return Theme.PRIMARY;
    }
    if (this.selRow === r || this.selCol === c) {
      return Theme.PRIMARY_LIGHT;
    }
    return Theme.KEY_BG;
  }

  private formulaText(): string {
    return `${this.selRow} × ${this.selCol} = ${this.selRow * this.selCol}`;
  }

  private rhymeText(): string {
    const digits: string[] = ['', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
    const product: number = this.selRow * this.selCol;
    const a: string = digits[this.selRow];
    const b: string = digits[this.selCol];
    if (product < 10) {
      return `${a}${b}得${digits[product]}`;
    }
    if (product % 10 === 0) {
      return `${a}${b}${product / 10 === 1 ? '十' : digits[product / 10] + '十'}`;
    }
    if (product < 20) {
      return `${a}${b}十${digits[product % 10]}`;
    }
    return `${a}${b}${digits[Math.floor(product / 10)]}十${digits[product % 10]}`;
  }
}
