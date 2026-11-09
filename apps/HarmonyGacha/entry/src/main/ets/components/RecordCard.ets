@Component
export struct RecordCard {
  @Prop itemName: string = '';
  @Prop star: number = 3;
  @Prop poolName: string = '';
  @Prop dateStr: string = '';
  @Prop pullNo: number = 0;
  @Prop goldColor: string = '#FFD24A';
  @Prop purpleColor: string = '#B487E8';
  @Prop blueColor: string = '#6E9CD2';
  @Prop cardColor: string = '#221E18';
  @Prop border: string = '#3A3428';
  @Prop textMain: string = '#F5EFE2';
  @Prop textSub: string = '#A89F8C';

  private starColor(): string {
    if (this.star === 5) {
      return this.goldColor;
    }
    if (this.star === 4) {
      return this.purpleColor;
    }
    return this.blueColor;
  }

  private starText(): string {
    if (this.star === 5) {
      return '★ 5';
    }
    if (this.star === 4) {
      return '★ 4';
    }
    return '★ 3';
  }

  build() {
    Row({ space: 12 }) {
      Text(this.starText())
        .fontSize(16)
        .fontWeight(800)
        .fontColor(this.starColor())
        .width(44)

      Column({ space: 4 }) {
        Text(this.itemName)
          .fontSize(15)
          .fontWeight(600)
          .fontColor(this.textMain)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: 8 }) {
          Text(this.poolName)
            .fontSize(11)
            .fontColor(this.textSub)
            .maxLines(1)
          Text(this.dateStr)
            .fontSize(11)
            .fontColor(this.textSub)
          if (this.pullNo > 0) {
            Text(`第${this.pullNo}抽`)
              .fontSize(11)
              .fontColor(this.starColor())
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .borderRadius(10)
    .backgroundColor(this.cardColor)
    .border({ width: { left: 3 }, color: { left: this.starColor() } })
  }
}
