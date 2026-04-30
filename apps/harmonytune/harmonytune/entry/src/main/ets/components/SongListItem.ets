import { SongEntity } from '../model/SongEntity';
import { FormatUtils } from '../utils/FormatUtils';

@ComponentV2
export struct SongListItem {
  @Prop song: SongEntity = SongEntity.empty();
  @Prop isActive: boolean = false;
  onPlay?: (song: SongEntity) => void;
  onFavorite?: (song: SongEntity) => void;

  build() {
    Row({ space: 14 }) {
      Stack({ alignContent: Alignment.Center }) {
        Rect()
          .width(52)
          .height(52)
          .radius(14)
          .fill(this.isActive ? '#7C8CFF' : '#1D2236')
        Text('♪')
          .fontColor('#FFFFFF')
          .fontSize(24)
      }
      Column({ space: 6 }) {
        Text(this.song.title)
          .fontSize(17)
          .fontWeight(this.isActive ? FontWeight.Bold : FontWeight.Medium)
          .fontColor('#F5F7FF')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(`${this.song.artist} · ${this.song.album}`)
          .fontSize(13)
          .fontColor('#8E96B4')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)

      Column({ space: 6 }) {
        Text(FormatUtils.formatDuration(this.song.duration))
          .fontSize(12)
          .fontColor('#96A0C5')
        Text(this.song.isFavorite ? '♥' : '♡')
          .fontSize(16)
          .fontColor(this.song.isFavorite ? '#FF7CA8' : '#A6B0D3')
          .onClick(() => {
            this.onFavorite?.(this.song);
          })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding(16)
    .borderRadius(18)
    .backgroundColor(this.isActive ? '#1D2442' : '#111522')
    .onClick(() => {
      this.onPlay?.(this.song);
    })
  }
}
