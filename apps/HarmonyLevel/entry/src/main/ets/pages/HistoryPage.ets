import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { PrefsHelper } from '../data/PrefsHelper';
import { MeasureRecord, MODE_RULER, formatAngle, formatTs, modeLabel } from '../model/Measure';

// BasicDataSource 并非框架内置类：此处自行实现 IDataSource 供 LazyForEach 使用
class HistoryDataSource implements IDataSource {
  private list: MeasureRecord[] = [];
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return this.list.length;
  }

  getData(index: number): MeasureRecord {
    return this.list[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos: number = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  setList(list: MeasureRecord[]): void {
    this.list = list;
    this.notifyReload();
  }

  private notifyReload(): void {
    for (let i = 0; i < this.listeners.length; i++) {
      this.listeners[i].onDataReloaded();
    }
  }
}

@Entry
@Component
struct HistoryPage {
  @State count: number = 0;
  private dataSource: HistoryDataSource = new HistoryDataSource();
  private context: common.Context | null = null;

  aboutToAppear(): void {
    this.context = getContext(this) as common.Context;
    this.reload();
  }

  onPageShow(): void {
    this.reload();
  }

  private async reload(): Promise<void> {
    const list: MeasureRecord[] = await PrefsHelper.getHistory(this.context!);
    this.dataSource.setList(list);
    this.count = list.length;
  }

  private async deleteRecord(id: number): Promise<void> {
    const remained: MeasureRecord[] = await PrefsHelper.deleteRecord(this.context!, id);
    this.dataSource.setList(remained);
    this.count = remained.length;
  }

  private confirmClearAll(): void {
    AlertDialog.show({
      title: '清空记录',
      message: '确定删除全部测量记录？此操作不可恢复。',
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '清空',
        fontColor: '#ff6d5a',
        action: () => {
          this.clearAll();
        }
      }
    });
  }

  private async clearAll(): Promise<void> {
    await PrefsHelper.clearHistory(this.context!);
    this.dataSource.setList([]);
    this.count = 0;
  }

  private angleText(rec: MeasureRecord): string {
    if (rec.mode === MODE_RULER) {
      return `${formatAngle(rec.angleX)}°`;
    }
    return `X ${formatAngle(rec.angleX)}° / Y ${formatAngle(rec.angleY)}°`;
  }

  @Builder
  deleteEnd(id: number) {
    Button('删除')
      .backgroundColor('#ff6d5a')
      .fontColor('#ffffff')
      .borderRadius(12)
      .margin(4)
      .onClick(() => {
        this.deleteRecord(id);
      })
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('‹')
          .fontSize(26)
          .fontColor('#e8edf2')
          .padding({ left: 4, right: 12 })
          .onClick(() => {
            router.back();
          })
        Text('测量记录')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#e8edf2')
        Blank()
        Text(`共 ${this.count} 条`)
          .fontSize(12)
          .fontColor('#93a1b0')
      }
      .width('100%')

      if (this.count === 0) {
        Column({ space: 8 }) {
          Text('暂无测量记录')
            .fontSize(15)
            .fontColor('#93a1b0')
          Text('在气泡仪或角度尺中点击「记录」保存测量点')
            .fontSize(12)
            .fontColor('#5c6b78')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 8 }) {
          LazyForEach(this.dataSource, (item: MeasureRecord) => {
            ListItem() {
              Row() {
                Column({ space: 4 }) {
                  Text(modeLabel(item.mode))
                    .fontSize(13)
                    .fontColor('#37c8f0')
                  Text(formatTs(item.ts))
                    .fontSize(11)
                    .fontColor('#93a1b0')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text(this.angleText(item))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#e8edf2')
              }
              .width('100%')
              .padding(14)
              .borderRadius(12)
              .backgroundColor('#1a222c')
            }
            .swipeAction({
              end: {
                builder: () => {
                  this.deleteEnd(item.id);
                }
              }
            })
          }, (item: MeasureRecord) => item.id.toString())
        }
        .layoutWeight(1)
        .width('100%')
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Auto)
      }

      if (this.count > 0) {
        Button('清空全部记录')
          .width('100%')
          .backgroundColor('#2c3947')
          .fontColor('#ff6d5a')
          .onClick(() => {
            this.confirmClearAll();
          })
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#0e1319')
  }
}
