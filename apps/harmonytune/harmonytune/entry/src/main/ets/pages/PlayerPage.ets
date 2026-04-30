import { SongEntity } from '../model/SongEntity';
import { DiscCover } from '../components/DiscCover';
import { LyricsView } from '../components/LyricsView';
import { PlayerService, PlayMode } from '../service/PlayerService';
import { FormatUtils } from '../utils/FormatUtils';

@ComponentV2
export struct PlayerPage {
  @StorageLink('currentSong') currentSong: SongEntity = SongEntity.empty();
  @StorageLink('currentTime') currentTime: number = 0;
  @StorageLink('currentDuration') currentDuration: number = 0;
  @StorageLink('isPlaying') isPlaying: boolean = false;
  @StorageLink('playMode') playMode: number = PlayMode.SEQUENCE;
  @StorageLink('librarySongs') librarySongs: SongEntity[] = [];
  @State sliderValue: number = 0;

  aboutToAppear(): void {
    this.syncSlider();
    if (!this.currentSong.path && this.librarySongs.length) {
      this.currentSong = this.librarySongs[0].clone();
    }
  }

  private syncSlider(): void {
    this.sliderValue = this.currentTime;
  }

  private playModeLabel(): ResourceStr | string {
    if (this.playMode === PlayMode.SHUFFLE) {
      return $r('app.string.player_mode_shuffle');
    }
    if (this.playMode === PlayMode.REPEAT_ONE) {
      return $r('app.string.player_mode_repeat_one');
    }
    return $r('app.string.player_mode_sequence');
  }

  private async togglePlay(): Promise<void> {
    const playerService = PlayerService.getInstance();
    if (this.isPlaying) {
      await playerService.pause();
      return;
    }
    if (this.currentSong.path || this.currentSong.title) {
      if (this.currentTime > 0) {
        await playerService.resume();
      } else {
        const queue = this.librarySongs.length ? this.librarySongs : [this.currentSong];
        playerService.setQueue(queue, Math.max(0, queue.findIndex((song: SongEntity) => song.path === this.currentSong.path)));
        await playerService.play(this.currentSong);
      }
      return;
    }
    if (this.librarySongs.length) {
      playerService.setQueue(this.librarySongs, 0);
      await playerService.play(this.librarySongs[0]);
    }
  }

  private async playNext(): Promise<void> {
    await PlayerService.getInstance().next();
  }

  private async playPrev(): Promise<void> {
    await PlayerService.getInstance().prev();
  }

  private async toggleFavorite(): Promise<void> {
    this.currentSong.isFavorite = !this.currentSong.isFavorite;
    AppStorage.setOrCreate('currentSong', this.currentSong);
    await PlayerService.getInstance().toggleFavorite();
  }

  private cyclePlayMode(): void {
    const mode = PlayerService.getInstance().cyclePlayMode();
    this.playMode = mode;
  }

  build() {
    Column({ space: 18 }) {
      Row() {
        Column({ space: 6 }) {
          Text($r('app.string.player_now_playing'))
            .fontSize(13)
            .fontColor('#7E88B0')
          Text('HarmonyTune Player')
            .fontSize(22)
            .fontWeight(FontWeight.Black)
            .fontColor('#FFFFFF')
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text(this.playModeLabel())
          .fontSize(12)
          .fontColor('#A8B2D7')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor('#141B30')
          .borderRadius(16)
      }
      .width('100%')
      .padding({ top: 8 })

      DiscCover({
        coverPath: this.currentSong.coverPath,
        isPlaying: this.isPlaying
      })

      Column({ space: 8 }) {
        Text(this.currentSong.title || '请选择一首歌曲')
          .fontSize(30)
          .fontWeight(FontWeight.Black)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
          .width('100%')
        Text(this.currentSong.artist || 'HarmonyTune')
          .fontSize(15)
          .fontColor('#A4ADD0')
          .textAlign(TextAlign.Center)
          .width('100%')
        Text(this.currentSong.album || '本地音乐')
          .fontSize(13)
          .fontColor('#7982A7')
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .width('100%')

      Column({ space: 10 }) {
        Slider({
          value: this.sliderValue,
          min: 0,
          max: Math.max(this.currentDuration, 1),
          step: 1000,
          style: SliderStyle.OutSet
        })
          .width('100%')
          .blockColor('#FFFFFF')
          .trackColor('#2A3150')
          .selectedColor('#8FA2FF')
          .onChange((value: number, mode: SliderChangeMode) => {
            this.sliderValue = value;
            if (mode === SliderChangeMode.End) {
              void PlayerService.getInstance().seekTo(value);
            }
          })
        Row() {
          Text(FormatUtils.formatDuration(this.currentTime))
            .fontSize(12)
            .fontColor('#8D95B8')
          Blank()
          Text(FormatUtils.formatDuration(this.currentDuration))
            .fontSize(12)
            .fontColor('#8D95B8')
        }
        .width('100%')
      }
      .width('100%')

      Row({ space: 26 }) {
        Column({ space: 8 }) {
          Text('⟲')
            .fontSize(22)
            .fontColor('#C8D0F2')
          Text(this.playModeLabel())
            .fontSize(11)
            .fontColor('#7F88AC')
        }
        .onClick(() => this.cyclePlayMode())

        Text('⏮')
          .fontSize(28)
          .fontColor('#FFFFFF')
          .onClick(() => {
            void this.playPrev();
          })

        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(88)
            .height(88)
            .fill('#7B8DFF')
            .shadow({ radius: 20, color: '#557B8DFF', offsetX: 0, offsetY: 8 })
          Text(this.isPlaying ? '❚❚' : '▶')
            .fontSize(32)
            .fontColor('#08101E')
            .fontWeight(FontWeight.Bold)
        }
        .onClick(() => {
          void this.togglePlay();
        })

        Text('⏭')
          .fontSize(28)
          .fontColor('#FFFFFF')
          .onClick(() => {
            void this.playNext();
          })

        Column({ space: 8 }) {
          Text(this.currentSong.isFavorite ? '♥' : '♡')
            .fontSize(24)
            .fontColor(this.currentSong.isFavorite ? '#FF7CA8' : '#C8D0F2')
          Text(this.currentSong.isFavorite ? $r('app.string.common_unfavorite') : $r('app.string.common_favorite'))
            .fontSize(11)
            .fontColor('#7F88AC')
        }
        .onClick(() => {
          void this.toggleFavorite();
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      LyricsView({
        lyrics: this.currentSong.lyrics,
        currentTime: this.currentTime,
        duration: Math.max(this.currentDuration, 1)
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 120 })
    .backgroundColor('#05070D')
  }
}
