
@Component
export struct TranslateResultCard {
  @Prop result: string;
  @Prop isVisible: boolean;
  onCopy: () => void = () => {};
  onShare: () => void = () => {};
  onFavorite: () => void = () => {};
  @Prop isFavorite: boolean;

  build() {
    Column() {
      Text('翻译结果')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 8, top: 16 })
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(this.result)
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 16 })

      Row() {
        Button() {
          Text('📋 复制')
            .fontSize(14)
            .fontColor('#FFFFFF')
        }
        .backgroundColor('#4A90D9')
        .width(80)
        .height(36)
        .onClick(() => this.onCopy())

        Button() {
          Text('🔗 分享')
            .fontSize(14)
            .fontColor('#FFFFFF')
        }
        .backgroundColor('#4A90D9')
        .width(80)
        .height(36)
        .onClick(() => this.onShare())

        Button() {
          Text(this.isFavorite ? '⭐ 已收藏' : '☆ 收藏')
            .fontSize(14)
            .fontColor('#FFFFFF')
        }
        .backgroundColor(this.isFavorite ? '#FF9500' : '#4A90D9')
        .width(80)
        .height(36)
        .onClick(() => this.onFavorite())
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F8F9FA')
    .borderRadius(12)
    .opacity(this.isVisible ? 1 : 0)
    .translate({ y: this.isVisible ? 0 : 20 })
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }
}
