import { AnnotationTool } from '../model/AnnotationTool';

@Component
export struct ColorPicker {
  @Prop selectedTool: AnnotationTool = AnnotationTool.BRUSH;
  @Link selectedColor: string;
  @Link lineWidth: number;
  @Link mosaicSize: number;
  @Link textValue: string;

  private readonly colors: string[] = ['#F44336', '#FF9800', '#FACC15', '#10B981', '#3B82F6', '#8B5CF6', '#111827', '#FFFFFF'];
  private readonly widths: number[] = [2, 4, 8, 12];
  private readonly mosaicSizes: number[] = [8, 12, 16, 24];

  build() {
    Column({ space: 12 }) {
      if (this.selectedTool !== AnnotationTool.MOSAIC) {
        Row({ space: 10 }) {
          ForEach(this.colors, (item: string) => {
            Stack() {
              Blank()
            }
            .width(28)
            .height(28)
            .backgroundColor(item)
            .borderRadius(14)
            .borderWidth(this.selectedColor === item ? 3 : 1)
            .borderColor(this.selectedColor === item ? '#111827' : '#CBD5E1')
            .onClick(() => {
              this.selectedColor = item;
            })
          }, (item: string) => item)
        }
      }

      if (this.selectedTool === AnnotationTool.BRUSH || this.selectedTool === AnnotationTool.ERASER || this.selectedTool === AnnotationTool.ARROW || this.selectedTool === AnnotationTool.RECT) {
        Row({ space: 10 }) {
          ForEach(this.widths, (item: number) => {
            Text(`${item}px`)
              .fontSize(13)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.lineWidth === item ? '#2563EB' : '#E5E7EB')
              .fontColor(this.lineWidth === item ? Color.White : '#1F2937')
              .borderRadius(16)
              .onClick(() => {
                this.lineWidth = item;
              })
          }, (item: number) => `${item}`)
        }
      }

      if (this.selectedTool === AnnotationTool.MOSAIC) {
        Row({ space: 10 }) {
          ForEach(this.mosaicSizes, (item: number) => {
            Text(`${item}px`)
              .fontSize(13)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.mosaicSize === item ? '#2563EB' : '#E5E7EB')
              .fontColor(this.mosaicSize === item ? Color.White : '#1F2937')
              .borderRadius(16)
              .onClick(() => {
                this.mosaicSize = item;
              })
          }, (item: number) => `${item}`)
        }
      }

      if (this.selectedTool === AnnotationTool.TEXT) {
        TextInput({ placeholder: '输入文字', text: this.textValue })
          .backgroundColor(Color.White)
          .borderRadius(12)
          .onChange((value: string) => {
            this.textValue = value;
          })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 0, bottom: 12 })
  }
}
