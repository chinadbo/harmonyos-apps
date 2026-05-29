class BasicDataSource implements IDataSource {
  private items: string[] = []
  private listeners: DataChangeListener[] = []

  constructor(items: string[] = []) {
    this.items = items
  }

  totalCount(): number {
    return this.items.length
  }

  getData(index: number): string {
    return this.items[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index: number = this.listeners.indexOf(listener)
    if (index >= 0) {
      this.listeners.splice(index, 1)
    }
  }

  update(items: string[]): void {
    this.items = items
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded()
    })
  }
}

@Component
export struct PhotoGrid {
  @Watch('onPhotosChanged') @Prop photoUris: string[] = []
  private dataSource: BasicDataSource = new BasicDataSource([])

  aboutToAppear(): void {
    this.dataSource.update(this.photoUris)
  }

  private onPhotosChanged(): void {
    this.dataSource.update(this.photoUris)
  }

  build() {
    if (this.photoUris.length === 0) {
      Column() {
        Text($r('app.string.empty_photo'))
          .fontSize(14)
          .fontColor('#8A8A8A')
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#F7F8FA')
      .borderRadius(16)
    } else {
      Grid() {
        LazyForEach(this.dataSource, (item: string, index: number) => {
          GridItem() {
            Image(item)
              .width('100%')
              .height(100)
              .borderRadius(12)
              .objectFit(ImageFit.Cover)
          }
        }, (item: string, index: number) => `${item}_${index}`)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .width('100%')
    }
  }
}
