import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { FileItem, FileFilterType } from '../model/FileItem';
import { FileService } from '../service/FileService';
import { FileListItem } from './components/FileListItem';
import { EmptyView } from './components/EmptyView';
import {
  IMAGE_EXTENSIONS,
  VIDEO_EXTENSIONS,
  AUDIO_EXTENSIONS,
  DOC_EXTENSIONS,
  CODE_EXTENSIONS,
  ARCHIVE_EXTENSIONS
} from '../model/FileConstants';

interface FilterChip {
  label: string;
  type: FileFilterType;
}

const FILTER_CHIPS: FilterChip[] = [
  { label: 'All', type: FileFilterType.ALL },
  { label: 'Image', type: FileFilterType.IMAGE },
  { label: 'Video', type: FileFilterType.VIDEO },
  { label: 'Audio', type: FileFilterType.AUDIO },
  { label: 'Doc', type: FileFilterType.DOC },
  { label: 'Archive', type: FileFilterType.ARCHIVE },
];

function extensionsForFilter(filter: FileFilterType): string[] {
  if (filter === FileFilterType.IMAGE) return IMAGE_EXTENSIONS;
  if (filter === FileFilterType.VIDEO) return VIDEO_EXTENSIONS;
  if (filter === FileFilterType.AUDIO) return AUDIO_EXTENSIONS;
  if (filter === FileFilterType.DOC) return DOC_EXTENSIONS;
  if (filter === FileFilterType.ARCHIVE) return ARCHIVE_EXTENSIONS;
  if (filter === FileFilterType.CODE) return CODE_EXTENSIONS;
  return [];
}

function getIconType(extension: string, isDirectory: boolean): string {
  if (isDirectory) return 'folder';
  const ext = extension.toLowerCase();
  if (IMAGE_EXTENSIONS.includes(ext)) return 'image';
  if (VIDEO_EXTENSIONS.includes(ext)) return 'video';
  if (AUDIO_EXTENSIONS.includes(ext)) return 'audio';
  if (CODE_EXTENSIONS.includes(ext)) return 'code';
  if (ARCHIVE_EXTENSIONS.includes(ext)) return 'archive';
  if (ext === 'pdf') return 'pdf';
  if (['doc', 'docx'].includes(ext)) return 'word';
  if (['xls', 'xlsx'].includes(ext)) return 'excel';
  if (['ppt', 'pptx'].includes(ext)) return 'ppt';
  return 'unknown';
}

@Component
export struct SearchPage {
  @Prop navStack: NavPathStack;
  @State searchText: string = '';
  @State filterType: FileFilterType = FileFilterType.ALL;
  @State results: FileItem[] = [];
  @State isSearching: boolean = false;
  @State rootPath: string = '';
  private debounceTimer: number = -1;

  aboutToAppear(): void {
    const stored = AppStorage.get<string>('rootPath');
    if (stored) {
      this.rootPath = stored;
    } else {
      const ctx = getContext(this) as common.UIAbilityContext;
      this.rootPath = ctx.filesDir;
    }
  }

  private triggerSearch(text: string): void {
    if (this.debounceTimer !== -1) {
      clearTimeout(this.debounceTimer);
    }
    if (!text) {
      this.results = [];
      this.isSearching = false;
      return;
    }
    this.debounceTimer = setTimeout(async () => {
      this.isSearching = true;
      this.results = await this.searchFiles(text, this.filterType);
      this.isSearching = false;
    }, 300);
  }

  private async searchFiles(text: string, filter: FileFilterType): Promise<FileItem[]> {
    const results: FileItem[] = [];
    const filterExts = extensionsForFilter(filter);
    const lowerText = text.toLowerCase();

    const walk = async (dirPath: string, depth: number): Promise<void> => {
      if (depth > 5 || results.length >= 200) return;
      let names: string[];
      try {
        names = fs.listFileSync(dirPath, { recursion: false, listNum: 0 });
      } catch (e) {
        return;
      }
      for (const name of names) {
        if (results.length >= 200) break;
        const fullPath = `${dirPath}/${name}`;
        let stat: fs.Stat;
        try {
          stat = fs.statSync(fullPath);
        } catch (e) {
          continue;
        }
        const isDirectory = stat.isDirectory();
        const dotIndex = name.lastIndexOf('.');
        const extension = (!isDirectory && dotIndex > 0) ? name.substring(dotIndex + 1).toLowerCase() : '';

        const nameMatches = name.toLowerCase().includes(lowerText);
        const typeMatches = filter === FileFilterType.ALL ||
          (filterExts.length > 0 && filterExts.includes(extension));

        if (nameMatches && typeMatches) {
          results.push({
            name,
            path: fullPath,
            isDirectory,
            size: stat.size,
            mtime: stat.mtime,
            extension,
            mimeType: '',
            iconType: getIconType(extension, isDirectory)
          });
        }

        if (isDirectory) {
          await walk(fullPath, depth + 1);
        }
      }
    };

    await walk(this.rootPath, 0);
    return results;
  }

  build() {
    Column() {
      TextInput({ placeholder: 'Search files...', text: this.searchText })
        .width('100%')
        .height(44)
        .padding({ left: 12, right: 40 })
        .backgroundColor(Color.White)
        .border({ width: { bottom: 0.5 }, color: '#e8e8e8', style: BorderStyle.Solid })
        .onChange((value: string) => {
          this.searchText = value;
          this.triggerSearch(value);
        })

      Row() {
        ForEach(FILTER_CHIPS, (chip: FilterChip) => {
          Text(chip.label)
            .fontSize(13)
            .fontColor(this.filterType === chip.type ? Color.White : '#555')
            .backgroundColor(this.filterType === chip.type ? '#007AFF' : '#f0f0f0')
            .borderRadius(14)
            .padding({ left: 12, right: 12, top: 5, bottom: 5 })
            .margin({ right: 8 })
            .onClick(() => {
              this.filterType = chip.type;
              if (this.searchText) {
                this.triggerSearch(this.searchText);
              }
            })
        }, (chip: FilterChip) => chip.label)
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(Color.White)
      .border({ width: { bottom: 0.5 }, color: '#e8e8e8', style: BorderStyle.Solid })

      if (this.isSearching) {
        LoadingProgress()
          .width(48)
          .height(48)
          .layoutWeight(1)
      } else if (this.results.length === 0 && this.searchText !== '') {
        EmptyView({ message: 'No results' })
      } else {
        List() {
          ForEach(this.results, (item: FileItem) => {
            ListItem() {
              FileListItem({
                item: item,
                isSelected: false,
                onTap: () => {
                  if (item.isDirectory) {
                    const params: Record<string, string> = { path: item.path };
                    this.navStack.pushPathByName('FileBrowserPage', params);
                  } else {
                    const params: Record<string, Object> = { file: item };
                    this.navStack.pushPathByName('FilePreviewPage', params);
                  }
                },
                onLongPress: () => {}
              })
            }
          }, (item: FileItem) => item.path)
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
