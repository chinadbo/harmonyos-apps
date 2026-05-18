import type { TrackingEvent } from '../model/TrackingEventModel';
import { minutesAgo } from '../utils/TimeUtils';

const EMPTY_EVENT: TrackingEvent = {
  time: '',
  location: '',
  description: '',
  eventType: ''
};

@Component
export struct TimelineItem {
  @Prop event: TrackingEvent = EMPTY_EVENT;
  @Prop isLast: boolean = false;

  build() {
    Row({ space: 12 }) {
      Column() {
        Circle()
          .width(12)
          .height(12)
          .fill('#3F8CFF')
        Blank()
          .width(2)
          .height(this.isLast ? 12 : 72)
          .backgroundColor(this.isLast ? Color.Transparent : '#D0D5DD')
      }
      .alignItems(HorizontalAlign.Center)

      Column({ space: 6 }) {
        Text(this.event.description)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#101828')
          .width('100%')
          .textAlign(TextAlign.Start)

        Text(`${this.event.location} · ${this.event.time}`)
          .fontSize(13)
          .fontColor('#475467')
          .width('100%')
          .textAlign(TextAlign.Start)

        Text(minutesAgo(this.event.time))
          .fontSize(12)
          .fontColor('#98A2B3')
          .width('100%')
          .textAlign(TextAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .alignItems(VerticalAlign.Top)
    .width('100%')
  }
}
