import { FileItem, ViewMode, SortMode } from '../model/FileItem'
import { FileService } from '../service/FileService'
import { FavoritesService } from '../service/FavoritesService'
import { FileListItem } from './components/FileListItem'
import { GridFileItem } from './components/GridFileItem'
import { BreadcrumbBar } from './components/BreadcrumbBar'
import { EmptyView } from './components/EmptyView'
import { RenameDialog } from './dialogs/RenameDialog'
import { NewFolderDialog } from './dialogs/NewFolderDialog'
import { DeleteConfirmDialog } from './dialogs/DeleteConfirmDialog'
import { FileDetailSheet } from './FileDetailSheet'

// FileDataSource implements IDataSource (must implement all 4 methods)
class FileDataSource implements IDataSource {
  private data: FileItem[] = []
  private listeners: DataChangeListener[] = []

  totalCount(): number { return this.data.length }
  getData(index: number): FileItem { return this.data[index] }
  registerDataChangeListener(listener: DataChangeListener): void { this.listeners.push(listener) }
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const idx = this.listeners.indexOf(listener)
    if (idx >= 0) this.listeners.splice(idx, 1)
  }
  setData(items: FileItem[]): void {
    this.data = items
    this.listeners.forEach(l => l.onDataReloaded())
  }
}

@Component
export struct FileBrowserPage {
  @Prop navStack: NavPathStack
  @Prop dirPath: string = ''
  @State viewMode: ViewMode = ViewMode.LIST
  @State sortMode: SortMode = SortMode.NAME_ASC
  @State isLoading: boolean = true
  @State selectedItems: string[] = []
  @State isMultiSelect: boolean = false
  @State isFavorite: boolean = false
  @State showDetailSheet: boolean = false
  @State detailFile: FileItem = {name:'',path:'',isDirectory:false,size:0,mtime:0,extension:'',mimeType:'',iconType:'unknown'}

  private dataSource: FileDataSource = new FileDataSource()
  private fileService = FileService.getInstance()
  private favService = FavoritesService.getInstance()

  // Dialog controllers
  private renameDialogCtrl: CustomDialogController = new CustomDialogController({builder: RenameDialog({currentName: '', onConfirm: (n)=>{}})})
  private newFolderDialogCtrl: CustomDialogController = new CustomDialogController({builder: NewFolderDialog({onConfirm: (n)=>{}})})
  private deleteDialogCtrl: CustomDialogController = new CustomDialogController({builder: DeleteConfirmDialog({fileName: '', onConfirm: ()=>{}})})

  aboutToAppear(): void {
    this.loadDirectory()
    this.checkFavorite()
  }

  async loadDirectory(): Promise<void> {
    this.isLoading = true
    try {
      const items = await this.fileService.listDirectory(this.dirPath)
      const sorted = this.sortItems(items)
      this.dataSource.setData(sorted)
    } catch(e) {}
    this.isLoading = false
  }

  sortItems(items: FileItem[]): FileItem[] {
    return [...items].sort((a, b) => {
      if (a.isDirectory !== b.isDirectory) return a.isDirectory ? -1 : 1
      switch(this.sortMode) {
        case SortMode.NAME_DESC: return b.name.localeCompare(a.name)
        case SortMode.DATE_DESC: return b.mtime - a.mtime
        case SortMode.SIZE_DESC: return b.size - a.size
        default: return a.name.localeCompare(b.name)
      }
    })
  }

  async checkFavorite(): Promise<void> {
    this.isFavorite = await this.favService.isFavorite(this.dirPath)
  }

  getPathParts(): string[] {
    return this.dirPath.split('/').filter(p => p.length > 0)
  }

  onFileOrDirTap(item: FileItem): void {
    if (this.isMultiSelect) {
      const idx = this.selectedItems.indexOf(item.path)
      if (idx >= 0) this.selectedItems.splice(idx, 1)
      else this.selectedItems.push(item.path)
      this.selectedItems = [...this.selectedItems]
      return
    }
    if (item.isDirectory) {
      this.navStack.pushPathByName('FileBrowserPage', {path: item.path} as Record<string, string>)
    } else {
      this.navStack.pushPathByName('FilePreviewPage', {file: JSON.stringify(item)} as Record<string, string>)
    }
  }

  build() {
    Column() {
      // Top toolbar
      Row() {
        BreadcrumbBar({
          pathParts: this.getPathParts(),
          onNavigate: (idx) => {
            const parts = this.getPathParts()
            const targetPath = '/' + parts.slice(0, idx+1).join('/')
            this.navStack.pushPathByName('FileBrowserPage', {path: targetPath} as Record<string, string>)
          }
        }).layoutWeight(1)
        // View mode toggle
        Text(this.viewMode === ViewMode.LIST ? '☰' : '⊞')
          .fontSize(20).fontColor('#007DFF').padding(8)
          .onClick(() => {
            this.viewMode = this.viewMode === ViewMode.LIST ? ViewMode.GRID : ViewMode.LIST
          })
        // Favorite toggle
        Text(this.isFavorite ? '⭐' : '☆')
          .fontSize(20).fontColor('#FFB800').padding(8)
          .onClick(async () => {
            if (this.isFavorite) {
              const favs = await this.favService.getFavorites()
              const fav = favs.find(f => f.path === this.dirPath)
              if (fav) await this.favService.removeFavorite(fav.id)
            } else {
              const name = this.dirPath.split('/').pop() || 'Folder'
              await this.favService.addFavorite(this.dirPath, name)
            }
            this.checkFavorite()
          })
      }.width('100%').height(48).backgroundColor('#FFFFFF').padding({left:8, right:8})

      // Multi-select toolbar (shown when isMultiSelect)
      if (this.isMultiSelect) {
        Row() {
          Text('Cancel').fontColor('#007DFF').onClick(() => {
            this.isMultiSelect = false
            this.selectedItems = []
          })
          Text(this.selectedItems.length + ' selected').layoutWeight(1).textAlign(TextAlign.Center)
          Text('Delete').fontColor('#FF3B30').onClick(async () => {
            for (const path of this.selectedItems) {
              await this.fileService.deleteFile(path, false)
            }
            this.selectedItems = []
            this.isMultiSelect = false
            this.loadDirectory()
          })
        }.width('100%').height(44).backgroundColor('#F0F0F0').padding({left:16, right:16})
      }

      // File list / grid
      if (this.isLoading) {
        LoadingProgress().width(40).height(40).margin('auto')
      } else if (this.dataSource.totalCount() === 0) {
        EmptyView({message: 'This folder is empty'})
      } else if (this.viewMode === ViewMode.LIST) {
        List() {
          LazyForEach(this.dataSource, (item: FileItem, index: number) => {
            ListItem() {
              FileListItem({
                item: item,
                isSelected: this.selectedItems.includes(item.path),
                onTap: () => this.onFileOrDirTap(item),
                onLongPress: () => {
                  this.isMultiSelect = true
                  this.selectedItems = [item.path]
                }
              })
            }.swipeAction({end: this.buildSwipeActions(item)})
          }, (item: FileItem) => item.path)
        }.layoutWeight(1)
      } else {
        Grid() {
          LazyForEach(this.dataSource, (item: FileItem, index: number) => {
            GridItem() {
              GridFileItem({
                item: item,
                isSelected: this.selectedItems.includes(item.path),
                onTap: () => this.onFileOrDirTap(item),
                onLongPress: () => {
                  this.isMultiSelect = true
                  this.selectedItems = [item.path]
                }
              })
            }
          }, (item: FileItem) => item.path)
        }.columnsTemplate('1fr 1fr 1fr').columnsGap(8).rowsGap(8).padding(8).layoutWeight(1)
      }

      // FAB - New folder button
      Stack() {}.layoutWeight(0)
    }
    .width('100%').height('100%').backgroundColor('#F1F3F5')
    .bindSheet(this.showDetailSheet, this.buildDetailContent(), {height: 300})
  }

  @Builder buildSwipeActions(item: FileItem) {
    Row() {
      Text('Delete').fontSize(14).fontColor('#FFFFFF').backgroundColor('#FF3B30').padding({left:16, right:16, top:8, bottom:8})
        .onClick(async () => {
          await this.fileService.deleteFile(item.path, item.isDirectory)
          this.loadDirectory()
        })
    }
  }

  @Builder buildDetailContent() {
    Column() {
      Text(this.detailFile.name).fontSize(16).fontWeight(FontWeight.Bold).padding(16)
    }
  }
}
