import common from '@ohos.app.ability.common';
import { ExpressionEvaluator } from '../engine/ExpressionEvaluator';
import { CalculatorDb } from '../data/CalculatorDb';
import { HistoryRecord } from '../model/HistoryRecord';
import { CalcButton } from '../components/CalcButton';
import { HistorySheet } from '../components/HistorySheet';

@Component
export struct StandardCalcPage {
  @State private expression: string = '';
  @State private result: string = '0';
  @State private histories: Array<HistoryRecord> = [];
  @State private showHistory: boolean = false;
  private context?: common.UIAbilityContext;

  async aboutToAppear(): Promise<void> {
    this.context = getContext(this) as common.UIAbilityContext;
    await this.loadHistory();
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column({ space: 16 }) {
        this.buildHeader();
        this.buildDisplay();
        this.buildKeypad();
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .backgroundColor('#1C1C1E');

      HistorySheet({
        records: this.histories,
        visible: this.showHistory,
        onClose: () => this.showHistory = false,
        onSelect: (record: HistoryRecord) => {
          this.expression = record.expression;
          this.result = record.result;
          this.showHistory = false;
        },
        onClear: async () => {
          if (!this.context) {
            return;
          }
          await CalculatorDb.clearHistory(this.context, 'standard');
          this.histories = [];
        }
      });
    }
  }

  @Builder
  private buildHeader(): void {
    Row() {
      Text('标准计算器')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White);
      Blank();
      Button('历史')
        .fontColor(Color.White)
        .backgroundColor('#3A3A3C')
        .borderRadius(18)
        .onClick(() => this.showHistory = true);
    }
    .width('100%');
  }

  @Builder
  private buildDisplay(): void {
    Column({ space: 8 }) {
      Text(this.expression.length > 0 ? this.expression : '0')
        .fontSize(28)
        .fontColor('#A0A0A5')
        .width('100%')
        .textAlign(TextAlign.End)
        .maxLines(2);
      Text(this.result)
        .fontSize(44)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .width('100%')
        .textAlign(TextAlign.End)
        .maxLines(1);
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#242426')
    .borderRadius(24)
    .layoutWeight(1)
    .justifyContent(FlexAlign.End);
  }

  @Builder
  private buildKeypad(): void {
    Column({ space: 12 }) {
      this.buildRow(['C', '(', ')', '÷'], ['function', 'function', 'function', 'operator']);
      this.buildRow(['7', '8', '9', '×'], ['number', 'number', 'number', 'operator']);
      this.buildRow(['4', '5', '6', '−'], ['number', 'number', 'number', 'operator']);
      this.buildRow(['1', '2', '3', '+'], ['number', 'number', 'number', 'operator']);
      Row({ space: 12 }) {
        CalcButton({ text: '0', styleType: 'number', widthRatio: 2, onTap: () => this.handleInput('0') });
        CalcButton({ text: '.', styleType: 'number', onTap: () => this.handleInput('.') });
        CalcButton({ text: '=', styleType: 'operator', onTap: () => this.handleEqual() });
      }
      .width('100%');
    }
    .width('100%');
  }

  @Builder
  private buildRow(labels: Array<string>, styles: Array<string>): void {
    Row({ space: 12 }) {
      ForEach(labels, (label: string, index: number) => {
        CalcButton({
          text: label,
          styleType: styles[index] as ('number' | 'operator' | 'function'),
          onTap: () => this.handleTap(label)
        });
      });
    }
    .width('100%');
  }

  private handleTap(label: string): void {
    if (label === 'C') {
      this.expression = '';
      this.result = '0';
      return;
    }
    if (label === '=') {
      this.handleEqual();
      return;
    }
    this.handleInput(label);
  }

  private handleInput(label: string): void {
    this.expression += label;
    this.previewResult();
  }

  private previewResult(): void {
    if (this.expression.length === 0) {
      this.result = '0';
      return;
    }
    try {
      this.result = ExpressionEvaluator.evaluateToString(this.expression);
    } catch (error) {
    }
  }

  private async handleEqual(): Promise<void> {
    if (this.expression.length === 0 || !this.context) {
      return;
    }
    try {
      const computed: string = ExpressionEvaluator.evaluateToString(this.expression);
      await CalculatorDb.insertHistory(this.context, this.expression, computed, 'standard');
      this.result = computed;
      this.expression = computed;
      await this.loadHistory();
    } catch (error) {
      this.result = '错误';
    }
  }

  private async loadHistory(): Promise<void> {
    if (!this.context) {
      return;
    }
    this.histories = await CalculatorDb.getHistory(this.context, 'standard');
  }
}
