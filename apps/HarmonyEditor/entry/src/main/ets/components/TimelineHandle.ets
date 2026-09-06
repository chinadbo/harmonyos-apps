import { AppStyles } from '../common/styles';
import { formatDuration } from '../common/utils';

@Component
export struct TimelineHandle {
  @Prop label: string = 'Start';
  @Prop accentColor: string = AppStyles.colors.brandPrimary;
  @Link timeMs: number;
  @Prop minMs: number = 0;
  @Prop maxMs: number = 0;
  @Prop trackWidth: number = 1;

  @State private startDragValue: number = 0;

  build() {
    Column({ space: 6 }) {
      Text(this.label)
        .fontSize(11)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppStyles.colors.textSecondary)
      Text(formatDuration(this.timeMs))
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppStyles.colors.textPrimary)
      Column()
        .width(22)
        .height(72)
        .borderRadius(AppStyles.radius.pill)
        .backgroundColor(this.accentColor)
    }
    .alignItems(HorizontalAlign.Center)
    .gesture(
      PanGesture({ direction: PanDirection.Horizontal, distance: 1 })
        .onActionStart(() => {
          this.startDragValue = this.timeMs;
        })
        .onActionUpdate((event: GestureEvent) => {
          const ratio = this.trackWidth <= 0 ? 0 : event.offsetX / this.trackWidth;
          const nextValue = this.startDragValue + Math.round(ratio * this.maxMs);
          this.timeMs = Math.min(this.maxMs, Math.max(this.minMs, nextValue));
        })
    )
  }
}
