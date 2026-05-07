@Component
export struct CategoryFilter {
  @Prop categories: string[] = [];
  @Prop selectedCategory: string = '全部';
  onSelect?: (category: string) => void = undefined;

  build() {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(this.categories, (category: string) => {
          Text(category)
            .fontSize(14)
            .fontWeight(this.selectedCategory === category ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(this.selectedCategory === category ? '#FFFFFF' : '#6F5D52')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(this.selectedCategory === category ? '#FF8A3D' : '#FFF5EC')
            .borderRadius(20)
            .onClick(() => {
              if (this.onSelect) {
                this.onSelect(category);
              }
            })
        }, (category: string) => category)
      }
      .padding({ right: 20 })
    }
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Horizontal)
  }
}
