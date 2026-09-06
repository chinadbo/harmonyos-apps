import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { FILTER_PRESETS, FilterPreset, FilterType } from '../common/constants';
import { AppStyles } from '../common/styles';
import { FilterItem } from '../components/FilterItem';
import { DataStore } from '../model/DataStore';
import { VideoSegment } from '../model/ProjectModel';

const NONE_PRESET: FilterPreset = {
  type: FilterType.NONE,
  label: 'None',
  description: 'Keep the original clip colors.',
  previewColor: '#475569'
};

@Entry
@Component
struct FilterPanelPage {
  @State private projectId: number = 0;
  @State private segmentId: number = 0;
  @State private segments: Array<VideoSegment> = [];
  @State private activeSegment: VideoSegment | null = null;
  @State private selectedFilter: FilterType = FilterType.NONE;
  @State private intensity: number = 0;
  @State private loading: boolean = true;
  @State private saving: boolean = false;

  aboutToAppear(): void {
    this.readParams();
    this.loadSegment();
  }

  private readParams(): void {
    try {
      const params = router.getParams() as Record<string, Object>;
      this.projectId = Number(params['projectId'] ?? 0);
      this.segmentId = Number(params['segmentId'] ?? 0);
    } catch (_error) {
      this.projectId = 0;
      this.segmentId = 0;
    }
  }

  private async loadSegment(): Promise<void> {
    this.loading = true;
    try {
      this.segments = await DataStore.getInstance().getSegments(this.projectId);
      this.activeSegment = this.segments.find((segment: VideoSegment) => segment.id === this.segmentId) ?? null;
      if (!this.activeSegment && this.segments.length > 0) {
        this.activeSegment = this.segments[0];
      }
      this.selectedFilter = this.activeSegment?.filterType ?? FilterType.NONE;
      this.intensity = this.activeSegment?.filterIntensity ?? 0;
    } catch (error) {
      promptAction.showToast({ message: `Failed to load filters: ${this.normalizeError(error)}` });
    } finally {
      this.loading = false;
    }
  }

  private presetList(): Array<FilterPreset> {
    return [NONE_PRESET, ...FILTER_PRESETS];
  }

  private choosePreset(filterType: FilterType): void {
    this.selectedFilter = filterType;
    if (filterType === FilterType.NONE) {
      this.intensity = 0;
    } else if (this.intensity === 0) {
      this.intensity = 60;
    }
  }

  private async saveFilter(): Promise<void> {
    if (!this.activeSegment) {
      promptAction.showToast({ message: 'No clip is available for filtering.' });
      return;
    }
    this.saving = true;
    try {
      const updatedSegments = this.segments.map((segment: VideoSegment) => ({ ...segment }));
      const index = updatedSegments.findIndex((segment: VideoSegment) => segment.id === this.activeSegment?.id);
      if (index < 0) {
        throw new Error('The selected clip could not be found.');
      }
      updatedSegments[index].filterType = this.selectedFilter;
      updatedSegments[index].filterIntensity = this.selectedFilter === FilterType.NONE ? 0 : this.intensity;
      await DataStore.getInstance().replaceSegments(this.projectId, updatedSegments);
      promptAction.showToast({ message: 'Filter saved' });
      router.back();
    } catch (error) {
      promptAction.showToast({ message: `Failed to save filter: ${this.normalizeError(error)}` });
    } finally {
      this.saving = false;
    }
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row({ space: 12 }) {
          Column({ space: 6 }) {
            Text('Filters')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppStyles.colors.textPrimary)
            Text('Choose a look for the selected clip and fine-tune its intensity.')
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
            Text('Loading filters...')
              .fontSize(13)
              .fontColor(AppStyles.colors.textSecondary)
          }
          .width('100%')
          .height(280)
          .justifyContent(FlexAlign.Center)
        } else if (!this.activeSegment) {
          Column({ space: 10 }) {
            Text('Clip not found')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppStyles.colors.textPrimary)
            Text('Return to the editor and select a valid clip to configure filters.')
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
            Stack({ alignContent: Alignment.Center }) {
              Image(this.activeSegment.sourcePath)
                .width('100%')
                .height(220)
                .objectFit(ImageFit.Cover)
                .borderRadius(AppStyles.radius.lg)
              Column({ space: 8 }) {
                Text(this.selectedFilter === FilterType.NONE ? 'Original' : this.selectedFilter)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFFFF')
                Text(`Intensity ${this.selectedFilter === FilterType.NONE ? 0 : this.intensity}%`)
                  .fontSize(12)
                  .fontColor('#FFE2E8F0')
              }
              .padding(16)
              .backgroundColor('rgba(15,23,42,0.35)')
              .borderRadius(AppStyles.radius.md)
            }
            .width('100%')

            Scroll(Axis.Horizontal) {
              Row({ space: 10 }) {
                ForEach(this.presetList(), (preset: FilterPreset) => {
                  FilterItem({
                    preset,
                    selected: preset.type === this.selectedFilter,
                    onTap: () => this.choosePreset(preset.type)
                  })
                }, (preset: FilterPreset) => preset.type)
              }
            }
            .scrollBar(BarState.Off)
            .width('100%')

            Column({ space: 8 }) {
              Row() {
                Text('Intensity')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(AppStyles.colors.textPrimary)
                Blank()
                Text(`${this.selectedFilter === FilterType.NONE ? 0 : this.intensity}%`)
                  .fontSize(12)
                  .fontColor(AppStyles.colors.textSecondary)
              }
              .width('100%')

              Slider({ value: this.selectedFilter === FilterType.NONE ? 0 : this.intensity, min: 0, max: 100, step: 1 })
                .width('100%')
                .onChange((value: number) => {
                  if (this.selectedFilter !== FilterType.NONE) {
                    this.intensity = Math.round(value);
                  }
                })
                .opacity(this.selectedFilter === FilterType.NONE ? 0.45 : 1)
                .blockColor(this.selectedFilter === FilterType.NONE ? AppStyles.colors.surfaceMuted : AppStyles.colors.brandPrimary)
                .trackColor(AppStyles.colors.surfaceMuted)
                .selectedColor(this.selectedFilter === FilterType.NONE ? AppStyles.colors.surfaceMuted : AppStyles.colors.brandPrimary)
            }
            .padding(AppStyles.cardPadding)
            .width('100%')
            .backgroundColor(AppStyles.colors.surfaceAlt)
            .borderRadius(AppStyles.radius.lg)
            .border({ width: 1, color: AppStyles.colors.border })

            Row({ space: 10 }) {
              Button('Cancel')
                .layoutWeight(1)
                .height(42)
                .fontColor(AppStyles.colors.textPrimary)
                .backgroundColor(AppStyles.colors.surface)
                .borderRadius(AppStyles.radius.lg)
                .onClick(() => router.back())
              Button(this.saving ? 'Saving...' : 'Apply Filter')
                .layoutWeight(1)
                .height(42)
                .fontColor('#FFFFFFFF')
                .backgroundColor(this.saving ? AppStyles.colors.surfaceMuted : AppStyles.colors.brandPrimary)
                .borderRadius(AppStyles.radius.lg)
                .onClick(() => {
                  if (!this.saving) {
                    this.saveFilter();
                  }
                })
            }
            .width('100%')
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
