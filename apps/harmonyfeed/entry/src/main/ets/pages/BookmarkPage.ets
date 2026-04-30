import router from '@ohos.router';
import { Article, ArticleDataSource } from '../model/Article';
import { ArticleCard } from '../components/ArticleCard';
import { EmptyState } from '../components/EmptyState';
import { ArticleService } from '../service/ArticleService';

/**
 * 收藏页面
 * 展示所有已收藏文章，支持离线阅读
 */
@Component
export struct BookmarkPage {
  @State isLoading: boolean = false;
  private dataSource: ArticleDataSource = new ArticleDataSource();
  private articleService = ArticleService.getInstance();

  aboutToAppear(): void {
    this.loadBookmarks();
  }

  async loadBookmarks(): Promise<void> {
    this.isLoading = true;
    try {
      const articles = await this.articleService.getBookmarkedArticles();
      this.dataSource.setArticles(articles);
    } catch (err) {
      console.error('[BookmarkPage] load error:', JSON.stringify(err));
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Text('收藏')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)

        if (this.dataSource.totalCount() > 0) {
          Text(`共 ${this.dataSource.totalCount()} 篇`)
            .fontSize(13)
            .fontColor($r('app.color.text_hint'))
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      // 列表
      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color($r('app.color.primary_color'))
          .layoutWeight(1)
          .margin({ top: 60 })
      } else if (this.dataSource.totalCount() === 0) {
        EmptyState({
          message: '还没有收藏文章\n在文章列表左滑可以收藏',
        })
      } else {
        List() {
          LazyForEach(this.dataSource, (article: Article) => {
            ArticleCard({
              article,
              onTap: (a: Article) => {
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
              onMarkRead: async (a: Article) => {
                await this.articleService.markRead(a.id);
                a.isRead = true;
              },
              onToggleBookmark: async (a: Article) => {
                await this.articleService.toggleBookmark(a);
                // 取消收藏后从列表移除
                if (!a.isBookmarked) {
                  await this.loadBookmarks();
                }
              },
            })
          }, (article: Article) => String(article.id))
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.surface_color'))
  }
}
