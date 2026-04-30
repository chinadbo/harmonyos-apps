@Entry
@ComponentV2
export struct WidgetCard {
  @State title: string = 'HarmonyPlayer';
  @State artist: string = '未在播放';
  @State isPlaying: boolean = false;

  build() {
    Row({ space: 12 }) {
      Image($r('app.media.default_cover'))
        .width(56)
        .height(56)
        .borderRadius(12)
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
        Text(this.artist)
          .fontSize(12)
          .fontColor('#666666')
          .maxLines(1)
      }
      .layoutWeight(1)
      Button(this.isPlaying ? '暂停' : '播放')
        .type(ButtonType.Capsule)
        .onClick(() => {
          postCardAction({ action: 'message', params: { action: 'toggle' } });
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
  }
}
