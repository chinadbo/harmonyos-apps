import { MindMapMeta } from '../models/MindMap';

@Component
export struct MindCard {
  @Prop item: MindMapMeta;
  @Prop isDarkMode: boolean;
  onOpen?: (id: string) => void;
  onDelete?: (item: MindMapMeta) => void;

  private formatTime(timestamp: number): string {
    try {
      const date: Date = new Date(timestamp);
      const year: string = `${date.getFullYear()}`;
      const month: string = `${date.getMonth() + 1}`.padStart(2, '0');
      const day: string = `${date.getDate()}`.padStart(2, '0');
      const hours: string = `${date.getHours()}`.padStart(2, '0');
      const minutes: string = `${date.getMinutes()}`.padStart(2, '0');
      return `${year}-${month}-${day} ${hours}:${minutes}`;
    } catch (error) {
      return '时间未知';
    }
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text(this.item.title)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isDarkMode ? '#FFF4F7FB' : '#FF1F2530')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Blank()
        Button('删除')
          .fontSize(14)
          .backgroundColor('#FFE14D4D')
          .onClick(() => {
            if (this.onDelete) {
              this.onDelete(this.item);
            }
          })
      }
      .width('100%')

      Text(`节点数量：${this.item.nodeCount}`)
        .fontSize(14)
        .fontColor(this.isDarkMode ? '#FFB5C0D0' : '#FF5E6A79')

      Text(`最近修改：${this.formatTime(this.item.updatedAt)}`)
        .fontSize(14)
        .fontColor(this.isDarkMode ? '#FFB5C0D0' : '#FF5E6A79')

      Row() {
        Blank()
        Button('打开脑图')
          .fontSize(15)
          .backgroundColor('#FF5B8FF9')
          .onClick(() => {
            if (this.onOpen) {
              this.onOpen(this.item.id);
            }
          })
      }
      .width('100%')
    }
    .padding(16)
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.isDarkMode ? '#FF1E2630' : '#FFFFFFFF')
    .borderRadius(20)
    .shadow({ radius: 12, color: '#22000000', offsetX: 0, offsetY: 6 })
  }
}
