/**
 * 2x2 每日一题卡片：题干 + 选项摘要，点击进入 App 刷题
 */
let storage = new LocalStorage()

@Entry(storage)
@Component
struct QuestionWidgetCard {
  @LocalStorageProp('stem') stem: string = '今日份驾考题'
  @LocalStorageProp('options') options: string = '打开 App 开始刷题'
  @LocalStorageProp('chapter') chapter: string = '驾考通'
  @LocalStorageProp('subject') subject: number = 1

  build() {
    Column() {
      Row() {
        Text('🚗 驾考每日一题')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C64F2')
        Blank()
        Text(this.chapter)
          .fontSize(11)
          .fontColor('#6B7280')
      }
      .width('100%')

      Text(this.stem)
        .fontSize(14)
        .fontColor('#1F2937')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(20)
        .margin({ top: 10 })
        .width('100%')

      Text(this.options)
        .fontSize(11)
        .fontColor('#6B7280')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 8 })
        .width('100%')

      Blank()

      Text('点击卡片去答题 ›')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1C64F2')
        .alignSelf(ItemAlign.End)
        .margin({ bottom: 6 })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .borderRadius(20)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      postCardAction({
        'action': 'router',
        'abilityName': 'EntryAbility',
        'params': {
          'target': 'pages/PracticePage'
        }
      })
    })
  }
}
