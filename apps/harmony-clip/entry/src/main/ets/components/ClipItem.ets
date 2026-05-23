import { ClipEntry } from '../model/ClipEntry';
import { TypeBadge } from './TypeBadge';
import { ClipDetector } from '../service/ClipDetector';

@Component
export struct ClipItem {
  @Prop entry: ClipEntry = {
    id: 0,
    content: '',
    type: 'text' as any,
    isPrivate: false,
    isFavorite: false,
    createTime: 0,
    previewText: '',
  };
  onFavoriteToggle: (id: number, current: boolean) => void = () => {};
  onCopy: (content: string) => void = () => {};

  build() {
    Row({ space: 0 }) {
      Column({ space: 6 }) {
        Row({ space: 8 }) {
          TypeBadge({ type: this.entry.type, isPrivate: this.entry.isPrivate })

          Blank()

          Text(ClipDetector.formatRelativeTime(this.entry.createTime))
            .fontSize(11)
            .fontColor('#99182431')
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Text(this.entry.isPrivate ? '●●● 隐私内容 ●●●' : this.entry.previewText)
          .fontSize(14)
          .fontColor(this.entry.isPrivate ? '#99182431' : '#182431')
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .fontStyle(this.entry.isPrivate ? FontStyle.Italic : FontStyle.Normal)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding({ right: 8 })

      Column() {
        Image(this.entry.isFavorite
          ? $r('sys.media.ohos_ic_public_favor_filled')
          : $r('sys.media.ohos_ic_public_favor'))
          .width(22)
          .height(22)
          .fillColor(this.entry.isFavorite ? '#FFB300' : '#99182431')
          .onClick(() => {
            this.onFavoriteToggle(this.entry.id, this.entry.isFavorite);
          })
      }
      .width(36)
      .height(36)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding({ left: 16, right: 12, top: 14, bottom: 14 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .onClick(() => {
      this.onCopy(this.entry.content);
    })
  }
}
