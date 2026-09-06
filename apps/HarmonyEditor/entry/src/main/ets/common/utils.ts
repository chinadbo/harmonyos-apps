import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';

export function formatDuration(ms: number): string {
  const safeMs: number = Math.max(0, ms);
  const totalSeconds: number = Math.floor(safeMs / 1000);
  const hours: number = Math.floor(totalSeconds / 3600);
  const minutes: number = Math.floor((totalSeconds % 3600) / 60);
  const seconds: number = totalSeconds % 60;
  if (hours > 0) {
    return `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
  }
  return `${pad(minutes)}:${pad(seconds)}`;
}

export function formatFileSize(bytes: number): string {
  if (bytes < 1024) {
    return `${bytes} B`;
  }
  if (bytes < 1024 * 1024) {
    return `${(bytes / 1024).toFixed(1)} KB`;
  }
  if (bytes < 1024 * 1024 * 1024) {
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }
  return `${(bytes / (1024 * 1024 * 1024)).toFixed(2)} GB`;
}

export function normalizeProgress(progress: number): number {
  if (progress < 0) {
    return 0;
  }
  if (progress > 100) {
    return 100;
  }
  return Math.round(progress);
}

export function buildProjectName(prefix: string = 'Project'): string {
  const date: Date = new Date();
  return `${prefix} ${date.getMonth() + 1}/${date.getDate()} ${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

export function getOutputDir(context: common.UIAbilityContext): string {
  const dir: string = `${context.filesDir}/exports`;
  if (!fs.accessSync(dir)) {
    fs.mkdirSync(dir);
  }
  return dir;
}

export function buildOutputPath(context: common.UIAbilityContext, projectName: string, extension: string): string {
  const safeName: string = sanitizeFileName(projectName);
  return `${getOutputDir(context)}/${safeName}_${Date.now()}.${extension}`;
}

export function sanitizeFileName(input: string): string {
  const trimmed: string = input.trim();
  if (trimmed.length === 0) {
    return 'harmony_editor';
  }
  return trimmed.replace(/[^a-zA-Z0-9_-]+/g, '_').replace(/_+/g, '_');
}

export function parseBoolean(value: string | undefined, fallback: boolean): boolean {
  if (value === undefined) {
    return fallback;
  }
  return value === 'true';
}

export function parseNumber(value: string | undefined, fallback: number): number {
  if (value === undefined) {
    return fallback;
  }
  const parsed: number = Number(value);
  return Number.isNaN(parsed) ? fallback : parsed;
}

function pad(value: number): string {
  return value.toString().padStart(2, '0');
}
