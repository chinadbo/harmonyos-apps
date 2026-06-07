import { ShoppingList } from '../model/ShoppingList';

@Component
export struct ShoppingListCard {
  @Prop list: ShoppingList;
  @Prop totalCount: number;
  @Prop completedCount: number;
  onClick?: () => void;

  private getCategoryColor(): string {
    switch (this.list.category) {
      case '超市':
        return '#4C9BFF';
      case '菜市场':
        return '#3CB371';
      case '网购':
        return '#FF8C42';
      default:
        return '#8A8A8A';
    }
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text(this.list.name)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#222222')
          .layoutWeight(1)

        Text(this.list.category)
          .fontSize(12)
          .fontColor(this.getCategoryColor())
          .backgroundColor(`${this.getCategoryColor()}1A`)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .borderRadius(12)
      }
      .width('100%')

      Row({ space: 12 }) {
        Text(`共 ${this.totalCount} 项`)
          .fontSize(14)
          .fontColor('#666666')

        Text(`已完成 ${this.completedCount} 项`)
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')

      if (this.totalCount > 0) {
        Stack({ alignContent: Alignment.Start }) {
          Row()
            .width('100%')
            .height(6)
            .backgroundColor('#EAEAEA')
            .borderRadius(3)

          Row()
            .width(`${Math.max(8, Math.round((this.completedCount / this.totalCount) * 100))}%`)
            .height(6)
            .backgroundColor('#4C9BFF')
            .borderRadius(3)
        }
        .width('100%')
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({ radius: 12, color: '#14000000', offsetX: 0, offsetY: 4 })
    .onClick(() => {
      if (this.onClick) {
        this.onClick();
      }
    })
  }
}
