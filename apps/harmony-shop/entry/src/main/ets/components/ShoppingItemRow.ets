import { ShoppingItem } from '../model/ShoppingItem';

@Component
export struct ShoppingItemRow {
  @Prop item: ShoppingItem;
  onToggle?: (id: number, value: boolean) => void;
  onDelete?: (id: number) => void;

  build() {
    Row({ space: 12 }) {
      Checkbox({ name: `${this.item.id}` })
        .select(this.item.isCompleted)
        .onChange((value: boolean) => {
          if (this.onToggle) {
            this.onToggle(this.item.id, value);
          }
        })

      Column({ space: 4 }) {
        Text(this.item.name)
          .fontSize(18)
          .fontColor(this.item.isCompleted ? '#999999' : '#222222')
          .decoration({ type: this.item.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })

        Row({ space: 8 }) {
          Text(`${this.item.quantity}${this.item.unit}`)
            .fontSize(13)
            .fontColor('#666666')

          Text(this.item.category)
            .fontSize(13)
            .fontColor('#666666')

          if (this.item.note.length > 0) {
            Text(this.item.note)
              .fontSize(13)
              .fontColor('#999999')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Button('删除')
        .fontSize(12)
        .height(30)
        .backgroundColor('#FFE8E8')
        .fontColor('#D94B4B')
        .onClick(() => {
          if (this.onDelete) {
            this.onDelete(this.item.id);
          }
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
    .opacity(this.item.isCompleted ? 0.7 : 1)
  }
}
