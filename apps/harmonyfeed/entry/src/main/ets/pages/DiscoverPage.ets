import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { POPULAR_FEEDS } from '../model/Feed';
import { FeedService } from '../service/FeedService';
import { StringUtils } from '../utils/StringUtils';

/** 热门订阅源的显式类型定义（避免 ArkTS typeof 兼容问题） */
interface PopularFeed {
  name: string;
  url: string;
  category: string;
  description: string;
}

/**
 * 发现/添加订阅源页面
 * 支持 URL 手动添加 + 热门源一键订阅
 */
@Entry
@Component
struct DiscoverPage {
  @State customUrl: string = '';
  @State urlError: string = '';
  @State isAdding: boolean = false;
  @State addingUrl: string = '';
  @State selectedCategory: string = '全部';

  private feedService = FeedService.getInstance();

  private get categories(): string[] {
    const cats = new Set<string>(['全部']);
    POPULAR_FEEDS.forEach(f => cats.add(f.category));
    return Array.from(cats);
  }

  private get filteredFeeds() {
    if (this.selectedCategory === '全部') return POPULAR_FEEDS;
    return POPULAR_FEEDS.filter(f => f.category === this.selectedCategory);
  }

  async handleAddFeed(url: string): Promise<void> {
    if (this.isAdding) return;
    this.isAdding = true;
    this.addingUrl = url;
    this.urlError = '';
    try {
      await this.feedService.addFeed(url);
      promptAction.showToast({ message: '订阅添加成功！' });
    } catch (err) {
      const msg = (err as Error).message || '添加失败';
      if (url === this.customUrl) {
        this.urlError = msg;
      } else {
        promptAction.showToast({ message: msg });
      }
    } finally {
      this.isAdding = false;
      this.addingUrl = '';
    }
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
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

        Text('发现订阅源')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .padding({ left: 8 })
      }
      .width('100%')
      .padding({ left: 8, right: 16, top: 12, bottom: 8 })

      // URL 输入区
      Column({ space: 8 }) {
        Row({ space: 8 }) {
          TextInput({ placeholder: '粘贴 RSS/Atom 地址...', text: this.customUrl })
            .fontSize(14)
            .layoutWeight(1)
            .onChange((val) => {
              this.customUrl = val;
              this.urlError = '';
            })
            .onSubmit(() => {
              if (StringUtils.isValidUrl(this.customUrl)) {
                this.handleAddFeed(this.customUrl);
              }
            })

          Button(this.isAdding && this.addingUrl === this.customUrl ? '...' : '订阅')
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary_color'))
            .padding({ left: 16, right: 16 })
            .enabled(!this.isAdding)
            .onClick(() => {
              if (StringUtils.isValidUrl(this.customUrl.trim())) {
                this.handleAddFeed(this.customUrl.trim());
              } else {
                this.urlError = '请输入有效的 RSS/Atom URL';
              }
            })
        }

        if (this.urlError) {
          Text(this.urlError)
            .fontSize(12)
            .fontColor($r('app.color.error_color'))
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })
      .backgroundColor(Color.White)

      Divider()
        .strokeWidth(4)
        .color($r('app.color.surface_color'))

      // 分类 Tabs
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.categories, (cat: string) => {
            Text(cat)
              .fontSize(13)
              .fontColor(this.selectedCategory === cat ? Color.White : $r('app.color.text_secondary'))
              .backgroundColor(this.selectedCategory === cat ? $r('app.color.primary_color') : $r('app.color.surface_color'))
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .borderRadius(16)
              .onClick(() => this.selectedCategory = cat)
          }, (cat: string) => cat)
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .padding({ top: 12, bottom: 12 })

      // 热门订阅源列表
      Scroll() {
        Column() {
          Text('热门订阅源')
            .fontSize(14)
            .fontColor($r('app.color.text_hint'))
            .width('100%')
            .padding({ left: 16, bottom: 8 })

          ForEach(this.filteredFeeds, (feed: PopularFeed) => {
            Row({ space: 12 }) {
              Column({ space: 4 }) {
                Text(feed.name)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_primary'))
                Text(feed.description)
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              // 分类 badge
              Text(feed.category)
                .fontSize(11)
                .fontColor($r('app.color.primary_color'))
                .backgroundColor($r('app.color.primary_light'))
                .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                .borderRadius(10)

              // 订阅按钮
              Button(this.isAdding && this.addingUrl === feed.url ? '...' : '+ 订阅')
                .fontSize(13)
                .fontColor($r('app.color.primary_color'))
                .backgroundColor(Color.Transparent)
                .border({ width: 1, color: $r('app.color.primary_color'), radius: 16 })
                .padding({ left: 12, right: 12 })
                .enabled(!this.isAdding)
                .onClick(() => this.handleAddFeed(feed.url))
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor(Color.White)

            Divider()
              .strokeWidth(0.5)
              .color($r('app.color.divider_color'))
              .margin({ left: 16 })
          }, (feed: PopularFeed) => feed.url)
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.surface_color'))
  }
}
