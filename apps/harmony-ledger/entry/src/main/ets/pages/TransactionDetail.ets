import router from '@ohos.router';
import { TransactionRepo } from '../data/TransactionRepo';
import { CategoryRepo } from '../data/CategoryRepo';
import { Transaction, Category } from '../data/DataModels';
import { DatabaseHelper } from '../data/DatabaseHelper';
import { FormatUtils } from '../utils/FormatUtils';
import { DateUtils } from '../utils/DateUtils';

@Entry
@Component
struct TransactionDetail {
  private transactionRepo: TransactionRepo = TransactionRepo.getInstance();
  private categoryRepo: CategoryRepo = CategoryRepo.getInstance();
  private db: DatabaseHelper = DatabaseHelper.getInstance();
  @State transaction?: Transaction;
  @State category?: Category;
  @State currency: string = '¥';

  async aboutToAppear(): Promise<void> {
    const params = router.getParams() as Record<string, number | string>;
    const id: number = Number(params['id']);
    this.currency = await this.db.getCurrency();
    this.transaction = await this.transactionRepo.getById(id) ?? undefined;
    if (this.transaction) {
      this.category = await this.categoryRepo.getById(this.transaction.categoryId) ?? undefined;
    }
  }

  private async remove(): Promise<void> {
    if (!this.transaction) {
      return;
    }
    await this.transactionRepo.delete(this.transaction.id);
    router.back();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('账单详情')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)

        if (this.transaction) {
          Column({ space: 12 }) {
            Text(this.category?.icon ?? '🧾')
              .fontSize(42)
            Text(this.category?.name ?? '未分类')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
            Text(FormatUtils.formatSignedAmount(this.transaction.amount, this.transaction.type, this.currency))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.transaction.type === 'income' ? '#2E7D32' : '#D32F2F')
          }
          .width('100%')
          .padding(24)
          .backgroundColor(Color.White)
          .borderRadius(24)

          Column({ space: 12 }) {
            this.buildRow('日期', DateUtils.displayDate(this.transaction.date))
            this.buildRow('备注', this.transaction.note.length > 0 ? this.transaction.note : '无')
            this.buildRow('类型', this.transaction.type === 'income' ? '收入' : '支出')
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(24)

          Row({ space: 12 }) {
            Button('编辑')
              .layoutWeight(1)
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/AddTransaction',
                  params: { id: this.transaction?.id ?? 0 }
                });
              })
            Button('删除')
              .layoutWeight(1)
              .backgroundColor('#D32F2F')
              .fontColor(Color.White)
              .onClick(async () => {
                await this.remove();
              })
          }
        }
      }
      .padding(16)
      .width('100%')
    }
    .backgroundColor('#F6F7FB')
  }

  @Builder
  private buildRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#757575')
        .layoutWeight(1)
      Text(value)
        .fontSize(16)
    }
  }
}
