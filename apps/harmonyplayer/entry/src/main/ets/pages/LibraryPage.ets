import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';
import { SongInfo } from '../model/SongInfo';
import { SongItem } from '../components/SongItem';
import { MediaScanner } from '../service/MediaScanner';
import { PlayerService } from '../service/PlayerService';
import { PlayerViewModel } from '../viewmodel/PlayerViewModel';
import { BasicDataSource } from '../datasource/BasicDataSource';

class SongDataSource extends BasicDataSource {
  private songs: SongInfo[] = [];

  constructor(songs: SongInfo[]) {
    super();
    this.songs = songs;
  }

  totalCount(): number {
    return this.songs.length;
  }

  getData(index: number): SongInfo {
    return this.songs[index];
  }

  setSongs(songs: SongInfo[]): void {
    this.songs = songs;
    this.notifyDataReload();
  }
}

@Component
export struct LibraryPage {
  @State songs: SongInfo[] = [];
  @State keyword: string = '';
  @State loading: boolean = false;
  @StorageProp(PlayerViewModel.KEY_SCAN_PATH) scanPath: string = PlayerViewModel.DEFAULT_SCAN_PATH;
  private dataSource: SongDataSource = new SongDataSource([]);

  aboutToAppear(): void {
    this.requestPermissionAndScan();
  }

  private async requestPermissionAndScan(): Promise<void> {
    this.loading = true;
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const atManager = abilityAccessCtrl.createAtManager();
      await atManager.requestPermissionsFromUser(context, ['ohos.permission.READ_AUDIO']);
      const songs: SongInfo[] = await MediaScanner.getInstance().scanDirectory(this.scanPath);
      this.songs = songs;
      this.dataSource.setSongs(this.filteredSongs());
    } finally {
      this.loading = false;
    }
  }

  private filteredSongs(): SongInfo[] {
    const searchText: string = this.keyword.trim().toLowerCase();
    if (searchText.length === 0) {
      return this.songs;
    }
    return this.songs.filter((song: SongInfo) => song.title.toLowerCase().includes(searchText) || song.artist.toLowerCase().includes(searchText));
  }

  private async playSong(song: SongInfo): Promise<void> {
    const queue: SongInfo[] = this.filteredSongs();
    await PlayerService.getInstance().playSong(song, queue);
  }

  build() {
    Column({ space: 12 }) {
      TextInput({ placeholder: '搜索歌曲或歌手', text: this.keyword })
        .width('100%')
        .height(44)
        .backgroundColor('#F5F5F5')
        .borderRadius(12)
        .onChange((value: string) => {
          this.keyword = value;
          this.dataSource.setSongs(this.filteredSongs());
        })
      Row({ space: 12 }) {
        Text(this.loading ? '正在扫描音乐...' : `共 ${this.filteredSongs().length} 首歌曲`)
          .fontSize(13)
          .fontColor('#666666')
        Blank()
        Button('重新扫描')
          .type(ButtonType.Capsule)
          .onClick(async () => {
            await this.requestPermissionAndScan();
          })
      }
      LazyForEach(this.dataSource, (song: SongInfo) => {
        SongItem({ song: song, onTap: async (selectedSong: SongInfo) => { await this.playSong(selectedSong); } })
      }, (song: SongInfo) => song.uri)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#FAFAFA')
  }
}
