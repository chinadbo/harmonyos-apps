import { FileItem } from '../model/FileItem';
import { formatFileSize } from '../utils/FileSizeFormatter';
import { formatDate } from '../utils/DateFormatter';

@Component
export struct FileDetailSheet {
  @State file: FileItem = {
    name: '',
    path: '',
    isDirectory: false,
    size: 0,
    mtime: 0,
    extension: '',
    mimeType: '',
    iconType: ''
  };
  @State isVisible: boolean = false;

  showDetail(f: FileItem): void {
    this.file = f;
    this.isVisible = true;
  }

  @Builder
  sheetContent() {
    Column({ space: 12 }) {
      Text(this.file.name)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)

      Row() {
        Text('Path')
          .fontSize(14)
          .fontColor('#999999')
          .width(80)
        Text(this.file.path)
          .fontSize(14)
          .flexGrow(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
      }
      .width('100%')

      Row() {
        Text('Size')
          .fontSize(14)
          .fontColor('#999999')
          .width(80)
        Text(formatFileSize(this.file.size))
          .fontSize(14)
          .flexGrow(1)
      }
      .width('100%')

      Row() {
        Text('Modified')
          .fontSize(14)
          .fontColor('#999999')
          .width(80)
        Text(formatDate(this.file.mtime))
          .fontSize(14)
          .flexGrow(1)
      }
      .width('100%')

      Row() {
        Text('Type')
          .fontSize(14)
          .fontColor('#999999')
          .width(80)
        Text(this.file.isDirectory ? 'folder' : (this.file.extension || 'file'))
          .fontSize(14)
          .flexGrow(1)
      }
      .width('100%')
    }
    .padding(16)
    .width('100%')
    .height(300)
  }

  build() {
    Column() {
      Button('Details')
        .onClick(() => {
          this.isVisible = true;
        })
    }
    .bindSheet($$this.isVisible, this.sheetContent(), {
      height: 300,
      showClose: true,
      onDisappear: () => {
        this.isVisible = false;
      }
    })
  }
}
