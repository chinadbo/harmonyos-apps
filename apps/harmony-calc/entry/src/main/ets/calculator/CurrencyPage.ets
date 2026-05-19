import common from '@ohos.app.ability.common';
import { ExchangeRateService, ExchangeRatesPayload } from '../network/ExchangeRateService';

@Component
export struct CurrencyPage {
  @State private currencies: Array<string> = ExchangeRateService.getSupportedCurrencies();
  @State private fromCurrency: string = 'CNY';
  @State private toCurrency: string = 'USD';
  @State private amount: string = '100';
  @State private converted: string = '13.8';
  @State private source: string = 'loading';
  @State private updatedAt: string = '--';
  private context?: common.UIAbilityContext;
  private payload?: ExchangeRatesPayload;

  async aboutToAppear(): Promise<void> {
    this.context = getContext(this) as common.UIAbilityContext;
    await this.refreshRates(false);
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Text('汇率换算')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White);
        Blank();
        Button('刷新')
          .fontColor(Color.White)
          .backgroundColor('#FF9F0A')
          .borderRadius(18)
          .onClick(async () => await this.refreshRates(true));
      }
      .width('100%');

      Text(`来源：${this.source}  更新时间：${this.updatedAt}`)
        .fontSize(13)
        .fontColor('#A0A0A5')
        .width('100%');

      Column({ space: 16 }) {
        this.buildCurrencySelect('源货币', true);
        TextInput({ text: this.amount, placeholder: '输入金额' })
          .type(InputType.Normal)
          .fontColor(Color.White)
          .backgroundColor('#2C2C2E')
          .borderRadius(16)
          .onChange((value: string) => {
            this.amount = value;
            this.calculate();
          });
        this.buildCurrencySelect('目标货币', false);
        TextInput({ text: this.converted, placeholder: '换算结果' })
          .type(InputType.Normal)
          .fontColor(Color.White)
          .backgroundColor('#2C2C2E')
          .borderRadius(16)
          .onChange((value: string) => {
            this.converted = value;
            this.reverseCalculate();
          });
        Button('交换货币')
          .fontColor(Color.White)
          .backgroundColor('#3A3A3C')
          .borderRadius(20)
          .onClick(() => {
            const temp: string = this.fromCurrency;
            this.fromCurrency = this.toCurrency;
            this.toCurrency = temp;
            this.calculate();
          });
      }
      .padding(16)
      .backgroundColor('#242426')
      .borderRadius(24)
      .width('100%');

      Column({ space: 8 }) {
        ForEach(this.currencies, (currency: string) => {
          Row() {
            Text(`1 CNY`)
              .fontSize(14)
              .fontColor('#A0A0A5');
            Blank();
            Text(`${this.getRateLabel(currency)} ${currency}`)
              .fontSize(15)
              .fontColor(Color.White);
          }
          .width('100%')
          .padding({ top: 6, bottom: 6 });
        });
      }
      .padding(16)
      .backgroundColor('#242426')
      .borderRadius(24)
      .width('100%');
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#1C1C1E');
  }

  @Builder
  private buildCurrencySelect(title: string, isSource: boolean): void {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(14)
        .fontColor('#A0A0A5')
        .width('100%');
      Select(this.currencies.map((currency: string) => ({ value: currency })))
        .selected(this.findCurrencyIndex(isSource ? this.fromCurrency : this.toCurrency))
        .value(isSource ? this.fromCurrency : this.toCurrency)
        .fontColor(Color.White)
        .backgroundColor('#2C2C2E')
        .borderRadius(16)
        .onSelect((index: number) => {
          if (isSource) {
            this.fromCurrency = this.currencies[index];
            this.calculate();
          } else {
            this.toCurrency = this.currencies[index];
            this.calculate();
          }
        });
    }
    .width('100%');
  }

  private async refreshRates(forceRefresh: boolean): Promise<void> {
    if (!this.context) {
      return;
    }
    try {
      this.payload = await ExchangeRateService.getRates(this.context, forceRefresh);
      this.source = this.payload.source;
      this.updatedAt = this.formatTime(this.payload.timestamp);
      this.calculate();
    } catch (error) {
      this.source = 'error';
    }
  }

  private calculate(): void {
    if (!this.payload) {
      return;
    }
    const amountNumber: number = Number(this.amount);
    if (!isFinite(amountNumber)) {
      this.converted = '';
      return;
    }
    const cnyValue: number = amountNumber / this.payload.rates[this.fromCurrency];
    const targetValue: number = cnyValue * this.payload.rates[this.toCurrency];
    this.converted = this.format(targetValue);
  }

  private reverseCalculate(): void {
    if (!this.payload) {
      return;
    }
    const targetNumber: number = Number(this.converted);
    if (!isFinite(targetNumber)) {
      this.amount = '';
      return;
    }
    const cnyValue: number = targetNumber / this.payload.rates[this.toCurrency];
    const sourceValue: number = cnyValue * this.payload.rates[this.fromCurrency];
    this.amount = this.format(sourceValue);
  }

  private getRateLabel(currency: string): string {
    if (!this.payload) {
      return '--';
    }
    return this.format(this.payload.rates[currency]);
  }

  private findCurrencyIndex(currency: string): number {
    const index: number = this.currencies.indexOf(currency);
    return index >= 0 ? index : 0;
  }

  private format(value: number): string {
    return value.toFixed(6).replace(/\.0+$/, '').replace(/(\.\d*?[1-9])0+$/, '$1');
  }

  private formatTime(timestamp: number): string {
    const date: Date = new Date(timestamp);
    const month: string = (date.getMonth() + 1).toString().padStart(2, '0');
    const day: string = date.getDate().toString().padStart(2, '0');
    const hours: string = date.getHours().toString().padStart(2, '0');
    const minutes: string = date.getMinutes().toString().padStart(2, '0');
    return `${month}-${day} ${hours}:${minutes}`;
  }
}
