import common from '@ohos.app.ability.common';
import { ExpressionEvaluator, AngleMode } from '../engine/ExpressionEvaluator';
import { CalculatorDb } from '../data/CalculatorDb';
import { HistoryRecord } from '../model/HistoryRecord';
import { CalcButton } from '../components/CalcButton';
import { HistorySheet } from '../components/HistorySheet';

@Component
export struct ScientificCalcPage {
  @State private expression: string = '';
  @State private result: string = '0';
  @State private angleMode: AngleMode = 'deg';
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
        this.buildScientificPad();
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
          await CalculatorDb.clearHistory(this.context, 'scientific');
          this.histories = [];
        }
      });
    }
  }

  @Builder
  private buildHeader(): void {
    Row() {
      Text('科学计算器')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White);
      Blank();
      Button(this.angleMode === 'deg' ? 'DEG' : 'RAD')
        .fontColor(Color.White)
        .backgroundColor('#FF9F0A')
        .borderRadius(18)
        .margin({ right: 8 })
        .onClick(() => {
          this.angleMode = this.angleMode === 'deg' ? 'rad' : 'deg';
          this.previewResult();
        });
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
        .fontSize(24)
        .fontColor('#A0A0A5')
        .width('100%')
        .textAlign(TextAlign.End)
        .maxLines(3);
      Text(this.result)
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .width('100%')
        .textAlign(TextAlign.End);
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#242426')
    .borderRadius(24)
    .layoutWeight(1)
    .justifyContent(FlexAlign.End);
  }

  @Builder
  private buildScientificPad(): void {
    Column({ space: 12 }) {
      this.buildRow(['sin(', 'cos(', 'tan(', 'log('], ['function', 'function', 'function', 'function']);
      this.buildRow(['ln(', 'sqrt(', 'abs(', 'factorial('], ['function', 'function', 'function', 'function']);
      this.buildRow(['C', '(', ')', '^'], ['function', 'function', 'function', 'operator']);
      this.buildRow(['7', '8', '9', '÷'], ['number', 'number', 'number', 'operator']);
      this.buildRow(['4', '5', '6', '×'], ['number', 'number', 'number', 'operator']);
      this.buildRow(['1', '2', '3', '−'], ['number', 'number', 'number', 'operator']);
      Row({ space: 12 }) {
        CalcButton({ text: '0', styleType: 'number', onTap: () => this.handleInput('0') });
        CalcButton({ text: '.', styleType: 'number', onTap: () => this.handleInput('.') });
        CalcButton({ text: '%', styleType: 'operator', onTap: () => this.handleInput('%') });
        CalcButton({ text: '+', styleType: 'operator', onTap: () => this.handleInput('+') });
      }
      .width('100%');
      Row({ space: 12 }) {
        CalcButton({ text: 'π', styleType: 'function', onTap: () => this.handleInput('π') });
        CalcButton({ text: 'e', styleType: 'function', onTap: () => this.handleInput('e') });
        CalcButton({ text: '!', styleType: 'function', onTap: () => this.handleInput('!') });
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
    this.handleInput(label);
  }

  private handleInput(text: string): void {
    this.expression += text;
    this.previewResult();
  }

  private previewResult(): void {
    if (this.expression.length === 0) {
      this.result = '0';
      return;
    }
    try {
      this.result = ExpressionEvaluator.evaluateToString(this.expression, this.angleMode);
    } catch (error) {
    }
  }

  private async handleEqual(): Promise<void> {
    if (this.expression.length === 0 || !this.context) {
      return;
    }
    try {
      const computed: string = ExpressionEvaluator.evaluateToString(this.expression, this.angleMode);
      await CalculatorDb.insertHistory(this.context, this.expression, computed, 'scientific');
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
    this.histories = await CalculatorDb.getHistory(this.context, 'scientific');
  }
}
