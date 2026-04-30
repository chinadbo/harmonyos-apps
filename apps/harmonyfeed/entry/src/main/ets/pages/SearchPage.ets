import router from '@ohos.router';
import { Article, ArticleDataSource } from '../model/Article';
import { ArticleCard } from '../components/ArticleCard';
import { EmptyState } from '../components/EmptyState';
import { ArticleService } from '../service/ArticleService';
import { Constants } from '../utils/Constants';

/**
 * 搜索页面
 * 支持文章标题/内容全文搜索，实时结果（防抖 300ms）
 */
@Entry
@Component
struct SearchPage {
  @State keyword: string = '';
  @State isSearching: boolean = false;
  @State hasSearched: boolean = false;
  private dataSource: ArticleDataSource = new ArticleDataSource();
  private articleService = ArticleService.getInstance();
  private debounceTimer: number = -1;

  build() {
    Column() {
      // 搜索栏
      Row({ space: 8 }) {
        Button() {
          Image($r('sys.media.ohos_ic_public_back'))
            .width(18)
            .height(18)
            .fillColor($r('app.color.text_primary'))
        }
        .width(36)
        .height(36)
        .backgroundColor(Color.Transparent)
        .onClick(() => router.back())

        Search({
          value: this.keyword,
          placeholder: '搜索文章标题、内容...',
        })
          .layoutWeight(1)
          .searchButton('搜索')
          .onChange((val) => {
            this.keyword = val;
            // 防抖搜索
            if (this.debounceTimer !== -1) {
              clearTimeout(this.debounceTimer);
            }
            if (val.trim().length >= 2) {
              this.debounceTimer = setTimeout(() => {
                this.doSearch(val.trim());
              }, Constants.SEARCH_DEBOUNCE_MS);
            } else if (val.trim().length === 0) {
              this.dataSource.setArticles([]);
              this.hasSearched = false;
            }
          })
          .onSubmit((val) => {
            if (val.trim()) {
              if (this.debounceTimer !== -1) clearTimeout(this.debounceTimer);
              this.doSearch(val.trim());
            }
          })
      }
      .width('100%')
      .padding({ left: 4, right: 8, top: 8, bottom: 8 })
      .backgroundColor(Color.White)

      Divider()
        .strokeWidth(0.5)
        .color($r('app.color.divider_color'))

      // 结果区域
      if (!this.hasSearched) {
        Column({ space: 12 }) {
          Image($r('sys.media.ohos_ic_public_search'))
            .width(60)
            .height(60)
            .opacity(0.2)
          Text('输入关键词搜索文章')
            .fontSize(15)
            .fontColor($r('app.color.text_hint'))
          Text('最少输入 2 个字符')
            .fontSize(13)
            .fontColor($r('app.color.text_hint'))
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.isSearching) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color($r('app.color.primary_color'))
          .layoutWeight(1)
          .margin({ top: 60 })
      } else if (this.dataSource.totalCount() === 0) {
        EmptyState({ message: `未找到含"${this.keyword}"的文章` })
      } else {
        Column({ space: 0 }) {
          Text(`找到 ${this.dataSource.totalCount()} 篇文章`)
            .fontSize(12)
            .fontColor($r('app.color.text_hint'))
            .width('100%')
            .padding({ left: 16, top: 8, bottom: 4 })

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
                onMarkRead: () => {},
                onToggleBookmark: () => {},
              })
            }, (article: Article) => String(article.id))
          }
          .scrollBar(BarState.Off)
          .layoutWeight(1)
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.surface_color'))
  }

  private async doSearch(keyword: string): Promise<void> {
    this.isSearching = true;
    this.hasSearched = true;
    try {
      const results = await this.articleService.searchArticles(keyword);
      this.dataSource.setArticles(results);
    } catch (err) {
      console.error('[SearchPage] search error:', JSON.stringify(err));
    } finally {
      this.isSearching = false;
    }
  }
}
