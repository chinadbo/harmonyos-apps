/**
 * 选项条目：正常态 / 选中态 / 判分后的正确、错误着色
 */
import { optionLabel } from '../data/Question'

const COLOR_NORMAL = '#F3F4F6'
const COLOR_SELECTED = '#1C64F2'
const COLOR_CORRECT = '#16A34A'
const COLOR_WRONG = '#DC2626'

@Component
export struct OptionItem {
  @Prop text: string = ''
  @Prop index: number = 0
  @Prop selected: boolean = false
  @Prop showResult: boolean = false
  @Prop isAnswer: boolean = false
  onSelect: (index: number) => void = () => {}

  private colorOf(): string {
    if (this.showResult) {
      if (this.selected && this.isAnswer) {
        return COLOR_CORRECT
      }
      if (this.selected && !this.isAnswer) {
        return COLOR_WRONG
      }
      if (!this.selected && this.isAnswer) {
        return COLOR_CORRECT
      }
    }
    if (this.selected) {
      return COLOR_SELECTED
    }
    return COLOR_NORMAL
  }

  private textColorOf(): string {
    if (this.showResult || this.selected) {
      if (this.showResult && !this.selected && !this.isAnswer) {
        return '#9CA3AF'
      }
      return '#FFFFFF'
    }
    return '#1F2937'
  }

  build() {
    Row() {
      Text(optionLabel(this.index))
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.textColorOf())
        .width(28)
        .height(28)
        .textAlign(TextAlign.Center)
      Text(this.text)
        .fontSize(16)
        .fontColor(this.textColorOf())
        .layoutWeight(1)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      if (this.showResult && this.selected && this.isAnswer) {
        Text('✓').fontColor('#FFFFFF').fontSize(16)
      } else if (this.showResult && this.selected && !this.isAnswer) {
        Text('✗').fontColor('#FFFFFF').fontSize(16)
      }
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .borderRadius(12)
    .backgroundColor(this.colorOf())
    .margin({ bottom: 10 })
    .onClick(() => this.onSelect(this.index))
  }
}
