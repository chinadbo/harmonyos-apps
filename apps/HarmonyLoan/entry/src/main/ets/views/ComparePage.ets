import router from '@ohos.router';
import { CalcResult, LoanInput, RepayMode, defaultLoanInput, loanTypeLabel }
  from '../model/LoanTypes';
import { LoanCalculator } from '../model/LoanCalculator';
import CurveChart from '../components/CurveChart';

interface PageParams {
  input?: string;
}

interface CompareRow {
  idx: number;
  pay1: number;
  pay2: number;
  interest1: number;
  interest2: number;
}

function inputWithMode(input: LoanInput, mode: RepayMode): LoanInput {
  const copy: LoanInput = {
    amountFen: input.amountFen,
    months: input.months,
    rateBp: input.rateBp,
    type: input.type,
    mode: mode,
    commercialFen: input.commercialFen,
    commercialRateBp: input.commercialRateBp,
    providentFen: input.providentFen,
    providentRateBp: input.providentRateBp
  };
  return copy;
}

class CompareDataSource implements IDataSource {
  private rows: CompareRow[] = [];
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return this.rows.length;
  }

  getData(index: number): CompareRow {
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

  setRows(rows: CompareRow[]): void {
    this.rows = rows;
    for (let i = 0; i < this.listeners.length; i++) {
      this.listeners[i].onDataReloaded();
    }
  }
}

@Entry
@Component
struct ComparePage {
  @State input: LoanInput = defaultLoanInput();
  @State equalPayment: CalcResult = LoanCalculator.emptyResult();
  @State equalPrincipal: CalcResult = LoanCalculator.emptyResult();
  private dataSource: CompareDataSource = new CompareDataSource();

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
    this.equalPayment = LoanCalculator.calc(inputWithMode(input, 'equal_payment'));
    this.equalPrincipal = LoanCalculator.calc(inputWithMode(input, 'equal_principal'));
    this.dataSource.setRows(this.buildRows(this.equalPayment, this.equalPrincipal));
  }

  private buildRows(r1: CalcResult, r2: CalcResult): CompareRow[] {
    const rows: CompareRow[] = [];
    const count = Math.max(r1.rows.length, r2.rows.length);
    for (let i = 0; i < count; i++) {
      let pay1 = 0;
      let pay2 = 0;
      let interest1 = 0;
      let interest2 = 0;
      if (i < r1.rows.length) {
        pay1 = r1.rows[i].monthPayFen;
        interest1 = r1.rows[i].interestFen;
      }
      if (i < r2.rows.length) {
        pay2 = r2.rows[i].monthPayFen;
        interest2 = r2.rows[i].interestFen;
      }
      rows.push({
        idx: i + 1,
        pay1: pay1,
        pay2: pay2,
        interest1: interest1,
        interest2: interest2
      });
    }
    return rows;
  }

  private interestDiff(): number {
    return this.equalPayment.totalInterestFen - this.equalPrincipal.totalInterestFen;
  }

  private diffText(): string {
    const diff = this.interestDiff();
    if (diff === 0) {
      return '两种方式总利息相同';
    }
    if (diff > 0) {
      return '等额本息比等额本金多付利息 ¥' + LoanCalculator.fenToYuanNoDecimal(diff);
    }
    return '等额本息比等额本金少付利息 ¥' + LoanCalculator.fenToYuanNoDecimal(-diff);
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
      Text('还款方式对比')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111827')
      Blank()
      Text(loanTypeLabel(this.input.type))
        .fontSize(11)
        .fontColor('#9CA3AF')
    }
    .width('100%')
    .height(52)
    .padding({ left: 6, right: 16 })
    .backgroundColor(Color.White)
  }

  @Builder
  modeColumn(title: string, color: string, monthly: string, interest: string, total: string) {
    Column({ space: 5 }) {
      Text(title)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(color)
      Text('首月 ¥' + monthly)
        .fontSize(13)
        .fontColor('#111827')
      Text('总利息 ' + interest)
        .fontSize(11)
        .fontColor('#6B7280')
      Text('总额 ' + total)
        .fontSize(11)
        .fontColor('#9CA3AF')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  summaryCard() {
    Column({ space: 12 }) {
      Row() {
        this.modeColumn('等额本息', '#2B6CF6',
          LoanCalculator.fenToYuanNoDecimal(this.equalPayment.monthlyFen),
          LoanCalculator.fenToYuanNoDecimal(this.equalPayment.totalInterestFen),
          LoanCalculator.fenToYuanNoDecimal(this.equalPayment.totalPayFen))
        Divider()
          .vertical(true)
          .height(54)
          .color('#EEF0F5')
        Column().width(12)
        this.modeColumn('等额本金', '#FF8A3D',
          LoanCalculator.fenToYuanNoDecimal(this.equalPrincipal.monthlyFen),
          LoanCalculator.fenToYuanNoDecimal(this.equalPrincipal.totalInterestFen),
          LoanCalculator.fenToYuanNoDecimal(this.equalPrincipal.totalPayFen))
      }
      .width('100%')

      Text(this.diffText())
        .fontSize(11)
        .fontColor('#6B7280')
        .backgroundColor('#F5F7FC')
        .borderRadius(8)
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .width('100%')
        .textAlign(TextAlign.Center)
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
      Text('本息月供')
        .fontSize(10)
        .fontColor('#2B6CF6')
        .width('24%')
        .textAlign(TextAlign.End)
      Text('本金月供')
        .fontSize(10)
        .fontColor('#FF8A3D')
        .width('24%')
        .textAlign(TextAlign.End)
      Text('本息利息')
        .fontSize(10)
        .fontColor('#6B7280')
        .width('22%')
        .textAlign(TextAlign.End)
      Text('本金利息')
        .fontSize(10)
        .fontColor('#6B7280')
        .width('21%')
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .height(32)
    .padding({ left: 12, right: 12 })
    .backgroundColor('#F0F3F9')
  }

  build() {
    Column() {
      this.header()
      Column({ space: 10 }) {
        this.summaryCard()

        Scroll() {
          Row({ space: 10 }) {
            Column() {
              CurveChart({
                rows: this.equalPayment.rows,
                title: '等额本息 · 逐年'
              })
            }
            .width(320)

            Column() {
              CurveChart({
                rows: this.equalPrincipal.rows,
                title: '等额本金 · 逐年'
              })
            }
            .width(320)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .height(238)

        this.tableHeader()
        List() {
          LazyForEach(this.dataSource, (row: CompareRow) => {
            ListItem() {
              Row() {
                Text(row.idx.toString())
                  .fontSize(10)
                  .fontColor('#6B7280')
                  .width('9%')
                Text(LoanCalculator.fenToYuanNoDecimal(row.pay1))
                  .fontSize(10)
                  .fontColor('#111827')
                  .width('24%')
                  .textAlign(TextAlign.End)
                Text(LoanCalculator.fenToYuanNoDecimal(row.pay2))
                  .fontSize(10)
                  .fontColor('#111827')
                  .width('24%')
                  .textAlign(TextAlign.End)
                Text(LoanCalculator.fenToYuanNoDecimal(row.interest1))
                  .fontSize(10)
                  .fontColor('#6B7280')
                  .width('22%')
                  .textAlign(TextAlign.End)
                Text(LoanCalculator.fenToYuanNoDecimal(row.interest2))
                  .fontSize(10)
                  .fontColor('#6B7280')
                  .width('21%')
                  .textAlign(TextAlign.End)
              }
              .width('100%')
              .height(34)
              .padding({ left: 12, right: 12 })
              .backgroundColor(row.idx % 2 === 0 ? '#FAFBFF' : Color.White)
            }
          }, (row: CompareRow) => row.idx.toString())
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
