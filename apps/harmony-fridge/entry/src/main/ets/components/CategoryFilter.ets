import { Constants } from '../common/Constants';

@Component
export struct CategoryFilter {
  @Prop categories: string[] = [Constants.ALL_CATEGORY, ...Constants.CATEGORIES];
  @Link selectedCategory: string;

  build() {
    Scroll() {
      Row({ space: 8 }) {
        ForEach(this.categories, (category: string) => {
          Text(category)
            .fontSize(14)
            .fontColor(this.selectedCategory === category ? '#FFFFFF' : '#30512F')
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.selectedCategory === category ? '#5E8E5A' : '#E8F3E7')
            .borderRadius(18)
            .onClick(() => {
              this.selectedCategory = category;
            })
        }, (category: string) => category)
      }
    }
    .scrollBar(BarState.Off)
  }
}
