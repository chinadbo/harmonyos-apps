import { Theme } from '../model/Theme';

@Component
export struct BadgeComponent {
  @Prop unlocked: boolean = false;
  @Prop isNew: boolean = false;
  @Prop label: string = '';
  @Prop icon: string = '';

  build() {
    Column({ space: 6 }) {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Text(this.icon)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.unlocked ? Color.White : Theme.TEXT_SECONDARY)
          .width(56)
          .height(56)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.unlocked ? Theme.PRIMARY : '#E8ECF2')
          .borderRadius(28)
        if (this.isNew) {
          Text('新')
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor(Theme.DANGER)
            .borderRadius(8)
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
        }
      }
      Text(this.label)
        .fontSize(11)
        .maxLines(1)
        .fontColor(this.unlocked ? Theme.TEXT_DARK : Theme.TEXT_SECONDARY)
    }
    .width(72)
    .opacity(this.unlocked ? 1 : 0.55)
  }
}
