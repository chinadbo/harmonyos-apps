let storageWidget = new LocalStorage();

@Entry(storageWidget)
@Component
struct WordWidget {
  @LocalStorageProp('word') word: string = 'achieve';
  @LocalStorageProp('phonetic') phonetic: string = '/əˈtʃiːv/';
  @LocalStorageProp('meaning') meaning: string = '达到；实现';
  @LocalStorageProp('example') example: string = 'Hard work helps you achieve goals.';

  build() {
    Column() {
      // 标题区
      Row() {
        Text('📖')
          .fontSize(14)
        Text('每日一词')
          .fontSize(12)
          .fontColor('#6B7280')
          .margin({ left: 4 })
        Blank()
        Text('HarmonyFlash')
          .fontSize(10)
          .fontColor('#9CA3AF')
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 单词
      Text(this.word)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A2E')
        .alignSelf(ItemAlign.Start)

      // 音标
      Text(this.phonetic)
        .fontSize(13)
        .fontColor('#6B7280')
        .alignSelf(ItemAlign.Start)
        .margin({ top: 2, bottom: 8 })

      // 释义
      Text(this.meaning)
        .fontSize(14)
        .fontColor('#374151')
        .alignSelf(ItemAlign.Start)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Blank()

      // 底部提示
      Text('点击开始学习 →')
        .fontSize(11)
        .fontColor('#3B82F6')
        .alignSelf(ItemAlign.End)
    }
    .width('100%')
    .height('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        params: {
          targetPage: 'StudyPage'
        }
      });
    })
  }
}
