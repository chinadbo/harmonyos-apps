import { router } from '@ohos.router';
import { preferences } from '@ohos.data.preferences';
import { promptAction } from '@ohos.arkui';

@Component
export struct SettingsPage {
  @State darkMode: boolean = false;
  @State autoSave: boolean = true;
  @State showGrid: boolean = false;
  @State brushPreview: boolean = true;
  @State pref: preferences.Preferences | null = null;

  aboutToAppear() {
    this.pref = preferences.getPreferencesSync(getContext(this) as Context, { name: 'harmony_doodle_settings' });
    this.darkMode = this.pref.getSync('darkMode', false) as boolean;
    this.autoSave = this.pref.getSync('autoSave', true) as boolean;
    this.showGrid = this.pref.getSync('showGrid', false) as boolean;
    this.brushPreview = this.pref.getSync('brushPreview', true) as boolean;
  }

  private saveSettings() {
    this.pref?.putSync('darkMode', this.darkMode);
    this.pref?.putSync('autoSave', this.autoSave);
    this.pref?.putSync('showGrid', this.showGrid);
    this.pref?.putSync('brushPreview', this.brushPreview);
    this.pref?.flushSync();
  }

  build() {
    Column() {
      Row() {
        Button('←')
          .width(40)
          .height(40)
          .fontSize(20)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onClick(() => {
            router.back();
          })

        Text('Settings')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E0E0E0' })

      List() {
        ListItem() {
          Row() {
            Text('🌙 Dark Mode')
              .fontSize(16)
              .fontColor('#333333')
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
              .onChange((isOn: boolean) => {
                this.darkMode = isOn;
                this.saveSettings();
              })
          }
          .width('100%')
          .height(56)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .border({ width: { bottom: 1 }, color: '#E0E0E0' })
        }

        ListItem() {
          Row() {
            Text('💾 Auto Save')
              .fontSize(16)
              .fontColor('#333333')
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.autoSave })
              .onChange((isOn: boolean) => {
                this.autoSave = isOn;
                this.saveSettings();
              })
          }
          .width('100%')
          .height(56)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .border({ width: { bottom: 1 }, color: '#E0E0E0' })
        }

        ListItem() {
          Row() {
            Text('📐 Show Grid')
              .fontSize(16)
              .fontColor('#333333')
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.showGrid })
              .onChange((isOn: boolean) => {
                this.showGrid = isOn;
                this.saveSettings();
              })
          }
          .width('100%')
          .height(56)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .border({ width: { bottom: 1 }, color: '#E0E0E0' })
        }

        ListItem() {
          Row() {
            Text('🖌️ Brush Preview')
              .fontSize(16)
              .fontColor('#333333')
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.brushPreview })
              .onChange((isOn: boolean) => {
                this.brushPreview = isOn;
                this.saveSettings();
              })
          }
          .width('100%')
          .height(56)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .border({ width: { bottom: 1 }, color: '#E0E0E0' })
        }

        ListItem() {
          Button('About')
            .width('100%')
            .height(48)
            .fontSize(16)
            .backgroundColor('#F5F5F5')
            .fontColor('#333333')
            .borderRadius(8)
            .onClick(() => {
              router.pushUrl({ url: 'pages/AboutPage' });
            })
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }
}
