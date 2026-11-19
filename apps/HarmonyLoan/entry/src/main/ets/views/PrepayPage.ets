import router from '@ohos.router';
import { CalcResult, LoanInput, PaymentRow, PrepayResult, PrepayStrategy, defaultLoanInput,
  loanTypeLabel, repayModeLabel } from '../model/LoanTypes';
import { LoanCalculator } from '../model/LoanCalculator';

interface PageParams {
  input?: string;
}

function emptyPrepayResult(): PrepayResult {
  const empty: PrepayResult = {
    valid: false,
    prepayFen: 0,
    afterMonths: 0,
    strategy: 'shorten',
    oldMonthlyFen: 0,
    newMonthlyFen: 0,
    oldMonths: 0,
    newMonths: 0,
    remainBeforeFen: 0,
    remainAfterFen: 0,
    interestPaidBeforeFen: 0,
    newTotalInterestFen: 0,
    savedInterestFen: 0,
    rows: []
  };
  return empty;
}

@Entry
@Component
struct PrepayPage {
  @State input: LoanInput = defaultLoanInput();
  @State original: CalcResult = LoanCalculator.emptyResult();
  @State prepayText: string = '10';
  @State afterMonths: number = 12;
  @State strategy: PrepayStrategy = 'shorten';
  @State result: PrepayResult = emptyPrepayResult();
  @State hasResult: boolean = false;

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
    this.original = LoanCalculator.calc(input);
    this.afterMonths = Math.min(12, Math.max(1, input.months - 1));
    this.recalc();
  }

  private recalc(): void {
    const fen = LoanCalculator.parseWanToFen(this.prepayText);
    this.result = LoanCalculator.prepay(this.input, fen, this.afterMonths, this.strategy);
    this.hasResult = this.result.valid;
  }

  private remainBefore(): number {
    if (this.afterMonths >= 1 && this.afterMonths <= this.original.rows.length) {
      return this.original.rows[this.afterMonths - 1].remainFen;
    }
    return 0;
  }

  private monthsText(months: number): string {
    const y = Math.floor(months / 12);
    const m = months % 12;
    if (y <= 0) {
      return m.toString() + ' 个月';
    }
    if (m === 0) {
      return y.toString() + ' 年';
    }
    return y.toString() + ' 年 ' + m.toString() + ' 个月';
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
      Text('提前还款试算')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111827')
      Blank()
      Text(loanTypeLabel(this.input.type) + ' · ' + repayModeLabel(this.input.mode))
        .fontSize(11)
        .fontColor('#9CA3AF')
    }
    .width('100%')
    .height(52)
    .padding({ left: 6, right: 16 })
    .backgroundColor(Color.White)
  }

  @Builder
  segChip(label: string, active: boolean, tap: () => void) {
    Text(label)
      .fontSize(12)
      .fontColor(active ? '#FFFFFF' : '#4B5563')
      .backgroundColor(active ? '#2B6CF6' : '#F1F3F8')
      .borderRadius(15)
      .padding({ left: 14, right: 14, top: 6, bottom: 6 })
      .margin({ right: 8 })
      .onClick(() => {
        tap();
      })
  }

  @Builder
  fieldLabel(text: string) {
    Text(text)
      .fontSize(12)
      .fontColor('#6B7280')
      .width('100%')
  }

  @Builder
  statRow(label: string, value: string, highlight: boolean) {
    Row() {
      Text(label)
        .fontSize(12)
        .fontColor('#6B7280')
      Blank()
      Text(value)
        .fontSize(13)
        .fontWeight(highlight ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(highlight ? '#FF8A3D' : '#111827')
    }
    .width('100%')
  }

  @Builder
  inputCard() {
    Column({ space: 14 }) {
      Row() {
        Text('原方案：月供 ¥' + LoanCalculator.fenToYuan(this.original.monthlyFen))
          .fontSize(12)
          .fontColor('#111827')
        Blank()
        Text('共 ' + this.input.months.toString() + ' 期')
          .fontSize(11)
          .fontColor('#9CA3AF')
      }
      .width('100%')

      Column({ space: 6 }) {
        this.fieldLabel('提前还款金额（万元）')
        Row({ space: 8 }) {
          TextInput({ text: this.prepayText, placeholder: '例如 10' })
            .type(InputType.NUMBER_DECIMAL)
            .layoutWeight(1)
            .height(42)
            .fontSize(15)
            .backgroundColor('#F5F6FA')
            .borderRadius(8)
            .onChange((text: string) => {
              this.prepayText = text;
              this.recalc();
            })
          Text('万')
            .fontSize(14)
            .fontColor('#6B7280')
        }
        .width('100%')
        Row() {
          this.segChip('5万', false, () => {
            this.prepayText = '5';
            this.recalc();
          })
          this.segChip('10万', false, () => {
            this.prepayText = '10';
            this.recalc();
          })
          this.segChip('20万', false, () => {
            this.prepayText = '20';
            this.recalc();
          })
          this.segChip('50万', false, () => {
            this.prepayText = '50';
            this.recalc();
          })
        }
        .width('100%')
      }
      .width('100%')

      Column({ space: 6 }) {
        Row() {
          Text('提前还款时点')
            .fontSize(12)
            .fontColor('#6B7280')
          Blank()
          Text('第 ' + this.afterMonths.toString() + ' 期后（' +
            this.monthsText(this.afterMonths) + '）')
            .fontSize(12)
            .fontColor('#2B6CF6')
        }
        .width('100%')
        Slider({
          value: this.afterMonths,
          min: 1,
          max: Math.max(2, this.input.months - 1),
          step: 1,
          style: SliderStyle.OutSet
        })
          .width('100%')
          .selectedColor('#2B6CF6')
          .onChange((value: number, mode: SliderChangeMode) => {
            this.afterMonths = Math.round(value);
            this.recalc();
          })
        Text('还款前剩余本金约 ¥' + LoanCalculator.fenToYuanNoDecimal(this.remainBefore()))
          .fontSize(11)
          .fontColor('#9CA3AF')
          .width('100%')
      }
      .width('100%')

      Column({ space: 8 }) {
        this.fieldLabel('处理方式')
        Row() {
          this.segChip('缩短还款年限', this.strategy === 'shorten', () => {
            this.strategy = 'shorten';
            this.recalc();
          })
          this.segChip('减少每月月供', this.strategy === 'reduce', () => {
            this.strategy = 'reduce';
            this.recalc();
          })
        }
        .width('100%')
        Text(this.strategy === 'shorten' ? '月供基本不变，缩短还款期限，节省利息更多' :
          '还款期限不变，降低后续月供，缓解月度压力')
          .fontSize(11)
          .fontColor('#9CA3AF')
          .width('100%')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  @Builder
  resultCard() {
    Column({ space: 12 }) {
      if (!this.hasResult) {
        Text('请输入有效的提前还款金额')
          .fontSize(13)
          .fontColor('#9CA3AF')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 12, bottom: 12 })
      } else {
        Text('预计节省利息')
          .fontSize(12)
          .fontColor('#6B7280')
          .width('100%')
          .textAlign(TextAlign.Center)
        Text('¥' + LoanCalculator.fenToYuan(this.result.savedInterestFen))
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF8A3D')
          .width('100%')
          .textAlign(TextAlign.Center)
        Divider()
          .color('#EEF0F5')
        this.statRow('提前还款金额', '¥' + LoanCalculator.fenToYuan(this.result.prepayFen), false)
        this.statRow('还款前剩余本金', '¥' + LoanCalculator.fenToYuanNoDecimal(this.result.remainBeforeFen), false)
        this.statRow('还款后剩余本金', '¥' + LoanCalculator.fenToYuanNoDecimal(this.result.remainAfterFen), false)
        this.statRow('新方案月供', this.result.newMonths > 0 ?
          '¥' + LoanCalculator.fenToYuan(this.result.newMonthlyFen) : '结清', true)
        this.statRow('原剩余期数 / 新期数',
          (this.result.oldMonths - this.result.afterMonths).toString() + ' 期 / ' +
            this.result.newMonths.toString() + ' 期', false)
        this.statRow('剩余利息（新方案）',
          '¥' + LoanCalculator.fenToYuanNoDecimal(this.result.newTotalInterestFen), false)
        this.statRow('已付利息（前 ' + this.result.afterMonths.toString() + ' 期）',
          '¥' + LoanCalculator.fenToYuanNoDecimal(this.result.interestPaidBeforeFen), false)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 12, color: '#10000000', offsetX: 0, offsetY: 4 })
  }

  @Builder
  newPlanCard() {
    if (this.hasResult && this.result.rows.length > 0) {
      Column({ space: 8 }) {
        Row() {
          Text('新还款计划（前 12 期）')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#111827')
          Blank()
          Text('共 ' + this.result.newMonths.toString() + ' 期')
            .fontSize(11)
            .fontColor('#9CA3AF')
        }
        .width('100%')

        Row() {
          Text('期数')
            .fontSize(10)
            .fontColor('#6B7280')
            .width('10%')
          Text('月供')
            .fontSize(10)
            .fontColor('#6B7280')
            .width('24%')
            .textAlign(TextAlign.End)
          Text('本金')
            .fontSize(10)
            .fontColor('#6B7280')
            .width('22%')
            .textAlign(TextAlign.End)
          Text('利息')
            .fontSize(10)
            .fontColor('#6B7280')
            .width('20%')
            .textAlign(TextAlign.End)
          Text('剩余本金')
            .fontSize(10)
            .fontColor('#6B7280')
            .width('24%')
            .textAlign(TextAlign.End)
        }
        .width('100%')
        .height(24)

        ForEach(this.result.rows.slice(0, 12), (row: PaymentRow) => {
          Row() {
            Text(row.idx.toString())
              .fontSize(10)
              .fontColor('#6B7280')
              .width('10%')
            Text(LoanCalculator.fenToYuanNoDecimal(row.monthPayFen))
              .fontSize(10)
              .fontColor('#111827')
              .width('24%')
              .textAlign(TextAlign.End)
            Text(LoanCalculator.fenToYuanNoDecimal(row.principalFen))
              .fontSize(10)
              .fontColor('#2B6CF6')
              .width('22%')
              .textAlign(TextAlign.End)
            Text(LoanCalculator.fenToYuanNoDecimal(row.interestFen))
              .fontSize(10)
              .fontColor('#FF8A3D')
              .width('20%')
              .textAlign(TextAlign.End)
            Text(LoanCalculator.fenToYuanNoDecimal(row.remainFen))
              .fontSize(10)
              .fontColor('#6B7280')
              .width('24%')
              .textAlign(TextAlign.End)
          }
          .width('100%')
          .height(28)
          .backgroundColor(row.idx % 2 === 0 ? '#FAFBFF' : Color.White)
        }, (row: PaymentRow) => 'new_' + row.idx.toString())

        if (this.result.rows.length > 12) {
          Text('仅展示前 12 期，完整计划可在还款计划页查看')
            .fontSize(10)
            .fontColor('#B0B7C3')
            .width('100%')
            .textAlign(TextAlign.Center)
        }
      }
      .width('100%')
      .padding(14)
      .backgroundColor(Color.White)
      .borderRadius(16)
    }
  }

  build() {
    Column() {
      this.header()
      Scroll() {
        Column({ space: 12 }) {
          this.inputCard()
          this.resultCard()
          this.newPlanCard()
          Text('试算结果仅供参考，实际以贷款合同与银行规则为准')
            .fontSize(10)
            .fontColor('#B0B7C3')
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 10, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }
}
