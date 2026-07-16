import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { BrowserDatabase } from '../database/BrowserDatabase';
import { HistoryItem } from '../model/HistoryItem';
import { Constants } from '../utils/Constants';

@Entry
@Component
struct HistoryPage {
  @State history: HistoryItem[] = [];

  aboutToAppear() {
    this.loadHistory();
  }

  async loadHistory() {
    this.history = await BrowserDatabase.getInstance().queryHistory();
  }

  async clearAllHistory() {
    promptAction.showDialog({
      title: '确认清除',
      message: '确定要清除所有浏览历史吗？',
      buttons: [
        { text: '取消', color: '#999999' },
        { text: '确定', color: '#ff4444' }
      ]
    }).then(async (value) => {
      if (value.index === 1) {
        await BrowserDatabase.getInstance().clearHistory();
        await this.loadHistory();
        promptAction.showToast({ message: '历史已清除' });
      }
    });
  }

  build() {
    Column() {
      Row() {
        Button('返回')
          .fontSize(14)
          .backgroundColor(Color.Transparent)
          .fontColor('#2196F3')
          .onClick(() => router.back())

        Text('浏览历史')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('清除')
          .fontSize(14)
          .backgroundColor(Color.Transparent)
          .fontColor('#ff4444')
          .onClick(() => this.clearAllHistory())
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#ffffff')

      Scroll() {
        Column() {
          ForEach(this.history, (item: HistoryItem, index: number) => {
            Row() {
              Column() {
                Text(item.title || item.url)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                Text(item.url)
                  .fontSize(12)
                  .fontColor('#999999')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                Text(new Date(item.visitTime).toLocaleString())
                  .fontSize(11)
                  .fontColor('#cccccc')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .height(64)
            .padding(12)
            .backgroundColor('#ffffff')
            .borderRadius(8)
            .margin({ bottom: 6 })
          }, (item: HistoryItem) => item.id.toString())
        }
        .width('100%')
        .padding(12)
      }
      .layoutWeight(1)

      if (this.history.length === 0) {
        Text('暂无历史记录')
          .fontSize(16)
          .fontColor('#999999')
          .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
