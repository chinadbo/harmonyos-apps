import { GalleryVideoItem } from '../model/VideoModel';
import { AppStyles } from '../common/styles';
import { formatDuration } from '../common/utils';

@Component
@Reusable
export struct VideoThumbnail {
  @Prop video: GalleryVideoItem;
  @Prop onToggle: (uri: string) => void = () => {};
  @State private showPreviewFlag: boolean = false;

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(this.video.thumbnailUri)
        .width('100%')
        .height(118)
        .borderRadius(AppStyles.radius.md)
        .objectFit(ImageFit.Cover)

      if (this.showPreviewFlag) {
        Column({ space: 6 }) {
          Text('Preview')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFFFF')
          Text('3-second quick view')
            .fontSize(10)
            .fontColor('#FFE2E8F0')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('rgba(15,23,42,0.55)')
        .borderRadius(AppStyles.radius.md)
      }

      Row() {
        Text(formatDuration(this.video.durationMs))
          .fontSize(11)
          .fontColor('#FFFFFFFF')
          .backgroundColor('rgba(15,23,42,0.68)')
          .borderRadius(AppStyles.radius.pill)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        Blank()
        Text(this.video.selected ? 'Selected' : 'Preview')
          .fontSize(11)
          .fontColor('#FFFFFFFF')
          .backgroundColor(this.video.selected ? AppStyles.colors.brandPrimary : 'rgba(15,23,42,0.68)')
          .borderRadius(AppStyles.radius.pill)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .onClick(() => this.preview())
      }
      .width('100%')
      .padding(8)
    }
    .padding(6)
    .backgroundColor(this.video.selected ? '#332563EB' : AppStyles.colors.surfaceAlt)
    .borderRadius(AppStyles.radius.md)
    .border({ width: this.video.selected ? 1.5 : 1, color: this.video.selected ? AppStyles.colors.brandPrimary : AppStyles.colors.border })
    .onClick(() => this.onToggle(this.video.uri))
  }

  private preview(): void {
    this.showPreviewFlag = true;
    setTimeout(() => {
      this.showPreviewFlag = false;
    }, 3000);
  }
}
