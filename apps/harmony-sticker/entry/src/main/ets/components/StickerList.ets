import { StickerItem } from '../models/StickerModel';

@Component
export struct StickerList {
  @Prop stickers: StickerItem[];
  @Prop selectedStickerId: number;
  onSelectSticker?: (id: number) => void;

  build() {
    Column({ space: 8 }) {
      Text('Sticker layers')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)

      if (this.stickers.length === 0) {
        Text('Add a sticker to start composing your meme.')
          .fontSize(13)
          .fontColor('#FF64748B')
      }

      ForEach(this.stickers, (item: StickerItem) => {
        Row() {
          Text(item.text)
            .fontSize(14)
            .fontWeight(this.selectedStickerId === item.id ? FontWeight.Bold : FontWeight.Medium)
            .fontColor('#FF0F172A')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .padding(12)
        .backgroundColor(this.selectedStickerId === item.id ? '#FFE0E7FF' : '#FFFFFFFF')
        .borderRadius(16)
        .border({ width: 1, color: this.selectedStickerId === item.id ? '#FF4F46E5' : '#FFE2E8F0' })
        .onClick(() => {
          if (this.onSelectSticker) {
            this.onSelectSticker(item.id);
          }
        });
      }, (item: StickerItem) => item.id.toString())
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
