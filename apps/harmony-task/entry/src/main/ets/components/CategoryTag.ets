@Component
export struct CategoryTag {
  @Prop name: string = '';
  @Prop color: string = '#999999';
  @Prop selected: boolean = false;
  onTap?: () => void;

  build() {
    Text(this.name)
      .fontSize(13)
      .fontColor(this.selected ? Color.White : this.color)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.selected ? this.color : this.color + '20')
      .borderRadius(16)
      .onClick(() => {
        if (this.onTap) {
          this.onTap();
        }
      })
  }
}
