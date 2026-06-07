@Component
export struct ProgressBar {
  @Prop total: number;
  @Prop completed: number;

  private getProgress(): number {
    if (this.total <= 0) {
      return 0;
    }
    return this.completed / this.total;
  }

  build() {
    Column({ space: 8 }) {
      Row() {
        Text('完成进度')
          .fontSize(15)
          .fontColor('#666666')
          .layoutWeight(1)

        Text(`${this.completed}/${this.total}`)
          .fontSize(15)
          .fontColor('#4C9BFF')
      }
      .width('100%')

      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(10)
          .backgroundColor('#E8EDF3')
          .borderRadius(5)

        Row()
          .width(`${Math.round(this.getProgress() * 100)}%`)
          .height(10)
          .backgroundColor('#4C9BFF')
          .borderRadius(5)
      }
      .width('100%')
    }
    .width('100%')
  }
}
