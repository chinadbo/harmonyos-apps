import { FileItem } from '../../model/FileItem';

function getIconEmoji(iconType: string): string {
  if (iconType === 'folder') return '📁';
  if (iconType === 'image') return '🖼';
  if (iconType === 'video') return '🎬';
  if (iconType === 'audio') return '🎵';
  if (iconType === 'pdf') return '📄';
  if (iconType === 'word') return '📝';
  if (iconType === 'excel') return '📊';
  if (iconType === 'ppt') return '📋';
  if (iconType === 'code') return '💻';
  if (iconType === 'archive') return '🗜';
  return '📎';
}

function formatSize(bytes: number): string {
  if (bytes < 1024) return bytes + ' B';
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
  if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  return (bytes / (1024 * 1024 * 1024)).toFixed(1) + ' GB';
}

function formatDate(mtime: number): string {
  const d = new Date(mtime);
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

@Reusable
@Component
export struct FileListItem {
  @Prop item: FileItem;
  @Prop isSelected: boolean;
  @Prop onTap: () => void;
  @Prop onLongPress: () => void;

  aboutToReuse(params: Record<string, Object>): void {
    this.item = params['item'] as FileItem;
    this.isSelected = params['isSelected'] as boolean;
  }

  build() {
    Row() {
      if (this.isSelected) {
        Text('☑')
          .fontSize(20)
          .margin({ right: 8 })
      }

      Text(getIconEmoji(this.item.iconType))
        .fontSize(28)
        .margin({ right: 12 })

      Column() {
        Row() {
          Text(this.item.name)
            .fontSize(15)
            .fontColor('#1a1a1a')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          if (this.item.extension) {
            Text(this.item.extension.toUpperCase())
              .fontSize(11)
              .fontColor('#888')
              .margin({ left: 4 })
          }
        }
        .width('100%')

        Row() {
          Text(this.item.isDirectory ? '--' : formatSize(this.item.size))
            .fontSize(12)
            .fontColor('#999')

          Text(formatDate(this.item.mtime))
            .fontSize(12)
            .fontColor('#999')
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('>')
        .fontSize(16)
        .fontColor('#ccc')
        .margin({ left: 8 })
    }
    .width('100%')
    .height(60)
    .padding({ left: 12, right: 12 })
    .backgroundColor(Color.White)
    .border({ width: { bottom: 0.5 }, color: '#e8e8e8', style: BorderStyle.Solid })
    .alignItems(VerticalAlign.Center)
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        TapGesture()
          .onAction(() => {
            this.onTap();
          }),
        LongPressGesture()
          .onAction(() => {
            this.onLongPress();
          })
      )
    )
  }
}
