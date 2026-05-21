import { FilterParams } from '../model/FilterParams'

@Component
export struct FilterPanel {
  @Prop presets: Array<{ name: string; params: FilterParams }> = []
  @Prop currentPresetName: string = '原图'
  onPresetChange: (params: FilterParams) => void = () => {}

  build() {
    Scroll() {
      Row({ space: 12 }) {
        ForEach(this.presets, (preset: { name: string; params: FilterParams }) => {
          Column() {
            // 预设色块示意
            Row()
              .width(54)
              .height(54)
              .borderRadius(10)
              .backgroundColor(this.getPresetColor(preset.name))
              .border({
                width: this.currentPresetName === preset.name ? 2 : 0,
                color: '#2196F3'
              })

            Text(preset.name)
              .fontSize(12)
              .fontColor(this.currentPresetName === preset.name ? '#2196F3' : '#666666')
              .margin({ top: 4 })
              .fontWeight(this.currentPresetName === preset.name ? FontWeight.Medium : FontWeight.Normal)
          }
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.onPresetChange(preset.params)
          })
        }, (preset: { name: string; params: FilterParams }) => preset.name)
      }
      .padding({ left: 4, right: 4, top: 8, bottom: 8 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  private getPresetColor(name: string): string {
    switch (name) {
      case '清晨': return '#FFE9D0'
      case '暖调': return '#FFD08A'
      case '冷淡': return '#C8D8E8'
      case '复古': return '#D4BBA0'
      case '黑白': return '#AAAAAA'
      default: return '#E0E0E0'
    }
  }
}
