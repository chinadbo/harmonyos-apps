import { ExportFormat, ExportResolution, FilterType, SETTING_KEYS } from '../common/constants';

export enum ProjectStatus {
  DRAFT = 'draft',
  EXPORTING = 'exporting',
  EXPORTED = 'exported',
  FAILED = 'failed'
}

export interface Project {
  id: number;
  name: string;
  outputPath: string;
  createdAt: number;
  updatedAt: number;
  status: ProjectStatus;
}

export interface VideoSegment {
  id: number;
  projectId: number;
  sourcePath: string;
  startTime: number;
  endTime: number;
  duration: number;
  order: number;
  filterType: FilterType;
  filterIntensity: number;
}

export interface AudioTrack {
  id: number;
  projectId: number;
  sourcePath: string;
  volume: number;
  fadeInMs: number;
  fadeOutMs: number;
}

export interface ProjectBundle {
  project: Project;
  segments: Array<VideoSegment>;
  audioTrack: AudioTrack | null;
}

export interface ProjectSummary extends Project {
  segmentCount: number;
  totalDuration: number;
}

export interface ExportSettings {
  resolution: ExportResolution;
  format: ExportFormat;
  autoSaveEnabled: boolean;
}

export function createDefaultSettings(): ExportSettings {
  return {
    resolution: ExportResolution.RES_ORIGINAL,
    format: ExportFormat.FORMAT_MP4,
    autoSaveEnabled: true
  };
}

export function createProject(name: string): Project {
  const timestamp: number = Date.now();
  return {
    id: 0,
    name,
    outputPath: '',
    createdAt: timestamp,
    updatedAt: timestamp,
    status: ProjectStatus.DRAFT
  };
}

export function createVideoSegment(projectId: number, sourcePath: string, duration: number, order: number): VideoSegment {
  return {
    id: 0,
    projectId,
    sourcePath,
    startTime: 0,
    endTime: duration,
    duration,
    order,
    filterType: FilterType.NONE,
    filterIntensity: 0
  };
}

export function createAudioTrack(projectId: number, sourcePath: string): AudioTrack {
  return {
    id: 0,
    projectId,
    sourcePath,
    volume: 70,
    fadeInMs: 0,
    fadeOutMs: 0
  };
}

export function cloneSegment(segment: VideoSegment): VideoSegment {
  return {
    ...segment
  };
}

export function cloneSegments(segments: Array<VideoSegment>): Array<VideoSegment> {
  return segments.map((segment: VideoSegment) => cloneSegment(segment));
}

export function cloneProject(project: Project): Project {
  return {
    ...project
  };
}

export function getSettingsKeys(): Array<string> {
  return [
    SETTING_KEYS.DEFAULT_EXPORT_RESOLUTION,
    SETTING_KEYS.DEFAULT_EXPORT_FORMAT,
    SETTING_KEYS.AUTO_SAVE_ENABLED
  ];
}
