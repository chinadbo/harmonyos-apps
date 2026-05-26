import { HistoryRecord } from '../model/HistoryRecord';
import HistoryDbService from '../service/HistoryDbService';
import { EditorRouteParam } from '../model/AnnotationTool';

class HistoryListDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private records: HistoryRecord[] = [];

  totalCount(): number {
    return this.records.length;
  }

  getData(index: number): HistoryRecord {
    return this.records[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    this.listeners = this.listeners.filter((item: DataChangeListener) => item !== listener);
  }

  reload(records: HistoryRecord[]): void {
    this.records = records;
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded();
    });
  }
}

@Component
export struct HistoryPage {
  private readonly navStack: NavPathStack = AppStorage.get('navStack') as NavPathStack;
  private readonly dataSource: HistoryListDataSource = new HistoryListDataSource();
  @State records: HistoryRecord[] = [];

  async aboutToAppear(): Promise<void> {
    const records = await HistoryDbService.queryAll();
    this.records = records;
    this.dataSource.reload(records);
  }

  private openRecord(record: HistoryRecord): void {
    const routeParam: EditorRouteParam = {
      imageUri: record.savedPath,
      imagePath: record.imagePath,
      fromHistory: true
    };
    this.navStack.pushPathByName('AnnotateEditor', routeParam);
  }

  private formatTime(value: number): string {
    const date = new Date(value);
    const year = date.getFullYear();
    const month = `${date.getMonth() + 1}`.padStart(2, '0');
    const day = `${date.getDate()}`.padStart(2, '0');
    const hours = `${date.getHours()}`.padStart(2, '0');
    const minutes = `${date.getMinutes()}`.padStart(2, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }

  build() {
    Column({ space: 16 }) {
      Row({ space: 12 }) {
        Button('返回')
          .onClick(() => this.navStack.pop())
        Text($r('app.string.history_title'))
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0F172A')
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      if (this.records.length === 0) {
        Column() {
          Text($r('app.string.empty_history'))
            .fontSize(16)
            .fontColor('#64748B')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          LazyForEach(this.dataSource, (record: HistoryRecord) => {
            ListItem() {
              Row({ space: 14 }) {
                Image(record.thumbnailUri)
                  .width(88)
                  .height(88)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(12)

                Column({ space: 8 }) {
                  Text(this.formatTime(record.createdAt))
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#0F172A')
                  Text(record.savedPath)
                    .fontSize(12)
                    .fontColor('#475569')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(record.imagePath)
                    .fontSize(12)
                    .fontColor('#64748B')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Color.White)
              .borderRadius(18)
              .onClick(() => this.openRecord(record))
            }
          }, (record: HistoryRecord) => `${record.id ?? 0}`)
        }
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F1F5F9')
  }
}
