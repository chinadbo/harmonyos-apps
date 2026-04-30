import { SongEntity } from '../model/SongEntity';
import { FormatUtils } from '../utils/FormatUtils';

@ComponentV2
export struct MiniPlayer {
  @StorageLink('currentSong') currentSong: SongEntity = SongEntity.empty();
  @StorageLink('currentTime') currentTime: number = 0;
  @StorageLink('currentDuration') currentDuration: number = 0;
  @StorageLink('isPlaying') isPlaying: boolean = false;
  onTogglePlay?: () => void;
  onOpenPlayer?: () => void;
  onNext?: () => void;

  private progress(): number {
    if (!this.currentDuration) {
      return 0;
    }
    return Math.min(1, this.currentTime / this.currentDuration);
  }

  build() {
    if (!this.currentSong.path && !this.currentSong.title) {
      Blank();
      return;
    }

    Column({ space: 10 }) {
      Row({ space: 12 }) {
        Stack({ alignContent: Alignment.Center }) {
          Rect()
            .width(48)
            .height(48)
            .radius(16)
            .fill('#202745')
          Text('♪')
            .fontColor('#FFFFFF')
            .fontSize(22)
        }
        Column({ space: 4 }) {
          Text(this.currentSong.title || $r('app.string.mini_player_default_title'))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .maxLines(1)
          Text(`${this.currentSong.artist || $r('app.string.mini_player_default_artist')} · ${FormatUtils.formatDuration(this.currentDuration)}`)
            .fontSize(12)
            .fontColor('#9BA3C7')
            .maxLines(1)
        }
        .layoutWeight(1)

        Row({ space: 18 }) {
          Text(this.isPlaying ? '❚❚' : '▶')
            .fontSize(22)
            .fontColor('#FFFFFF')
            .onClick(() => this.onTogglePlay?.())
          Text('⏭')
            .fontSize(20)
            .fontColor('#FFFFFF')
            .onClick(() => this.onNext?.())
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Stack({ alignContent: Alignment.Start }) {
        Rect()
          .width('100%')
          .height(3)
          .radius(3)
          .fill('#232944')
        Rect()
          .width(`${this.progress() * 100}%`)
          .height(3)
          .radius(3)
          .fill('#8EA0FF')
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor('#0E1220')
    .borderRadius({ topLeft: 24, topRight: 24, bottomLeft: 0, bottomRight: 0 })
    .shadow({ radius: 24, color: '#55000000', offsetX: 0, offsetY: -6 })
    .onClick(() => this.onOpenPlayer?.())
  }
}
