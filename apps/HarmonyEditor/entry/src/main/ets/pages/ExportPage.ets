import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { EXPORT_FORMAT_OPTIONS, EXPORT_RESOLUTION_OPTIONS, ExportFormat, ExportResolution } from '../common/constants';
import { AppStyles } from '../common/styles';
import { formatDuration, normalizeProgress } from '../common/utils';
import { ProgressRing } from '../components/ProgressRing';
import { DataStore } from '../model/DataStore';
import { AudioTrack, Project, ProjectStatus, VideoSegment } from '../model/ProjectModel';
import { ExportResult, ExportService } from '../services/ExportService';

@Entry
@Component
struct ExportPage {
  @StorageLink('defaultExportResolution') private defaultExportResolution: string = ExportResolution.RES_ORIGINAL;
  @StorageLink('defaultExportFormat') private defaultExportFormat: string = ExportFormat.FORMAT_MP4;
  @StorageLink('autoSaveEnabled') private autoSaveEnabled: boolean = true;
  @State private projectId: number = 0;
  @State private project: Project | null = null;
  @State private segments: Array<VideoSegment> = [];
  @State private audioTrack: AudioTrack | null = null;
  @State private resolution: ExportResolution = ExportResolution.RES_ORIGINAL;
  @State private format: ExportFormat = ExportFormat.FORMAT_MP4;
  @State private progress: number = 0;
  @State private exporting: boolean = false;
  @State private result: ExportResult | null = null;
  @State private errorMessage: string = '';
  @State private loading: boolean = true;

  aboutToAppear(): void {
    this.readParams();
    this.loadExportData();
  }

  private readParams(): void {
    try {
      const params = router.getParams() as Record<string, Object>;
      this.projectId = Number(params['projectId'] ?? 0);
    } catch (_error) {
      this.projectId = 0;
    }
  }

  private async loadExportData(): Promise<void> {
    this.loading = true;
    try {
      const bundle = await DataStore.getInstance().getProjectBundle(this.projectId);
      if (!bundle) {
        this.project = null;
        this.segments = [];
        this.audioTrack = null;
        return;
      }
      this.project = bundle.project;
      this.segments = bundle.segments;
      this.audioTrack = bundle.audioTrack;
      const settings = await DataStore.getInstance().getExportSettings();
      this.resolution = settings.resolution;
      this.format = settings.format;
      AppStorage.SetOrCreate<string>('defaultExportResolution', settings.resolution);
      AppStorage.SetOrCreate<string>('defaultExportFormat', settings.format);
    } catch (error) {
      promptAction.showToast({ message: `Failed to load export settings: ${this.normalizeError(error)}` });
    } finally {
      this.loading = false;
    }
  }

  private totalDurationMs(): number {
    return this.segments.reduce((total: number, segment: VideoSegment) => total + Math.max(0, segment.duration), 0);
  }

  private async startExport(): Promise<void> {
    if (!this.project || this.segments.length === 0 || this.exporting) {
      return;
    }
    this.exporting = true;
    this.progress = 0;
    this.result = null;
    this.errorMessage = '';
    try {
      await DataStore.getInstance().updateProjectStatus(this.projectId, ProjectStatus.EXPORTING);
      await DataStore.getInstance().saveExportSettings({
        resolution: this.resolution,
        format: this.format,
        autoSaveEnabled: this.autoSaveEnabled
      });
      AppStorage.SetOrCreate<string>('defaultExportResolution', this.resolution);
      AppStorage.SetOrCreate<string>('defaultExportFormat', this.format);
      const exportResult = await ExportService.getInstance().exportProject({
        project: this.project,
        segments: this.segments,
        audioTrack: this.audioTrack,
        resolution: this.resolution,
        format: this.format
      }, (progress: number) => {
        this.progress = normalizeProgress(progress);
      });
      this.result = exportResult;
      await DataStore.getInstance().updateProjectStatus(this.projectId, ProjectStatus.EXPORTED, exportResult.outputUri);
      this.project = await DataStore.getInstance().getProject(this.projectId);
      promptAction.showToast({ message: 'Export completed successfully.' });
    } catch (error) {
      this.errorMessage = this.normalizeError(error);
      await DataStore.getInstance().updateProjectStatus(this.projectId, ProjectStatus.FAILED);
      this.project = await DataStore.getInstance().getProject(this.projectId);
      promptAction.showToast({ message: `Export failed: ${this.errorMessage}` });
    } finally {
      this.exporting = false;
    }
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row({ space: 12 }) {
          Column({ space: 6 }) {
            Text('Export')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppStyles.colors.textPrimary)
            Text('Choose output settings, render the timeline, and save the result to the gallery.')
              .fontSize(14)
              .fontColor(AppStyles.colors.textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('Back')
            .height(40)
            .fontColor(AppStyles.colors.textPrimary)
            .backgroundColor(AppStyles.colors.surfaceAlt)
            .onClick(() => router.back())
        }
        .width('100%')

        if (this.loading) {
          Column({ space: 10 }) {
            LoadingProgress()
              .width(42)
              .height(42)
              .color(AppStyles.colors.brandPrimary)
            Text('Loading export options...')
              .fontSize(13)
              .fontColor(AppStyles.colors.textSecondary)
          }
          .width('100%')
          .height(280)
          .justifyContent(FlexAlign.Center)
        } else if (!this.project) {
          Column({ space: 10 }) {
            Text('Project not found')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppStyles.colors.textPrimary)
            Text('Open a valid project before exporting a video.')
              .fontSize(14)
              .fontColor(AppStyles.colors.textSecondary)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .height(280)
          .padding(24)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(AppStyles.colors.surfaceAlt)
          .borderRadius(AppStyles.radius.lg)
        } else {
          Column({ space: 16 }) {
            this.buildSummaryCard()
            this.buildOptionCard('Resolution', EXPORT_RESOLUTION_OPTIONS.map((option) => option.value as string), this.resolution, (value: string) => {
              this.resolution = value as ExportResolution;
            })
            this.buildOptionCard('Format', EXPORT_FORMAT_OPTIONS.map((option) => option.value as string), this.format, (value: string) => {
              this.format = value as ExportFormat;
            })
            this.buildProgressCard()

            Button(this.exporting ? 'Exporting...' : 'Start Export')
              .width('100%')
              .height(46)
              .fontColor('#FFFFFFFF')
              .backgroundColor(!this.exporting && this.segments.length > 0 ? AppStyles.colors.brandPrimary : AppStyles.colors.surfaceMuted)
              .borderRadius(AppStyles.radius.lg)
              .onClick(() => {
                if (!this.exporting && this.segments.length > 0) {
                  this.startExport();
                }
              })
          }
          .width('100%')
        }
      }
      .padding(AppStyles.pagePadding)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppStyles.colors.background)
  }

  @Builder
  private buildSummaryCard() {
    Column({ space: 10 }) {
      Text(this.project?.name ?? 'Untitled Project')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppStyles.colors.textPrimary)

      Row({ space: 10 }) {
        this.infoChip(`${this.segments.length} clips`)
        this.infoChip(formatDuration(this.totalDurationMs()))
        this.infoChip(this.projectStatusLabel())
      }
      .width('100%')
    }
    .padding(AppStyles.cardPadding)
    .width('100%')
    .backgroundColor(AppStyles.colors.surfaceAlt)
    .borderRadius(AppStyles.radius.lg)
    .border({ width: 1, color: AppStyles.colors.border })
  }

  @Builder
  private buildOptionCard(title: string, options: Array<string>, selectedValue: string, onChange: (value: string) => void) {
    Column({ space: 12 }) {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppStyles.colors.textPrimary)

      Row({ space: 10 }) {
        ForEach(options, (option: string) => {
          Text(option.toUpperCase())
            .fontSize(12)
            .fontWeight(selectedValue === option ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(selectedValue === option ? '#FFFFFFFF' : AppStyles.colors.textSecondary)
            .backgroundColor(selectedValue === option ? AppStyles.colors.brandPrimary : AppStyles.colors.chip)
            .borderRadius(AppStyles.radius.pill)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .onClick(() => onChange(option))
        }, (option: string) => option)
      }
      .width('100%')
    }
    .padding(AppStyles.cardPadding)
    .width('100%')
    .backgroundColor(AppStyles.colors.surfaceAlt)
    .borderRadius(AppStyles.radius.lg)
    .border({ width: 1, color: AppStyles.colors.border })
  }

  @Builder
  private buildProgressCard() {
    Column({ space: 12 }) {
      ProgressRing({
        progress: this.progress,
        label: this.exporting ? 'Exporting' : (this.result ? 'Ready' : 'Idle')
      })

      if (this.result) {
        Column({ space: 8 }) {
          Text('Export complete')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppStyles.colors.textPrimary)
          Text(`Output: ${this.result.outputUri}`)
            .fontSize(12)
            .fontColor(AppStyles.colors.textSecondary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(`Saved to gallery: ${this.result.savedUri}`)
            .fontSize(12)
            .fontColor(AppStyles.colors.textSecondary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          if (this.result.warningMessage.length > 0) {
            Text(this.result.warningMessage)
              .fontSize(12)
              .fontColor(AppStyles.colors.warning)
          }
        }
        .width('100%')
      } else if (this.errorMessage.length > 0) {
        Column({ space: 8 }) {
          Text('Export failed')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppStyles.colors.danger)
          Text(this.errorMessage)
            .fontSize(12)
            .fontColor(AppStyles.colors.textSecondary)
        }
        .width('100%')
      } else {
        Text('Ready to export with your selected settings.')
          .fontSize(12)
          .fontColor(AppStyles.colors.textSecondary)
      }
    }
    .padding(AppStyles.cardPadding)
    .width('100%')
    .backgroundColor(AppStyles.colors.surfaceAlt)
    .borderRadius(AppStyles.radius.lg)
    .border({ width: 1, color: AppStyles.colors.border })
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

  private projectStatusLabel(): string {
    if (!this.project) {
      return 'Draft';
    }
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

  private normalizeError(error: unknown): string {
    if (typeof error === 'object' && error !== null && 'message' in error) {
      const message = (error as Record<string, unknown>)['message'];
      if (typeof message === 'string') {
        return message;
      }
    }
    return JSON.stringify(error);
  }
}
