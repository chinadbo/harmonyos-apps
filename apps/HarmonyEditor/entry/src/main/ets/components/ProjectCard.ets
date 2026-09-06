import { ProjectStatus, ProjectSummary } from '../model/ProjectModel';
import { AppStyles } from '../common/styles';
import { formatDuration } from '../common/utils';

@Component
@Reusable
export struct ProjectCard {
  @Prop project: ProjectSummary;
  @Prop onOpen: (projectId: number) => void = () => {};
  @Prop onDelete: (projectId: number) => void = () => {};

  build() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.project.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppStyles.colors.textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`Updated ${new Date(this.project.updatedAt).toLocaleString()}`)
            .fontSize(12)
            .fontColor(AppStyles.colors.textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(this.statusLabel())
          .fontSize(11)
          .fontColor('#FFFFFFFF')
          .backgroundColor(this.statusColor())
          .borderRadius(AppStyles.radius.pill)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      }
      .width('100%')

      Row({ space: 10 }) {
        this.infoChip(`${this.project.segmentCount} segments`)
        this.infoChip(formatDuration(this.project.totalDuration))
      }
      .width('100%')
    }
    .padding(AppStyles.cardPadding)
    .width('100%')
    .backgroundColor(AppStyles.colors.surfaceAlt)
    .borderRadius(AppStyles.radius.lg)
    .border({ width: 1, color: AppStyles.colors.border })
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        TapGesture().onAction(() => this.onOpen(this.project.id)),
        LongPressGesture({ repeat: false, duration: 500 }).onAction(() => this.onDelete(this.project.id))
      )
    )
  }

  @Builder
  private infoChip(label: string) {
    Text(label)
      .fontSize(11)
      .fontColor(AppStyles.colors.textSecondary)
      .backgroundColor(AppStyles.colors.chip)
      .borderRadius(AppStyles.radius.pill)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
  }

  private statusLabel(): string {
    switch (this.project.status) {
      case ProjectStatus.EXPORTING:
        return 'Exporting';
      case ProjectStatus.EXPORTED:
        return 'Exported';
      case ProjectStatus.FAILED:
        return 'Failed';
      case ProjectStatus.DRAFT:
      default:
        return 'Draft';
    }
  }

  private statusColor(): string {
    switch (this.project.status) {
      case ProjectStatus.EXPORTING:
        return AppStyles.colors.warning;
      case ProjectStatus.EXPORTED:
        return AppStyles.colors.success;
      case ProjectStatus.FAILED:
        return AppStyles.colors.danger;
      case ProjectStatus.DRAFT:
      default:
        return AppStyles.colors.brandPrimary;
    }
  }
}
