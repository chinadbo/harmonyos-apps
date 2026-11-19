import router from '@ohos.router';
import { CalcResult, LoanInput, PaymentRow, defaultLoanInput, loanTypeLabel,
  repayModeLabel } from '../model/LoanTypes';
import { LoanCalculator } from '../model/LoanCalculator';

interface PageParams {
  input?: string;
}

/** 自实现 IDataSource，供 LazyForEach 使用（框架无内置 BasicDataSource） */
class ScheduleDataSource implements IDataSource {
  private rows: PaymentRow[] = [];
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return this.rows.length;
  }

  getData(index: number): PaymentRow {
    return this.rows[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }

  setRows(rows: PaymentRow[]): void {
    this.rows = rows;
    for (let i = 0; i < this.listeners.length; i++) {
      this.listeners[i].onDataReloaded();
    }
  }
}

@Entry
@Component
struct SchedulePage {
  @State input: LoanInput = defaultLoanInput();
  @State summary: CalcResult = LoanCalculator.emptyResult();
  @State titleText: string = '还款计划';
  private dataSource: ScheduleDataSource = new ScheduleDataSource();

  aboutToAppear(): void {
    const params = router.getParams() as PageParams;
    let input = defaultLoanInput();
    if (params !== undefined && params !== null && params.input !== undefined) {
      try {
        input = JSON.parse(params.input) as LoanInput;
      } catch (e) {
        input = defaultLoanInput();
      }
    }
    this.input = input;
    this.summary = LoanCalculator.calc(input);
    this.titleText = loanTypeLabel(input.type) + ' · ' + repayModeLabel(input.mode);
    this.dataSource.setRows(this.summary.rows);
  }

  @Builder
  header() {
    Row() {
      Text('‹')
        .fontSize(28)
        .fontColor('#111827')
        .width(36)
        .height('100%')
        .textAlign(TextAlign.Center)
        .onClick(() => {
          router.back();
        })
      Text('还款计划')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111827')
      Blank()
      Text('共 ' + this.summary.rows.length.toString() + ' 期')
        .fontSize(11)
        .fontColor('#9CA3AF')
    }
    .width('100%')
    .height(52)
    .padding({ left: 6, right: 16 })
    .backgroundColor(Color.White)
  }

  @Builder
  stat(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(10)
        .fontColor('#9CA3AF')
      Text(value)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111827')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  summaryCard() {
    Column({ space: 12 }) {
      Row() {
        Text(this.titleText)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
        Blank()
        Text(LoanCalculator.fenToWan(this.input.amountFen) + ' 万')
          .fontSize(12)
          .fontColor('#2B6CF6')
      }
      .width('100%')

      Row() {
        this.stat('月供', '¥' + LoanCalculator.fenToYuan(this.summary.monthlyFen))
        this.stat('总利息', LoanCalculator.fenToYuanNoDecimal(this.summary.totalInterestFen))
        this.stat('还款总额', LoanCalculator.fenToYuanNoDecimal(this.summary.totalPayFen))
      }
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(14)
  }

  @Builder
  tableHeader() {
    Row() {
      Text('期数')
        .fontSize(10)
        .fontColor('#6B7280')
        .width('9%')
      Text('月供')
        .fontSize(10)
        .fontColor('#6B7280')
        .width('23%')
        .textAlign(TextAlign.End)
      Text('本金')
        .fontSize(10)
        .fontColor('#6B7280')
        .width('23%')
        .textAlign(TextAlign.End)
      Text('利息')
        .fontSize(10)
        .fontColor('#6B7280')
        .width('21%')
        .textAlign(TextAlign.End)
      Text('剩余本金')
        .fontSize(10)
        .fontColor('#6B7280')
        .width('24%')
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .height(34)
    .padding({ left: 12, right: 12 })
    .backgroundColor('#F0F3F9')
  }

  build() {
    Column() {
      this.header()
      Column({ space: 10 }) {
        this.summaryCard()
        this.tableHeader()
        List() {
          LazyForEach(this.dataSource, (row: PaymentRow) => {
            ListItem() {
              Row() {
                Text(row.idx.toString())
                  .fontSize(10)
                  .fontColor('#6B7280')
                  .width('9%')
                Text(LoanCalculator.fenToYuanNoDecimal(row.monthPayFen))
                  .fontSize(10)
                  .fontColor('#111827')
                  .width('23%')
                  .textAlign(TextAlign.End)
                Text(LoanCalculator.fenToYuanNoDecimal(row.principalFen))
                  .fontSize(10)
                  .fontColor('#2B6CF6')
                  .width('23%')
                  .textAlign(TextAlign.End)
                Text(LoanCalculator.fenToYuanNoDecimal(row.interestFen))
                  .fontSize(10)
                  .fontColor('#FF8A3D')
                  .width('21%')
                  .textAlign(TextAlign.End)
                Text(LoanCalculator.fenToYuanNoDecimal(row.remainFen))
                  .fontSize(10)
                  .fontColor('#6B7280')
                  .width('24%')
                  .textAlign(TextAlign.End)
              }
              .width('100%')
              .height(36)
              .padding({ left: 12, right: 12 })
              .backgroundColor(row.idx % 2 === 0 ? '#FAFBFF' : Color.White)
            }
          }, (row: PaymentRow) => row.idx.toString())
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .divider({ strokeWidth: 0.5, color: '#F0F2F7' })
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }
}
