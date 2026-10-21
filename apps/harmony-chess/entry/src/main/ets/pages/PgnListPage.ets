import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { GameRecord } from '../model/Types';
import { StorageService } from '../service/StorageService';

@Entry
@Component
struct PgnListPage {
  @State records: Array<GameRecord> = [];

  aboutToAppear(): void {
    this.records = StorageService.listRecords();
  }

  private formatTime(ts: number): string {
    const d = new Date(ts);
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
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
        Text('棋谱库')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text(`${this.records.length} 局`)
          .fontSize(14)
          .fontColor('#888888')
      }
      .width('100%')
      .padding(12)

      if (this.records.length === 0) {
        Column() {
          Text('暂无棋谱')
            .fontSize(18)
            .fontColor('#888888')
          Text('对弈结束后可保存棋谱')
            .fontSize(14)
            .fontColor('#AAAAAA')
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.records, (rec: GameRecord) => {
            ListItem() {
              Row() {
                Column() {
                  Text(rec.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(`${rec.result} · ${this.formatTime(rec.createdAt)}`)
                    .fontSize(12)
                    .fontColor('#888888')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Button('删除')
                  .fontSize(12)
                  .height(32)
                  .backgroundColor('#D9534F')
                  .onClick(() => {
                    StorageService.deleteRecord(rec.id);
                    this.records = StorageService.listRecords();
                    promptAction.showToast({ message: '已删除' });
                  })
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .onClick(() => {
                router.pushUrl({ url: 'pages/ReplayPage', params: { recordId: rec.id } });
              })
            }
            .margin({ left: 12, right: 12, bottom: 8 })
          })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAF3E7')
  }
}
