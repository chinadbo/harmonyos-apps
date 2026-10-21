import router from '@ohos.router';

@Entry
@Component
struct HomePage {
  @State showAiDialog: boolean = false;

  build() {
    Column() {
      // 标题
      Text('HarmonyChess')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5B3A29')
        .margin({ top: 60, bottom: 8 })
      Text('国际象棋对弈与棋谱学习')
        .fontSize(16)
        .fontColor('#888888')
        .margin({ bottom: 60 })

      // 主菜单
      Button('人机对弈')
        .width('70%')
        .height(56)
        .fontSize(18)
        .backgroundColor('#5B7DB1')
        .margin({ bottom: 16 })
        .onClick(() => {
          this.showAiDialog = true;
        })

      Button('双人对弈')
        .width('70%')
        .height(56)
        .fontSize(18)
        .backgroundColor('#6BA368')
        .margin({ bottom: 16 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/GamePage', params: { mode: 'pvp', level: 0 } });
        })

      Button('棋谱库')
        .width('70%')
        .height(56)
        .fontSize(18)
        .backgroundColor('#B58863')
        .margin({ bottom: 16 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/PgnListPage' });
        })

      Button('设置')
        .width('70%')
        .height(48)
        .fontSize(16)
        .backgroundColor('#999999')
        .onClick(() => {
          router.pushUrl({ url: 'pages/SettingsPage' });
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FAF3E7')
    .bindSheet($$this.showAiDialog, this.aiDialogBuilder(), {
      height: SheetSize.MEDIUM,
      showClose: true,
      title: { title: '选择 AI 难度' }
    })
  }

  @Builder
  aiDialogBuilder() {
    Column({ space: 12 }) {
      Text('选择 AI 难度')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })

      Button('Lv1 随机走子')
        .width('100%')
        .height(48)
        .onClick(() => {
          this.showAiDialog = false;
          router.pushUrl({ url: 'pages/GamePage', params: { mode: 'ai', level: 1 } });
        })

      Button('Lv2 贪婪评估')
        .width('100%')
        .height(48)
        .onClick(() => {
          this.showAiDialog = false;
          router.pushUrl({ url: 'pages/GamePage', params: { mode: 'ai', level: 2 } });
        })

      Button('Lv3 两层搜索')
        .width('100%')
        .height(48)
        .onClick(() => {
          this.showAiDialog = false;
          router.pushUrl({ url: 'pages/GamePage', params: { mode: 'ai', level: 3 } });
        })
    }
    .padding(24)
  }
}
