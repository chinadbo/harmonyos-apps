import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import web_webview from '@ohos.web.webview';
import { ArticleService } from '../service/ArticleService';
import { Article } from '../model/Article';

/**
 * 文章阅读页面（核心功能页）
 * 使用 Web 组件渲染文章内容
 * 支持：字体调节、夜间模式、收藏、分享、查看原文
 * 利用 Reader Kit 风格的沉浸式阅读体验
 */
@Entry
@Component
struct ArticleReaderPage {
  @State articleId: number = 0;
  @State articleTitle: string = '';
  @State articleLink: string = '';
  @State articleContent: string = '';
  @State isBookmarked: boolean = false;
  @State isDarkMode: boolean = false;
  @State fontSize: number = 16;
  @State showToolbar: boolean = true;
  @State isLoading: boolean = true;
  @State readProgress: number = 0;

  private webController: web_webview.WebviewController = new web_webview.WebviewController();
  private articleService = ArticleService.getInstance();
  private hideToolbarTimer: number = -1;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    this.articleId = Number(params['articleId']) || 0;
    this.articleTitle = String(params['articleTitle'] || '');
    this.articleLink = String(params['articleLink'] || '');
    this.articleContent = String(params['articleContent'] || '');
  }

  aboutToDisappear(): void {
    if (this.hideToolbarTimer !== -1) {
      clearTimeout(this.hideToolbarTimer);
    }
    // 保存阅读进度
    if (this.articleId > 0) {
      this.articleService.markRead(this.articleId, this.readProgress);
    }
  }

  /**
   * HTML 内容安全过滤（防 XSS）
   * 移除 <script>/<iframe>/<object>/<embed> 及所有 on* 事件属性
   */
  sanitizeHtml(html: string): string {
    if (!html) return '';
    return html
      // 移除 script 标签及内容
      .replace(/<script[\s\S]*?<\/script>/gi, '')
      // 移除 iframe/object/embed/applet 标签
      .replace(/<(iframe|object|embed|applet|meta|base)[^>]*>[\s\S]*?<\/\1>/gi, '')
      .replace(/<(iframe|object|embed|applet|meta|base)[^>]*\/>/gi, '')
      // 移除 on* 事件属性（onclick、onload 等）
      .replace(/\s+on\w+\s*=\s*["'][^"']*["']/gi, '')
      .replace(/\s+on\w+\s*=\s*[^\s>]*/gi, '')
      // 移除 javascript: 协议链接
      .replace(/href\s*=\s*["']javascript:[^"']*["']/gi, 'href="#"')
      .replace(/src\s*=\s*["']javascript:[^"']*["']/gi, 'src=""');
  }

  /** 构建沉浸式阅读 HTML */
  buildReaderHtml(): string {
    const bgColor = this.isDarkMode ? '#1a1a1a' : '#ffffff';
    const textColor = this.isDarkMode ? '#e0e0e0' : '#1a1a1a';
    const linkColor = this.isDarkMode ? '#82b1ff' : '#2979FF';
    const codeColor = this.isDarkMode ? '#2d2d2d' : '#f5f5f5';

    // 对 RSS 内容进行 XSS 过滤后渲染
    const rawContent = this.articleContent || '<p style="color:#999">暂无正文内容，请点击"查看原文"阅读。</p>';
    const content = this.sanitizeHtml(rawContent);

    return `<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    background: ${bgColor};
    color: ${textColor};
    font-size: ${this.fontSize}px;
    font-family: -apple-system, 'PingFang SC', 'Microsoft YaHei', sans-serif;
    line-height: 1.75;
    padding: 20px 18px 60px;
    word-break: break-word;
    transition: background 0.3s, color 0.3s;
  }
  h1, h2, h3, h4 {
    line-height: 1.4;
    margin: 1.2em 0 0.6em;
    font-weight: 600;
  }
  h1 { font-size: 1.4em; }
  h2 { font-size: 1.2em; }
  h3 { font-size: 1.1em; }
  p { margin: 0.8em 0; }
  a { color: ${linkColor}; text-decoration: none; }
  img {
    max-width: 100%;
    height: auto;
    border-radius: 8px;
    margin: 8px 0;
    display: block;
  }
  code {
    background: ${codeColor};
    padding: 2px 6px;
    border-radius: 4px;
    font-size: 0.9em;
    font-family: 'Courier New', monospace;
  }
  pre {
    background: ${codeColor};
    padding: 12px;
    border-radius: 8px;
    overflow-x: auto;
    margin: 12px 0;
    font-size: 0.85em;
    line-height: 1.5;
  }
  pre code { background: transparent; padding: 0; }
  blockquote {
    border-left: 3px solid ${linkColor};
    padding-left: 16px;
    margin: 12px 0;
    opacity: 0.8;
  }
  hr { border: none; border-top: 1px solid #eee; margin: 16px 0; }
  table { width: 100%; border-collapse: collapse; margin: 12px 0; font-size: 0.9em; }
  th, td { border: 1px solid #ddd; padding: 8px; }
  th { background: ${codeColor}; }
  ul, ol { padding-left: 24px; margin: 8px 0; }
  li { margin: 4px 0; }
  figure { margin: 12px 0; }
  figcaption { font-size: 0.85em; color: #999; text-align: center; margin-top: 4px; }
</style>
</head>
<body>
${content}
<script>
  // 上报阅读进度
  window.addEventListener('scroll', function() {
    var scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
    var scrollHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
    var progress = scrollHeight > 0 ? Math.min(scrollTop / scrollHeight, 1) : 0;
    // 通过标题传递进度（简化方案）
    document.title = 'progress:' + progress.toFixed(2);
  }, { passive: true });
</script>
</body>
</html>`;
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 阅读内容（Web 组件）
      Web({
        src: 'about:blank',
        controller: this.webController
      })
        .width('100%')
        .height('100%')
        .javaScriptAccess(true)
        .domStorageAccess(false)
        .onPageBegin(() => {
          this.isLoading = true;
        })
        .onPageEnd(() => {
          this.isLoading = false;
        })
        .onTitleReceive((event) => {
          // 解析进度（从 title 中读取）
          if (event && event.title.startsWith('progress:')) {
            const p = parseFloat(event.title.replace('progress:', ''));
            if (!isNaN(p)) this.readProgress = p;
          }
        })

      // 顶部工具栏（半透明）
      if (this.showToolbar) {
        Column() {
          Row() {
            Button() {
              Image($r('sys.media.ohos_ic_public_back'))
                .width(20)
                .height(20)
                .fillColor(this.isDarkMode ? Color.White : $r('app.color.text_primary'))
            }
            .width(40)
            .height(40)
            .backgroundColor(Color.Transparent)
            .onClick(() => router.back())

            Text(this.articleTitle)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isDarkMode ? Color.White : $r('app.color.text_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
              .padding({ left: 8, right: 8 })

            // 收藏
            Button() {
              Image(this.isBookmarked
                ? $r('sys.media.ohos_ic_public_collect_filled')
                : $r('sys.media.ohos_ic_public_collect'))
                .width(20)
                .height(20)
                .fillColor('#FF9800')
            }
            .width(40)
            .height(40)
            .backgroundColor(Color.Transparent)
            .onClick(async () => {
              // 持久化收藏状态到数据库
              if (this.articleId > 0) {
                const article = new Article({
                  id: this.articleId,
                  isBookmarked: this.isBookmarked,
                });
                await this.articleService.toggleBookmark(article);
                this.isBookmarked = article.isBookmarked;
              } else {
                this.isBookmarked = !this.isBookmarked;
              }
              promptAction.showToast({
                message: this.isBookmarked ? '已收藏' : '已取消收藏'
              });
            })

            // 更多选项
            Button() {
              Image($r('sys.media.ohos_ic_public_more'))
                .width(20)
                .height(20)
                .fillColor(this.isDarkMode ? Color.White : $r('app.color.text_secondary'))
            }
            .width(40)
            .height(40)
            .backgroundColor(Color.Transparent)
          }
          .width('100%')
          .height(50)
          .padding({ left: 4, right: 4 })
        }
        .width('100%')
        .backgroundColor(this.isDarkMode ? 'rgba(26,26,26,0.92)' : 'rgba(255,255,255,0.92)')
        .backdropBlur(10)
      }

      // 底部工具栏
      if (this.showToolbar) {
        Column() {
          Divider()
            .strokeWidth(0.5)
            .color(this.isDarkMode ? '#333' : $r('app.color.divider_color'))

          Row({ space: 4 }) {
            // 字体缩小
            Button('A-')
              .fontSize(14)
              .fontColor(this.isDarkMode ? Color.White : $r('app.color.text_primary'))
              .backgroundColor(Color.Transparent)
              .padding({ left: 12, right: 12 })
              .onClick(() => {
                if (this.fontSize > 12) this.fontSize -= 1;
                this.refreshContent();
              })

            Text(`${this.fontSize}px`)
              .fontSize(13)
              .fontColor($r('app.color.text_hint'))
              .width(40)
              .textAlign(TextAlign.Center)

            // 字体放大
            Button('A+')
              .fontSize(14)
              .fontColor(this.isDarkMode ? Color.White : $r('app.color.text_primary'))
              .backgroundColor(Color.Transparent)
              .padding({ left: 12, right: 12 })
              .onClick(() => {
                if (this.fontSize < 22) this.fontSize += 1;
                this.refreshContent();
              })

            Blank()

            // 夜间模式
            Button() {
              Image(this.isDarkMode
                ? $r('sys.media.ohos_ic_public_daynight')
                : $r('sys.media.ohos_ic_public_night_mode'))
                .width(20)
                .height(20)
                .fillColor(this.isDarkMode ? '#FFD740' : $r('app.color.text_secondary'))
            }
            .width(44)
            .height(44)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.isDarkMode = !this.isDarkMode;
              this.refreshContent();
            })

            // 查看原文
            Button('原文')
              .fontSize(13)
              .fontColor($r('app.color.primary_color'))
              .backgroundColor($r('app.color.primary_light'))
              .padding({ left: 14, right: 14 })
              .borderRadius(16)
              .onClick(() => {
                if (this.articleLink) {
                  router.pushUrl({
                    url: 'pages/ArticleReaderPage',
                    params: {
                      articleId: 0,
                      articleTitle: this.articleTitle,
                      articleLink: this.articleLink,
                      articleContent: '',
                      isWebMode: true,
                    }
                  });
                }
              })
          }
          .width('100%')
          .height(52)
          .padding({ left: 8, right: 12 })
        }
        .width('100%')
        .position({ x: 0, y: '100%' })
        .translate({ y: -52 })
        .backgroundColor(this.isDarkMode ? 'rgba(26,26,26,0.92)' : 'rgba(255,255,255,0.92)')
        .backdropBlur(10)
      }

      // 加载中
      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color($r('app.color.primary_color'))
          .position({ x: '50%', y: '50%' })
          .translate({ x: -20, y: -20 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDarkMode ? '#1a1a1a' : Color.White)
    .onClick(() => {
      this.showToolbar = !this.showToolbar;
    })
    .onAppear(() => {
      // 加载内容
      this.webController.loadData(
        this.buildReaderHtml(),
        'text/html',
        'UTF-8',
        '',
        ''
      );
    })
  }

  /** 刷新 Web 内容（字体/主题变更） */
  refreshContent(): void {
    this.webController.loadData(
      this.buildReaderHtml(),
      'text/html',
      'UTF-8',
      '',
      ''
    );
  }
}
