@Entry
@Component
export struct WidgetCard {
  @LocalStorageProp('title') title: string = 'HarmonyPack'
  @LocalStorageProp('destination') destination: string = '暂无行程'
  @LocalStorageProp('dateText') dateText: string = '点击创建新的旅行计划'
  @LocalStorageProp('progressText') progressText: string = '打包进度 0%'
  @LocalStorageProp('progressValue') progressValue: string = '0'
  @LocalStorageProp('tripTypeText') tripTypeText: string = '尚未设置'
  @LocalStorageProp('tripId') tripId: string = '0'
  @LocalStorageProp('emptyText') emptyText: string = '立即开始添加行程'

  @State isLargeCard: boolean = false

  aboutToAppear(): void {
    const width = Number((AppStorage.Get('ohos.extra.param.key.form.width') as string) || '0')
    this.isLargeCard = width >= 320
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.title)
            .fontSize(this.isLargeCard ? 18 : 16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0F172A')
            .maxLines(1)
          Text(this.destination)
            .fontSize(this.isLargeCard ? 14 : 12)
            .fontColor('#475569')
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(`${this.progressValue}%`)
          .fontSize(this.isLargeCard ? 24 : 20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2563EB')
      }
      .width('100%')

      Text(this.dateText)
        .fontSize(12)
        .fontColor('#64748B')
        .width('100%')

      Text(this.tripTypeText)
        .fontSize(12)
        .fontColor('#64748B')
        .width('100%')

      if (this.isLargeCard) {
        Text(this.emptyText)
          .fontSize(12)
          .fontColor('#64748B')
          .width('100%')
      }

      Row()
        .width('100%')
        .height(8)
        .backgroundColor('#DBEAFE')
        .borderRadius(10)

      Button(this.isLargeCard ? '打开行程详情' : '打开应用')
        .width('100%')
        .height(34)
        .fontSize(13)
        .backgroundColor('#2563EB')
        .borderRadius(18)
        .onClick(() => {
          postCardAction(this, {
            action: 'router',
            bundleName: 'com.openclaw.harmonypack',
            moduleName: 'entry',
            abilityName: 'EntryAbility',
            params: {
              route: 'trip_detail',
              tripId: this.tripId,
              source: 'widget'
            }
          })
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
