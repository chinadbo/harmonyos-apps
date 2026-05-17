import { Notebook, formatTime } from '../model/NoteModel';

@Component
export struct NotebookCard {
  @Prop notebook: Notebook;
  @Prop selected: boolean = false;
  onClick?: (notebook: Notebook) => void;

  build() {
    Column({ space: 10 }) {
      Row() {
        Text(this.notebook.name)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.selected ? '#FFFFFF' : '#111827')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Blank()
        Text(`${this.notebook.noteCount} 篇`)
          .fontSize(12)
          .fontColor(this.selected ? '#DBEAFE' : '#6B7280')
      }
      .width('100%')

      if (this.notebook.description.length > 0) {
        Text(this.notebook.description)
          .fontSize(13)
          .fontColor(this.selected ? '#E5E7EB' : '#6B7280')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(18)
      } else {
        Text('暂无分类描述')
          .fontSize(13)
          .fontColor(this.selected ? '#E5E7EB' : '#9CA3AF')
      }

      Row() {
        Text('更新于 ' + formatTime(this.notebook.updatedAt))
          .fontSize(12)
          .fontColor(this.selected ? '#DBEAFE' : '#9CA3AF')
        Blank()
        Text(this.selected ? '当前' : '查看')
          .fontSize(12)
          .fontColor(this.selected ? '#FFFFFF' : '#2563EB')
      }
      .width('100%')
    }
    .padding(16)
    .width('100%')
    .backgroundColor(this.selected ? '#2563EB' : '#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 10, color: '#12000000', offsetX: 0, offsetY: 4 })
    .onClick(() => {
      if (this.onClick) {
        this.onClick(this.notebook);
      }
    })
  }
}
