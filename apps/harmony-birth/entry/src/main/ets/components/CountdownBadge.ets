@Component
export struct CountdownBadge {
  @Prop label: string;
  @Prop backgroundColor: string = '#FFE7D9';
  @Prop textColor: string = '#D9480F';

  build() {
    Text(this.label)
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.textColor)
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .backgroundColor(this.backgroundColor)
      .borderRadius(12)
  }
}
