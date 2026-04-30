import { SongEntity } from '../model/SongEntity';
import { MiniPlayer } from '../components/MiniPlayer';
import { PlayerService } from '../service/PlayerService';
import { MainPage } from './MainPage';
import { LibraryPage } from './LibraryPage';
import { PlayerPage } from './PlayerPage';
import { PlaylistPage } from './PlaylistPage';
import { SettingsPage } from './SettingsPage';

@Entry
@ComponentV2
export struct Index {
  private navPathStack: NavPathStack = new NavPathStack();
  @StorageLink('currentSong') currentSong: SongEntity = SongEntity.empty();
  @StorageLink('isPlaying') isPlaying: boolean = false;
  @StorageLink('playerCommand') playerCommand: string = '';
  @StorageLink('playerSeekCommand') playerSeekCommand: number = -1;
  @State selectedTab: number = 0;
  @State playerPageVisible: boolean = false;

  aboutToAppear(): void {
    AppStorage.setOrCreate('navPathStack', this.navPathStack);
  }

  onPageShow(): void {
    this.consumeRemoteCommand();
  }

  private consumeRemoteCommand(): void {
    if (this.playerCommand) {
      void PlayerService.getInstance().handleRemoteCommand(this.playerCommand);
      this.playerCommand = '';
      AppStorage.setOrCreate('playerCommand', '');
    }
    if (this.playerSeekCommand >= 0) {
      void PlayerService.getInstance().seekTo(this.playerSeekCommand);
      this.playerSeekCommand = -1;
      AppStorage.setOrCreate('playerSeekCommand', -1);
    }
  }

  private async togglePlay(): Promise<void> {
    const playerService = PlayerService.getInstance();
    if (this.isPlaying) {
      await playerService.pause();
      return;
    }
    if (this.currentSong.path || this.currentSong.title) {
      await playerService.resume();
      return;
    }
    const librarySongs = AppStorage.get('librarySongs') as SongEntity[] || [];
    if (librarySongs.length) {
      playerService.setQueue(librarySongs, 0);
      await playerService.play(librarySongs[0]);
    }
  }

  @Builder
  private buildCurrentPage(): void {
    if (this.playerPageVisible) {
      PlayerPage();
      return;
    }
    if (this.selectedTab === 0) {
      MainPage();
      return;
    }
    if (this.selectedTab === 1) {
      LibraryPage();
      return;
    }
    if (this.selectedTab === 2) {
      PlaylistPage();
      return;
    }
    SettingsPage();
  }

  @Builder
  private buildTabBar(): void {
    Row() {
      this.buildTabItem(0, $r('app.string.tab_home'), '🏠');
      this.buildTabItem(1, $r('app.string.tab_library'), '🎵');
      this.buildTabItem(2, $r('app.string.tab_playlist'), '📚');
      this.buildTabItem(3, $r('app.string.tab_settings'), '⚙');
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 10, bottom: this.currentSong.path || this.currentSong.title ? 6 : 16 })
    .backgroundColor('#0B0F19')
    .borderRadius({ topLeft: 28, topRight: 28, bottomLeft: 0, bottomRight: 0 })
  }

  @Builder
  private buildTabItem(index: number, label: ResourceStr, icon: string): void {
    Column({ space: 6 }) {
      Text(icon)
        .fontSize(20)
        .fontColor(this.selectedTab === index && !this.playerPageVisible ? '#FFFFFF' : '#6F789D')
      Text(label)
        .fontSize(11)
        .fontColor(this.selectedTab === index && !this.playerPageVisible ? '#FFFFFF' : '#6F789D')
    }
    .layoutWeight(1)
    .padding({ top: 8, bottom: 8 })
    .onClick(() => {
      this.playerPageVisible = false;
      this.selectedTab = index;
    })
  }

  build() {
    Navigation(this.navPathStack) {
      Stack({ alignContent: Alignment.Bottom }) {
        this.buildCurrentPage();
        Column() {
          if (this.currentSong.path || this.currentSong.title) {
            MiniPlayer({
              onTogglePlay: () => {
                void this.togglePlay();
              },
              onOpenPlayer: () => {
                this.playerPageVisible = true;
              },
              onNext: () => {
                void PlayerService.getInstance().next();
              }
            })
          }
          this.buildTabBar();
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#090B13')
    }
    .hideBackButton(true)
    .title('HarmonyTune')
    .toolbarConfiguration([])
    .mode(NavigationMode.Stack)
  }
}
