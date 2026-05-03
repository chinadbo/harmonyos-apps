import { DatabaseHelper } from '../data/DatabaseHelper';
import { TransactionRepo } from '../data/TransactionRepo';
import { FileExportHelper } from '../utils/FileExportHelper';

@Entry
@Component
struct Settings {
  private db: DatabaseHelper = DatabaseHelper.getInstance();
  private transactionRepo: TransactionRepo = TransactionRepo.getInstance();
  @State currency: string = '¥';
  @State exportedPath: string = '';
  private options: string[] = ['¥', '$', '€'];

  async aboutToAppear(): Promise<void> {
    this.currency = await this.db.getCurrency();
  }

  private async saveCurrency(currency: string): Promise<void> {
    this.currency = currency;
    await this.db.setCurrency(this.currency);
  }

  private async exportCsv(): Promise<void> {
    const context = this.db.requireContext();
    const content: string = await this.transactionRepo.exportCsv();
    this.exportedPath = await FileExportHelper.exportCsv(context, 'transactions.csv', content);
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('设置')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)

        Column({ space: 12 }) {
          Text('货币单位')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Start)
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.options, (item: string) => {
              Button(item)
                .type(ButtonType.Capsule)
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.currency === item ? '#5C6BC0' : '#E0E0E0')
                .fontColor(this.currency === item ? Color.White : '#212121')
                .onClick(async () => {
                  await this.saveCurrency(item);
                })
            }, (item: string) => item)
          }
        }
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(24)

        Column({ space: 12 }) {
          Text('CSV 导出')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Start)
          Button('导出账单 CSV')
            .width('100%')
            .onClick(async () => {
              await this.exportCsv();
            })
          if (this.exportedPath.length > 0) {
            Text(this.exportedPath)
              .fontSize(12)
              .fontColor('#757575')
          }
        }
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(24)

        Column({ space: 8 }) {
          Text('关于')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Start)
          Text('HarmonyLedger 是一个运行在 HarmonyOS 上的本地个人记账工具，支持账单管理、统计分析、预算控制与桌面卡片。')
            .fontSize(14)
            .fontColor('#616161')
        }
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(24)
      }
      .padding(16)
      .width('100%')
    }
    .backgroundColor('#F6F7FB')
  }
}
