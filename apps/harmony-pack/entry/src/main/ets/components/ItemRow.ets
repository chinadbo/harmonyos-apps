import { Item } from '../model/Item'
import { getCategoryLabel } from '../model/Constants'

@Component
export struct ItemRow {
  @Prop item: Item = new Item()
  @Prop onToggle: (itemId: number, isPacked: boolean) => void = () => {
  }
  @Prop onEdit: (itemId: number) => void = () => {
  }

  build() {
    Row({ space: 12 }) {
      Checkbox({ name: `item-${this.item.id}`, group: 'trip-items' })
        .select(this.item.isPacked)
        .onChange((value: boolean) => {
          this.onToggle(this.item.id, value)
        })

      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(this.item.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.item.isPacked ? '#94A3B8' : '#111827')
            .decoration({ type: this.item.isPacked ? TextDecorationType.LineThrough : TextDecorationType.None })
          Text(`x${this.item.quantity}`)
            .fontSize(12)
            .fontColor('#2563EB')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor('#EFF6FF')
            .borderRadius(10)
        }

        Text(getCategoryLabel(this.item.category))
          .fontSize(12)
          .fontColor('#64748B')

        if (this.item.note.length > 0) {
          Text(this.item.note)
            .fontSize(12)
            .fontColor('#94A3B8')
            .maxLines(2)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Button('编辑')
        .fontSize(13)
        .height(32)
        .backgroundColor('#F8FAFC')
        .fontColor('#2563EB')
        .borderRadius(16)
        .onClick(() => {
          this.onEdit(this.item.id)
        })
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
}
