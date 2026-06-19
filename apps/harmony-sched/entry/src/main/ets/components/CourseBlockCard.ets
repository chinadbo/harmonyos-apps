import { CourseBlock } from '../data/CourseModel';

@Component
export struct CourseBlockCard {
  @Prop block: CourseBlock;
  onTap: () => void = () => {};

  build() {
    Column({ space: 4 }) {
      Text(this.block.title)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .maxLines(2)
      Text(this.block.subtitle)
        .fontSize(10)
        .fontColor('#E5FFFFFF')
        .maxLines(2)
    }
    .width('100%')
    .height('100%')
    .padding(8)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.block.color)
    .borderRadius(12)
    .onClick(() => this.onTap())
  }
}
