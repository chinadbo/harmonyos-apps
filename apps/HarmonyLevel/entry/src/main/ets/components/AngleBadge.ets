// 角度数字徽章：大字号 + 色彩状态（level 绿 / near 黄 / off 常规色）。
@Component
export struct AngleBadge {
  @Prop text: string = '0.0';
  @Prop status: string = 'off';
  @Prop label: string = '';

  build() {
    Column({ space: 2 }) {
      Row() {
        Text(this.text)
          .fontSize(52)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.colorOf(this.status))
          .maxLines(1)
        Text('°')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.colorOf(this.status))
      }
      .alignItems(VerticalAlign.Bottom)

      if (this.label.length > 0) {
        Text(this.label)
          .fontSize(12)
          .fontColor('#93a1b0')
      }
    }
    .alignItems(HorizontalAlign.Center)
  }

  private colorOf(status: string): string {
    if (status === 'level') {
      return '#35e08a';
    }
    if (status === 'near') {
      return '#ffc14d';
    }
    return '#e8edf2';
  }
}
