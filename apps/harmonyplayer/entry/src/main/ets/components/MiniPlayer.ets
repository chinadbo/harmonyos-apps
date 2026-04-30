import router from '@ohos.router';
import { PlayerService } from '../service/PlayerService';
import { SongInfo } from '../model/SongInfo';
import { PlayerViewModel } from '../viewmodel/PlayerViewModel';

@Component
export struct MiniPlayer {
  @StorageProp(PlayerViewModel.KEY_IS_PLAYING) isPlaying: boolean = false;
  @StorageProp(PlayerViewModel.KEY_CURRENT_SONG) currentSong: SongInfo | null = null;

  build() {
    if (this.currentSong !== null) {
      Row({ space: 12 }) {
        Image(this.currentSong.coverUri || $r('app.media.default_cover'))
          .width(40)
          .height(40)
          .borderRadius(8)
        Column({ space: 4 }) {
          Text(this.currentSong.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
          Text(this.currentSong.artist)
            .fontSize(12)
            .fontColor('#666666')
            .maxLines(1)
        }
        .layoutWeight(1)
        Button(this.isPlaying ? '暂停' : '播放')
          .type(ButtonType.Capsule)
          .fontSize(12)
          .onClick(async (event?: ClickEvent) => {
            event?.stopPropagation();
            await PlayerService.getInstance().togglePlayPause();
          })
        Button('下一首')
          .type(ButtonType.Capsule)
          .fontSize(12)
          .onClick(async (event?: ClickEvent) => {
            event?.stopPropagation();
            await PlayerService.getInstance().next();
          })
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F5F5F5')
      .borderRadius(16)
      .onClick(() => {
        router.pushUrl({ url: 'pages/PlayerPage' });
      })
    }
  }
}
