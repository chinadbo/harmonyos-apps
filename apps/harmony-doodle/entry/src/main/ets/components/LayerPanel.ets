import { ToolType } from '../models/Types';
import { Layer } from '../engine/Layer';

@Component
export struct LayerPanel {
  @State layers: Layer[] = [];
  @State activeIndex: number = 0;
  private onLayerSelect?: (index: number) => void;
  private onLayerToggle?: (index: number) => void;
  private onLayerDelete?: (index: number) => void;
  private onAddLayer?: () => void;

  build() {
    Column() {
      Row() {
        Text('Layers')
          .fontSize(14)
          .fontColor('#666666')
          .layoutWeight(1)

        Button('+')
          .width(32)
          .height(32)
          .fontSize(20)
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')
          .borderRadius(16)
          .onClick(() => {
            this.onAddLayer?.();
          })
      }
      .width('100%')
      .margin({ bottom: 8 })

      List() {
        ForEach(this.layers, (layer: Layer, index: number) => {
          ListItem() {
            Row() {
              Button(layer.visible ? '👁' : '🚫')
                .width(36)
                .height(36)
                .fontSize(14)
                .backgroundColor(layer.visible ? '#E6F0FF' : '#F5F5F5')
                .fontColor('#007DFF')
                .borderRadius(8)
                .onClick(() => {
                  layer.visible = !layer.visible;
                  this.onLayerToggle?.(index);
                })

              Text(layer.name)
                .fontSize(14)
                .fontColor(this.activeIndex === index ? '#007DFF' : '#333333')
                .layoutWeight(1)
                .margin({ left: 8 })

              Text('Opacity: ' + Math.round(layer.opacity * 100) + '%')
                .fontSize(11)
                .fontColor('#999999')
                .margin({ right: 8 })

              if (this.layers.length > 1) {
                Button('🗑')
                  .width(36)
                  .height(36)
                  .fontSize(14)
                  .backgroundColor('#FF4444')
                  .fontColor('#FFFFFF')
                  .borderRadius(8)
                  .onClick(() => {
                    this.onLayerDelete?.(index);
                  })
              }
            }
            .width('100%')
            .height(48)
            .padding(8)
            .backgroundColor(this.activeIndex === index ? '#E6F0FF' : '#FFFFFF')
            .borderRadius(8)
            .margin({ bottom: 4 })
            .onClick(() => {
              this.activeIndex = index;
              this.onLayerSelect?.(index);
            })
          }
        }, (layer: Layer) => layer.id.toString())
      }
      .width('100%')
      .height(200)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }
}
