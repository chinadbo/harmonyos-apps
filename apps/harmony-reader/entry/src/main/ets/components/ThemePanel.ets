import common from '@ohos.app.ability.common';
import { ThemeKey } from '../model/BookInfo';
import PreferencesService from '../service/PreferencesService';

@Component
export struct ThemePanel {
  @StorageLink('readerTheme') theme: ThemeKey = 'light';
  @StorageLink('readerFontSize') fontSize: number = 18;
  @Prop context: common.UIAbilityContext;

  private async updateTheme(theme: ThemeKey): Promise<void> {
    this.theme = theme;
    await PreferencesService.saveTheme(this.context, theme);
  }

  private async updateFontSize(fontSize: number): Promise<void> {
    const normalized = Math.max(14, Math.min(24, Math.round(fontSize / 2) * 2));
    this.fontSize = normalized;
    await PreferencesService.saveFontSize(this.context, normalized);
  }

  build() {
    Column({ space: 16 }) {
      Text('阅读设置')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      Text(`字体大小 ${this.fontSize}sp`)
        .fontSize(14)
      Slider({ value: this.fontSize, min: 14, max: 24, step: 2, style: SliderStyle.OutSet })
        .onChange((value: number) => {
          this.updateFontSize(value);
        })

      Row({ space: 12 }) {
        this.buildThemeButton('日间', 'light');
        this.buildThemeButton('护眼', 'eye');
        this.buildThemeButton('夜间', 'dark');
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFFFF')
    .borderRadius({ topLeft: 24, topRight: 24 })
  }

  @Builder
  private buildThemeButton(label: string, value: ThemeKey) {
    Button(label)
      .type(ButtonType.Capsule)
      .backgroundColor(this.theme === value ? '#5B8FF9' : '#F0F0F0')
      .fontColor(this.theme === value ? Color.White : '#333333')
      .onClick(() => {
        this.updateTheme(value);
      })
  }
}
