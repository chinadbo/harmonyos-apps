import { SongInfo } from '../model/SongInfo';
import { PlayerService } from '../service/PlayerService';
import { PlayerViewModel } from '../viewmodel/PlayerViewModel';

@Component
export struct PlaylistPage {
  @StorageProp(PlayerViewModel.KEY_PLAY_QUEUE) playQueue: SongInfo[] = [];
  @StorageProp(PlayerViewModel.KEY_CURRENT_SONG) currentSong: SongInfo | null = null;

  build() {
    Column({ space: 12 }) {
      Row() {
        Text(`当前队列 (${this.playQueue.length})`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('清空队列')
          .type(ButtonType.Capsule)
          .onClick(async () => {
            await PlayerService.getInstance().clearQueue();
          })
      }
      List({ space: 8 }) {
        ForEach(this.playQueue, (song: SongInfo, index: number) => {
          ListItem() {
            Row({ space: 12 }) {
              Text(`${index + 1}`)
                .width(24)
                .fontColor('#999999')
              Column({ space: 2 }) {
                Text(song.title)
                  .fontSize(16)
                  .fontWeight(song.uri === this.currentSong?.uri ? FontWeight.Bold : FontWeight.Regular)
                Text(song.artist)
                  .fontSize(12)
                  .fontColor('#666666')
              }
              .layoutWeight(1)
            }
            .padding(12)
            .backgroundColor(song.uri === this.currentSong?.uri ? '#EEF5FF' : '#FFFFFF')
            .borderRadius(12)
            .onClick(async () => {
              await PlayerService.getInstance().playAt(index);
            })
          }
        }, (song: SongInfo) => song.uri)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
