import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Article, ArticleDataSource } from '../model/Article';
import { ArticleCard } from '../components/ArticleCard';
import { EmptyState } from '../components/EmptyState';
import { ArticleService } from '../service/ArticleService';

/**
 * 文章列表页面
 * 支持指定 Feed 的文章列表，或全部文章
 * LazyForEach + @Reusable 实现高性能列表
 */
@Component
export struct ArticleListPage {
  @Prop feedId: number = -1;      // -1 表示全部
  @Prop feedTitle: string = '文章';
  @State isLoading: boolean = false;
  @State filter: 'all' | 'unread' | 'bookmarked' = 'all';
  private dataSource: ArticleDataSource = new ArticleDataSource();
  private articleService = ArticleService.getInstance();

  aboutToAppear(): void {
    this.loadArticles();
  }

  async loadArticles(): Promise<void> {
    this.isLoading = true;
    try {
      let articles: Article[] = [];
      if (this.filter === 'bookmarked') {
        articles = await this.articleService.getBookmarkedArticles();
      } else if (this.filter === 'unread') {
        articles = await this.articleService.getUnreadArticles();
      } else if (this.feedId > 0) {
        articles = await this.articleService.getArticlesByFeed(this.feedId);
      } else {
        articles = await this.articleService.getAllArticles();
      }
      this.dataSource.setArticles(articles);
    } catch (err) {
      console.error('[ArticleListPage] loadArticles error:', JSON.stringify(err));
    } finally {
      this.isLoading = false;
    }
  }

  async handleMarkRead(article: Article): Promise<void> {
    await this.articleService.markRead(article.id);
    article.isRead = true;
    this.dataSource.notifyDataChange(
      this.dataSource.totalCount() - 1 // 触发列表刷新
    );
  }

  async handleToggleBookmark(article: Article): Promise<void> {
    const newState = await this.articleService.toggleBookmark(article);
    promptAction.showToast({
      message: newState ? '已收藏' : '已取消收藏'
    });
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        if (this.feedId > 0) {
          Button() {
            Image($r('sys.media.ohos_ic_public_back'))
              .width(20)
              .height(20)
              .fillColor($r('app.color.text_primary'))
          }
          .width(36)
          .height(36)
          .backgroundColor(Color.Transparent)
          .onClick(() => router.back())
        }

        Text(this.feedTitle)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .padding({ left: this.feedId > 0 ? 0 : 16 })

        // 搜索按钮
        Button() {
          Image($r('sys.media.ohos_ic_public_search'))
            .width(20)
            .height(20)
            .fillColor($r('app.color.text_secondary'))
        }
        .width(36)
        .height(36)
        .backgroundColor(Color.Transparent)
        .onClick(() => router.pushUrl({ url: 'pages/SearchPage' }))

        // 全部已读
        Button() {
          Image($r('sys.media.ohos_ic_public_ok'))
            .width(20)
            .height(20)
            .fillColor($r('app.color.text_secondary'))
        }
        .width(36)
        .height(36)
        .backgroundColor(Color.Transparent)
        .onClick(async () => {
          await this.articleService.markAllRead(this.feedId > 0 ? this.feedId : undefined);
          await this.loadArticles();
          promptAction.showToast({ message: '已全部标为已读' });
        })
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 12, bottom: 8 })

      // 过滤器 Chips
      Row({ space: 8 }) {
        ForEach(
          [
            { key: 'all', label: '全部' },
            { key: 'unread', label: '未读' },
            { key: 'bookmarked', label: '收藏' },
          ],
          (item: { key: string; label: string }) => {
            Text(item.label)
              .fontSize(13)
              .fontColor(this.filter === item.key ? Color.White : $r('app.color.text_secondary'))
              .backgroundColor(this.filter === item.key ? $r('app.color.primary_color') : $r('app.color.surface_color'))
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .borderRadius(16)
              .onClick(() => {
                this.filter = item.key as 'all' | 'unread' | 'bookmarked';
                this.loadArticles();
              })
          },
          (item: { key: string }) => item.key
        )
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })

      // 内容区
      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color($r('app.color.primary_color'))
          .layoutWeight(1)
          .margin({ top: 60 })
      } else if (this.dataSource.totalCount() === 0) {
        EmptyState({ message: '暂无文章' })
      } else {
        List() {
          LazyForEach(this.dataSource, (article: Article) => {
            ArticleCard({
              article,
              onTap: (a: Article) => {
                this.articleService.markRead(a.id);
                a.isRead = true;
                router.pushUrl({
                  url: 'pages/ArticleReaderPage',
                  params: {
                    articleId: a.id,
                    articleTitle: a.title,
                    articleLink: a.link,
                    articleContent: a.content || a.summary,
                  }
                });
              },
              onMarkRead: (a: Article) => this.handleMarkRead(a),
              onToggleBookmark: (a: Article) => this.handleToggleBookmark(a),
            })
          }, (article: Article) => String(article.id))
        }
        .listDirection(Axis.Vertical)
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.surface_color'))
  }
}
