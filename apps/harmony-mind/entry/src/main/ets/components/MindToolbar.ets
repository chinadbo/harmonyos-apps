import { Constants } from '../utils/Constants';

@Component
export struct MindToolbar {
  @Prop selectedNodeText: string;
  @Prop selectedColor: string;
  @Prop canDelete: boolean;
  @Prop isDarkMode: boolean;
  onAddChild?: () => void;
  onEditNode?: () => void;
  onDeleteNode?: () => void;
  onColorChange?: (color: string) => void;
  onResetView?: () => void;

  build() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Button('加子节点')
          .layoutWeight(1)
          .backgroundColor('#FF5B8FF9')
          .onClick(() => {
            if (this.onAddChild) {
              this.onAddChild();
            }
          })
        Button('编辑文本')
          .layoutWeight(1)
          .backgroundColor('#FF61DDAA')
          .onClick(() => {
            if (this.onEditNode) {
              this.onEditNode();
            }
          })
        Button('删除节点')
          .layoutWeight(1)
          .enabled(this.canDelete)
          .backgroundColor(this.canDelete ? '#FFE14D4D' : '#FF9FA7B3')
          .onClick(() => {
            if (this.canDelete && this.onDeleteNode) {
              this.onDeleteNode();
            }
          })
      }
      .width('100%')

      Column({ space: 8 }) {
        Row() {
          Text(`当前节点：${this.selectedNodeText}`)
            .fontSize(14)
            .fontColor(this.isDarkMode ? '#FFF4F7FB' : '#FF1F2530')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Blank()
          Button('重置视图')
            .fontSize(14)
            .backgroundColor(this.isDarkMode ? '#FF303B48' : '#FFE7ECF3')
            .fontColor(this.isDarkMode ? '#FFF4F7FB' : '#FF1F2530')
            .onClick(() => {
              if (this.onResetView) {
                this.onResetView();
              }
            })
        }
        .width('100%')

        Row({ space: 8 }) {
          ForEach(Constants.COLOR_PALETTE, (color: string) => {
            Row()
              .width(28)
              .height(28)
              .borderRadius(14)
              .backgroundColor(color)
              .border({ width: this.selectedColor === color ? 3 : 1, color: this.selectedColor === color ? '#FFFFFFFF' : '#33000000' })
              .onClick(() => {
                if (this.onColorChange) {
                  this.onColorChange(color);
                }
              })
          })
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.isDarkMode ? '#FF1E2630' : '#FFFFFFFF')
    .borderRadius(20)
  }
}
