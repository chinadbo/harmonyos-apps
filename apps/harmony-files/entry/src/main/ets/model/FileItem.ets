export interface FileItem {
  name: string;
  path: string;
  isDirectory: boolean;
  size: number;
  mtime: number;
  extension: string;
  mimeType: string;
  iconType: string;
}

export interface FavoriteItem {
  id: string;
  name: string;
  path: string;
  addedAt: number;
}

export enum ViewMode {
  LIST = 'list',
  GRID = 'grid'
}

export enum SortMode {
  NAME_ASC = 'name_asc',
  NAME_DESC = 'name_desc',
  DATE_DESC = 'date_desc',
  SIZE_DESC = 'size_desc'
}

export enum FileFilterType {
  ALL = 'all',
  IMAGE = 'image',
  VIDEO = 'video',
  AUDIO = 'audio',
  DOC = 'doc',
  ARCHIVE = 'archive',
  CODE = 'code'
}
