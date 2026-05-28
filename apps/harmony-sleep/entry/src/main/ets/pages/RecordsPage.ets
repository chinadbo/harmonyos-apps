import DatabaseService from '../service/DatabaseService';
import { SleepRecord } from '../model/SleepRecord';
import { SleepDataSource } from '../model/SleepDataSource';
import { SleepRecordItem } from '../components/SleepRecordItem';

@Component
export default struct RecordsPage {
  @State dataSource: SleepDataSource = new SleepDataSource();
  @State isLoading: boolean = false;
  @State hasMore: boolean = true;
  private offset: number = 0;
  private pageSize: number = 20;

  async aboutToAppear(): Promise<void> {
    await this.loadMore();
  }

  async loadMore(): Promise<void> {
    if (this.isLoading || !this.hasMore) return;
    this.isLoading = true;
    try {
      const records = await DatabaseService.instance().getRecords(this.pageSize, this.offset);
      if (records.length < this.pageSize) {
        this.hasMore = false;
      }
      if (this.offset === 0) {
        this.dataSource.reloadData(records);
      } else {
        records.forEach(r => this.dataSource.appendData(r));
      }
      this.offset += records.length;
    } catch (err) {
      console.error('[RecordsPage] loadMore error:', JSON.stringify(err));
    } finally {
      this.isLoading = false;
    }
  }

  async deleteRecord(id: number, index: number): Promise<void> {
    await DatabaseService.instance().deleteRecord(id);
    this.dataSource.spliceData(index, 1);
    this.offset = Math.max(0, this.offset - 1);
  }

  build() {
    Column() {
      Text('睡眠记录')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .padding({ horizontal: 16, vertical: 12 })
        .alignSelf(ItemAlign.Start)

      if (this.dataSource.totalCount() === 0 && !this.isLoading) {
        Column({ space: 8 }) {
          Text('📭')
            .fontSize(48)
          Text('暂无睡眠记录')
            .fontSize(16)
            .fontColor('#BBBBBB')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .width('100%')
      } else {
        List({ space: 8 }) {
          LazyForEach(this.dataSource, (record: SleepRecord, index: number) => {
            ListItem() {
              SleepRecordItem({ record: record })
            }
            .swipeAction({
              end: {
                builder: () => {
                  this.DeleteButton(record.id, index);
                }
              }
            })
          }, (record: SleepRecord) => record.id.toString())

          if (this.hasMore) {
            ListItem() {
              Row() {
                if (this.isLoading) {
                  LoadingProgress()
                    .width(24)
                    .height(24)
                    .color('#5B8DEF')
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .padding(16)
            }
          }
        }
        .layoutWeight(1)
        .padding({ horizontal: 16 })
        .divider({ strokeWidth: 1, color: '#F0F0F0', startMargin: 16, endMargin: 16 })
        .onScrollIndex((first, last) => {
          if (last >= this.dataSource.totalCount() - 3) {
            this.loadMore();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  @Builder
  DeleteButton(id: number, index: number) {
    Button('删除')
      .backgroundColor('#F44336')
      .fontColor(Color.White)
      .fontSize(14)
      .padding({ horizontal: 16, vertical: 12 })
      .borderRadius(8)
      .onClick(() => {
        this.deleteRecord(id, index);
      })
  }
}
