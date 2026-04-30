import { Article } from '../model/Article';

/**
 * 文章卡片组件
 * @Reusable 优化列表滚动性能
 * 支持左滑操作（标记已读、收藏）
 */
@Reusable
@Component
export struct ArticleCard {
  @State article: Article = new Article();
  onTap: (article: Article) => void = () => {};
  onMarkRead: (article: Article) => void = () => {};
  onToggleBookmark: (article: Article) => void = () => {};

  aboutToReuse(params: Record<string, Object>): void {
    this.article = params['article'] as Article;
  }

  @Builder
  SwipeActions() {
    Row() {
      // 收藏按钮
      Button() {
        Column({ space: 4 }) {
          Image(this.article.isBookmarked
            ? $r('sys.media.ohos_ic_public_collect_filled')
            : $r('sys.media.ohos_ic_public_collect'))
            .width(22)
            .height(22)
            .fillColor(Color.White)
          Text(this.article.isBookmarked ? '取消收藏' : '收藏')
            .fontSize(10)
            .fontColor(Color.White)
        }
      }
      .width(64)
      .height('100%')
      .backgroundColor('#FF9800')
      .borderRadius(0)
      .onClick(() => this.onToggleBookmark(this.article))

      // 标记已读按钮
      if (!this.article.isRead) {
        Button() {
          Column({ space: 4 }) {
            Image($r('sys.media.ohos_ic_public_ok'))
              .width(22)
              .height(22)
              .fillColor(Color.White)
            Text('已读')
              .fontSize(10)
              .fontColor(Color.White)
          }
        }
        .width(64)
        .height('100%')
        .backgroundColor($r('app.color.primary_color'))
        .borderRadius(0)
        .onClick(() => this.onMarkRead(this.article))
      }
    }
  }

  build() {
    ListItem() {
      Column() {
        Row({ space: 12 }) {
          // 未读指示器
          if (!this.article.isRead) {
            Circle({ width: 8, height: 8 })
              .fill($r('app.color.primary_color'))
              .flexShrink(0)
          } else {
            Circle({ width: 8, height: 8 })
              .fill(Color.Transparent)
              .flexShrink(0)
          }

          Column({ space: 6 }) {
            // 来源和时间
            Row() {
              Text(this.article.feedTitle)
                .fontSize(11)
                .fontColor($r('app.color.primary_color'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)

              Text(this.article.getPublishedDisplay())
                .fontSize(11)
                .fontColor($r('app.color.text_hint'))
                .flexShrink(0)
            }
            .width('100%')

            // 文章标题
            Text(this.article.title)
              .fontSize(15)
              .fontWeight(this.article.isRead ? FontWeight.Normal : FontWeight.Medium)
              .fontColor(this.article.isRead ? $r('app.color.read_text') : $r('app.color.text_primary'))
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .lineHeight(22)

            // 摘要
            if (this.article.getSummaryText()) {
              Text(this.article.getSummaryText())
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .lineHeight(20)
            }

            // 作者
            if (this.article.author) {
              Text(this.article.author)
                .fontSize(11)
                .fontColor($r('app.color.text_hint'))
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          // 收藏图标
          if (this.article.isBookmarked) {
            Image($r('sys.media.ohos_ic_public_collect_filled'))
              .width(16)
              .height(16)
              .fillColor('#FF9800')
              .flexShrink(0)
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })

        Divider()
          .strokeWidth(0.5)
          .color($r('app.color.divider_color'))
          .margin({ left: 36 })
      }
    }
    .swipeAction({ end: this.SwipeActions() })
    .onClick(() => this.onTap(this.article))
  }
}
