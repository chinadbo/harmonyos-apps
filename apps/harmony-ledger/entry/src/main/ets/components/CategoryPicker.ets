import { Category } from '../data/DataModels';

@Component
export struct CategoryPicker {
  @Prop categories: Category[] = [];
  @Link selectedCategoryId: number;

  build() {
    Column({ space: 12 }) {
      Text('分类')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.categories, (category: Category) => {
          Row() {
            Text(category.icon)
              .fontSize(18)
            Text(category.name)
              .fontSize(14)
              .margin({ left: 6 })
          }
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .margin({ right: 8, bottom: 8 })
          .backgroundColor(this.selectedCategoryId === category.id ? category.color : '#F5F5F5')
          .opacity(this.selectedCategoryId === category.id ? 1 : 0.88)
          .borderRadius(20)
          .onClick(() => {
            this.selectedCategoryId = category.id;
          })
        }, (category: Category) => `${category.id}`)
      }
    }
    .alignItems(HorizontalAlign.Start)
  }
}
