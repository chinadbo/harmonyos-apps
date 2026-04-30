import { MiniPlayer } from '../components/MiniPlayer';
import { LibraryPage } from './LibraryPage';
import { PlayerPage } from './PlayerPage';
import { SettingsPage } from './SettingsPage';
import { PlaylistPage } from './PlaylistPage';
import { SongInfo } from '../model/SongInfo';
import { PlayerViewModel } from '../viewmodel/PlayerViewModel';

@Entry
@Component
export struct Index {
  @StorageProp(PlayerViewModel.KEY_CURRENT_SONG) currentSong: SongInfo | null = null;
  @StorageProp(PlayerViewModel.KEY_SHOW_PRIVACY) showPrivacyDialog: boolean = false;

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: 12 }) {
        if (this.currentSong !== null) {
          MiniPlayer()
        }
        Tabs({ barPosition: BarPosition.End }) {
          TabContent() {
            LibraryPage()
          }
          .tabBar('音乐库')
          TabContent() {
            PlayerPage()
          }
          .tabBar('播放器')
          TabContent() {
            SettingsPage()
          }
          .tabBar('设置')
        }
        .layoutWeight(1)
        PlaylistPage()
          .visibility(Visibility.None)
      }
      .width('100%')
      .height('100%')
      .padding(12)
      .backgroundColor('#FFFFFF')
      if (this.showPrivacyDialog) {
        Column({ space: 12 }) {
          Text('隐私提示')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          Text('HarmonyPlayer 仅申请 READ_AUDIO 权限用于读取本地音乐文件，不进行网络传输，也不集成第三方 SDK。')
            .fontSize(14)
            .textAlign(TextAlign.Center)
          Button('我已知晓并同意')
            .type(ButtonType.Capsule)
            .onClick(() => {
              this.showPrivacyDialog = false;
              AppStorage.setOrCreate(PlayerViewModel.KEY_SHOW_PRIVACY, false);
            })
        }
        .width('82%')
        .padding(24)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .shadow({ radius: 24, color: '#33000000', offsetX: 0, offsetY: 8 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}
