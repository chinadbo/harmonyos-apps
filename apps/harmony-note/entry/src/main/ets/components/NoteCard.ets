import { NoteIndexItem, formatTime } from '../model/NoteModel';

@Component
export struct NoteCard {
  @Prop note: NoteIndexItem;
  @Prop notebookName: string = '';
  onClick?: (note: NoteIndexItem) => void;
  onDelete?: (note: NoteIndexItem) => void;

  build() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 6 }) {
          Text(this.note.title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor('#1F2937')

          if (this.note.preview.length > 0) {
            Text(this.note.preview)
              .fontSize(14)
              .fontColor('#6B7280')
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .lineHeight(20)
          } else {
            Text('暂无摘要')
              .fontSize(14)
              .fontColor('#9CA3AF')
          }
        }
        .layoutWeight(1)

        Button('删除')
          .type(ButtonType.Capsule)
          .fontSize(12)
          .backgroundColor('#FDECEC')
          .fontColor('#D14343')
          .onClick(() => {
            if (this.onDelete) {
              this.onDelete(this.note);
            }
          })
      }
      .alignItems(VerticalAlign.Top)
      .width('100%')

      Row({ space: 12 }) {
        Text(this.notebookName.length > 0 ? this.notebookName : '未分类')
          .fontSize(12)
          .fontColor('#4B5563')
          .backgroundColor('#EEF2FF')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .borderRadius(999)

        Text(`${this.note.wordCount} 字`)
          .fontSize(12)
          .fontColor('#6B7280')

        Blank()

        Text(formatTime(this.note.updatedAt))
          .fontSize(12)
          .fontColor('#9CA3AF')
      }
      .width('100%')
    }
    .padding(16)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 12, color: '#14000000', offsetX: 0, offsetY: 4 })
    .onClick(() => {
      if (this.onClick) {
        this.onClick(this.note);
      }
    })
  }
}
