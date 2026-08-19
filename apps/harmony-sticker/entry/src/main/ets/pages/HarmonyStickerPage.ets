import { StickerCanvas } from '../components/StickerCanvas';
import { StickerList } from '../components/StickerList';
import { StickerToolbar } from '../components/StickerToolbar';
import { BACKGROUND_OPTIONS, COLOR_OPTIONS, MAX_FONT_SIZE, MIN_FONT_SIZE, createSticker } from '../common/EditorDefaults';
import { BackgroundOption, StickerItem } from '../models/StickerModel';

@Entry
@Component
struct HarmonyStickerPage {
  @State private stickerInput: string = 'HELLO HARMONY';
  @State private stickers: StickerItem[] = [
    createSticker(1, 'HELLO HARMONY', '#FFFFFFFF'),
    { id: 2, text: 'MAKE IT MEME', color: '#FF111827', fontSize: 24, offsetX: 0, offsetY: 112 }
  ];
  @State private selectedStickerId: number = 1;
  @State private selectedBackgroundId: number = 1;
  @State private nextStickerId: number = 3;

  private get selectedSticker(): StickerItem | null {
    for (let i = 0; i < this.stickers.length; i++) {
      if (this.stickers[i].id === this.selectedStickerId) {
        return this.stickers[i];
      }
    }
    return null;
  }

  private get selectedBackground(): BackgroundOption {
    for (let i = 0; i < BACKGROUND_OPTIONS.length; i++) {
      if (BACKGROUND_OPTIONS[i].id === this.selectedBackgroundId) {
        return BACKGROUND_OPTIONS[i];
      }
    }
    return BACKGROUND_OPTIONS[0];
  }

  private updateSticker(mutator: (sticker: StickerItem) => StickerItem): void {
    this.stickers = this.stickers.map((item: StickerItem) => {
      if (item.id === this.selectedStickerId) {
        return mutator(item);
      }
      return item;
    });
  }

  private selectSticker(id: number): void {
    this.selectedStickerId = id;
    const sticker = this.selectedSticker;
    if (sticker) {
      this.stickerInput = sticker.text;
    }
  }

  private addSticker(): void {
    const text = this.stickerInput.trim().length > 0 ? this.stickerInput.trim() : `Sticker ${this.nextStickerId}`;
    const newSticker = createSticker(this.nextStickerId, text, '#FFFFFFFF');
    newSticker.offsetY = (this.stickers.length % 4) * 48 - 72;
    this.stickers = [...this.stickers, newSticker];
    this.selectSticker(newSticker.id);
    this.nextStickerId += 1;
  }

  private deleteSticker(): void {
    if (this.stickers.length === 0) {
      return;
    }

    this.stickers = this.stickers.filter((item: StickerItem) => item.id !== this.selectedStickerId);
    if (this.stickers.length > 0) {
      this.selectSticker(this.stickers[this.stickers.length - 1].id);
      return;
    }

    this.selectedStickerId = -1;
    this.stickerInput = '';
  }

  private moveSelectedSticker(dx: number, dy: number): void {
    this.updateSticker((item: StickerItem) => ({
      ...item,
      offsetX: item.offsetX + dx,
      offsetY: item.offsetY + dy
    }));
  }

  private resizeSelectedSticker(delta: number): void {
    this.updateSticker((item: StickerItem) => ({
      ...item,
      fontSize: Math.min(MAX_FONT_SIZE, Math.max(MIN_FONT_SIZE, item.fontSize + delta))
    }));
  }

  private recolorSelectedSticker(color: string): void {
    this.updateSticker((item: StickerItem) => ({
      ...item,
      color
    }));
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        Column({ space: 6 }) {
          Text('HarmonySticker')
            .fontSize(30)
            .fontWeight(FontWeight.Black)
            .fontColor('#FF0F172A')

          Text('Build stickers and meme cards with editable text layers and preset scenes.')
            .fontSize(15)
            .fontColor('#FF475569')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        StickerCanvas({
          stickers: this.stickers,
          selectedStickerId: this.selectedStickerId,
          background: this.selectedBackground,
          onSelectSticker: (id: number) => {
            this.selectSticker(id);
          }
        })

        StickerToolbar({
          stickerText: this.stickerInput,
          selectedSticker: this.selectedSticker,
          colorOptions: COLOR_OPTIONS,
          backgroundOptions: BACKGROUND_OPTIONS,
          selectedBackgroundId: this.selectedBackgroundId,
          onTextChange: (value: string) => {
            this.stickerInput = value;
            if (this.selectedSticker) {
              this.updateSticker((item: StickerItem) => ({
                ...item,
                text: value
              }));
            }
          },
          onAddSticker: () => this.addSticker(),
          onDeleteSticker: () => this.deleteSticker(),
          onMoveSticker: (dx: number, dy: number) => this.moveSelectedSticker(dx, dy),
          onFontSizeChange: (delta: number) => this.resizeSelectedSticker(delta),
          onColorSelect: (color: string) => this.recolorSelectedSticker(color),
          onBackgroundSelect: (id: number) => {
            this.selectedBackgroundId = id;
          }
        })

        StickerList({
          stickers: this.stickers,
          selectedStickerId: this.selectedStickerId,
          onSelectSticker: (id: number) => {
            this.selectSticker(id);
          }
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 24, bottom: 32 })
      .backgroundColor('#FFF8FAFC')
      .alignItems(HorizontalAlign.Center)
    }
    .scrollBar(BarState.Off)
  }
}
