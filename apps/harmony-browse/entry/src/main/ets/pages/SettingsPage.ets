import router from '@ohos.router';
import { Constants } from '../utils/Constants';
import { BrowserDatabase } from '../database/BrowserDatabase';

@Entry
@Component
struct SettingsPage {
  @State searchEngine: string = '必应';
  @State showClearDialog: boolean = false;

  aboutToAppear() {
    // 从持久化存储读取设置
  }

  build() {
    Column() {
      Row() {
        Button('返回')
          .fontSize(14)
          .backgroundColor(Color.Transparent)
          .fontColor('#2196F3')
          .onClick(() => router.back())

        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#ffffff')

      Scroll() {
        Column() {
          // 搜索引擎设置
          Row() {
            Text('搜索引擎')
              .fontSize(16)
              .layoutWeight(1)
            Text(this.searchEngine)
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .margin({ bottom: 8 })
          .onClick(() => {
            // 弹出搜索引擎选择
          })

          // 清除数据
          Row() {
            Text('清除所有数据')
              .fontSize(16)
              .fontColor('#ff4444')
              .layoutWeight(1)
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .margin({ bottom: 8 })
          .onClick(() => this.showClearDialog = true)

          // 关于
          Column() {
            Text('HarmonyBrowse')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 8 })
            Text('版本 1.0.0')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ bottom: 4 })
            Text('HarmonyOS 轻量浏览器')
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .margin({ top: 16 })
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding(12)
      }
      .layoutWeight(1)

      // 清除确认对话框
      if (this.showClearDialog) {
        Column() {
          Column() {
            Text('确认清除')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 16 })
            Text('确定要清除所有数据吗？包括书签和历史记录。')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 24 })

            Row() {
              Button('取消')
                .width(120)
                .height(44)
                .backgroundColor('#999999')
                .onClick(() => this.showClearDialog = false)

              Button('确定')
                .width(120)
                .height(44)
                .backgroundColor('#ff4444')
                .margin({ left: 12 })
                .onClick(() => {
                  BrowserDatabase.getInstance().clearHistory();
                  this.showClearDialog = false;
                })
            }
          }
          .width('80%')
          .padding(24)
          .backgroundColor('#ffffff')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#33000000', offsetX: 0, offsetY: 4 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#66000000')
        .onClick(() => this.showClearDialog = false)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
