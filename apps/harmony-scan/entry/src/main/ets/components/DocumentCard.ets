import { DocumentModel } from '../model/DocumentModel';

@Component
export struct DocumentCard {
  @Prop document: DocumentModel = {
    id: 0,
    name: '',
    createdAt: '',
    pageCount: 0,
    thumbnailPath: '',
    pdfPath: '',
    pages: []
  };
  @Prop onClick: () => void = () => {};

  private formatDate(value: string): string {
    const date = new Date(value);
    const year = date.getFullYear();
    const month = `${date.getMonth() + 1}`.padStart(2, '0');
    const day = `${date.getDate()}`.padStart(2, '0');
    const hour = `${date.getHours()}`.padStart(2, '0');
    const minute = `${date.getMinutes()}`.padStart(2, '0');
    return `${year}-${month}-${day} ${hour}:${minute}`;
  }

  build() {
    Row({ space: 14 }) {
      if (this.document.thumbnailPath.length > 0) {
        Image(this.document.thumbnailPath)
          .width(88)
          .height(112)
          .borderRadius(14)
          .objectFit(ImageFit.Cover)
          .backgroundColor('#F2F3F5')
      } else {
        Column() {
          Text('DOC')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#7A5AF8')
        }
        .width(88)
        .height(112)
        .borderRadius(14)
        .backgroundColor('#EEF2FF')
        .justifyContent(FlexAlign.Center)
      }

      Column({ space: 8 }) {
        Text(this.document.name)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#222222')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.formatDate(this.document.createdAt))
          .fontSize(13)
          .fontColor('#666666')
        Row({ space: 8 }) {
          Text(`${this.document.pageCount} 页`)
            .fontSize(13)
            .fontColor('#4F46E5')
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor('#EEF2FF')
            .borderRadius(12)
          if (this.document.pdfPath.length > 0) {
            Text('已导出 PDF')
              .fontSize(13)
              .fontColor('#047857')
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .backgroundColor('#ECFDF5')
              .borderRadius(12)
          }
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({ radius: 12, color: '#12000000', offsetX: 0, offsetY: 4 })
    .onClick(() => this.onClick())
  }
}
