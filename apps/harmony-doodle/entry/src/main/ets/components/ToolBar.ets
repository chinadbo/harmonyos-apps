import { ToolType, ToolConfig } from '../models/Types';

@Component
export struct ToolBar {
  @Link currentTool: ToolType;
  @Link currentSize: number;
  private onToolChange?: (tool: ToolType) => void;
  private onSizeChange?: (size: number) => void;

  private toolIcons: string[] = ['✏️', '🖊️', '🧼', '🖍️', '📏', '▢', '⭕', '➡️'];

  build() {
    Column() {
      Text('Tools')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 8 })

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround }) {
        ForEach([ToolType.Pencil, ToolType.Marker, ToolType.Eraser, ToolType.Highlighter,
                 ToolType.Line, ToolType.Rectangle, ToolType.Circle, ToolType.Arrow],
          (tool: ToolType) => {
            Column() {
              Text(this.toolIcons[tool])
                .fontSize(24)
                .textAlign(TextAlign.Center)

              Text(['Pencil', 'Marker', 'Eraser', 'Highlighter', 'Line', 'Rect', 'Circle', 'Arrow'][tool])
                .fontSize(10)
                .fontColor(this.currentTool === tool ? '#007DFF' : '#666666')
                .margin({ top: 2 })
            }
            .width(60)
            .height(60)
            .backgroundColor(this.currentTool === tool ? '#E6F0FF' : '#FFFFFF')
            .borderRadius(8)
            .border({ width: this.currentTool === tool ? 2 : 1, color: this.currentTool === tool ? '#007DFF' : '#E0E0E0' })
            .margin(4)
            .onClick(() => {
              this.currentTool = tool;
              this.onToolChange?.(tool);
            })
          }, (tool: ToolType) => tool.toString())
      }
      .width('100%')

      Text('Size: ' + this.currentSize)
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 8, bottom: 4 })

      Slider({ value: this.currentSize, min: 1, max: 50, step: 1 })
        .width('100%')
        .onChange((value: number) => {
          this.currentSize = value;
          this.onSizeChange?.(value);
        })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }
}
