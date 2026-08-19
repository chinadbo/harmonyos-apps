import { MOVE_STEP } from '../common/EditorDefaults';
import { BackgroundOption, StickerItem } from '../models/StickerModel';

@Component
export struct StickerToolbar {
  @Prop stickerText: string;
  @Prop selectedSticker: StickerItem | null;
  @Prop colorOptions: string[];
  @Prop backgroundOptions: BackgroundOption[];
  @Prop selectedBackgroundId: number;
  onTextChange?: (value: string) => void;
  onAddSticker?: () => void;
  onDeleteSticker?: () => void;
  onMoveSticker?: (dx: number, dy: number) => void;
  onFontSizeChange?: (delta: number) => void;
  onColorSelect?: (color: string) => void;
  onBackgroundSelect?: (id: number) => void;

  @Builder private actionButton(label: string, handler?: () => void) {
    Button(label)
      .type(ButtonType.Capsule)
      .fontSize(14)
      .onClick(() => {
        if (handler) {
          handler();
        }
      });
  }

  build() {
    Column({ space: 14 }) {
      TextInput({ text: this.stickerText, placeholder: 'Enter sticker text' })
        .width('100%')
        .onChange((value: string) => {
          if (this.onTextChange) {
            this.onTextChange(value);
          }
        })

      Row({ space: 10 }) {
        this.actionButton('Add Sticker', this.onAddSticker)
        this.actionButton('Delete', this.onDeleteSticker)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      if (this.selectedSticker) {
        Column({ space: 10 }) {
          Text('Selected sticker controls')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)

          Row({ space: 8 }) {
            this.actionButton('Up', () => this.onMoveSticker && this.onMoveSticker(0, -MOVE_STEP))
            this.actionButton('Left', () => this.onMoveSticker && this.onMoveSticker(-MOVE_STEP, 0))
            this.actionButton('Right', () => this.onMoveSticker && this.onMoveSticker(MOVE_STEP, 0))
            this.actionButton('Down', () => this.onMoveSticker && this.onMoveSticker(0, MOVE_STEP))
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)

          Row({ space: 8 }) {
            this.actionButton('A-', () => this.onFontSizeChange && this.onFontSizeChange(-2))
            this.actionButton('A+', () => this.onFontSizeChange && this.onFontSizeChange(2))
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)

          Row({ space: 8 }) {
            ForEach(this.colorOptions, (color: string) => {
              Button('')
                .width(32)
                .height(32)
                .backgroundColor(color)
                .borderRadius(16)
                .border({ width: this.selectedSticker && this.selectedSticker.color === color ? 3 : 1, color: '#FF111827' })
                .onClick(() => {
                  if (this.onColorSelect) {
                    this.onColorSelect(color);
                  }
                });
            }, (color: string) => color)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
        }
        .padding(16)
        .backgroundColor('#FFF8FAFC')
        .borderRadius(20)
        .alignItems(HorizontalAlign.Start)
      }

      Column({ space: 8 }) {
        Text('Background presets')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)

        Row({ space: 8 }) {
          ForEach(this.backgroundOptions, (background: BackgroundOption) => {
            Button(background.title)
              .type(this.selectedBackgroundId === background.id ? ButtonType.Capsule : ButtonType.Normal)
              .fontSize(13)
              .onClick(() => {
                if (this.onBackgroundSelect) {
                  this.onBackgroundSelect(background.id);
                }
              });
          }, (background: BackgroundOption) => background.id.toString())
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
