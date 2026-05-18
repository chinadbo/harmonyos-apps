import type { TrackingEvent } from '../model/TrackingEventModel';
import { TimelineItem } from './TimelineItem';

@Component
export struct TimelineView {
  @Prop events: TrackingEvent[] = [];

  build() {
    Column({ space: 12 }) {
      ForEach(this.events, (item: TrackingEvent, index: number) => {
        TimelineItem({ event: item, isLast: index === this.events.length - 1 })
      }, (item: TrackingEvent) => `${item.time}-${item.description}`)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(20)
  }
}
