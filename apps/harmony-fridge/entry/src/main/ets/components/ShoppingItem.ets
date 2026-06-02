import { ShoppingEntry } from '../model/ShoppingEntry';

@Component
export struct ShoppingItem {
  @Prop entry: ShoppingEntry = new ShoppingEntry();
  @Prop onToggle: (entry: ShoppingEntry) => void = () => {};
  @Prop onDelete: (entry: ShoppingEntry) => void = () => {};

  build() {
    Row({ space: 12 }) {
      Checkbox({ name: `shopping_${this.entry.id}`, group: 'shopping' })
        .select(this.entry.completed === 1)
        .onChange(() => {
          this.onToggle(this.entry);
        })
      Column({ space: 4 }) {
        Text(this.entry.name)
          .fontSize(16)
          .fontColor(this.entry.completed === 1 ? '#91A290' : '#20331E')
          .decoration({ type: this.entry.completed === 1 ? TextDecorationType.LineThrough : TextDecorationType.None })
        Text(this.entry.quantityText)
          .fontSize(13)
          .fontColor('#6D816B')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Button('删除')
        .type(ButtonType.Capsule)
        .backgroundColor('#FCEDEE')
        .fontColor('#AD4257')
        .onClick(() => {
          this.onDelete(this.entry);
        })
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
  }
}
