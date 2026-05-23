@Component
export struct EmptyState {
  @Prop title: string = '暂无数据';
  @Prop description: string = '';
  @Prop iconName: string = 'clipboard';

  build() {
    Column({ space: 12 }) {
      Image($r('sys.media.ohos_ic_public_clipboard'))
        .width(64)
        .height(64)
        .fillColor('#CCCCCC')
        .opacity(0.6)

      Text(this.title)
        .fontSize(17)
        .fontColor('#182431')
        .fontWeight(FontWeight.Medium)

      if (this.description) {
        Text(this.description)
          .fontSize(14)
          .fontColor('#99182431')
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .padding({ left: 40, right: 40 })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 80, bottom: 80 })
  }
}
