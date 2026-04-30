import { SongEntity } from '../model/SongEntity';
import { MediaScanService } from '../service/MediaScanService';

@ComponentV2
export struct SettingsPage {
  @StorageLink('mediaPermissionGranted') mediaPermissionGranted: boolean = false;
  @StorageLink('recentSongs') recentSongs: SongEntity[] = [];
  @StorageLink('librarySongs') librarySongs: SongEntity[] = [];
  @State darkModeEnabled: boolean = true;
  @State insightIntentEnabled: boolean = true;
  @State crossDeviceEnabled: boolean = true;
  @State infoMessage: string = 'HarmonyTune 已准备好连接你的本地音乐世界。';

  private rescanMusic(): void {
    const songs = MediaScanService.getInstance().createMockSongs();
    this.librarySongs = songs.map((song: SongEntity) => song.clone());
    AppStorage.setOrCreate('librarySongs', this.librarySongs);
    this.infoMessage = `扫描完成，当前音乐库共有 ${this.librarySongs.length} 首歌曲。`;
  }

  private clearRecent(): void {
    this.recentSongs = [];
    AppStorage.setOrCreate('recentSongs', []);
    this.infoMessage = '最近播放已清空，新的聆听轨迹将从下一次播放开始记录。';
  }

  @Builder
  private buildSectionTitle(title: ResourceStr, subtitle: string): void {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(22)
        .fontWeight(FontWeight.Black)
        .fontColor('#FFFFFF')
        .width('100%')
      Text(subtitle)
        .fontSize(13)
        .fontColor('#8A93B8')
        .width('100%')
        .lineHeight(22)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildActionRow(title: ResourceStr, desc: string, actionLabel: string, clickAction: () => void): void {
    Row() {
      Column({ space: 6 }) {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text(desc)
          .fontSize(12)
          .fontColor('#8690B6')
          .lineHeight(18)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Button(actionLabel)
        .type(ButtonType.Capsule)
        .backgroundColor('#1A223A')
        .fontColor('#E7ECFF')
        .onClick(() => clickAction())
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#111726')
    .borderRadius(22)
  }

  @Builder
  private buildSwitchRow(title: ResourceStr, desc: string, value: boolean, onChange: (checked: boolean) => void): void {
    Row() {
      Column({ space: 6 }) {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text(desc)
          .fontSize(12)
          .fontColor('#8690B6')
          .lineHeight(18)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Toggle({ type: ToggleType.Switch, isOn: value })
        .selectedColor('#7C8DFF')
        .switchPointColor('#FFFFFF')
        .onChange((checked: boolean) => onChange(checked))
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#111726')
    .borderRadius(22)
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        this.buildSectionTitle($r('app.string.settings_title'), '扫描、媒体控制、外观体验和产品信息都集中在这里管理。');

        this.buildActionRow($r('app.string.settings_scan'), '重新整理本地音乐资源，刷新首页、音乐库和歌单可见内容。', '执行', () => {
          this.rescanMusic();
        });
        this.buildActionRow($r('app.string.settings_recent_clear'), '清空最近播放列表，但不会删除本地音乐文件或收藏状态。', '清空', () => {
          this.clearRecent();
        });

        this.buildSwitchRow($r('app.string.settings_dark_mode'), '播放器、首页与歌单页统一使用深色视觉，突出封面与歌词内容。', this.darkModeEnabled, (checked: boolean) => {
          this.darkModeEnabled = checked;
          this.infoMessage = checked ? '深色模式已开启。' : '深色模式已关闭。';
        });
        this.buildSwitchRow($r('app.string.settings_insight_intent'), '预留 InsightIntent 语音控制能力，便于未来联动系统语音入口。', this.insightIntentEnabled, (checked: boolean) => {
          this.insightIntentEnabled = checked;
          this.infoMessage = checked ? '语音控制预留能力已启用。' : '语音控制预留能力已关闭。';
        });
        this.buildSwitchRow($r('app.string.settings_cross_device'), '为手机到平板的媒体流转保留开关与交互入口。', this.crossDeviceEnabled, (checked: boolean) => {
          this.crossDeviceEnabled = checked;
          this.infoMessage = checked ? '跨设备流转能力已启用。' : '跨设备流转能力已关闭。';
        });

        Column({ space: 12 }) {
          Text($r('app.string.settings_about'))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .width('100%')
          Text('HarmonyTune 是面向 HarmonyOS API 16 的本地音乐播放器模板工程，强调完整项目结构、音频播放核心、RelationalStore 持久化以及 AVSession 媒体控制整合。')
            .fontSize(13)
            .fontColor('#95A0C8')
            .lineHeight(22)
            .width('100%')
          Text($r('app.string.settings_version'))
            .fontSize(13)
            .fontColor('#7B85AC')
          Text(`媒体权限：${this.mediaPermissionGranted ? '已授予' : '待授权'}`)
            .fontSize(13)
            .fontColor('#7B85AC')
          Text(`最近播放：${this.recentSongs.length} 首 · 音乐库：${this.librarySongs.length} 首`)
            .fontSize(13)
            .fontColor('#7B85AC')
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#111726')
        .borderRadius(24)

        Column({ space: 8 }) {
          Text('状态消息')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .width('100%')
          Text(this.infoMessage)
            .fontSize(13)
            .fontColor('#9EA7CA')
            .lineHeight(22)
            .width('100%')
        }
        .width('100%')
        .padding(18)
        .backgroundColor('#101728')
        .borderRadius(22)
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
