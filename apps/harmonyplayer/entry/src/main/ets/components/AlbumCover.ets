@Component
export struct AlbumCover {
  @Prop coverUri: string = '';
  @StorageProp('isPlaying') isPlaying: boolean = false;

  build() {
    Stack() {
      Image(this.coverUri || $r('app.media.default_cover'))
        .width(260)
        .height(260)
        .borderRadius(130)
        .objectFit(ImageFit.Cover)
        .rotate({ angle: this.isPlaying ? 360 : 0 })
        .animation({ duration: 12000, curve: Curve.Linear, iterations: -1, playMode: PlayMode.Normal })
    }
    .width(280)
    .height(280)
    .backgroundColor('#F4F4F4')
    .borderRadius(140)
  }
}
