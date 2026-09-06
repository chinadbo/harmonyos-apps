import { AppStyles } from '../common/styles';
import { formatDuration } from '../common/utils';
import { VideoSegment } from '../model/ProjectModel';
import { TimelineHandle } from './TimelineHandle';

@Component
export struct TimelineTrack {
  @Prop segments: Array<VideoSegment> = [];
  @Link trimStartMs: number;
  @Link trimEndMs: number;
  @Prop totalDurationMs: number = 0;
  @Prop onRangeChanged: (startMs: number, endMs: number) => void = () => {};
  @State private trackWidth: number = 320;

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('Timeline')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppStyles.colors.textPrimary)
        Blank()
        Text(`${formatDuration(this.trimStartMs)} - ${formatDuration(this.trimEndMs)}`)
          .fontSize(12)
          .fontColor(AppStyles.colors.textSecondary)
      }
      .width('100%')

      Column({ space: 10 }) {
        this.buildRuler()

        Stack({ alignContent: Alignment.CenterStart }) {
          Row({ space: 8 }) {
            ForEach(this.segments, (segment: VideoSegment) => {
              Column({ space: 4 }) {
                Text(`#${segment.order + 1}`)
                  .fontSize(11)
                  .fontColor(AppStyles.colors.textSecondary)
                Text(formatDuration(segment.duration))
                  .fontSize(10)
                  .fontColor(AppStyles.colors.textSecondary)
              }
              .width(84)
              .height(64)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor(AppStyles.colors.surfaceMuted)
              .borderRadius(AppStyles.radius.md)
            }, (segment: VideoSegment) => `${segment.id}_${segment.order}`)
          }
          .width('100%')

          Row() {
            TimelineHandle({
              label: 'Start',
              accentColor: AppStyles.colors.brandPrimary,
              timeMs: $trimStartMs,
              minMs: 0,
              maxMs: this.trimEndMs,
              trackWidth: this.trackWidth
            })
            Blank()
            TimelineHandle({
              label: 'End',
              accentColor: AppStyles.colors.brandSecondary,
              timeMs: $trimEndMs,
              minMs: this.trimStartMs,
              maxMs: this.totalDurationMs,
              trackWidth: this.trackWidth
            })
          }
          .width('100%')
        }
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          this.trackWidth = Number(newValue.width);
        })
      }
      .padding(12)
      .backgroundColor(AppStyles.colors.surfaceAlt)
      .borderRadius(AppStyles.radius.lg)
      .border({ width: 1, color: AppStyles.colors.border })

      Button('Apply Trim')
        .height(40)
        .fontColor('#FFFFFFFF')
        .backgroundColor(AppStyles.colors.brandPrimary)
        .onClick(() => this.onRangeChanged(this.trimStartMs, this.trimEndMs))
    }
    .width('100%')
  }

  @Builder
  private buildRuler() {
    Row() {
      ForEach([0, 1, 2, 3, 4], (index: number) => {
        Column({ space: 4 }) {
          Divider()
            .vertical(true)
            .strokeWidth(1)
            .color(AppStyles.colors.textSecondary)
            .height(12)
          Text(formatDuration(Math.round((this.totalDurationMs / 4) * index)))
            .fontSize(10)
            .fontColor(AppStyles.colors.textSecondary)
        }
        .layoutWeight(1)
      })
    }
    .width('100%')
  }
}
