import { Theme } from '../utils/Theme';
import { TimeUtils } from '../utils/TimeUtils';

/**
 * 通用记录卡片：图标 + 标题 + 副标题 + 时间 + 可选删除
 */
@Component
export struct RecordCard {
  @Prop icon: string = '📝';
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @Prop timeMs: number = 0;
  @Prop badge: string = '';
  @Prop badgeColor: string = Theme.PRIMARY;
  @Prop deletable: boolean = false;
  recordId: number = -1;
  kind: string = '';
  onDelete: (kind: string, recordId: number) => void = (kind: string, recordId: number) => {
  };

  build() {
    Row() {
      Text(this.icon)
        .fontSize(24)
        .width(44)
        .height(44)
        .textAlign(TextAlign.Center)
        .borderRadius(12)
        .backgroundColor(Theme.GRAY_BG)

      Column() {
        Text(this.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.TEXT)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(12)
            .fontColor(Theme.TEXT_SUB)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 2 })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      Column() {
        Text(TimeUtils.formatTime(this.timeMs))
          .fontSize(12)
          .fontColor(Theme.TEXT_LIGHT)
        if (this.badge.length > 0) {
          Text(this.badge)
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor(this.badgeColor)
            .borderRadius(8)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.End)

      if (this.deletable) {
        Text('✕')
          .fontSize(14)
          .fontColor(Theme.TEXT_LIGHT)
          .width(32)
          .height(32)
          .textAlign(TextAlign.Center)
          .margin({ left: 4 })
          .onClick(() => {
            this.onDelete(this.kind, this.recordId);
          })
      }
    }
    .width('100%')
    .padding({ top: 8, bottom: 8, left: 8, right: 4 })
    .backgroundColor(Theme.CARD)
    .borderRadius(14)
  }
}
