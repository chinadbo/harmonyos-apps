@Component
export struct EmptyState {
  title: string = '还没有内容';
  message: string = '开始记录第一篇日记吧';

  build() {
    Column({ space: 10 }) {
      Text('◌')
        .fontSize(36)
        .fontColor('#94A3B8')
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#0F172A')
      Text(this.message)
        .fontSize(13)
        .fontColor('#64748B')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ top: 32, bottom: 32, left: 20, right: 20 })
    .backgroundColor('#F8FAFC')
    .borderRadius(20)
  }
}
