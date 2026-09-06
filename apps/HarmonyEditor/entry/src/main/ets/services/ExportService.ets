import fs from '@ohos.file.fs';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { ExportFormat, ExportResolution } from '../common/constants';
import { AudioTrack, Project, VideoSegment } from '../model/ProjectModel';
import { PermissionService } from './PermissionService';
import { EditorOutput, VideoEditorService } from './VideoEditorService';

export interface ExportRequest {
  project: Project;
  segments: Array<VideoSegment>;
  audioTrack: AudioTrack | null;
  resolution: ExportResolution;
  format: ExportFormat;
}

export interface ExportResult {
  outputUri: string;
  savedUri: string;
  warningMessage: string;
}

export class ExportService {
  private static instance: ExportService = new ExportService();
  private videoEditorService: VideoEditorService = VideoEditorService.getInstance();

  static getInstance(): ExportService {
    return ExportService.instance;
  }

  async exportProject(request: ExportRequest, onProgress?: (progress: number) => void): Promise<ExportResult> {
    const context = PermissionService.getContext();
    const canWrite = await PermissionService.ensureWriteMediaPermission();
    if (!canWrite) {
      throw new Error('Write permission was denied, so export cannot continue.');
    }

    const editorOutput: EditorOutput = await this.videoEditorService.exportProject(context, {
      project: request.project,
      segments: request.segments,
      audioTrack: request.audioTrack,
      resolution: request.resolution,
      format: request.format
    }, onProgress);
    const savedUri = await this.saveToGallery(editorOutput.outputPath, request.format);
    return {
      outputUri: editorOutput.outputPath,
      savedUri,
      warningMessage: editorOutput.warningMessage
    };
  }

  private async saveToGallery(outputPath: string, format: ExportFormat): Promise<string> {
    const context = PermissionService.getContext();
    const helper = photoAccessHelper.getPhotoAccessHelper(context);
    const extension = format === ExportFormat.FORMAT_MOV ? 'mov' : 'mp4';
    const assetUri = await helper.createAsset(photoAccessHelper.PhotoType.VIDEO, extension);
    const sourceFile = fs.openSync(outputPath, fs.OpenMode.READ_ONLY);
    const targetFile = fs.openSync(assetUri, fs.OpenMode.READ_WRITE);
    try {
      await fs.copyFile(sourceFile.fd, targetFile.fd);
    } finally {
      fs.closeSync(sourceFile);
      fs.closeSync(targetFile);
    }
    return assetUri;
  }
}

export default ExportService.getInstance();
