@Component
export struct SectionHeader {
  @Prop title: string = '';
  @Prop actionText: string = '';
  onAction?: () => void;

  build() {
    Row() {
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#16202A')
        .layoutWeight(1)
      if (this.actionText.length > 0) {
        Button(this.actionText)
          .type(ButtonType.Capsule)
          .backgroundColor('#EAF0FF')
          .fontColor('#4E7BF2')
          .onClick(() => {
            if (this.onAction) {
              this.onAction();
            }
          })
      }
    }
    .width('100%')
  }
}
