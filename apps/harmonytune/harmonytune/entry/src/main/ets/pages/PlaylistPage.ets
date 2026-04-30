import { PlaylistEntity } from '../model/PlaylistEntity';
import { SongEntity } from '../model/SongEntity';
import { PlayerService } from '../service/PlayerService';
import { SongListItem } from '../components/SongListItem';

@ComponentV2
export struct PlaylistPage {
  @StorageLink('librarySongs') librarySongs: SongEntity[] = [];
  @State playlists: PlaylistEntity[] = [];
  @State selectedPlaylistId: number = 0;
  @State createCounter: number = 1;

  aboutToAppear(): void {
    this.ensurePlaylists();
  }

  private ensurePlaylists(): void {
    if (this.playlists.length) {
      return;
    }
    const favorites = this.librarySongs.filter((song: SongEntity) => song.isFavorite);
    const recent = [...this.librarySongs].slice(0, Math.min(5, this.librarySongs.length));
    this.playlists = [
      new PlaylistEntity({ id: 1, name: '我喜欢的旋律', songs: favorites, createdAt: Date.now() - 60000 }),
      new PlaylistEntity({ id: 2, name: '通勤氛围组', songs: recent, createdAt: Date.now() - 120000 }),
      new PlaylistEntity({ id: 3, name: '夜晚安静时', songs: [...this.librarySongs].reverse().slice(0, Math.min(4, this.librarySongs.length)), createdAt: Date.now() - 240000 })
    ];
    this.selectedPlaylistId = this.playlists[0]?.id || 0;
  }

  private selectedPlaylist(): PlaylistEntity | undefined {
    return this.playlists.find((playlist: PlaylistEntity) => playlist.id === this.selectedPlaylistId);
  }

  private createPlaylist(): void {
    const nextId = this.playlists.length ? Math.max(...this.playlists.map((item: PlaylistEntity) => item.id)) + 1 : 1;
    const count = Math.min(this.librarySongs.length, 3 + this.createCounter);
    const songs = this.librarySongs.slice(0, count).map((song: SongEntity) => song.clone());
    const playlist = new PlaylistEntity({
      id: nextId,
      name: `新歌收藏夹 ${this.createCounter}`,
      songs,
      createdAt: Date.now()
    });
    this.createCounter += 1;
    this.playlists = [playlist, ...this.playlists];
    this.selectedPlaylistId = playlist.id;
  }

  private async playPlaylistSong(song: SongEntity, playlist: PlaylistEntity): Promise<void> {
    const index = Math.max(0, playlist.songs.findIndex((item: SongEntity) => item.path === song.path));
    const playerService = PlayerService.getInstance();
    playerService.setQueue(playlist.songs, index);
    await playerService.play(song);
  }

  @Builder
  private buildHeader(): void {
    Row() {
      Column({ space: 6 }) {
        Text($r('app.string.playlist_title'))
          .fontSize(28)
          .fontWeight(FontWeight.Black)
          .fontColor('#FFFFFF')
        Text('把不同场景的声音收纳成你专属的情绪地图。')
          .fontSize(13)
          .fontColor('#8A93B8')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Button($r('app.string.playlist_create'))
        .type(ButtonType.Capsule)
        .backgroundColor('#7B8DFF')
        .fontColor('#09101F')
        .fontWeight(FontWeight.Bold)
        .onClick(() => this.createPlaylist())
    }
    .width('100%')
  }

  @Builder
  private buildPlaylistCards(): void {
    if (!this.playlists.length) {
      Column({ space: 12 }) {
        Text($r('app.string.playlist_empty'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text('点击右上角按钮即可用当前音乐库自动生成一组体验歌单。')
          .fontSize(13)
          .fontColor('#8791B8')
      }
      .width('100%')
      .padding(24)
      .backgroundColor('#111726')
      .borderRadius(24)
      return;
    }

    Scroll({ scrollable: true, scrollBar: BarState.Off }) {
      Row({ space: 12 }) {
        ForEach(this.playlists, (playlist: PlaylistEntity) => {
          Column({ space: 14 }) {
            Row() {
              Text('🎧')
                .fontSize(24)
              Blank()
              Text(playlist.id === this.selectedPlaylistId ? '当前' : '选择')
                .fontSize(12)
                .fontColor(playlist.id === this.selectedPlaylistId ? '#0A1020' : '#AEB7DA')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(playlist.id === this.selectedPlaylistId ? '#DCE3FF' : '#1B2238')
                .borderRadius(12)
            }
            .width('100%')
            Column({ space: 8 }) {
              Text(playlist.name)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .width('100%')
              Text(`${playlist.songs.length} 首歌曲`)
                .fontSize(13)
                .fontColor('#8F98BC')
                .width('100%')
              Text('适合在切换心情、设备或场景时，一键延续播放氛围。')
                .fontSize(12)
                .fontColor('#6C759A')
                .lineHeight(20)
                .width('100%')
            }
            .width('100%')
          }
          .width(220)
          .padding(18)
          .backgroundColor(playlist.id === this.selectedPlaylistId ? '#202744' : '#111726')
          .borderRadius(24)
          .onClick(() => {
            this.selectedPlaylistId = playlist.id;
          })
        }, (playlist: PlaylistEntity) => `${playlist.id}`)
      }
      .padding({ right: 16 })
    }
    .width('100%')
    .height(180)
  }

  @Builder
  private buildPlaylistDetail(): void {
    const playlist = this.selectedPlaylist();
    if (!playlist) {
      Blank();
      return;
    }
    Column({ space: 14 }) {
      Row() {
        Column({ space: 6 }) {
          Text(playlist.name)
            .fontSize(22)
            .fontWeight(FontWeight.Black)
            .fontColor('#FFFFFF')
          Text('选中任意歌曲即可按当前歌单顺序开始播放。')
            .fontSize(13)
            .fontColor('#8F98BC')
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Button('全部播放')
          .type(ButtonType.Capsule)
          .backgroundColor('#1B2238')
          .fontColor('#E4E9FF')
          .onClick(() => {
            if (playlist.songs.length) {
              void this.playPlaylistSong(playlist.songs[0], playlist);
            }
          })
      }
      .width('100%')

      if (!playlist.songs.length) {
        Column({ space: 10 }) {
          Text('这个歌单还没有曲目')
            .fontSize(16)
            .fontColor('#FFFFFF')
          Text('你可以重新生成体验歌单，或者将收藏歌曲加入此处。')
            .fontSize(13)
            .fontColor('#7F89B0')
        }
        .width('100%')
        .padding(22)
        .backgroundColor('#111726')
        .borderRadius(24)
      } else {
        Column({ space: 12 }) {
          ForEach(playlist.songs, (song: SongEntity) => {
            SongListItem({
              song,
              isActive: false,
              onPlay: (selected: SongEntity) => {
                void this.playPlaylistSong(selected, playlist);
              },
              onFavorite: (selected: SongEntity) => {
                selected.isFavorite = !selected.isFavorite;
                playlist.songs = [...playlist.songs];
                this.playlists = [...this.playlists];
              }
            })
          }, (song: SongEntity) => `${song.id}-${song.path}`)
        }
      }
    }
    .width('100%')
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        this.buildHeader();
        this.buildPlaylistCards();
        this.buildPlaylistDetail();
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
