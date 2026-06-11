@Component
export struct QuickAddButton {
  @Prop label: string = ''
  @Prop amount: number = 0
  @Prop onTap: (amount: number) => void = () => {}

  build() {
    Button(`${this.label}\n${this.amount} ml`)
      .type(ButtonType.Capsule)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .width('22%')
      .height(64)
      .onClick(() => this.onTap(this.amount))
  }
}
