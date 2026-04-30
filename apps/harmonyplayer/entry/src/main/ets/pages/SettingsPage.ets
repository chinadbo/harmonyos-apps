import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { PlayerViewModel } from '../viewmodel/PlayerViewModel';

@Component
export struct SettingsPage {
  @StorageProp(PlayerViewModel.KEY_SCAN_PATH) scanPath: string = PlayerViewModel.DEFAULT_SCAN_PATH;
  @StorageProp(PlayerViewModel.KEY_CROSS_DEVICE) crossDeviceEnabled: boolean = false;
  @State versionName: string = '1.0.0';

  private async persist(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    const prefs = await preferences.getPreferences(context, { name: 'harmonyplayer_preferences' });
    await prefs.put('scanPath', this.scanPath);
    await prefs.put('crossDeviceEnabled', this.crossDeviceEnabled);
    await prefs.flush();
  }

  build() {
    Column({ space: 20 }) {
      Column({ space: 8 }) {
        Text('扫描目录')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        TextInput({ placeholder: '请输入音乐扫描路径', text: this.scanPath })
          .width('100%')
          .height(44)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .onChange((value: string) => {
            this.scanPath = value;
            AppStorage.setOrCreate(PlayerViewModel.KEY_SCAN_PATH, value);
          })
      }
      Row() {
        Column({ space: 4 }) {
          Text('跨设备流转')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          Text('在支持的 HarmonyOS 设备之间同步当前播放状态')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.crossDeviceEnabled })
          .onChange(async (value: boolean) => {
            this.crossDeviceEnabled = value;
            AppStorage.setOrCreate(PlayerViewModel.KEY_CROSS_DEVICE, value);
            await this.persist();
          })
      }
      Column({ space: 4 }) {
        Text('版本信息')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(`HarmonyPlayer ${this.versionName}`)
          .fontSize(14)
          .fontColor('#666666')
      }
      Button('保存设置')
        .type(ButtonType.Capsule)
        .onClick(async () => { await this.persist(); })
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
