import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import picker from '@ohos.file.picker';
import { ROUTES, TIMELINE_MIN_GAP_MS } from '../common/constants';
import { AppStyles } from '../common/styles';
import { formatDuration } from '../common/utils';
import { TimelineTrack } from '../components/TimelineTrack';
import { DataStore } from '../model/DataStore';
import { AudioTrack, createAudioTrack, Project, ProjectStatus, VideoSegment } from '../model/ProjectModel';

@Entry
@Component
struct EditorPage {
  @StorageLink('autoSaveEnabled') private autoSaveEnabled: boolean = true;
  @State private projectId: number = 0;
  @State private project: Project | null = null;
  @State private segments: Array<VideoSegment> = [];
  @State private audioTrack: AudioTrack | null = null;
  @State private selectedSegmentIndex: number = 0;
  @State private trimStartMs: number = 0;
  @State private trimEndMs: number = 0;
  @State private busy: boolean = true;
  @State private busyLabel: string = 'Loading project...';
  @State private dirty: boolean = false;
  @State private audioVolume: number = 70;
  @State private fadeInMs: number = 0;
  @State private fadeOutMs: number = 0;

  aboutToAppear(): void {
    this.readParams();
    this.loadProject();
  }

  onPageShow(): void {
    if (this.projectId > 0) {
      this.loadProject();
    }
  }

  private readParams(): void {
    try {
      const params = router.getParams() as Record<string, Object>;
      this.projectId = Number(params['projectId'] ?? 0);
      AppStorage.SetOrCreate<number>('currentProjectId', this.projectId);
    } catch (_error) {
      this.projectId = 0;
    }
  }

  private async loadProject(): Promise<void> {
    if (this.projectId <= 0) {
      this.project = null;
      this.segments = [];
      this.audioTrack = null;
      this.busy = false;
      return;
    }
    this.busy = true;
    this.busyLabel = 'Loading project...';
    try {
      const bundle = await DataStore.getInstance().getProjectBundle(this.projectId);
      if (!bundle) {
        this.project = null;
        this.segments = [];
        this.audioTrack = null;
        return;
      }
      this.project = bundle.project;
      this.segments = bundle.segments.map((segment: VideoSegment) => ({ ...segment }));
      this.audioTrack = bundle.audioTrack ? { ...bundle.audioTrack } : null;
      this.audioVolume = bundle.audioTrack?.volume ?? 70;
      this.fadeInMs = bundle.audioTrack?.fadeInMs ?? 0;
      this.fadeOutMs = bundle.audioTrack?.fadeOutMs ?? 0;
      if (this.segments.length > 0) {
        this.selectedSegmentIndex = Math.min(this.selectedSegmentIndex, this.segments.length - 1);
        this.syncTrimState(this.segments[this.selectedSegmentIndex]);
      } else {
        this.selectedSegmentIndex = 0;
        this.trimStartMs = 0;
        this.trimEndMs = 0;
      }
      this.dirty = false;
    } catch (error) {
      promptAction.showToast({ message: `Failed to load project: ${this.normalizeError(error)}` });
    } finally {
      this.busy = false;
      this.busyLabel = '';
    }
  }

  private currentSegment(): VideoSegment | null {
    if (this.segments.length === 0) {
      return null;
    }
    return this.segments[Math.min(this.selectedSegmentIndex, this.segments.length - 1)];
  }

  private currentPreviewUri(): string {
    const segment = this.currentSegment();
    return segment ? segment.sourcePath : '';
  }

  private totalDurationMs(): number {
    return this.segments.reduce((total: number, segment: VideoSegment) => total + Math.max(0, segment.duration), 0);
  }

  private currentTimelineLimitMs(): number {
    const segment = this.currentSegment();
    if (!segment) {
      return 0;
    }
    return Math.max(segment.endTime, segment.duration, this.trimEndMs);
  }

  private syncTrimState(segment: VideoSegment): void {
    this.trimStartMs = segment.startTime;
    this.trimEndMs = segment.endTime;
  }

  private selectSegment(index: number): void {
    if (index < 0 || index >= this.segments.length) {
      return;
    }
    this.selectedSegmentIndex = index;
    this.syncTrimState(this.segments[index]);
  }

  private markDirty(): void {
    this.dirty = true;
    if (this.autoSaveEnabled) {
      this.saveChanges(false);
    }
  }

  private async saveChanges(showToast: boolean): Promise<void> {
    if (this.projectId <= 0) {
      return;
    }
    this.busy = true;
    this.busyLabel = 'Saving changes...';
    try {
      await DataStore.getInstance().replaceSegments(this.projectId, this.segments.map((segment: VideoSegment) => ({ ...segment })));
      if (this.audioTrack) {
        await DataStore.getInstance().saveAudioTrack(this.projectId, {
          ...this.audioTrack,
          volume: this.audioVolume,
          fadeInMs: this.fadeInMs,
          fadeOutMs: this.fadeOutMs
        });
      } else {
        await DataStore.getInstance().saveAudioTrack(this.projectId, null);
      }
      this.dirty = false;
      if (showToast) {
        promptAction.showToast({ message: 'Changes saved' });
      }
      const refreshedProject = await DataStore.getInstance().getProject(this.projectId);
      if (refreshedProject) {
        this.project = refreshedProject;
      }
    } catch (error) {
      promptAction.showToast({ message: `Save failed: ${this.normalizeError(error)}` });
    } finally {
      this.busy = false;
      this.busyLabel = '';
    }
  }

  private async applyTrim(startMs: number, endMs: number): Promise<void> {
    const segment = this.currentSegment();
    if (!segment) {
      return;
    }
    if (endMs - startMs < TIMELINE_MIN_GAP_MS) {
      promptAction.showToast({ message: 'Trim range is too short.' });
      this.syncTrimState(segment);
      return;
    }
    const updatedSegments = this.segments.map((item: VideoSegment) => ({ ...item }));
    const updated = updatedSegments[this.selectedSegmentIndex];
    updated.startTime = startMs;
    updated.endTime = endMs;
    updated.duration = endMs - startMs;
    this.segments = updatedSegments;
    this.syncTrimState(updated);
    this.markDirty();
  }

  private moveSelectedSegment(offset: number): void {
    const currentIndex = this.selectedSegmentIndex;
    const nextIndex = currentIndex + offset;
    if (currentIndex < 0 || currentIndex >= this.segments.length || nextIndex < 0 || nextIndex >= this.segments.length) {
      return;
    }
    const updatedSegments = this.segments.map((segment: VideoSegment) => ({ ...segment }));
    const current = updatedSegments[currentIndex];
    updatedSegments[currentIndex] = updatedSegments[nextIndex];
    updatedSegments[nextIndex] = current;
    updatedSegments.forEach((segment: VideoSegment, index: number) => {
      segment.order = index;
    });
    this.segments = updatedSegments;
    this.selectedSegmentIndex = nextIndex;
    this.syncTrimState(this.segments[this.selectedSegmentIndex]);
    this.markDirty();
  }

  private confirmDeleteSelectedSegment(): void {
    const segment = this.currentSegment();
    if (!segment) {
      return;
    }
    AlertDialog.show({
      title: 'Remove clip',
      message: 'Delete this clip from the project timeline?',
      autoCancel: true,
      primaryButton: { value: 'Cancel' },
      secondaryButton: {
        value: 'Delete',
        action: () => {
          this.deleteSelectedSegment();
        }
      }
    });
  }

  private deleteSelectedSegment(): void {
    if (this.segments.length === 0) {
      return;
    }
    const updatedSegments = this.segments.filter((_segment: VideoSegment, index: number) => index !== this.selectedSegmentIndex)
      .map((segment: VideoSegment, index: number) => ({
        ...segment,
        order: index
      }));
    this.segments = updatedSegments;
    this.selectedSegmentIndex = Math.max(0, Math.min(this.selectedSegmentIndex, this.segments.length - 1));
    const segment = this.currentSegment();
    if (segment) {
      this.syncTrimState(segment);
    } else {
      this.trimStartMs = 0;
      this.trimEndMs = 0;
    }
    this.markDirty();
  }

  private async chooseAudioTrack(): Promise<void> {
    this.busy = true;
    this.busyLabel = 'Choosing audio...';
    try {
      const pickerRecord = picker as unknown as Record<string, unknown>;
      const PickerConstructor = pickerRecord['DocumentViewPicker'];
      if (typeof PickerConstructor !== 'function') {
        throw new Error('Document picker is unavailable');
      }
      const documentPicker = new (PickerConstructor as new () => Object)();
      const select = (documentPicker as Record<string, unknown>)['select'];
      if (typeof select !== 'function') {
        throw new Error('Audio picker is unavailable');
      }
      const result = await Promise.resolve((select as (...args: Array<unknown>) => unknown).call(documentPicker, {
        maxSelectNumber: 1,
        fileSuffixFilters: ['mp3', 'wav', 'm4a', 'aac']
      }));
      const uri = this.readPickerUri(result);
      if (uri.length === 0) {
        promptAction.showToast({ message: 'No audio file was selected.' });
        return;
      }
      this.audioTrack = createAudioTrack(this.projectId, uri);
      this.audioVolume = this.audioTrack.volume;
      this.fadeInMs = this.audioTrack.fadeInMs;
      this.fadeOutMs = this.audioTrack.fadeOutMs;
      this.markDirty();
    } catch (error) {
      promptAction.showToast({ message: `Audio pick failed: ${this.normalizeError(error)}` });
    } finally {
      this.busy = false;
      this.busyLabel = '';
    }
  }

  private readPickerUri(result: unknown): string {
    if (Array.isArray(result) && result.length > 0 && typeof result[0] === 'string') {
      return result[0];
    }
    if (typeof result === 'object' && result !== null) {
      const record = result as Record<string, unknown>;
      const uris = record['uris'];
      if (Array.isArray(uris) && uris.length > 0 && typeof uris[0] === 'string') {
        return uris[0];
      }
      const uri = record['uri'];
      if (typeof uri === 'string') {
        return uri;
      }
    }
    return '';
  }

  private removeAudioTrack(): void {
    this.audioTrack = null;
    this.audioVolume = 70;
    this.fadeInMs = 0;
    this.fadeOutMs = 0;
    this.markDirty();
  }

  private updateAudioVolume(value: number): void {
    this.audioVolume = Math.round(value);
    if (this.audioTrack) {
      this.audioTrack = {
        ...this.audioTrack,
        volume: this.audioVolume,
        fadeInMs: this.fadeInMs,
        fadeOutMs: this.fadeOutMs
      };
      this.markDirty();
    }
  }

  private updateFadeIn(value: number): void {
    this.fadeInMs = Math.round(value);
    if (this.audioTrack) {
      this.audioTrack = {
        ...this.audioTrack,
        volume: this.audioVolume,
        fadeInMs: this.fadeInMs,
        fadeOutMs: this.fadeOutMs
      };
      this.markDirty();
    }
  }

  private updateFadeOut(value: number): void {
    this.fadeOutMs = Math.round(value);
    if (this.audioTrack) {
      this.audioTrack = {
        ...this.audioTrack,
        volume: this.audioVolume,
        fadeInMs: this.fadeInMs,
        fadeOutMs: this.fadeOutMs
      };
      this.markDirty();
    }
  }

  private async openAddClips(): Promise<void> {
    if (this.dirty) {
      await this.saveChanges(false);
    }
    router.pushUrl({ url: ROUTES.VIDEO_PICKER, params: { projectId: this.projectId } });
  }

  private async openFilters(): Promise<void> {
    const segment = this.currentSegment();
    if (!segment) {
      promptAction.showToast({ message: 'Select a clip before opening filters.' });
      return;
    }
    if (this.dirty) {
      await this.saveChanges(false);
    }
    router.pushUrl({ url: ROUTES.FILTER_PANEL, params: { projectId: this.projectId, segmentId: segment.id } });
  }

  private async openExport(): Promise<void> {
    if (this.dirty) {
      await this.saveChanges(false);
    }
    router.pushUrl({ url: ROUTES.EXPORT, params: { projectId: this.projectId } });
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row({ space: 12 }) {
          Column({ space: 6 }) {
            Text(this.project ? this.project.name : 'Editor')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppStyles.colors.textPrimary)
            Text(this.project ? `${this.segments.length} clips • ${formatDuration(this.totalDurationMs())} total` : 'Load a project to start editing.')
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

        if (this.busy) {
          Column({ space: 10 }) {
            LoadingProgress()
              .width(42)
              .height(42)
              .color(AppStyles.colors.brandPrimary)
            Text(this.busyLabel.length > 0 ? this.busyLabel : 'Working...')
              .fontSize(13)
              .fontColor(AppStyles.colors.textSecondary)
          }
          .width('100%')
          .height(220)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(AppStyles.colors.surfaceAlt)
          .borderRadius(AppStyles.radius.lg)
        } else if (!this.project) {
          Column({ space: 10 }) {
            Text('Project not found')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppStyles.colors.textPrimary)
            Text('Return to the project list and create or reopen a valid project.')
              .fontSize(14)
              .fontColor(AppStyles.colors.textSecondary)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .height(220)
          .padding(24)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(AppStyles.colors.surfaceAlt)
          .borderRadius(AppStyles.radius.lg)
        } else {
          Column({ space: 16 }) {
            this.buildPreviewCard()
            this.buildSegmentList()
            this.buildTimelineCard()
            this.buildAudioCard()
            this.buildToolbar()
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
  private buildPreviewCard() {
    Column({ space: 12 }) {
      if (this.currentPreviewUri().length > 0) {
        Image(this.currentPreviewUri())
          .width('100%')
          .height(220)
          .objectFit(ImageFit.Cover)
          .borderRadius(AppStyles.radius.lg)
      } else {
        Column({ space: 8 }) {
          Text('Preview unavailable')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppStyles.colors.textPrimary)
          Text('Select a clip to see its preview and timeline controls.')
            .fontSize(13)
            .fontColor(AppStyles.colors.textSecondary)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(220)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(AppStyles.colors.surfaceMuted)
        .borderRadius(AppStyles.radius.lg)
      }

      Row({ space: 10 }) {
        this.infoChip(this.projectStatusLabel())
        this.infoChip(this.currentSegment() ? `Clip ${this.selectedSegmentIndex + 1}` : 'No clip')
        this.infoChip(this.currentSegment() ? formatDuration(this.currentSegment()?.duration ?? 0) : '--:--')
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
  private buildSegmentList() {
    Column({ space: 12 }) {
      Row() {
        Text('Clips')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppStyles.colors.textPrimary)
        Blank()
        if (this.dirty) {
          Text('Unsaved changes')
            .fontSize(11)
            .fontColor(AppStyles.colors.warning)
        }
      }
      .width('100%')

      Scroll(Axis.Horizontal) {
        Row({ space: 10 }) {
          ForEach(this.segments, (segment: VideoSegment, index: number) => {
            Column({ space: 6 }) {
              Text(`Clip ${index + 1}`)
                .fontSize(13)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppStyles.colors.textPrimary)
              Text(formatDuration(segment.duration))
                .fontSize(11)
                .fontColor(AppStyles.colors.textSecondary)
              Text(segment.filterType === 'none' ? 'No filter' : segment.filterType)
                .fontSize(11)
                .fontColor(AppStyles.colors.textSecondary)
                .maxLines(1)
            }
            .width(112)
            .padding(12)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(index === this.selectedSegmentIndex ? '#332563EB' : AppStyles.colors.surfaceAlt)
            .borderRadius(AppStyles.radius.md)
            .border({
              width: index === this.selectedSegmentIndex ? 1.5 : 1,
              color: index === this.selectedSegmentIndex ? AppStyles.colors.brandPrimary : AppStyles.colors.border
            })
            .onClick(() => this.selectSegment(index))
          }, (segment: VideoSegment) => `${segment.id}_${segment.order}`)
        }
      }
      .scrollBar(BarState.Off)
      .width('100%')

      Row({ space: 10 }) {
        Button('Move Left')
          .layoutWeight(1)
          .height(40)
          .fontColor(AppStyles.colors.textPrimary)
          .backgroundColor(AppStyles.colors.surface)
          .onClick(() => this.moveSelectedSegment(-1))
        Button('Move Right')
          .layoutWeight(1)
          .height(40)
          .fontColor(AppStyles.colors.textPrimary)
          .backgroundColor(AppStyles.colors.surface)
          .onClick(() => this.moveSelectedSegment(1))
        Button('Delete')
          .layoutWeight(1)
          .height(40)
          .fontColor('#FFFFFFFF')
          .backgroundColor(AppStyles.colors.danger)
          .onClick(() => this.confirmDeleteSelectedSegment())
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
  private buildTimelineCard() {
    Column({ space: 12 }) {
      if (this.currentSegment()) {
        TimelineTrack({
          segments: this.segments,
          trimStartMs: $trimStartMs,
          trimEndMs: $trimEndMs,
          totalDurationMs: this.currentTimelineLimitMs(),
          onRangeChanged: (startMs: number, endMs: number) => this.applyTrim(startMs, endMs)
        })
      } else {
        Text('Add clips to start trimming the timeline.')
          .fontSize(13)
          .fontColor(AppStyles.colors.textSecondary)
      }
    }
    .width('100%')
  }

  @Builder
  private buildAudioCard() {
    Column({ space: 12 }) {
      Row() {
        Text('Audio Track')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppStyles.colors.textPrimary)
        Blank()
        Text(this.audioTrack ? 'Attached' : 'Optional')
          .fontSize(11)
          .fontColor(this.audioTrack ? AppStyles.colors.success : AppStyles.colors.textSecondary)
      }
      .width('100%')

      Text(this.audioTrack ? this.audioTrack.sourcePath : 'Choose a music or narration file to mix into the project.')
        .fontSize(12)
        .fontColor(AppStyles.colors.textSecondary)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row({ space: 10 }) {
        Button(this.audioTrack ? 'Replace Audio' : 'Add Audio')
          .layoutWeight(1)
          .height(40)
          .fontColor('#FFFFFFFF')
          .backgroundColor(AppStyles.colors.brandPrimary)
          .onClick(() => this.chooseAudioTrack())
        Button('Remove')
          .layoutWeight(1)
          .height(40)
          .fontColor(AppStyles.colors.textPrimary)
          .backgroundColor(AppStyles.colors.surface)
          .onClick(() => this.removeAudioTrack())
      }
      .width('100%')

      Text(`Volume ${this.audioVolume}%`)
        .fontSize(12)
        .fontColor(AppStyles.colors.textSecondary)
      Slider({ value: this.audioVolume, min: 0, max: 100, step: 1 })
        .width('100%')
        .onChange((value: number) => this.updateAudioVolume(value))

      Text(`Fade in ${this.fadeInMs} ms`)
        .fontSize(12)
        .fontColor(AppStyles.colors.textSecondary)
      Slider({ value: this.fadeInMs, min: 0, max: 3000, step: 250 })
        .width('100%')
        .onChange((value: number) => this.updateFadeIn(value))

      Text(`Fade out ${this.fadeOutMs} ms`)
        .fontSize(12)
        .fontColor(AppStyles.colors.textSecondary)
      Slider({ value: this.fadeOutMs, min: 0, max: 3000, step: 250 })
        .width('100%')
        .onChange((value: number) => this.updateFadeOut(value))
    }
    .padding(AppStyles.cardPadding)
    .width('100%')
    .backgroundColor(AppStyles.colors.surfaceAlt)
    .borderRadius(AppStyles.radius.lg)
    .border({ width: 1, color: AppStyles.colors.border })
  }

  @Builder
  private buildToolbar() {
    Column({ space: 12 }) {
      Row({ space: 10 }) {
        Button('Add Clips')
          .layoutWeight(1)
          .height(42)
          .fontColor(AppStyles.colors.textPrimary)
          .backgroundColor(AppStyles.colors.surface)
          .onClick(() => this.openAddClips())
        Button('Filters')
          .layoutWeight(1)
          .height(42)
          .fontColor(AppStyles.colors.textPrimary)
          .backgroundColor(AppStyles.colors.surface)
          .onClick(() => this.openFilters())
        Button('Export')
          .layoutWeight(1)
          .height(42)
          .fontColor('#FFFFFFFF')
          .backgroundColor(AppStyles.colors.brandPrimary)
          .onClick(() => this.openExport())
      }
      .width('100%')

      if (!this.autoSaveEnabled) {
        Button(this.dirty ? 'Save Changes' : 'Saved')
          .width('100%')
          .height(42)
          .fontColor('#FFFFFFFF')
          .backgroundColor(this.dirty ? AppStyles.colors.brandSecondary : AppStyles.colors.surfaceMuted)
          .onClick(() => this.saveChanges(true))
      }
    }
    .width('100%')
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
