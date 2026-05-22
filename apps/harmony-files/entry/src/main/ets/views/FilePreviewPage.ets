import { FileItem } from '../model/FileItem'
import { FileService } from '../service/FileService'
import { IMAGE_EXTENSIONS, CODE_EXTENSIONS } from '../model/FileConstants'

@Component
export struct FilePreviewPage {
  @Prop file: FileItem
  @Prop navStack: NavPathStack
  @State textContent: string = ''
  @State isLoading: boolean = true
  @State errorMsg: string = ''

  aboutToAppear(): void {
    if (IMAGE_EXTENSIONS.includes(this.file.extension)) {
      this.isLoading = false
    } else if (CODE_EXTENSIONS.includes(this.file.extension) || this.file.extension === 'txt') {
      FileService.getInstance().readTextFile(this.file.path)
        .then((content: string) => {
          this.textContent = content
          this.isLoading = false
        })
        .catch((err: Error) => {
          this.errorMsg = err.message
          this.isLoading = false
        })
    } else {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      Row() {
        Text('<').fontSize(24).fontColor('#007DFF').onClick(() => this.navStack.pop())
        Text(this.file.name)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 12 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      if (this.isLoading) {
        LoadingProgress().width(40).height(40).margin('auto')
      } else if (IMAGE_EXTENSIONS.includes(this.file.extension)) {
        Image(this.file.path)
          .objectFit(ImageFit.Contain)
          .width('100%')
          .layoutWeight(1)
      } else if (this.textContent.length > 0) {
        Scroll() {
          Text(this.textContent)
            .fontSize(13)
            .fontFamily('monospace')
            .padding(16)
            .width('100%')
        }.layoutWeight(1)
      } else {
        Column() {
          Text('🚫').fontSize(48)
          Text('Cannot preview this file type')
            .fontSize(15)
            .fontColor('#666666')
            .margin({ top: 12 })
          Text('Extension: .' + this.file.extension)
            .fontSize(13)
            .fontColor('#999999')
            .margin({ top: 6 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}
