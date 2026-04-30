import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Feed } from '../model/Feed';
import { FeedItem } from '../components/FeedItem';
import { EmptyState } from '../components/EmptyState';
import { FeedService } from '../service/FeedService';

/**
 * 订阅管理页面
 * 展示所有 Feed，支持添加、删除、下拉刷新
 */
@Component
export struct FeedListPage {
  @State feeds: Feed[] = [];
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State showAddDialog: boolean = false;
  @State newFeedUrl: string = '';
  @State addError: string = '';
  @State isAdding: boolean = false;

  private feedService = FeedService.getInstance();

  aboutToAppear(): void {
    this.loadFeeds();
  }

  async loadFeeds(): Promise<void> {
    this.isLoading = true;
    try {
      this.feeds = await this.feedService.getAllFeeds();
    } catch (err) {
      console.error('[FeedListPage] loadFeeds error:', JSON.stringify(err));
    } finally {
      this.isLoading = false;
    }
  }

  async handleRefresh(): Promise<void> {
    this.isRefreshing = true;
    try {
      await this.feedService.refreshAllFeeds(this.feeds);
      this.feeds = await this.feedService.getAllFeeds();
      promptAction.showToast({ message: '已刷新全部订阅' });
    } catch (err) {
      console.error('[FeedListPage] refresh error:', JSON.stringify(err));
    } finally {
      this.isRefreshing = false;
    }
  }

  async handleAddFeed(): Promise<void> {
    if (!this.newFeedUrl.trim()) {
      this.addError = '请输入 Feed 地址';
      return;
    }
    this.isAdding = true;
    this.addError = '';
    try {
      await this.feedService.addFeed(this.newFeedUrl.trim());
      this.feeds = await this.feedService.getAllFeeds();
      this.showAddDialog = false;
      this.newFeedUrl = '';
      promptAction.showToast({ message: '订阅添加成功！' });
    } catch (err) {
      this.addError = (err as Error).message || '添加失败，请检查地址';
    } finally {
      this.isAdding = false;
    }
  }

  async handleDeleteFeed(feed: Feed): Promise<void> {
    promptAction.showDialog({
      title: '删除订阅',
      message: `确定删除"${feed.title}"及其所有文章吗？`,
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '删除', color: '#FF5252' },
      ]
    }).then(async (result) => {
      if (result.index === 1) {
        await this.feedService.deleteFeed(feed.id);
        this.feeds = this.feeds.filter(f => f.id !== feed.id);
        promptAction.showToast({ message: '已删除' });
      }
    });
  }

  @Builder
  AddFeedDialog() {
    if (this.showAddDialog) {
      Stack() {
        // 遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.4)')
          .onClick(() => {
            this.showAddDialog = false;
            this.newFeedUrl = '';
            this.addError = '';
          })

        // 弹窗内容
        Column({ space: 16 }) {
          Text('添加订阅源')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          TextInput({ placeholder: '输入 RSS/Atom 源地址', text: this.newFeedUrl })
            .fontSize(14)
            .onChange((val) => {
              this.newFeedUrl = val;
              this.addError = '';
            })
            .onSubmit(() => this.handleAddFeed())

          if (this.addError) {
            Text(this.addError)
              .fontSize(12)
              .fontColor($r('app.color.error_color'))
          }

          Row({ space: 12 }) {
            Button('取消')
              .layoutWeight(1)
              .backgroundColor($r('app.color.surface_color'))
              .fontColor($r('app.color.text_secondary'))
              .onClick(() => {
                this.showAddDialog = false;
                this.newFeedUrl = '';
                this.addError = '';
              })

            Button(this.isAdding ? '添加中...' : '添加')
              .layoutWeight(1)
              .backgroundColor($r('app.color.primary_color'))
              .fontColor(Color.White)
              .enabled(!this.isAdding)
              .onClick(() => this.handleAddFeed())
          }
        }
        .width('85%')
        .padding(20)
        .backgroundColor(Color.White)
        .borderRadius(16)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
    }
  }

  build() {
    Stack() {
      Column() {
        // 顶部栏
        Row() {
          Text('订阅')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)

          // 刷新按钮
          Button() {
            Image($r('sys.media.ohos_ic_public_refresh'))
              .width(20)
              .height(20)
              .fillColor($r('app.color.text_secondary'))
          }
          .width(36)
          .height(36)
          .backgroundColor(Color.Transparent)
          .onClick(() => this.handleRefresh())

          // 添加按钮 — 跳转发现页
          Button() {
            Image($r('sys.media.ohos_ic_public_add'))
              .width(20)
              .height(20)
              .fillColor($r('app.color.primary_color'))
          }
          .width(36)
          .height(36)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            router.pushUrl({ url: 'pages/DiscoverPage' });
          })
        }
        .width('100%')
        .padding({ left: 16, right: 8, top: 12, bottom: 8 })

        // 列表区域
        if (this.isLoading) {
          LoadingProgress()
            .width(40)
            .height(40)
            .color($r('app.color.primary_color'))
            .layoutWeight(1)
        } else if (this.feeds.length === 0) {
          EmptyState({
            message: '还没有订阅源，点击右上角 + 添加',
            actionText: '发现热门订阅源',
            onAction: () => {
              router.pushUrl({ url: 'pages/DiscoverPage' });
            }
          })
        } else {
          Refresh({ refreshing: $$this.isRefreshing }) {
            List() {
              ForEach(this.feeds, (feed: Feed) => {
                FeedItem({
                  feed,
                  onTap: (f: Feed) => {
                    router.pushUrl({
                      url: 'pages/ArticleListPage',
                      params: { feedId: f.id, feedTitle: f.title }
                    });
                  },
                  onLongPress: (f: Feed) => this.handleDeleteFeed(f),
                })
                Divider()
                  .strokeWidth(0.5)
                  .color($r('app.color.divider_color'))
                  .margin({ left: 68 })
              }, (feed: Feed) => String(feed.id))
            }
            .listDirection(Axis.Vertical)
            .divider({ strokeWidth: 0 })
          }
          .onRefreshing(() => this.handleRefresh())
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.surface_color'))

      this.AddFeedDialog()
    }
  }
}
