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

@Reusable
@Component
export struct GridFileItem {
  @Prop item: FileItem;
  @Prop isSelected: boolean;
  @Prop onTap: () => void;
  @Prop onLongPress: () => void;

  aboutToReuse(params: Record<string, Object>): void {
    this.item = params['item'] as FileItem;
    this.isSelected = params['isSelected'] as boolean;
  }

  build() {
    Stack() {
      Column() {
        Text(getIconEmoji(this.item.iconType))
          .fontSize(40)
          .margin({ bottom: 6 })

        Text(this.item.name)
          .fontSize(13)
          .fontColor('#1a1a1a')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Center)
          .width('100%')

        Text(this.item.isDirectory ? '--' : formatSize(this.item.size))
          .fontSize(11)
          .fontColor('#999')
          .margin({ top: 2 })
      }
      .width('100%')
      .height(120)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .padding(8)
      .backgroundColor(Color.White)
      .borderRadius(8)

      if (this.isSelected) {
        Column()
          .width('100%')
          .height(120)
          .borderRadius(8)
          .border({ width: 2, color: '#007DFF', style: BorderStyle.Solid })
          .backgroundColor('rgba(0, 125, 255, 0.08)')
      }
    }
    .width('100%')
    .height(120)
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
