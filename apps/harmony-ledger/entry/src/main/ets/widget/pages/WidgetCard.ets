declare function postCardAction(component: Object, options: {
  action: string;
  abilityName: string;
  params?: Record<string, string | number | boolean>;
}): void;

let storage = new LocalStorage();

@Entry(storage)
@Component
struct WidgetCard {
  @LocalStorageProp('monthlyBalance') monthlyBalance: string = '0.00';
  @LocalStorageProp('todayExpense') todayExpense: string = '0.00';
  @LocalStorageProp('currency') currency: string = '¥';

  build() {
    Column({ space: 12 }) {
      Text('HarmonyLedger')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)
      Row() {
        this.buildMetric('本月结余', `${this.currency}${this.monthlyBalance}`)
        this.buildMetric('今日支出', `${this.currency}${this.todayExpense}`)
      }
      Button('快速记账')
        .width('100%')
        .height(36)
        .backgroundColor('#5C6BC0')
        .fontColor(Color.White)
        .onClick(() => {
          postCardAction(this, {
            action: 'router',
            abilityName: 'EntryAbility',
            params: { targetPage: 'add' }
          });
        })
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }

  @Builder
  private buildMetric(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#757575')
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
  }
}
