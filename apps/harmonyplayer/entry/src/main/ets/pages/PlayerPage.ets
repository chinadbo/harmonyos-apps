import { SongInfo } from '../model/SongInfo';
import { PlayMode } from '../model/PlayMode';
import { LyricLine } from '../model/LyricLine';
import { AlbumCover } from '../components/AlbumCover';
import { ProgressBar } from '../components/ProgressBar';
import { LyricView } from '../components/LyricView';
import { PlayerService } from '../service/PlayerService';
import { PlayerViewModel } from '../viewmodel/PlayerViewModel';

@Component
export struct PlayerPage {
  @StorageProp(PlayerViewModel.KEY_CURRENT_SONG) currentSong: SongInfo | null = null;
  @StorageProp(PlayerViewModel.KEY_IS_PLAYING) isPlaying: boolean = false;
  @StorageProp(PlayerViewModel.KEY_CURRENT_TIME) currentTime: number = 0;
  @StorageProp(PlayerViewModel.KEY_TOTAL_TIME) totalTime: number = 0;
  @StorageProp(PlayerViewModel.KEY_PLAY_MODE) playMode: PlayMode = PlayMode.SEQUENCE;
  @StorageProp(PlayerViewModel.KEY_LYRIC_LINES) lyricLines: LyricLine[] = [];

  private async switchMode(): Promise<void> {
    const nextMode: PlayMode = this.playMode === PlayMode.REPEAT_ALL ? PlayMode.SEQUENCE : this.playMode + 1;
    await PlayerService.getInstance().setPlayMode(nextMode);
  }

  private modeLabel(): string {
    if (this.playMode === PlayMode.SHUFFLE) {
      return '随机';
    }
    if (this.playMode === PlayMode.REPEAT_ONE) {
      return '单曲';
    }
    if (this.playMode === PlayMode.REPEAT_ALL) {
      return '列表';
    }
    return '顺序';
  }

  build() {
    Column({ space: 20 }) {
      Text(this.currentSong?.title ?? '未在播放')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .maxLines(1)
      Text(this.currentSong?.artist ?? '请选择一首歌曲开始播放')
        .fontSize(14)
        .fontColor('#666666')
      AlbumCover({ coverUri: this.currentSong?.coverUri ?? '' })
      ProgressBar({
        currentTime: this.currentTime,
        totalTime: this.totalTime,
        onSeek: async (value: number) => {
          await PlayerService.getInstance().seekTo(value);
        }
      })
      Row({ space: 16 }) {
        Button(this.modeLabel())
          .type(ButtonType.Capsule)
          .onClick(async () => { await this.switchMode(); })
        Button('上一首')
          .type(ButtonType.Capsule)
          .onClick(async () => { await PlayerService.getInstance().previous(); })
        Button(this.isPlaying ? '暂停' : '播放')
          .type(ButtonType.Capsule)
          .onClick(async () => { await PlayerService.getInstance().togglePlayPause(); })
        Button('下一首')
          .type(ButtonType.Capsule)
          .onClick(async () => { await PlayerService.getInstance().next(); })
      }
      .justifyContent(FlexAlign.Center)
      LyricView({ lines: this.lyricLines })
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
  }
}
