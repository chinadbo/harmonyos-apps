import router from '@ohos.router';
import { HomeViewModel } from '../viewmodel/HomeViewModel';
import { Category, Transaction, TransactionDataSource } from '../data/DataModels';
import { TransactionItem } from '../components/TransactionItem';
import { FormatUtils } from '../utils/FormatUtils';

@Entry
@Component
struct Index {
  private viewModel: HomeViewModel = new HomeViewModel();
  @State income: number = 0;
  @State expense: number = 0;
  @State balance: number = 0;
  @State currency: string = '¥';
  @State transactionCount: number = 0;
  private dataSource: TransactionDataSource = this.viewModel.dataSource;
  @State categories: Category[] = [];

  async aboutToAppear(): Promise<void> {
    await this.reload();
  }

  private async reload(): Promise<void> {
    await this.viewModel.load();
    this.income = this.viewModel.summary.income;
    this.expense = this.viewModel.summary.expense;
    this.balance = this.viewModel.summary.balance;
    this.currency = this.viewModel.currency;
    this.transactionCount = this.viewModel.summary.transactionCount;
    this.categories = this.viewModel.categoryList;
    this.dataSource = this.viewModel.dataSource;
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column({ space: 16 }) {
        this.buildHeader()
        this.buildSummaryCard()
        this.buildActionRow()
        this.buildTransactionList()
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .backgroundColor('#F6F7FB')

      Button('+')
        .width(56)
        .height(56)
        .borderRadius(28)
        .fontSize(26)
        .fontColor(Color.White)
        .backgroundColor('#5C6BC0')
        .margin({ right: 24, bottom: 24 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/AddTransaction' });
        })
    }
  }

  @Builder
  private buildHeader() {
    Row() {
      Column({ space: 4 }) {
        Text('HarmonyLedger')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
        Text(`本月共 ${this.transactionCount} 笔`)
          .fontSize(13)
          .fontColor('#757575')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Button('设置')
        .type(ButtonType.Capsule)
        .fontSize(14)
        .onClick(() => router.pushUrl({ url: 'pages/Settings' }))
    }
  }

  @Builder
  private buildSummaryCard() {
    Column({ space: 16 }) {
      Text('月度概览')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
      Text(FormatUtils.formatAmount(this.balance, this.currency))
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.balance >= 0 ? '#2E7D32' : '#D32F2F')
      Row() {
        this.buildMetric('收入', this.income, '#2E7D32')
        this.buildMetric('支出', this.expense, '#D32F2F')
      }
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(24)
  }

  @Builder
  private buildMetric(label: string, amount: number, color: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(13)
        .fontColor('#757575')
      Text(FormatUtils.formatAmount(amount, this.currency))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildActionRow() {
    Row({ space: 10 }) {
      Button('统计')
        .layoutWeight(1)
        .onClick(() => router.pushUrl({ url: 'pages/Statistics' }))
      Button('预算')
        .layoutWeight(1)
        .onClick(() => router.pushUrl({ url: 'pages/Budget' }))
      Button('分类')
        .layoutWeight(1)
        .onClick(() => router.pushUrl({ url: 'pages/CategoryManage' }))
    }
  }

  private findCategory(categoryId: number): Category | undefined {
    return this.categories.find((item: Category) => item.id === categoryId);
  }

  @Builder
  private buildTransactionList() {
    Column({ space: 12 }) {
      Text('最近账单')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)

      List({ space: 12 }) {
        LazyForEach(this.dataSource, (transaction: Transaction) => {
          ListItem() {
            TransactionItem({
              transaction,
              category: this.findCategory(transaction.categoryId),
              currency: this.currency
            })
          }
          .onClick(() => {
            router.pushUrl({
              url: 'pages/TransactionDetail',
              params: {
                id: transaction.id
              }
            });
          })
        }, (transaction: Transaction) => `${transaction.id}`)
      }
      .layoutWeight(1)
      .divider({ strokeWidth: 0 })
    }
    .layoutWeight(1)
  }
}
