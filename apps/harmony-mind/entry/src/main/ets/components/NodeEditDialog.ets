@Component
export struct NodeEditDialog {
  @Link isVisible: boolean;
  @Link draftText: string;
  @Prop title: string;
  @Prop isDarkMode: boolean;
  onConfirm?: (text: string) => void;

  build() {
    if (this.isVisible) {
      Column() {
        Column({ space: 16 }) {
          Text(this.title)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.isDarkMode ? '#FFF4F7FB' : '#FF1F2530')

          TextInput({ text: this.draftText, placeholder: '请输入节点文本' })
            .width('100%')
            .fontSize(16)
            .onChange((value: string) => {
              this.draftText = value;
            })

          Row({ space: 12 }) {
            Button('取消')
              .layoutWeight(1)
              .backgroundColor(this.isDarkMode ? '#FF303B48' : '#FFE7ECF3')
              .fontColor(this.isDarkMode ? '#FFF4F7FB' : '#FF1F2530')
              .onClick(() => {
                this.isVisible = false;
              })
            Button('确认')
              .layoutWeight(1)
              .backgroundColor('#FF5B8FF9')
              .onClick(() => {
                if (this.onConfirm) {
                  this.onConfirm(this.draftText);
                }
                this.isVisible = false;
              })
          }
          .width('100%')
        }
        .width('84%')
        .padding(20)
        .backgroundColor(this.isDarkMode ? '#FF1E2630' : '#FFFFFFFF')
        .borderRadius(20)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')
      .backgroundColor('#66000000')
      .position({ x: 0, y: 0 })
      .zIndex(99)
    }
  }
}
