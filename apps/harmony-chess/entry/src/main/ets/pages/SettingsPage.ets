import router from '@ohos.router';
import { SoundService } from '../service/SoundService';

@Entry
@Component
struct SettingsPage {
  @StorageLink('ai_level') aiLevel: number = 2;
  @StorageLink('vibrate_on') vibrateOn: boolean = true;
  @StorageLink('theme') theme: string = 'classic';

  aboutToAppear(): void {
    SoundService.setEnabled(this.vibrateOn);
  }

  build() {
    Column() {
      Row() {
        Button('← 返回')
          .fontSize(14)
          .height(36)
          .backgroundColor('#999999')
          .onClick(() => { router.back(); })
        Blank()
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
        Blank().width(60)
      }
      .width('100%')
      .padding(12)

      Column({ space: 16 }) {
        // AI 难度
        Row() {
          Text('默认 AI 难度')
            .fontSize(16)
            .layoutWeight(1)
          Select([
            { value: 'Lv1 随机' },
            { value: 'Lv2 贪婪' },
            { value: 'Lv3 两层搜索' }
          ])
            .selected(this.aiLevel - 1)
            .onSelect((idx: number) => {
              this.aiLevel = idx + 1;
            })
        }
        .width('100%')

        // 振动
        Row() {
          Text('走子振动反馈')
            .fontSize(16)
            .layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.vibrateOn })
            .onChange((isOn: boolean) => {
              this.vibrateOn = isOn;
              SoundService.setEnabled(isOn);
            })
        }
        .width('100%')

        // 主题（占位）
        Row() {
          Text('棋盘主题')
            .fontSize(16)
            .layoutWeight(1)
          Select([
            { value: '经典米棕' },
            { value: '绿色棋协' }
          ])
            .selected(this.theme === 'classic' ? 0 : 1)
            .onSelect((idx: number) => {
              this.theme = idx === 0 ? 'classic' : 'green';
            })
        }
        .width('100%')

        Blank().height(24)

        Text('关于')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .width('100%')
        Text('HarmonyChess v1.0.0\n鸿蒙原生国际象棋 App\n支持人机对弈、双人对弈、PGN 棋谱学习与复盘')
          .fontSize(13)
          .fontColor('#666666')
          .width('100%')
      }
      .width('100%')
      .padding(20)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAF3E7')
  }
}
