import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { MAX_SEGMENT_SELECT_COUNT, ROUTES } from '../common/constants';
import { AppStyles } from '../common/styles';
import { buildProjectName } from '../common/utils';
import { VideoThumbnail } from '../components/VideoThumbnail';
import { createProject, createVideoSegment } from '../model/ProjectModel';
import { createGalleryVideoItem, extractVideoInfo, GalleryVideoItem } from '../model/VideoModel';
import { DataStore } from '../model/DataStore';
import { PermissionService } from '../services/PermissionService';

@Entry
@Component
struct VideoPickerPage {
  @StorageLink('editorDraftName') private editorDraftName: string = '';
  @State private videos: Array<GalleryVideoItem> = [];
  @State private loading: boolean = true;
  @State private submitting: boolean = false;
  @State private appendProjectId: number = 0;

  aboutToAppear(): void {
    this.readParams();
    this.loadVideos();
  }

  private readParams(): void {
    try {
      const params = router.getParams() as Record<string, Object>;
      this.appendProjectId = Number(params['projectId'] ?? 0);
    } catch (_error) {
      this.appendProjectId = 0;
    }
  }

  private async loadVideos(): Promise<void> {
    this.loading = true;
    try {
      const granted = await PermissionService.ensureReadMediaPermission();
      if (!granted) {
        this.videos = [];
        promptAction.showToast({ message: 'Read permission was denied.' });
        return;
      }
      const videoUris = await this.loadVideoUris();
      const items: Array<GalleryVideoItem> = [];
      for (const uri of videoUris) {
        const info = await extractVideoInfo(uri);
        items.push(createGalleryVideoItem(info));
      }
      this.videos = items;
    } catch (error) {
      this.videos = [];
      promptAction.showToast({ message: `Failed to load videos: ${this.normalizeError(error)}` });
    } finally {
      this.loading = false;
    }
  }

  private async loadVideoUris(): Promise<Array<string>> {
    const helper = photoAccessHelper.getPhotoAccessHelper(PermissionService.getContext()) as unknown as Record<string, unknown>;
    const getAssets = helper['getAssets'];
    if (typeof getAssets !== 'function') {
      throw new Error('PhotoAccessHelper getAssets is unavailable');
    }
    const fetchResult = await Promise.resolve((getAssets as (...args: Array<unknown>) => unknown).call(helper, {
      fetchColumns: ['uri']
    }));
    return await this.readAssetUris(fetchResult);
  }

  private async readAssetUris(fetchResult: unknown): Promise<Array<string>> {
    const resultRecord = fetchResult as Record<string, unknown>;
    const loadAll = resultRecord?.['getAllObject'];
    const loadPage = resultRecord?.['getObjects'];
    const close = resultRecord?.['close'];
    let assets: Array<unknown> = [];
    try {
      if (Array.isArray(fetchResult)) {
        assets = fetchResult;
      } else if (typeof loadAll === 'function') {
        const output = await Promise.resolve((loadAll as (...args: Array<unknown>) => unknown).call(resultRecord));
        assets = Array.isArray(output) ? output : [];
      } else if (typeof loadPage === 'function') {
        const output = await Promise.resolve((loadPage as (...args: Array<unknown>) => unknown).call(resultRecord));
        assets = Array.isArray(output) ? output : [];
      }
    } finally {
      if (typeof close === 'function') {
        await Promise.resolve((close as (...args: Array<unknown>) => unknown).call(resultRecord));
      }
    }
    const uris: Array<string> = [];
    for (const asset of assets) {
      const uri = this.readAssetUri(asset);
      if (uri.length > 0) {
        uris.push(uri);
      }
      if (uris.length >= 50) {
        break;
      }
    }
    return uris;
  }

  private readAssetUri(asset: unknown): string {
    if (typeof asset !== 'object' || asset === null) {
      return '';
    }
    const assetRecord = asset as Record<string, unknown>;
    const directUri = assetRecord['uri'] ?? assetRecord['photoUri'];
    if (typeof directUri === 'string') {
      return directUri;
    }
    const getter = assetRecord['get'];
    if (typeof getter === 'function') {
      const uriValue = (getter as (...args: Array<unknown>) => unknown).call(assetRecord, 'uri');
      if (typeof uriValue === 'string') {
        return uriValue;
      }
      const photoUriValue = (getter as (...args: Array<unknown>) => unknown).call(assetRecord, 'photoUri');
      if (typeof photoUriValue === 'string') {
        return photoUriValue;
      }
    }
    return '';
  }

  private toggleVideo(uri: string): void {
    const updatedVideos = this.videos.map((video: GalleryVideoItem) => ({
      ...video
    }));
    const target = updatedVideos.find((video: GalleryVideoItem) => video.uri === uri);
    if (!target) {
      return;
    }
    if (!target.selected && this.selectedCount() >= MAX_SEGMENT_SELECT_COUNT) {
      promptAction.showToast({ message: `Select up to ${MAX_SEGMENT_SELECT_COUNT} clips per project.` });
      return;
    }
    target.selected = !target.selected;
    this.videos = updatedVideos;
  }

  private async confirmSelection(): Promise<void> {
    if (this.selectedCount() === 0) {
      promptAction.showToast({ message: 'Select at least one video to continue.' });
      return;
    }
    this.submitting = true;
    try {
      const store = DataStore.getInstance();
      const selectedVideos = this.videos.filter((video: GalleryVideoItem) => video.selected);
      if (this.appendProjectId > 0) {
        const existingSegments = await store.getSegments(this.appendProjectId);
        const appendedSegments = selectedVideos.map((video: GalleryVideoItem, index: number) =>
          createVideoSegment(this.appendProjectId, video.uri, video.durationMs, existingSegments.length + index)
        );
        await store.replaceSegments(this.appendProjectId, [...existingSegments, ...appendedSegments]);
        promptAction.showToast({ message: `${selectedVideos.length} clip(s) added to the project.` });
        router.back();
        return;
      }

      const draftName = this.editorDraftName;
      const project = await store.insertProject(createProject(draftName.length > 0 ? draftName : buildProjectName()));
      const segments = selectedVideos.map((video: GalleryVideoItem, index: number) =>
        createVideoSegment(project.id, video.uri, video.durationMs, index)
      );
      await store.replaceSegments(project.id, segments);
      AppStorage.SetOrCreate<number>('currentProjectId', project.id);
      AppStorage.SetOrCreate<string>('editorDraftName', '');
      router.replaceUrl({ url: ROUTES.EDITOR, params: { projectId: project.id } });
    } catch (error) {
      promptAction.showToast({ message: `Failed to save selection: ${this.normalizeError(error)}` });
    } finally {
      this.submitting = false;
    }
  }

  private selectedCount(): number {
    return this.videos.filter((video: GalleryVideoItem) => video.selected).length;
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row({ space: 12 }) {
          Column({ space: 6 }) {
            Text(this.appendProjectId > 0 ? 'Add Clips' : 'Pick Videos')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppStyles.colors.textPrimary)
            Text('Select up to 10 videos from the gallery for your edit timeline.')
              .fontSize(14)
              .fontColor(AppStyles.colors.textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Text(`${this.selectedCount()}/${MAX_SEGMENT_SELECT_COUNT}`)
            .fontSize(12)
            .fontColor(AppStyles.colors.textSecondary)
            .backgroundColor(AppStyles.colors.chip)
            .borderRadius(AppStyles.radius.pill)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        }
        .width('100%')

        Row({ space: 10 }) {
          Button('Back')
            .layoutWeight(1)
            .height(42)
            .fontColor(AppStyles.colors.textPrimary)
            .backgroundColor(AppStyles.colors.surfaceAlt)
            .borderRadius(AppStyles.radius.lg)
            .onClick(() => router.back())

          Button(this.submitting ? 'Saving...' : (this.appendProjectId > 0 ? 'Add to Project' : 'Create Project'))
            .layoutWeight(1)
            .height(42)
            .fontColor('#FFFFFFFF')
            .backgroundColor(this.submitting ? AppStyles.colors.surfaceMuted : AppStyles.colors.brandPrimary)
            .borderRadius(AppStyles.radius.lg)
            .onClick(() => {
              if (!this.submitting) {
                this.confirmSelection();
              }
            })
        }
        .width('100%')

        if (this.loading) {
          Column({ space: 10 }) {
            LoadingProgress()
              .width(42)
              .height(42)
              .color(AppStyles.colors.brandPrimary)
            Text('Loading videos...')
              .fontSize(13)
              .fontColor(AppStyles.colors.textSecondary)
          }
          .width('100%')
          .height(280)
          .justifyContent(FlexAlign.Center)
        } else if (this.videos.length === 0) {
          Column({ space: 10 }) {
            Text('No videos found')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppStyles.colors.textPrimary)
            Text('Grant media access and keep a few videos in the gallery to start editing.')
              .fontSize(14)
              .fontColor(AppStyles.colors.textSecondary)
              .textAlign(TextAlign.Center)
            Button('Retry')
              .margin({ top: 8 })
              .fontColor('#FFFFFFFF')
              .backgroundColor(AppStyles.colors.brandPrimary)
              .onClick(() => this.loadVideos())
          }
          .width('100%')
          .height(320)
          .padding(24)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(AppStyles.colors.surfaceAlt)
          .borderRadius(AppStyles.radius.lg)
        } else {
          Grid() {
            ForEach(this.videos, (video: GalleryVideoItem) => {
              GridItem() {
                VideoThumbnail({
                  video,
                  onToggle: (uri: string) => this.toggleVideo(uri)
                })
              }
            }, (video: GalleryVideoItem) => video.uri)
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
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
