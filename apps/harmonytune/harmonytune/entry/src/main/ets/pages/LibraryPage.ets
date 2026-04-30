import { SongEntity } from '../model/SongEntity';
import { SongListItem } from '../components/SongListItem';
import { PlayerService } from '../service/PlayerService';
import { FormatUtils } from '../utils/FormatUtils';

@ComponentV2
export struct LibraryPage {
  @StorageLink('librarySongs') librarySongs: SongEntity[] = [];
  @StorageLink('currentSong') currentSong: SongEntity = SongEntity.empty();
  @State selectedTab: number = 0;
  @State searchText: string = '';

  private get filteredSongs(): SongEntity[] {
    if (!this.searchText.trim()) {
      return this.librarySongs;
    }
    const keyword = this.searchText.trim().toLowerCase();
    return this.librarySongs.filter((song: SongEntity) => {
      return song.title.toLowerCase().includes(keyword)
        || song.artist.toLowerCase().includes(keyword)
        || song.album.toLowerCase().includes(keyword);
    });
  }

  private groupAlbums(): Array<Record<string, Object>> {
    const groups = new Map<string, { artist: string; count: number; coverPath: string }>();
    this.filteredSongs.forEach((song: SongEntity) => {
      const key = song.album || '未知专辑';
      const current = groups.get(key) || { artist: song.artist, count: 0, coverPath: song.coverPath };
      current.count += 1;
      current.artist = current.artist || song.artist;
      current.coverPath = current.coverPath || song.coverPath;
      groups.set(key, current);
    });
    return Array.from(groups.entries()).map(([album, value]) => ({
      album,
      artist: value.artist,
      count: value.count,
      coverPath: value.coverPath
    }));
  }

  private groupArtists(): Array<Record<string, Object>> {
    const groups = new Map<string, { album: string; count: number }>();
    this.filteredSongs.forEach((song: SongEntity) => {
      const key = song.artist || '未知艺术家';
      const current = groups.get(key) || { album: song.album, count: 0 };
      current.count += 1;
      current.album = current.album || song.album;
      groups.set(key, current);
    });
    return Array.from(groups.entries()).map(([artist, value]) => ({
      artist,
      album: value.album,
      count: value.count
    }));
  }

  private async playSong(song: SongEntity): Promise<void> {
    const filtered = this.filteredSongs;
    const index = Math.max(0, filtered.findIndex((item: SongEntity) => item.path === song.path));
    const playerService = PlayerService.getInstance();
    playerService.setQueue(filtered, index);
    await playerService.play(song);
  }

  @Builder
  private buildHeader(): void {
    Column({ space: 14 }) {
      Text($r('app.string.library_title'))
        .fontSize(28)
        .fontWeight(FontWeight.Black)
        .fontColor('#FFFFFF')
        .width('100%')

      TextInput({ placeholder: $r('app.string.library_search_placeholder'), text: this.searchText })
        .placeholderColor('#7480A8')
        .backgroundColor('#12182A')
        .fontColor('#F5F7FF')
        .caretColor('#8FA2FF')
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.searchText = value;
        })

      Tabs({ barPosition: BarPosition.Start, index: this.selectedTab }) {
        TabContent() {
          this.buildSongList();
        }
        .tabBar($r('app.string.library_all_songs'))

        TabContent() {
          this.buildAlbumList();
        }
        .tabBar($r('app.string.library_album'))

        TabContent() {
          this.buildArtistList();
        }
        .tabBar($r('app.string.library_artist'))
      }
      .barMode(BarMode.Scrollable)
      .barWidth('100%')
      .barHeight(44)
      .backgroundColor('#090B13')
      .onChange((index: number) => {
        this.selectedTab = index;
      })
      .width('100%')
      .height('100%')
    }
    .width('100%')
  }

  @Builder
  private buildSongList(): void {
    if (!this.filteredSongs.length) {
      this.buildEmptyState('歌曲');
      return;
    }
    Scroll() {
      Column({ space: 12 }) {
        Row() {
          Text(`搜索结果 ${this.filteredSongs.length} 首`)
            .fontSize(13)
            .fontColor('#7E88B0')
          Blank()
          Text('点击歌曲立即播放')
            .fontSize(12)
            .fontColor('#6C769E')
        }
        .width('100%')
        ForEach(this.filteredSongs, (song: SongEntity) => {
          SongListItem({
            song,
            isActive: song.path === this.currentSong.path,
            onPlay: (selected: SongEntity) => {
              void this.playSong(selected);
            },
            onFavorite: (selected: SongEntity) => {
              selected.isFavorite = !selected.isFavorite;
              this.librarySongs = [...this.librarySongs];
              AppStorage.setOrCreate('librarySongs', this.librarySongs);
            }
          })
        }, (song: SongEntity) => `${song.id}-${song.path}`)
      }
      .width('100%')
      .padding({ top: 16, bottom: 140 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildAlbumList(): void {
    const albums = this.groupAlbums();
    if (!albums.length) {
      this.buildEmptyState('专辑');
      return;
    }
    Scroll() {
      Column({ space: 14 }) {
        ForEach(albums, (album: Record<string, Object>) => {
          Column({ space: 10 }) {
            Row({ space: 14 }) {
              Stack({ alignContent: Alignment.Center }) {
                Rect()
                  .width(62)
                  .height(62)
                  .radius(18)
                  .fill('#1B2137')
                Text('💿')
                  .fontSize(24)
              }
              Column({ space: 6 }) {
                Text(String(album.album))
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .width('100%')
                Text(`${String(album.artist)} · ${FormatUtils.groupCountLabel(Number(album.count))}`)
                  .fontSize(13)
                  .fontColor('#8E97B8')
                  .width('100%')
              }
              .layoutWeight(1)
            }
            .width('100%')

            Text('专辑视图用于快速浏览同一张唱片下的全部曲目，适合按完整专辑顺序播放。')
              .fontSize(12)
              .fontColor('#6D769A')
              .width('100%')
          }
          .width('100%')
          .padding(18)
          .backgroundColor('#111726')
          .borderRadius(24)
        }, (album: Record<string, Object>) => String(album.album))
      }
      .width('100%')
      .padding({ top: 16, bottom: 140 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildArtistList(): void {
    const artists = this.groupArtists();
    if (!artists.length) {
      this.buildEmptyState('艺术家');
      return;
    }
    Scroll() {
      Column({ space: 14 }) {
        ForEach(artists, (artist: Record<string, Object>) => {
          Row({ space: 14 }) {
            Stack({ alignContent: Alignment.Center }) {
              Circle()
                .width(58)
                .height(58)
                .fill('#1B2137')
              Text('🎤')
                .fontSize(24)
            }
            Column({ space: 6 }) {
              Text(String(artist.artist))
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(`${FormatUtils.groupCountLabel(Number(artist.count))} · 代表专辑 ${String(artist.album || '--')}`)
                .fontSize(13)
                .fontColor('#8E97B8')
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding(18)
          .backgroundColor('#111726')
          .borderRadius(24)
        }, (artist: Record<string, Object>) => String(artist.artist))
      }
      .width('100%')
      .padding({ top: 16, bottom: 140 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildEmptyState(typeLabel: string): void {
    Column({ space: 10 }) {
      Text($r('app.string.library_empty'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
      Text(`请先扫描本地媒体后再查看${typeLabel}内容。`)
        .fontSize(13)
        .fontColor('#7E88B0')
      Button($r('app.string.home_scan_music'))
        .type(ButtonType.Capsule)
        .backgroundColor('#7B8DFF')
        .fontColor('#09101F')
        .onClick(() => {
          this.librarySongs = [];
          AppStorage.setOrCreate('librarySongs', []);
        })
    }
    .width('100%')
    .height(280)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#111726')
    .borderRadius(24)
    .margin({ top: 20 })
  }

  build() {
    Column() {
      this.buildHeader();
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 20 })
    .backgroundColor('#090B13')
  }
}
