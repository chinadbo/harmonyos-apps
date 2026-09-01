export type AnnotationTool = 'pen' | 'arrow' | 'rect' | 'circle';

@Component
export struct AnnotationToolbar {
  @Link selectedTool: AnnotationTool;
  @Link selectedColor: string;
  onUndo: () => void = () => {};
  onClear: () => void = () => {};
  private readonly tools: Array<AnnotationTool> = ['pen', 'arrow', 'rect', 'circle'];
  private readonly colors: Array<string> = ['#FF3B30', '#F59E0B', '#10B981', '#3B82F6', '#8B5CF6'];

  build() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        ForEach(this.tools, (tool: AnnotationTool) => {
          Button(tool.toUpperCase())
            .fontSize(12)
            .fontColor(this.selectedTool === tool ? '#FFFFFF' : '#111827')
            .backgroundColor(this.selectedTool === tool ? '#111827' : '#E5E7EB')
            .onClick(() => {
              this.selectedTool = tool;
            })
        }, (tool: AnnotationTool) => tool)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row({ space: 8 }) {
        ForEach(this.colors, (color: string) => {
          Row()
            .width(28)
            .height(28)
            .borderRadius(14)
            .backgroundColor(color)
            .border({ width: this.selectedColor === color ? 3 : 1, color: this.selectedColor === color ? '#111827' : '#FFFFFF' })
            .onClick(() => {
              this.selectedColor = color;
            })
        }, (color: string) => color)
      }

      Row({ space: 12 }) {
        Button('Undo')
          .layoutWeight(1)
          .backgroundColor('#E5E7EB')
          .fontColor('#111827')
          .onClick(() => this.onUndo())
        Button('Clear')
          .layoutWeight(1)
          .backgroundColor('#FCA5A5')
          .fontColor('#7F1D1D')
          .onClick(() => this.onClear())
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F9FAFB')
    .borderRadius(20)
  }
}
