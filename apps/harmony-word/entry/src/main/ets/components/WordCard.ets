@Component
export struct WordCard {
  word: string = ''
  pinyin: string = ''
  definition: string = ''
  groupName: string = '默认'
  showBadge: boolean = true
  onClickAction: () => void = () => {}

  build() {
    Column({ space: 10 }) {
      Row() {
        Text(this.word)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
        Blank()
        if (this.showBadge) {
          Text(this.groupName)
            .fontSize(12)
            .fontColor('#2563EB')
            .backgroundColor('#DBEAFE')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .borderRadius(12)
        }
      }
      .width('100%')

      Text(this.pinyin)
        .fontSize(14)
        .fontColor('#6B7280')
        .width('100%')

      Text(this.definition)
        .fontSize(15)
        .fontColor('#374151')
        .width('100%')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding(16)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({ radius: 8, color: '#14000000', offsetX: 0, offsetY: 4 })
    .onClick(() => {
      this.onClickAction()
    })
  }
}
