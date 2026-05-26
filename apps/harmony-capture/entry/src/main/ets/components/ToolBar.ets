import { AnnotationTool } from '../model/AnnotationTool';

interface ToolItem {
  value: AnnotationTool
  label: string
}

@Component
export struct ToolBar {
  @Link selectedTool: AnnotationTool;
  @Prop onUndo: () => void = () => {};
  @Prop onSave: () => void = () => {};
  @Prop canUndo: boolean = false;

  private readonly items: ToolItem[] = [
    { value: AnnotationTool.BRUSH, label: '画笔' },
    { value: AnnotationTool.ERASER, label: '橡皮' },
    { value: AnnotationTool.ARROW, label: '箭头' },
    { value: AnnotationTool.RECT, label: '矩形' },
    { value: AnnotationTool.MOSAIC, label: '马赛克' },
    { value: AnnotationTool.TEXT, label: '文字' }
  ];

  build() {
    Column({ space: 12 }) {
      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.items, (item: ToolItem) => {
            Text(item.label)
              .fontSize(14)
              .fontColor(this.selectedTool === item.value ? Color.White : '#1F2937')
              .padding({ left: 14, right: 14, top: 10, bottom: 10 })
              .backgroundColor(this.selectedTool === item.value ? '#2563EB' : '#E5E7EB')
              .borderRadius(20)
              .onClick(() => {
                this.selectedTool = item.value;
              })
          }, (item: ToolItem) => item.value)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)

      Row({ space: 12 }) {
        Button('撤销')
          .enabled(this.canUndo)
          .layoutWeight(1)
          .onClick(() => this.onUndo())
        Button('保存')
          .layoutWeight(1)
          .onClick(() => this.onSave())
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F8FAFC')
  }
}
