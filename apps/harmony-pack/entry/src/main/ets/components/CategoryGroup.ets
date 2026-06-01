import { CategoryItemGroup } from '../model/Item'
import { getCategoryLabel } from '../model/Constants'
import ItemRow from './ItemRow'

@Component
export struct CategoryGroup {
  @Prop group: CategoryItemGroup = { category: 'other', items: [] }
  @State expanded: boolean = true
  @Prop onToggleItem: (itemId: number, isPacked: boolean) => void = () => {
  }
  @Prop onEditItem: (itemId: number) => void = () => {
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 4 }) {
          Text(getCategoryLabel(this.group.category))
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0F172A')
          Text(`${this.group.items.length} 项物品`)
            .fontSize(12)
            .fontColor('#64748B')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.expanded ? '收起' : '展开')
          .fontSize(13)
          .fontColor('#2563EB')
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#F8FAFC')
      .borderRadius(18)
      .onClick(() => {
        this.expanded = !this.expanded
      })

      if (this.expanded) {
        Column({ space: 10 }) {
          ForEach(this.group.items, (item) => {
            ItemRow({
              item: item,
              onToggle: this.onToggleItem,
              onEdit: this.onEditItem
            })
          }, (item) => `${item.id}`)
        }
      }
    }
    .width('100%')
  }
}
