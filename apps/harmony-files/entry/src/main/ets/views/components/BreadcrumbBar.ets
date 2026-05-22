@Component
export struct BreadcrumbBar {
  @Prop pathParts: string[];
  @Prop onNavigate: (index: number) => void;

  build() {
    Scroll() {
      Row() {
        ForEach(this.pathParts, (part: string, index: number) => {
          Row() {
            Text(part)
              .fontSize(14)
              .fontColor(index === this.pathParts.length - 1 ? '#1a1a1a' : '#666666')
              .fontWeight(index === this.pathParts.length - 1 ? FontWeight.Bold : FontWeight.Normal)
              .onClick(() => {
                this.onNavigate(index);
              })

            if (index < this.pathParts.length - 1) {
              Text('>')
                .fontSize(12)
                .fontColor('#ccc')
                .margin({ left: 4, right: 4 })
            }
          }
          .alignItems(VerticalAlign.Center)
        }, (part: string, index: number) => `${index}-${part}`)
      }
      .alignItems(VerticalAlign.Center)
      .padding({ left: 12, right: 12 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(40)
  }
}
