import { Feed } from '../model/Feed';

/**
 * 订阅源卡片组件
 * @Reusable 优化列表滚动性能
 */
@Reusable
@Component
export struct FeedItem {
  @State feed: Feed = new Feed();
  onTap: (feed: Feed) => void = () => {};
  onLongPress: (feed: Feed) => void = () => {};

  aboutToReuse(params: Record<string, Object>): void {
    this.feed = params['feed'] as Feed;
  }

  build() {
    Row({ space: 12 }) {
      // Feed 图标
      Image(this.feed.iconUrl || $r('sys.media.ohos_ic_public_news'))
        .width(40)
        .height(40)
        .borderRadius(8)
        .backgroundColor($r('app.color.primary_light'))
        .objectFit(ImageFit.Cover)
        .onError(() => {}) // 图标加载失败静默处理

      // Feed 信息
      Column({ space: 4 }) {
        Row() {
          Text(this.feed.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          // 未读数角标
          if (this.feed.unreadCount > 0) {
            Text(this.feed.unreadCount > 99 ? '99+' : String(this.feed.unreadCount))
              .fontSize(11)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.primary_color'))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(10)
              .margin({ left: 8 })
          }
        }
        .width('100%')

        Text(this.feed.description || this.feed.url)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.feed.getLastUpdatedDisplay())
          .fontSize(11)
          .fontColor($r('app.color.text_hint'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 右箭头
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(16)
        .height(16)
        .opacity(0.4)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor($r('app.color.card_background'))
    .onClick(() => this.onTap(this.feed))
    .gesture(
      LongPressGesture()
        .onAction(() => this.onLongPress(this.feed))
    )
  }
}
