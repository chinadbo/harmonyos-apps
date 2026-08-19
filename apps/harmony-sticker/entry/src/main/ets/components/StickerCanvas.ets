import { BackgroundOption, StickerItem } from '../models/StickerModel';
import { CANVAS_HEIGHT, CANVAS_WIDTH } from '../common/EditorDefaults';

@Component
export struct StickerCanvas {
  @Prop stickers: StickerItem[];
  @Prop selectedStickerId: number;
  @Prop background: BackgroundOption;
  onSelectSticker?: (id: number) => void;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Text(this.background.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.background.accent)
          .margin({ top: 18, left: 18, right: 18 })

        Text('Create your meme moment')
          .fontSize(12)
          .fontColor(this.background.accent)
          .opacity(0.88)
          .margin({ top: 6, left: 18, right: 18 })
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 135,
        colors: [[this.background.colors[0], 0], [this.background.colors[1], 1]]
      })
      .borderRadius(24)

      ForEach(this.stickers, (item: StickerItem) => {
        Text(item.text)
          .fontSize(item.fontSize)
          .fontWeight(FontWeight.ExtraBold)
          .fontColor(item.color)
          .textAlign(TextAlign.Center)
          .textShadow({ radius: 2, color: '#66000000', offsetX: 0, offsetY: 1 })
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.selectedStickerId === item.id ? '#33FFFFFF' : '#1AFFFFFF')
          .borderRadius(16)
          .border({
            width: this.selectedStickerId === item.id ? 2 : 1,
            color: this.selectedStickerId === item.id ? '#FFFFFFFF' : '#66FFFFFF'
          })
          .position({ x: CANVAS_WIDTH / 2 - 80 + item.offsetX, y: CANVAS_HEIGHT / 2 - 24 + item.offsetY })
          .onClick(() => {
            if (this.onSelectSticker) {
              this.onSelectSticker(item.id);
            }
          });
      }, (item: StickerItem) => item.id.toString())
    }
    .width(CANVAS_WIDTH)
    .height(CANVAS_HEIGHT)
    .borderRadius(24)
    .clip(true)
    .shadow({ radius: 16, color: '#260F172A', offsetX: 0, offsetY: 10 })
  }
}
