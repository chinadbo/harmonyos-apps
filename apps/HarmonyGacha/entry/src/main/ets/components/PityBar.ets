@Component
export struct PityBar {
  @Prop poolName: string = '';
  @Prop pity: number = 0;
  @Prop hardPity: number = 90;
  @Prop softStart: number = 74;
  @Prop isCurrent: boolean = false;
  @Prop cardColor: string = '#221E18';
  @Prop border: string = '#3A3428';
  @Prop trackColor: string = '#312B21';
  @Prop goldColor: string = '#FFD24A';
  @Prop primaryColor: string = '#E8B542';
  @Prop textMain: string = '#F5EFE2';
  @Prop textSub: string = '#A89F8C';

  private fillPercent(): number {
    const ratio = this.pity / this.hardPity;
    if (ratio <= 0) {
      return 0;
    }
    if (ratio >= 1) {
      return 100;
    }
    return ratio * 100;
  }

  private zonePercent(): number {
    return (this.hardPity - this.softStart) / this.hardPity * 100;
  }

  private remain(): number {
    const n = this.hardPity - this.pity;
    return n > 0 ? n : 0;
  }

  build() {
    Column({ space: 8 }) {
      Row({ space: 6 }) {
        Text(this.poolName)
          .fontSize(14)
          .fontColor(this.textMain)
          .fontWeight(600)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        if (this.isCurrent) {
          Text('当前')
            .fontSize(10)
            .fontColor(this.primaryColor)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
            .border({ width: 1, color: this.primaryColor })
        }
        if (this.pity >= this.softStart) {
          Text('软保底中')
            .fontSize(10)
            .fontColor(this.goldColor)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
            .border({ width: 1, color: this.goldColor })
        }
        Text(`${this.pity}/${this.hardPity}`)
          .fontSize(12)
          .fontColor(this.textSub)
      }
      .width('100%')

      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(10)
          .borderRadius(5)
          .backgroundColor(this.trackColor)

        Row() {
          Row()
            .width(`${this.zonePercent()}%`)
            .height(10)
            .backgroundColor(this.goldColor)
            .opacity(0.28)
        }
        .width('100%')
        .justifyContent(FlexAlign.End)

        if (this.fillPercent() > 0) {
          Row()
            .width(`${this.fillPercent()}%`)
            .height(10)
            .borderRadius(5)
            .linearGradient({
              angle: 90,
              colors: [[this.primaryColor, 0], [this.goldColor, 1]]
            })
        }
      }
      .width('100%')
      .borderRadius(5)
      .clip(true)

      Row() {
        Text(`距硬保底还有 ${this.remain()} 抽`)
          .fontSize(10)
          .fontColor(this.textSub)
        Blank()
        Text(`软保底自第 ${this.softStart} 抽起`)
          .fontSize(10)
          .fontColor(this.textSub)
      }
      .width('100%')
    }
    .padding(12)
    .borderRadius(12)
    .backgroundColor(this.cardColor)
    .border({ width: 1, color: this.border })
  }
}
