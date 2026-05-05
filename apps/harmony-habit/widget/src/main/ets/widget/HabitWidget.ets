let widgetStorage = new LocalStorage({
  todayDone: 0,
  todayTotal: 0,
  todayQuote: '今天完成一小步，长期就是一大步。'
});

@Entry(widgetStorage)
@Component
export struct HabitWidget {
  @StorageProp('todayDone') todayDone: number = 0;
  @StorageProp('todayTotal') todayTotal: number = 0;
  @StorageProp('todayQuote') todayQuote: string = '今天完成一小步，长期就是一大步。';

  private percent(): number {
    if (this.todayTotal === 0) {
      return 0;
    }
    return Math.round(this.todayDone * 100 / this.todayTotal);
  }

  build() {
    Column({ space: 10 }) {
      Text('HarmonyHabit')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('100%')
        .textAlign(TextAlign.Start)

      Row() {
        Column({ space: 4 }) {
          Text(`${this.todayDone}/${this.todayTotal}`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('今日打卡')
            .fontSize(12)
            .fontColor('#FFFFFFCC')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(`${this.percent()}%`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#A7F3D0')
      }

      Text(this.todayQuote)
        .fontSize(11)
        .fontColor('#E0EAFF')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      Button('打开应用')
        .height(30)
        .backgroundColor('#FFFFFF22')
        .fontColor('#FFFFFF')
        .onClick(() => {
          postCardAction(this, {
            action: 'router',
            bundleName: 'com.chinadbo.harmonyhabit',
            abilityName: 'EntryAbility',
            params: {
              targetPage: 'pages/Index'
            }
          });
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#111827')
  }
}
