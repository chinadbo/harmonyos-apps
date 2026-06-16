import { Template } from '../model/Template';

@Component
export struct TemplateItem {
  @Prop template: Template;
  @Prop renderedText: string;
  onCopy?: (text: string) => void;
  onShare?: (text: string) => void;

  build() {
    Column({ space: 12 }) {
      Text(this.renderedText)
        .fontSize(15)
        .fontColor('#1F2937')
        .width('100%')
        .textAlign(TextAlign.Start)
      Row({ space: 12 }) {
        Button('复制')
          .layoutWeight(1)
          .height(38)
          .backgroundColor('#FFF1ED')
          .fontColor('#C2410C')
          .onClick(() => {
            if (this.onCopy) {
              this.onCopy(this.renderedText);
            }
          })
        Button('分享')
          .layoutWeight(1)
          .height(38)
          .backgroundColor('#EEF2FF')
          .fontColor('#4338CA')
          .onClick(() => {
            if (this.onShare) {
              this.onShare(this.renderedText);
            }
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
  }
}
