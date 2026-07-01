import common from '@ohos.app.ability.common';
import { COLORS } from '../constants/AppConstants';
import { preferencesService } from '../services/PreferencesService';
import { SoundSelector } from '../components/SoundSelector';

@Component
export struct SettingsPage {
  @Prop stack: NavPathStack = new NavPathStack();
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  @State private soundType: string = 'classic';
  @State private ready: boolean = false;

  aboutToAppear(): void {
    void this.loadSettings();
  }

  private async loadSettings(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    await preferencesService.init(context);
    const settings = await preferencesService.getSettings();
    this.isDarkMode = settings.isDarkMode;
    this.soundType = settings.soundType;
    this.ready = true;
  }

  private async updateSoundType(value: string): Promise<void> {
    this.soundType = value;
    await preferencesService.setSoundType(value);
  }

  private async updateTheme(value: boolean): Promise<void> {
    this.isDarkMode = value;
    AppStorage.setOrCreate('isDarkMode', value);
    await preferencesService.setDarkMode(value);
  }

  build() {
    Column({ space: 18 }) {
      Row() {
        Button('Back')
          .backgroundColor(COLORS.surfaceAlt)
          .fontColor(COLORS.textPrimary)
          .onClick(() => {
            this.stack.pop();
          })
        Blank()
      }
      .width('100%')

      Text('Settings')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(COLORS.textPrimary)

      if (this.ready) {
        SoundSelector({
          selected: this.soundType,
          onSelect: (value: string) => {
            this.updateSoundType(value);
          }
        })
      }

      Row() {
        Column({ space: 6 }) {
          Text('Dark Theme')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(COLORS.textPrimary)
          Text('Use a low-glare visual style for practice sessions')
            .fontSize(14)
            .fontColor(COLORS.textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.isDarkMode })
          .selectedColor(COLORS.primary)
          .onChange((value: boolean) => {
            this.updateTheme(value);
          })
      }
      .padding(18)
      .backgroundColor(COLORS.surface)
      .borderRadius(24)
      .width('100%')

      Blank()
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.background)
    .alignItems(HorizontalAlign.Start)
  }
}
