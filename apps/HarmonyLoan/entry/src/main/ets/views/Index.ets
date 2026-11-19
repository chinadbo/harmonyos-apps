import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import { CalcResult, LoanInput, LoanPlan, LoanType, RepayMode,
  loanTypeLabel, repayModeLabel } from '../model/LoanTypes';
import { LoanCalculator } from '../model/LoanCalculator';
import PrefsService from '../service/PrefsService';
import PlanService from '../service/PlanService';
import ResultCard from '../components/ResultCard';
import RatioPie from '../components/RatioPie';
import CurveChart from '../components/CurveChart';

interface PageParams {
  input?: string;
}

@Entry
@Component
struct Index {
  @State loanType: LoanType = 'commercial';
  @State mode: RepayMode = 'equal_payment';
  @State years: number = 30;
  @State amountText: string = '100';
  @State providentText: string = '50';
  @State rateText: string = '3.5';
  @State providentRateText: string = '2.85';
  @State rateMode: string = 'lpr';
  @State lprBp: number = 350;
  @State gjjBp: number = 285;
  @State basePointText: string = '0';
  @State result: CalcResult = LoanCalculator.emptyResult();

  aboutToAppear(): void {
    this.loadData();
  }

  onPageHide(): void {
    const context = getContext(this) as common.UIAbilityContext;
    PrefsService.saveLastInput(context, this.buildInput()).catch((err: BusinessError) => {
      console.error(`save last input failed: ${JSON.stringify(err)}`);
    });
  }

  private async loadData(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    try {
      this.lprBp = await PrefsService.getLprBp(context);
      this.gjjBp = await PrefsService.getGjjBp(context);
      this.providentRateText = LoanCalculator.bpToRateText(this.gjjBp);
      const last = await PrefsService.getLastInput(context);
      if (last !== null) {
        this.loanType = last.type;
        this.mode = last.mode;
        this.years = Math.max(1, Math.round(last.months / 12));
        if (last.type === 'combined') {
          this.amountText = LoanCalculator.fenToWan(last.commercialFen);
          this.providentText = LoanCalculator.fenToWan(last.providentFen);
        } else {
          this.amountText = LoanCalculator.fenToWan(last.amountFen);
        }
        this.rateMode = 'direct';
        this.rateText = LoanCalculator.bpToRateText(last.type === 'provident' ? last.rateBp : last.commercialRateBp);
        if (last.providentRateBp > 0) {
          this.providentRateText = LoanCalculator.bpToRateText(last.providentRateBp);
        }
      }
    } catch (e) {
      console.error(`load prefs failed: ${JSON.stringify(e)}`);
    }
    this.recalc();
  }

  private basePointBp(): number {
    const value = parseFloat(this.basePointText);
    if (value !== value) {
      return 0;
    }
    return Math.round(value);
  }

  private commercialRateBp(): number {
    if (this.rateMode === 'lpr') {
      const bp = this.lprBp + this.basePointBp();
      return bp > 0 ? bp : 1;
    }
    return LoanCalculator.parseRateToBp(this.rateText);
  }

  private providentRateBp(): number {
    return LoanCalculator.parseRateToBp(this.providentRateText);
  }

  private currentRateBp(): number {
    if (this.loanType === 'provident') {
      return this.providentRateBp();
    }
    return this.commercialRateBp();
  }

  private buildInput(): LoanInput {
    const months = this.years * 12;
    const commercialRate = this.commercialRateBp();
    const providentRate = this.providentRateBp();
    let amountFen = 0;
    let commercialFen = 0;
    let providentFen = 0;
    let rateBp = commercialRate;
    if (this.loanType === 'combined') {
      commercialFen = LoanCalculator.parseWanToFen(this.amountText);
      providentFen = LoanCalculator.parseWanToFen(this.providentText);
      amountFen = commercialFen + providentFen;
    } else if (this.loanType === 'provident') {
      amountFen = LoanCalculator.parseWanToFen(this.amountText);
      providentFen = amountFen;
      rateBp = providentRate;
    } else {
      amountFen = LoanCalculator.parseWanToFen(this.amountText);
      commercialFen = amountFen;
    }
    const input: LoanInput = {
      amountFen: amountFen,
      months: months,
      rateBp: rateBp,
      type: this.loanType,
      mode: this.mode,
      commercialFen: commercialFen,
      commercialRateBp: commercialRate,
      providentFen: providentFen,
      providentRateBp: providentRate
    };
    return input;
  }

  private recalc(): void {
    this.result = LoanCalculator.calc(this.buildInput());
  }

  private rateLabel(): string {
    const tail = this.years.toString() + '年 · ' + loanTypeLabel(this.loanType);
    if (this.loanType === 'combined') {
      return '商贷 ' + LoanCalculator.bpToPercent(this.commercialRateBp()) +
        ' / 公积金 ' + LoanCalculator.bpToPercent(this.providentRateBp()) + ' · ' + tail;
    }
    return '年利率 ' + LoanCalculator.bpToPercent(this.currentRateBp()) + ' · ' + tail;
  }

  private navTo(url: string): void {
    const params: PageParams = {
      input: JSON.stringify(this.buildInput())
    };
    router.pushUrl({ url: url, params: params }).catch((err: BusinessError) => {
      console.error(`pushUrl ${url} failed: ${JSON.stringify(err)}`);
      promptAction.showToast({ message: '页面跳转失败' });
    });
  }

  private async savePlan(): Promise<void> {
    if (this.result.monthlyFen <= 0) {
      promptAction.showToast({ message: '请先输入有效的贷款信息' });
      return;
    }
    const context = getContext(this) as common.UIAbilityContext;
    const input = this.buildInput();
    const plan: LoanPlan = {
      name: loanTypeLabel(input.type) + ' ' + LoanCalculator.fenToWan(input.amountFen) +
        '万 ' + this.years + '年 ' + repayModeLabel(input.mode),
      input: input,
      monthlyFen: this.result.monthlyFen,
      totalInterestFen: this.result.totalInterestFen,
      createdAt: Date.now()
    };
    try {
      await PlanService.savePlan(context, plan);
      await PrefsService.saveLastInput(context, input);
      promptAction.showToast({ message: '方案已保存到历史' });
    } catch (e) {
      console.error(`save plan failed: ${JSON.stringify(e)}`);
      promptAction.showToast({ message: '保存失败' });
    }
  }

  @Builder
  segChip(label: string, active: boolean, tap: () => void) {
    Text(label)
      .fontSize(13)
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
  amountInput(label: string, value: string, onChangeAction: (value: string) => void) {
    Column({ space: 6 }) {
      this.fieldLabel(label)
      Row() {
        TextInput({ text: value, placeholder: '请输入金额' })
          .type(InputType.NUMBER_DECIMAL)
          .layoutWeight(1)
          .height(42)
          .fontSize(15)
          .backgroundColor('#F5F6FA')
          .borderRadius(8)
          .onChange((text: string) => {
            onChangeAction(text);
          })
        Text('万')
          .fontSize(14)
          .fontColor('#6B7280')
          .margin({ left: 8 })
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  header() {
    Row() {
      Column({ space: 2 }) {
        Text('房贷计算器')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
        Text('实时试算 · 本地存储 · 无权限')
          .fontSize(11)
          .fontColor('#9CA3AF')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Text('历史')
        .fontSize(14)
        .fontColor('#2B6CF6')
        .padding(8)
        .onClick(() => {
          this.navTo('views/HistoryPage');
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 6 })
  }

  @Builder
  formCard() {
    Column({ space: 14 }) {
      Column({ space: 8 }) {
        this.fieldLabel('贷款类型')
        Row() {
          this.segChip('商业贷款', this.loanType === 'commercial', () => {
            this.loanType = 'commercial';
            this.recalc();
          })
          this.segChip('公积金', this.loanType === 'provident', () => {
            this.loanType = 'provident';
            this.recalc();
          })
          this.segChip('组合贷', this.loanType === 'combined', () => {
            this.loanType = 'combined';
            this.recalc();
          })
        }
        .width('100%')
      }
      .width('100%')

      if (this.loanType === 'combined') {
        this.amountInput('商业贷款金额（万元）', this.amountText, (value: string) => {
          this.amountText = value;
          this.recalc();
        })
        this.amountInput('公积金贷款金额（万元）', this.providentText, (value: string) => {
          this.providentText = value;
          this.recalc();
        })
      } else {
        this.amountInput('贷款金额（万元）', this.amountText, (value: string) => {
          this.amountText = value;
          this.recalc();
        })
      }

      Column({ space: 6 }) {
        Row() {
          Text('贷款年限')
            .fontSize(12)
            .fontColor('#6B7280')
          Blank()
          Text(this.years.toString() + ' 年')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2B6CF6')
        }
        .width('100%')
        Slider({
          value: this.years,
          min: 1,
          max: 30,
          step: 1,
          style: SliderStyle.OutSet
        })
          .width('100%')
          .selectedColor('#2B6CF6')
          .onChange((value: number, mode: SliderChangeMode) => {
            this.years = Math.round(value);
            this.recalc();
          })
      }
      .width('100%')

      if (this.loanType !== 'provident') {
        Column({ space: 8 }) {
          this.fieldLabel('商业贷款利率')
          Row() {
            this.segChip('LPR + 基点', this.rateMode === 'lpr', () => {
              this.rateMode = 'lpr';
              this.recalc();
            })
            this.segChip('直接输入', this.rateMode === 'direct', () => {
              this.rateMode = 'direct';
              this.recalc();
            })
          }
          .width('100%')

          if (this.rateMode === 'lpr') {
            Row({ space: 8 }) {
              Text('LPR ' + LoanCalculator.bpToPercent(this.lprBp))
                .fontSize(12)
                .fontColor('#6B7280')
                .backgroundColor('#F5F6FA')
                .borderRadius(8)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              Text('基点')
                .fontSize(12)
                .fontColor('#6B7280')
              TextInput({ text: this.basePointText, placeholder: '0' })
                .type(InputType.NUMBER_DECIMAL)
                .layoutWeight(1)
                .height(36)
                .fontSize(14)
                .backgroundColor('#F5F6FA')
                .borderRadius(8)
                .onChange((text: string) => {
                  this.basePointText = text;
                  this.recalc();
                })
            }
            .width('100%')

            Text('执行利率 ' + LoanCalculator.bpToPercent(this.commercialRateBp()))
              .fontSize(12)
              .fontColor('#2B6CF6')
              .width('100%')
          } else {
            Row() {
              TextInput({ text: this.rateText, placeholder: '例如 3.5' })
                .type(InputType.NUMBER_DECIMAL)
                .layoutWeight(1)
                .height(40)
                .fontSize(15)
                .backgroundColor('#F5F6FA')
                .borderRadius(8)
                .onChange((text: string) => {
                  this.rateText = text;
                  this.recalc();
                })
              Text('%')
                .fontSize(14)
                .fontColor('#6B7280')
                .margin({ left: 8 })
            }
            .width('100%')
          }
        }
        .width('100%')
      }

      if (this.loanType === 'provident' || this.loanType === 'combined') {
        Column({ space: 6 }) {
          this.fieldLabel('公积金贷款利率（%）')
          Row() {
            TextInput({ text: this.providentRateText, placeholder: '例如 2.85' })
              .type(InputType.NUMBER_DECIMAL)
              .layoutWeight(1)
              .height(40)
              .fontSize(15)
              .backgroundColor('#F5F6FA')
              .borderRadius(8)
              .onChange((text: string) => {
                this.providentRateText = text;
                this.recalc();
              })
            Text('%')
              .fontSize(14)
              .fontColor('#6B7280')
              .margin({ left: 8 })
          }
          .width('100%')
        }
        .width('100%')
      }

      Column({ space: 8 }) {
        this.fieldLabel('还款方式')
        Row() {
          this.segChip('等额本息', this.mode === 'equal_payment', () => {
            this.mode = 'equal_payment';
            this.recalc();
          })
          this.segChip('等额本金', this.mode === 'equal_principal', () => {
            this.mode = 'equal_principal';
            this.recalc();
          })
        }
        .width('100%')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 12, color: '#10000000', offsetX: 0, offsetY: 4 })
  }

  @Builder
  actionRow() {
    Row({ space: 8 }) {
      Button('还款计划')
        .fontSize(12)
        .fontColor('#2B6CF6')
        .backgroundColor('#EAF0FF')
        .height(38)
        .layoutWeight(1)
        .onClick(() => {
          this.navTo('views/SchedulePage');
        })
      Button('提前还款')
        .fontSize(12)
        .fontColor('#2B6CF6')
        .backgroundColor('#EAF0FF')
        .height(38)
        .layoutWeight(1)
        .onClick(() => {
          this.navTo('views/PrepayPage');
        })
      Button('方案对比')
        .fontSize(12)
        .fontColor('#2B6CF6')
        .backgroundColor('#EAF0FF')
        .height(38)
        .layoutWeight(1)
        .onClick(() => {
          this.navTo('views/ComparePage');
        })
      Button('历史方案')
        .fontSize(12)
        .fontColor('#2B6CF6')
        .backgroundColor('#EAF0FF')
        .height(38)
        .layoutWeight(1)
        .onClick(() => {
          this.navTo('views/HistoryPage');
        })
    }
    .width('100%')
  }

  build() {
    Column() {
      this.header()
      Scroll() {
        Column({ space: 12 }) {
          this.formCard()
          Button('保存当前方案')
            .width('100%')
            .height(44)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .backgroundColor('#2B6CF6')
            .borderRadius(12)
            .onClick(() => {
              this.savePlan();
            })
          this.actionRow()
          ResultCard({
            monthlyFen: this.result.monthlyFen,
            totalInterestFen: this.result.totalInterestFen,
            totalPayFen: this.result.totalPayFen,
            totalPrincipalFen: this.result.totalPrincipalFen,
            modeLabel: repayModeLabel(this.mode),
            rateLabel: this.rateLabel()
          })
          RatioPie({
            principalFen: this.result.totalPrincipalFen,
            interestFen: this.result.totalInterestFen
          })
          CurveChart({
            rows: this.result.rows,
            title: '逐年还款曲线'
          })
          Text('所有数据仅保存在本机，不联网、不收集任何个人信息')
            .fontSize(10)
            .fontColor('#B0B7C3')
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 4 })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 6, bottom: 28 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }
}
