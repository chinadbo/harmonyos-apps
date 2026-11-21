import promptAction from '@ohos.promptAction';
import hilog from '@ohos.hilog';
import { BusinessError } from '@ohos.base';
import { ChartPoint, LineChart, recommendedGainLower, recommendedGainUpper } from './LineChart';
import { DbHelper } from '../database/DbHelper';
import { WeightRecord } from '../model/WeightRecord';
import {
  formatDate,
  formatMonthDay,
  getPregnancyWeek,
  getWeekdayCN,
  parseDate,
  PregnancyWeek,
  todayStr
} from '../utils/PregnancyCalc';

const DOMAIN: number = 0x0000;
const TAG: string = 'WeightView';
const PINK: string = '#F062A3';
const PINK_DARK: string = '#D6336C';
const TITLE_COLOR: string = '#3A2C33';
const BODY_COLOR: string = '#5A4A52';
const MUTED_COLOR: string = '#A98D9B';
const CARD_BG: string = '#FFFFFF';

@CustomDialog
struct WeightDialog {
  controller?: CustomDialogController;
  @Prop dueDate: string = '';
  @Prop initialDate: string = '';
  onConfirm?: (date: string, weight: number, week: number) => void;

  @State pickDate: Date = new Date();
  @State weightInput: string = '';
  @State errorText: string = '';

  aboutToAppear(): void {
    if (this.initialDate.length > 0) {
      this.pickDate = parseDate(this.initialDate);
    }
  }

  private pickerStart(): Date {
    const start: Date = new Date();
    start.setDate(start.getDate() - 280);
    return start;
  }

  private pickerEnd(): Date {
    return new Date();
  }

  private weekFor(dateStr: string): number {
    if (this.dueDate.length === 0) {
      return 0;
    }
    const pregnancy: PregnancyWeek = getPregnancyWeek(this.dueDate, dateStr);
    return pregnancy.week;
  }

  private previewWeekLabel(): string {
    if (this.dueDate.length === 0) {
      return '需先设置预产期';
    }
    return `孕${this.weekFor(formatDate(this.pickDate))}周`;
  }

  private confirm(): void {
    const text: string = this.weightInput.trim();
    const weight: number = parseFloat(text);
    if (text.length === 0 || Number.isNaN(weight)) {
      this.errorText = '请输入体重，例如 58.5';
      return;
    }
    if (weight <= 20 || weight > 200) {
      this.errorText = '请输入合理的体重（20 ~ 200 kg）';
      return;
    }
    const dateStr: string = formatDate(this.pickDate);
    if (this.onConfirm !== undefined) {
      this.onConfirm(dateStr, weight, this.weekFor(dateStr));
    }
    if (this.controller !== undefined) {
      this.controller.close();
    }
  }

  build() {
    Column() {
      Text('记录体重')
        .fontSize(19)
        .fontWeight(FontWeight.Bold)
        .fontColor(TITLE_COLOR)
      Text('建议每周固定时间、相同状态下称重')
        .fontSize(12)
        .fontColor(MUTED_COLOR)
        .margin({ top: 4 })

      Text('记录日期')
        .fontSize(13)
        .fontColor(BODY_COLOR)
        .margin({ top: 16 })
      DatePicker({
        start: this.pickerStart(),
        end: this.pickerEnd(),
        selected: this.pickDate
      })
        .width('100%')
        .onDateChange((value: Date) => {
          this.pickDate = value;
        })

      Row() {
        Text('对应孕周')
          .fontSize(12)
          .fontColor('#9A7C8B')
          .layoutWeight(1)
        Text(this.previewWeekLabel())
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(PINK_DARK)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFF4F9')
      .borderRadius(14)
      .margin({ top: 10 })

      Text('体重（kg）')
        .fontSize(13)
        .fontColor(BODY_COLOR)
        .margin({ top: 14 })
      TextInput({ text: this.weightInput, placeholder: '例如 58.5' })
        .type(InputType.NUMBER_DECIMAL)
        .maxLength(6)
        .height(46)
        .fontSize(16)
        .fontColor(TITLE_COLOR)
        .placeholderColor('#C9B2BE')
        .backgroundColor('#FFF6FA')
        .borderRadius(12)
        .padding({ left: 14, right: 14 })
        .margin({ top: 8 })
        .onChange((value: string) => {
          this.weightInput = value;
          this.errorText = '';
        })

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(12)
          .fontColor('#E05A5A')
          .margin({ top: 10 })
      }

      Row() {
        Row() {
          Text('取消')
            .fontSize(15)
            .fontColor('#8C7A84')
        }
        .layoutWeight(1)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .borderRadius(22)
        .backgroundColor('#F7F1F4')
        .margin({ right: 10 })
        .onClick(() => {
          if (this.controller !== undefined) {
            this.controller.close();
          }
        })

        Row() {
          Text('保存')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
        }
        .layoutWeight(1)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .borderRadius(22)
        .backgroundColor(PINK)
        .onClick(() => {
          this.confirm();
        })
      }
      .width('100%')
      .margin({ top: 18 })
    }
    .width('88%')
    .padding(22)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct WeightView {
  @Prop @Watch('onDueDateChanged') dueDate: string = '';
  @Prop @Watch('onTick') refreshTick: number = 0;

  @State points: ChartPoint[] = [];
  @State history: WeightRecord[] = [];
  @State currentWeek: number = 0;

  private addDialog: CustomDialogController | null = null;

  aboutToAppear(): void {
    this.reload();
  }

  onDueDateChanged(): void {
    this.reload();
  }

  onTick(): void {
    this.reload();
  }

  private async reload(): Promise<void> {
    this.refreshWeek();
    try {
      const list: WeightRecord[] = await DbHelper.getInstance().queryWeights();
      const pts: ChartPoint[] = [];
      for (let i = 0; i < list.length; i++) {
        const point: ChartPoint = { x: list[i].week, y: list[i].weight };
        pts.push(point);
      }
      const reversed: WeightRecord[] = [];
      for (let i = list.length - 1; i >= 0; i--) {
        reversed.push(list[i]);
      }
      this.points = pts;
      this.history = reversed;
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'reload failed: %{public}d %{public}s', error.code, error.message);
    }
  }

  private refreshWeek(): void {
    if (this.dueDate.length === 0) {
      this.currentWeek = 0;
      return;
    }
    const pregnancy: PregnancyWeek = getPregnancyWeek(this.dueDate, todayStr());
    this.currentWeek = pregnancy.week;
  }

  private openAddDialog(): void {
    if (this.dueDate.length === 0) {
      promptAction.showToast({ message: '请先在「我的」设置预产期' });
      return;
    }
    this.addDialog = new CustomDialogController({
      builder: WeightDialog({
        dueDate: this.dueDate,
        initialDate: todayStr(),
        onConfirm: (date: string, weight: number, week: number) => {
          this.saveWeight(date, weight, week);
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true
    });
    this.addDialog.open();
  }

  private async saveWeight(date: string, weight: number, week: number): Promise<void> {
    try {
      const helper: DbHelper = DbHelper.getInstance();
      const existing: WeightRecord[] = await helper.queryWeights();
      let target: WeightRecord | null = null;
      for (let i = 0; i < existing.length; i++) {
        if (existing[i].date === date) {
          target = existing[i];
          break;
        }
      }
      if (target !== null) {
        target.weight = weight;
        target.week = week;
        await helper.updateWeight(target);
        promptAction.showToast({ message: '已更新当日体重' });
      } else {
        const record: WeightRecord = new WeightRecord();
        record.date = date;
        record.weight = weight;
        record.week = week;
        await helper.insertWeight(record);
        promptAction.showToast({ message: '体重已记录' });
      }
      await this.reload();
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'saveWeight failed: %{public}d %{public}s', error.code, error.message);
      promptAction.showToast({ message: '保存失败，请重试' });
    }
  }

  private confirmDelete(record: WeightRecord): void {
    AlertDialog.show({
      title: '删除体重记录',
      message: `确定删除 ${formatMonthDay(record.date)} 的 ${record.weight.toFixed(1)} kg 记录吗？`,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#E05A5A',
        action: () => {
          this.deleteRecord(record);
        }
      }
    });
  }

  private async deleteRecord(record: WeightRecord): Promise<void> {
    try {
      await DbHelper.getInstance().deleteWeight(record.id);
      promptAction.showToast({ message: '记录已删除' });
      await this.reload();
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'deleteRecord failed: %{public}d %{public}s', error.code, error.message);
      promptAction.showToast({ message: '删除失败，请重试' });
    }
  }

  private rangeText(): string {
    if (this.dueDate.length === 0) {
      return '设置预产期后，可查看当前孕周的推荐增重区间。';
    }
    const lower: number = recommendedGainLower(this.currentWeek);
    const upper: number = recommendedGainUpper(this.currentWeek);
    return `孕${this.currentWeek}周建议累计增重约 ${lower.toFixed(1)} ~ ${upper.toFixed(1)} kg（以孕前体重为基准）。`;
  }

  @Builder
  header() {
    Row() {
      Column() {
        Text('体重记录')
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .fontColor(TITLE_COLOR)
        Text(`已记录 ${this.history.length} 条 · 关注增重节奏`)
          .fontSize(12)
          .fontColor(MUTED_COLOR)
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Row() {
        Text('＋ 记录')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
      }
      .height(38)
      .padding({ left: 16, right: 16 })
      .borderRadius(19)
      .backgroundColor(PINK)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.openAddDialog();
      })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 14 })
  }

  @Builder
  chartCard() {
    Column() {
      Row() {
        Text('体重趋势')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(TITLE_COLOR)
          .layoutWeight(1)
        Text(this.dueDate.length > 0 ? `当前孕${this.currentWeek}周` : '未设置预产期')
          .fontSize(11)
          .fontColor(PINK_DARK)
          .backgroundColor('#FFF0F6')
          .borderRadius(9)
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      LineChart({ points: this.points })
        .margin({ top: 8 })

      Column() {
        Text('参考增重区间')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(PINK_DARK)
        Text(this.rangeText())
          .fontSize(12)
          .lineHeight(19)
          .fontColor(BODY_COLOR)
          .margin({ top: 4 })
        Text('孕中晚期建议每周增重约 0.4 kg，具体请遵医嘱。')
          .fontSize(11)
          .fontColor(MUTED_COLOR)
          .margin({ top: 4 })
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFF4F9')
      .borderRadius(14)
      .margin({ top: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(CARD_BG)
    .borderRadius(22)
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 12, color: 'rgba(214,51,108,0.08)', offsetX: 0, offsetY: 4 })
  }

  @Builder
  historyRow(record: WeightRecord) {
    Row() {
      Column() {
        Text('⚖️')
          .fontSize(16)
      }
      .width(34)
      .height(34)
      .borderRadius(17)
      .backgroundColor('#FFF0F6')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ right: 12 })

      Column() {
        Text(`${formatMonthDay(record.date)} ${getWeekdayCN(record.date)}`)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(TITLE_COLOR)
        Text(`孕${record.week}周`)
          .fontSize(12)
          .fontColor(MUTED_COLOR)
          .margin({ top: 3 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(`${record.weight.toFixed(1)}`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(PINK_DARK)
      Text(' kg')
        .fontSize(12)
        .fontColor(MUTED_COLOR)
        .margin({ bottom: 2 })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .border({ width: { bottom: 0.5 }, color: '#F6E7EF' })
    .alignItems(VerticalAlign.Center)
    .gesture(
      LongPressGesture({ repeat: false, duration: 500 })
        .onAction((event: GestureEvent) => {
          this.confirmDelete(record);
        })
    )
  }

  @Builder
  historyCard() {
    Column() {
      Row() {
        Text('历史记录')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(TITLE_COLOR)
          .layoutWeight(1)
        Text(`${this.history.length} 条`)
          .fontSize(12)
          .fontColor('#C58AA6')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      if (this.history.length === 0) {
        Column() {
          Text('还没有体重记录')
            .fontSize(13)
            .fontColor('#B59AA8')
          Text('点击右上角「＋ 记录」添加第一条')
            .fontSize(11)
            .fontColor('#C9B2BE')
            .margin({ top: 4 })
        }
        .width('100%')
        .padding({ top: 22, bottom: 14 })
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(this.history, (record: WeightRecord) => {
          this.historyRow(record)
        }, (record: WeightRecord) => `${record.id}`)
        Text('长按条目可删除记录')
          .fontSize(11)
          .fontColor('#C9B2BE')
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: 10 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(CARD_BG)
    .borderRadius(22)
    .margin({ top: 16 })
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 12, color: 'rgba(214,51,108,0.08)', offsetX: 0, offsetY: 4 })
  }

  build() {
    Scroll() {
      Column() {
        this.header()
        this.chartCard()
        this.historyCard()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 18, bottom: 28 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF6FA')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
