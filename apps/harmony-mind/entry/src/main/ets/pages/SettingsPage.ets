import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { FileStorage } from '../utils/FileStorage';

@Entry
@Component
struct SettingsPage {
  @StorageLink('isDarkMode') isDarkMode: boolean = false;
  @State private storage?: FileStorage;
  @State private errorMessage: string = '';

  aboutToAppear(): void {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      this.storage = new FileStorage(context);
      this.storage.initialize().then(() => {
        if (this.storage) {
          this.storage.loadSettings().then((settings) => {
            this.isDarkMode = settings.isDarkMode;
          });
        }
      });
    } catch (error) {
      this.errorMessage = '设置加载失败';
    }
  }

  private async persistTheme(value: boolean): Promise<void> {
    try {
      if (this.storage) {
        await this.storage.saveSettings({ isDarkMode: value });
      }
    } catch (error) {
      this.errorMessage = '主题保存失败';
    }
  }

  build() {
    Column({ space: 18 }) {
      Row() {
        Button('返回')
          .backgroundColor(this.isDarkMode ? '#FF303B48' : '#FFE7ECF3')
          .fontColor(this.isDarkMode ? '#FFF4F7FB' : '#FF1F2530')
          .onClick(() => {
            router.back();
          })
        Blank()
      }
      .width('100%')

      Text('设置')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isDarkMode ? '#FFF4F7FB' : '#FF1F2530')

      Row() {
        Column({ space: 6 }) {
          Text('深色主题')
            .fontSize(18)
            .fontColor(this.isDarkMode ? '#FFF4F7FB' : '#FF1F2530')
          Text('切换应用整体视觉风格')
            .fontSize(14)
            .fontColor(this.isDarkMode ? '#FFD5DFEA' : '#FF607080')
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.isDarkMode })
          .onChange((value: boolean) => {
            this.isDarkMode = value;
            this.persistTheme(value);
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(this.isDarkMode ? '#FF1E2630' : '#FFFFFFFF')
      .borderRadius(20)

      Button('关于应用')
        .width('100%')
        .height(52)
        .fontSize(18)
        .backgroundColor('#FF5B8FF9')
        .onClick(() => {
          router.pushUrl({ url: 'pages/AboutPage' });
        })

      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor('#FFE14D4D')
      }

      Blank()
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDarkMode ? '#FF14181F' : '#FFF7F8FC')
    .alignItems(HorizontalAlign.Start)
  }
}
