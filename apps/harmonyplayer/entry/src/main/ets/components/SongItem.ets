import { SongInfo } from '../model/SongInfo';

@Reusable
@Component
export struct SongItem {
  @Prop song: SongInfo = new SongInfo();
  @Prop onTap: (song: SongInfo) => void = () => {};

  aboutToReuse(params: Record<string, Object>): void {
    this.song = params.song as SongInfo;
  }

  private formatDuration(duration: number): string {
    const minutes: number = Math.floor(duration / 60000);
    const seconds: number = Math.floor(duration / 1000) % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  build() {
    Row({ space: 12 }) {
      Image(this.song.coverUri || $r('app.media.default_cover'))
        .width(48)
        .height(48)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
      Column({ space: 4 }) {
        Text(this.song.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.song.artist)
          .fontSize(12)
          .fontColor('#666666')
          .maxLines(1)
      }
      .layoutWeight(1)
      Text(this.formatDuration(this.song.duration))
        .fontSize(12)
        .fontColor('#999999')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .onClick(() => this.onTap(this.song))
  }
}
