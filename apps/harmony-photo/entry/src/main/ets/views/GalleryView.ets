import { PhotoItem } from '../model/PhotoItem'
import { PhotoService } from '../service/PhotoService'
import { FavoriteStore } from '../service/FavoriteStore'
import { DateUtils } from '../utils/DateUtils'
import { PhotoCard } from '../components/PhotoCard'
import { PhotoPreview } from './PhotoPreview'

class PhotoDataSource implements IDataSource {
  private listeners: DataChangeListener[] = []
  private items: PhotoItem[] = []

  totalCount(): number {
    return this.items.length
  }

  getData(index: number): PhotoItem {
    return this.items[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    let pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  reload(newItems: PhotoItem[]): void {
    this.items = newItems
    this.listeners.forEach((l: DataChangeListener) => {
      l.onDataReloaded()
    })
  }
}

@Component
export struct GalleryView {
  @State private groupedPhotos: Array<{ month: string; photos: PhotoItem[] }> = []
  @State private selectedUris: string[] = []
  @State private isSelectMode: boolean = false
  @State private previewVisible: boolean = false
  @State private previewPhotos: PhotoItem[] = []
  @State private previewIndex: number = 0
  private dataSources: Record<string, PhotoDataSource> = {}

  aboutToAppear(): void {
    this.loadPhotos()
  }

  private async loadPhotos(): Promise<void> {
    let context = getContext(this) as Context
    await FavoriteStore.init(context)
    let photos = await PhotoService.fetchAllPhotos(context)
    let favUris = await FavoriteStore.getFavorites()
    photos.forEach((p: PhotoItem) => {
      p.isFavorite = favUris.indexOf(p.uri) >= 0
    })
    this.groupedPhotos = DateUtils.groupByMonth(photos)
    this.groupedPhotos.forEach((group) => {
      if (!this.dataSources[group.month]) {
        this.dataSources[group.month] = new PhotoDataSource()
      }
      this.dataSources[group.month].reload(group.photos)
    })
  }

  private toggleSelect(photo: PhotoItem): void {
    let idx = this.selectedUris.indexOf(photo.uri)
    if (idx >= 0) {
      let next = [...this.selectedUris]
      next.splice(idx, 1)
      this.selectedUris = next
    } else {
      this.selectedUris = [...this.selectedUris, photo.uri]
    }
  }

  private openPreview(photo: PhotoItem, allPhotos: PhotoItem[], localIndex: number): void {
    this.previewPhotos = allPhotos
    this.previewIndex = localIndex
    this.previewVisible = true
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('相册')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Blank()

          Button(this.isSelectMode ? '完成' : '选择')
            .height(36)
            .fontSize(14)
            .backgroundColor(this.isSelectMode ? '#2196F3' : '#EEEEEE')
            .fontColor(this.isSelectMode ? Color.White : '#333333')
            .borderRadius(18)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              this.isSelectMode = !this.isSelectMode
              if (!this.isSelectMode) {
                this.selectedUris = []
              }
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 12 })

        if (this.groupedPhotos.length === 0) {
          Column() {
            Text('暂无照片')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 20 })
            Text('点击下方编辑标签选择照片')
              .fontSize(12)
              .fontColor('#BBBBBB')
              .margin({ top: 8 })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          List({ space: 0 }) {
            ForEach(
              this.groupedPhotos,
              (group: { month: string; photos: PhotoItem[] }) => {
                ListItemGroup({
                  header: this.monthHeader(group.month)
                }) {
                  ListItem() {
                    WaterFlow() {
                      LazyForEach(
                        this.dataSources[group.month],
                        (item: PhotoItem, idx: number) => {
                          FlowItem() {
                            PhotoCard({
                              photo: item,
                              selected: this.selectedUris.indexOf(item.uri) >= 0,
                              showCheckBox: this.isSelectMode,
                              onTap: () => {
                                if (this.isSelectMode) {
                                  this.toggleSelect(item)
                                } else {
                                  this.openPreview(item, group.photos, idx)
                                }
                              },
                              onLongPress: () => {
                                this.isSelectMode = true
                                this.toggleSelect(item)
                              }
                            })
                          }
                        },
                        (item: PhotoItem) => item.uri
                      )
                    }
                    .columnsTemplate('1fr 1fr')
                    .columnsGap(4)
                    .rowsGap(4)
                    .width('100%')
                    // WaterFlow 嵌套在 ListItem 中需要明确高度，按每行2列计算估算高度
                    .height(Math.ceil(group.photos.length / 2) * 180)
                    .padding({ left: 4, right: 4 })
                    .nestedScroll({
                      scrollForward: NestedScrollMode.PARENT_FIRST,
                      scrollBackward: NestedScrollMode.SELF_FIRST
                    })
                  }
                }
              },
              (group: { month: string; photos: PhotoItem[] }) => group.month
            )
          }
          .sticky(StickyStyle.Header)
          .layoutWeight(1)
          .divider({ strokeWidth: 0 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      if (this.previewVisible) {
        PhotoPreview({
          photos: this.previewPhotos,
          initialIndex: this.previewIndex,
          onClose: () => {
            this.previewVisible = false
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  monthHeader(month: string) {
    Row() {
      Text(month)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
    }
    .width('100%')
    .height(40)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#F5F5F5')
  }
}
