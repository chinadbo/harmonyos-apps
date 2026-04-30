import { SongEntity } from '../model/SongEntity';
import { PlayerService } from '../service/PlayerService';
import { MediaScanService } from '../service/MediaScanService';
import { SongListItem } from '../components/SongListItem';
import { FormatUtils } from '../utils/FormatUtils';

@ComponentV2
export struct MainPage {
  @StorageLink('librarySongs') librarySongs: SongEntity[] = [];
  @StorageLink('recentSongs') recentSongs: SongEntity[] = [];
  @State heroMessage: string = '让每一首歌都拥有属于自己的舞台';
  @State scanSummary: string = '支持 MP3 / FLAC / AAC / WAV';

  aboutToAppear(): void {
    this.ensureMockLibrary();
  }

  private ensureMockLibrary(): void {
    if (this.librarySongs.length) {
      return;
    }
    const mockSongs = MediaScanService.getInstance().createMockSongs();
    this.librarySongs = mockSongs.map((song: SongEntity) => song.clone());
    AppStorage.setOrCreate('librarySongs', this.librarySongs);
  }

  private async playSong(song: SongEntity): Promise<void> {
    const playerService = PlayerService.getInstance();
    playerService.setQueue(this.librarySongs, Math.max(0, this.librarySongs.findIndex((item: SongEntity) => item.path === song.path)));
    await playerService.play(song);
  }

  private async quickPlayFirst(): Promise<void> {
    if (!this.librarySongs.length) {
      this.ensureMockLibrary();
    }
    if (this.librarySongs.length) {
      await this.playSong(this.librarySongs[0]);
    }
  }

  private scanMusic(): void {
    const songs = MediaScanService.getInstance().createMockSongs();
    this.librarySongs = songs.map((song: SongEntity) => song.clone());
    AppStorage.setOrCreate('librarySongs', this.librarySongs);
    this.scanSummary = `已为你准备 ${songs.length} 首可体验歌曲`;
    this.heroMessage = '音乐库已准备就绪，点击任意歌曲开始播放';
  }

  @Builder
  private buildHeroSection(): void {
    Column({ space: 18 }) {
      Row() {
        Text('HarmonyTune')
          .fontSize(28)
          .fontWeight(FontWeight.Black)
          .fontColor('#FFFFFF')
        Blank()
        Column({ space: 4 }) {
          Text('API 16')
            .fontSize(12)
            .fontColor('#AEB8DB')
          Text('AppGallery Ready')
            .fontSize(12)
            .fontColor('#7D86A8')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      Text(this.heroMessage)
        .fontSize(16)
        .fontColor('#C9D1F1')
        .lineHeight(26)

      Row({ space: 12 }) {
        Button($r('app.string.home_scan_music'))
          .type(ButtonType.Capsule)
          .backgroundColor('#7B8DFF')
          .fontColor('#09101F')
          .fontWeight(FontWeight.Bold)
          .onClick(() => this.scanMusic())

        Button($r('app.string.home_quick_play'))
          .type(ButtonType.Capsule)
          .backgroundColor('#1B2238')
          .fontColor('#D8DEFF')
          .onClick(() => {
            void this.quickPlayFirst();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Text(this.scanSummary)
        .fontSize(13)
        .fontColor('#8791B8')
    }
    .width('100%')
    .padding(22)
    .backgroundColor('#101728')
    .borderRadius(28)
    .shadow({ radius: 18, color: '#3B000000', offsetX: 0, offsetY: 6 })
  }

  @Builder
  private buildQuickEntryCard(title: ResourceStr, subtitle: string, icon: string, clickAction: () => void): void {
    Column({ space: 16 }) {
      Row() {
        Text(icon)
          .fontSize(28)
          .fontColor('#FFFFFF')
        Blank()
        Text('→')
          .fontSize(20)
          .fontColor('#9099BD')
      }
      .width('100%')

      Text(title)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#F8FAFF')
        .width('100%')
      Text(subtitle)
        .fontSize(13)
        .fontColor('#9099BD')
        .lineHeight(20)
        .width('100%')
    }
    .width('100%')
    .height(150)
    .padding(18)
    .backgroundColor('#131A2E')
    .borderRadius(24)
    .onClick(() => clickAction())
  }

  @Builder
  private buildQuickEntries(): void {
    GridRow({ columns: 2, gutter: { x: 12, y: 12 } }) {
      GridCol({ span: 1 }) {
        this.buildQuickEntryCard($r('app.string.home_card_library'), '按歌曲、专辑和艺术家浏览你的音乐收藏。', '🎼', () => {
          this.heroMessage = '前往音乐库探索你导入的所有声音。';
        });
      }
      GridCol({ span: 1 }) {
        this.buildQuickEntryCard($r('app.string.home_card_playlist'), '把不同情绪的曲目整理到你的专属歌单。', '📝', () => {
          this.heroMessage = '从收藏、最近播放中快速生成歌单。';
        });
      }
      GridCol({ span: 1 }) {
        this.buildQuickEntryCard($r('app.string.home_card_player'), '进入沉浸式播放页，享受旋转碟片与歌词滚动。', '💿', () => {
          void this.quickPlayFirst();
        });
      }
      GridCol({ span: 1 }) {
        this.buildQuickEntryCard($r('app.string.home_card_transfer'), '为跨设备流转和锁屏控制预留媒体会话能力。', '📲', () => {
          this.heroMessage = 'HarmonyTune 已准备好扩展跨设备播放体验。';
        });
      }
    }
  }

  @Builder
  private buildWelcomeSection(): void {
    if (this.librarySongs.length) {
      Column({ space: 14 }) {
        Row() {
          Text('音乐概览')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Blank()
          Text(`${this.librarySongs.length} 首歌曲`)
            .fontSize(13)
            .fontColor('#8D95B8')
        }
        .width('100%')

        Row({ space: 12 }) {
          Column({ space: 8 }) {
            Text('最近导入')
              .fontSize(13)
              .fontColor('#8D95B8')
            Text(this.librarySongs[0]?.title || '--')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text(FormatUtils.formatRelativeTime(this.librarySongs[0]?.addedAt || Date.now()))
              .fontSize(12)
              .fontColor('#7882A9')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .padding(18)
          .backgroundColor('#141A2D')
          .borderRadius(22)

          Column({ space: 8 }) {
            Text('收藏歌曲')
              .fontSize(13)
              .fontColor('#8D95B8')
            Text(`${this.librarySongs.filter((song: SongEntity) => song.isFavorite).length}`)
              .fontSize(28)
              .fontWeight(FontWeight.Black)
              .fontColor('#FFFFFF')
            Text('随时点亮心动')
              .fontSize(12)
              .fontColor('#7882A9')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .padding(18)
          .backgroundColor('#141A2D')
          .borderRadius(22)
        }
        .width('100%')
      }
      return;
    }

    Column({ space: 14 }) {
      Text($r('app.string.home_no_music_title'))
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('100%')
      Text($r('app.string.home_no_music_desc'))
        .fontSize(15)
        .fontColor('#AAB4D9')
        .lineHeight(24)
        .width('100%')
      Button($r('app.string.home_go_scan'))
        .type(ButtonType.Capsule)
        .backgroundColor('#7B8DFF')
        .fontColor('#09101F')
        .fontWeight(FontWeight.Bold)
        .onClick(() => this.scanMusic())
    }
    .width('100%')
    .padding(22)
    .backgroundColor('#111726')
    .borderRadius(28)
  }

  @Builder
  private buildRecentSection(): void {
    Column({ space: 14 }) {
      Row() {
        Text($r('app.string.home_recent_play'))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Blank()
        Text(`${this.recentSongs.length}/10`)
          .fontSize(13)
          .fontColor('#8D95B8')
      }
      .width('100%')

      if (!this.recentSongs.length) {
        Column({ space: 10 }) {
          Text($r('app.string.home_recent_empty'))
            .fontSize(15)
            .fontColor('#A5AECE')
          Text('播放歌曲后，这里会展示你的最近聆听轨迹。')
            .fontSize(13)
            .fontColor('#7680A7')
        }
        .width('100%')
        .padding(22)
        .backgroundColor('#111726')
        .borderRadius(24)
      } else {
        Column({ space: 12 }) {
          ForEach(this.recentSongs.slice(0, 10), (song: SongEntity) => {
            SongListItem({
              song,
              isActive: false,
              onPlay: (selected: SongEntity) => {
                void this.playSong(selected);
              },
              onFavorite: (selected: SongEntity) => {
                selected.isFavorite = !selected.isFavorite;
                this.recentSongs = [...this.recentSongs];
              }
            })
          }, (song: SongEntity) => `${song.path}-${song.id}`)
        }
      }
    }
    .width('100%')
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        this.buildHeroSection();
        this.buildQuickEntries();
        this.buildWelcomeSection();
        this.buildRecentSection();
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 120 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#090B13')
  }
}
