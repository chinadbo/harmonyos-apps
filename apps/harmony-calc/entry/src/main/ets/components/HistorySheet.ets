import { HistoryRecord } from '../model/HistoryRecord';

class BasicDataSource implements IDataSource {
  private listeners: Array<DataChangeListener> = [];
  private items: Array<HistoryRecord> = [];

  totalCount(): number {
    return this.items.length;
  }

  getData(index: number): HistoryRecord {
    return this.items[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index: number = this.listeners.indexOf(listener);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }

  reload(items: Array<HistoryRecord>): void {
    this.items = items.slice();
    this.notifyReload();
  }

  private notifyReload(): void {
    for (let i: number = 0; i < this.listeners.length; i += 1) {
      this.listeners[i].onDataReloaded();
    }
  }
}

@Component
export struct HistorySheet {
  @Prop records: Array<HistoryRecord> = [];
  @Prop visible: boolean = false;
  @Prop onClose: () => void = () => {};
  @Prop onSelect: (record: HistoryRecord) => void = () => {};
  @Prop onClear: () => void = () => {};
  private dataSource: BasicDataSource = new BasicDataSource();

  aboutToAppear(): void {
    this.dataSource.reload(this.records);
  }

  aboutToUpdate(): void {
    this.dataSource.reload(this.records);
  }

  build() {
    if (this.visible) {
      Column() {
        Row() {
          Text('历史记录')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White);
          Blank();
          Button('清空')
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#3A3A3C')
            .borderRadius(16)
            .onClick(() => this.onClear());
          Button('关闭')
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#3A3A3C')
            .borderRadius(16)
            .margin({ left: 8 })
            .onClick(() => this.onClose());
        }
        .width('100%')
        .margin({ bottom: 12 });

        if (this.records.length === 0) {
          Column() {
            Text('暂无历史记录')
              .fontSize(16)
              .fontColor('#A0A0A5');
          }
          .width('100%')
          .height(180)
          .justifyContent(FlexAlign.Center);
        } else {
          List({ space: 8, initialIndex: 0 }) {
            LazyForEach(this.dataSource, (record: HistoryRecord) => {
              ListItem() {
                Column({ space: 6 }) {
                  Text(record.expression)
                    .fontSize(15)
                    .fontColor('#A0A0A5')
                    .width('100%')
                    .textAlign(TextAlign.End);
                  Text(record.result)
                    .fontSize(24)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Color.White)
                    .width('100%')
                    .textAlign(TextAlign.End);
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#242426')
                .borderRadius(16)
                .onClick(() => this.onSelect(record));
              };
            }, (record: HistoryRecord) => record.id.toString())
          }
          .width('100%')
          .height(320);
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#1C1C1E')
      .borderRadius({ topLeft: 24, topRight: 24 })
      .shadow({ radius: 24, color: '#66000000', offsetX: 0, offsetY: -4 })
      .transition(TransitionEffect.move(TransitionEdge.BOTTOM))
      .alignSelf(ItemAlign.End);
    }
  }
}
