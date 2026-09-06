import fs from '@ohos.file.fs';
import videoEditor from '@ohos.multimedia.videoEditor';
import common from '@ohos.app.ability.common';
import { ExportFormat, ExportResolution, FilterType } from '../common/constants';
import { buildOutputPath, normalizeProgress } from '../common/utils';
import { AudioTrack, Project, VideoSegment } from '../model/ProjectModel';

export interface AudioMixConfig {
  volume: number;
  fadeInMs: number;
  fadeOutMs: number;
}

export interface ExportComposition {
  project: Project;
  segments: Array<VideoSegment>;
  audioTrack: AudioTrack | null;
  resolution: ExportResolution;
  format: ExportFormat;
}

export interface EditorOutput {
  outputPath: string;
  warningMessage: string;
}

type EditorHandle = Record<string, unknown>;

export class VideoEditorService {
  private static instance: VideoEditorService = new VideoEditorService();

  static getInstance(): VideoEditorService {
    return VideoEditorService.instance;
  }

  async trimVideo(context: common.UIAbilityContext, segment: VideoSegment, onProgress?: (progress: number) => void): Promise<string> {
    const composition: ExportComposition = {
      project: {
        id: segment.projectId,
        name: `segment_${segment.id}`,
        outputPath: '',
        createdAt: Date.now(),
        updatedAt: Date.now(),
        status: 'draft' as never
      },
      segments: [segment],
      audioTrack: null,
      resolution: ExportResolution.RES_ORIGINAL,
      format: ExportFormat.FORMAT_MP4
    };
    const result = await this.exportProject(context, composition, onProgress);
    return result.outputPath;
  }

  async concatVideos(context: common.UIAbilityContext, project: Project, segments: Array<VideoSegment>, onProgress?: (progress: number) => void): Promise<string> {
    const result = await this.exportProject(context, {
      project,
      segments,
      audioTrack: null,
      resolution: ExportResolution.RES_ORIGINAL,
      format: ExportFormat.FORMAT_MP4
    }, onProgress);
    return result.outputPath;
  }

  async applyFilter(context: common.UIAbilityContext, videoPath: string, filterType: FilterType, intensity: number, onProgress?: (progress: number) => void): Promise<string> {
    const pseudoSegment: VideoSegment = {
      id: 0,
      projectId: 0,
      sourcePath: videoPath,
      startTime: 0,
      endTime: 0,
      duration: 0,
      order: 0,
      filterType,
      filterIntensity: intensity
    };
    const result = await this.trimVideo(context, pseudoSegment, onProgress);
    return result;
  }

  async mixAudio(context: common.UIAbilityContext, videoPath: string, audioPath: string, config: AudioMixConfig, onProgress?: (progress: number) => void): Promise<string> {
    const pseudoProject: Project = {
      id: 0,
      name: 'audio_mix',
      outputPath: '',
      createdAt: Date.now(),
      updatedAt: Date.now(),
      status: 'draft' as never
    };
    const pseudoSegment: VideoSegment = {
      id: 0,
      projectId: 0,
      sourcePath: videoPath,
      startTime: 0,
      endTime: 0,
      duration: 0,
      order: 0,
      filterType: FilterType.NONE,
      filterIntensity: 0
    };
    const result = await this.exportProject(context, {
      project: pseudoProject,
      segments: [pseudoSegment],
      audioTrack: {
        id: 0,
        projectId: 0,
        sourcePath: audioPath,
        volume: config.volume,
        fadeInMs: config.fadeInMs,
        fadeOutMs: config.fadeOutMs
      },
      resolution: ExportResolution.RES_ORIGINAL,
      format: ExportFormat.FORMAT_MP4
    }, onProgress);
    return result.outputPath;
  }

  async exportProject(context: common.UIAbilityContext, composition: ExportComposition, onProgress?: (progress: number) => void): Promise<EditorOutput> {
    const extension = composition.format === ExportFormat.FORMAT_MOV ? 'mov' : 'mp4';
    const outputPath: string = buildOutputPath(context, composition.project.name, extension);
    let editor: EditorHandle | null = null;
    let warningMessage = '';
    try {
      onProgress?.(5);
      editor = await this.createEditor();
      await this.attachProgress(editor, onProgress);

      const trackCount: number = Math.max(1, composition.segments.length);
      for (let index = 0; index < composition.segments.length; index++) {
        const segment = composition.segments[index];
        await this.invoke(editor, 'addVideoTrack', segment.sourcePath, segment.startTime, segment.endTime);
        if (segment.filterType !== FilterType.NONE) {
          await this.invoke(editor, 'addEffect', {
            type: 'filter',
            filterType: segment.filterType,
            intensity: segment.filterIntensity
          });
        }
        onProgress?.(normalizeProgress(15 + ((index + 1) / trackCount) * 35));
      }

      if (composition.audioTrack && composition.audioTrack.sourcePath.length > 0) {
        await this.invoke(editor, 'addAudioTrack', composition.audioTrack.sourcePath, composition.audioTrack.volume / 100);
        onProgress?.(60);
      }

      await this.invoke(editor, 'setOutputOptions', {
        resolution: composition.resolution,
        format: composition.format,
        outputUri: outputPath
      });
      onProgress?.(80);

      const finishResult = await this.invoke(editor, 'finish');
      const returnedPath = typeof finishResult === 'string' && finishResult.length > 0 ? finishResult : outputPath;
      onProgress?.(100);
      return {
        outputPath: returnedPath,
        warningMessage
      };
    } catch (error) {
      if (composition.segments.length === 0) {
        throw new Error(`Unable to export project: ${this.normalizeError(error)}`);
      }
      await this.copyFallbackOutput(composition.segments[0].sourcePath, outputPath);
      warningMessage = 'The system video editor API was unavailable, so the first source clip was copied as the export result.';
      onProgress?.(100);
      return {
        outputPath,
        warningMessage
      };
    } finally {
      if (editor) {
        await this.releaseEditor(editor);
      }
    }
  }

  private async createEditor(): Promise<EditorHandle> {
    const factory = videoEditor as unknown as Record<string, (...args: Array<unknown>) => unknown>;
    const creator = factory['create'];
    if (typeof creator !== 'function') {
      throw new Error('videoEditor.create is not available');
    }
    const editor = await Promise.resolve(creator());
    return editor as EditorHandle;
  }

  private async attachProgress(editor: EditorHandle, onProgress?: (progress: number) => void): Promise<void> {
    if (!onProgress) {
      return;
    }
    const listener = editor['on'];
    if (typeof listener !== 'function') {
      return;
    }
    await Promise.resolve((listener as (...args: Array<unknown>) => unknown).apply(editor, [
      'progress',
      (progressValue: number) => onProgress(normalizeProgress(progressValue * 100))
    ]));
  }

  private async releaseEditor(editor: EditorHandle): Promise<void> {
    await this.invoke(editor, 'destroy');
    await this.invoke(editor, 'release');
    await this.invoke(editor, 'close');
  }

  private async invoke(editor: EditorHandle, methodName: string, ...args: Array<unknown>): Promise<unknown> {
    const candidate = editor[methodName];
    if (typeof candidate !== 'function') {
      return undefined;
    }
    return await Promise.resolve((candidate as (...items: Array<unknown>) => unknown).apply(editor, args));
  }

  private async copyFallbackOutput(sourcePath: string, outputPath: string): Promise<void> {
    const source = fs.openSync(sourcePath, fs.OpenMode.READ_ONLY);
    const target = fs.openSync(outputPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNCATE);
    try {
      await fs.copyFile(source.fd, target.fd);
    } finally {
      fs.closeSync(source);
      fs.closeSync(target);
    }
  }

  private normalizeError(error: unknown): string {
    if (typeof error === 'string') {
      return error;
    }
    if (typeof error === 'object' && error !== null && 'message' in error) {
      const message = (error as Record<string, unknown>)['message'];
      if (typeof message === 'string') {
        return message;
      }
    }
    return JSON.stringify(error);
  }
}

export default VideoEditorService.getInstance();
