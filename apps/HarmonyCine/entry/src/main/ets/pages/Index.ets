/**
 * Index：片单主页。
 * 三态片单（在看/想看/看过）+ 关键字搜索（防抖）+ 海报墙 + FAB 添加 + 统计/成就/设置入口。
 * 最后选中 Tab 与海报色偏移持久化在 Preferences。
 */
import router from '@ohos.router';
import { BusinessError } from '@ohos.base';
import {
  MovieItem,
  TabCounts,
  CineStatus,
  statusLabel,
  emptyCounts
} from '../model/Movie';
import { dbReady, getPrefNumber, putPrefNumber, PREF_KEY_LAST_TAB, PREF_KEY_POSTER_OFFSET } from '../data/DbService';
import { queryMovies, getCounts, checkAchievements } from '../data/MovieRepository';
import { MovieCard } from '../components/MovieCard';

const STATUS_TABS: string[] = [CineStatus.WATCHING, CineStatus.WISH, CineStatus.WATCHED];
const SEARCH_DEBOUNCE_MS: number = 300;

@Entry
@Component
struct Index {
  @State currentTab: number = 0;
  @State movies: MovieItem[] = [];
  @State keyword: string = '';
  @State counts: TabCounts = emptyCounts();
  @State loaded: boolean = false;
  private searchTimerId: number = -1;

  private async refresh(): Promise<void> {
    try {
      this.counts = await getCounts();
      this.movies = await queryMovies(STATUS_TABS[this.currentTab], this.keyword.trim());
      await checkAchievements();
      this.loaded = true;
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyCine] refresh failed, code=${e.code} message=${e.message}`);
    }
  }

  private async loadPrefs(): Promise<void> {
    const lastTab = await getPrefNumber(PREF_KEY_LAST_TAB, 0);
    if (lastTab >= 0 && lastTab < STATUS_TABS.length) {
      this.currentTab = lastTab;
    }
    const posterOffset = await getPrefNumber(PREF_KEY_POSTER_OFFSET, 0);
    AppStorage.setOrCreate('posterOffset', posterOffset);
  }

  async aboutToAppear(): Promise<void> {
    await this.loadPrefs();
    await dbReady();
    await this.refresh();
  }

  aboutToDisappear(): void {
    if (this.searchTimerId !== -1) {
      clearTimeout(this.searchTimerId);
      this.searchTimerId = -1;
    }
    putPrefNumber(PREF_KEY_LAST_TAB, this.currentTab);
  }

  onPageShow(): void {
    if (this.loaded) {
      this.refresh();
    }
  }

  private switchTab(index: number): void {
    if (this.currentTab === index) {
      return;
    }
    this.currentTab = index;
    this.refresh();
  }

  private tabCount(index: number): number {
    if (index === 0) {
      return this.counts.watching;
    }
    if (index === 1) {
      return this.counts.wish;
    }
    return this.counts.watched;
  }

  private openDetail(id: number): void {
    router.pushUrl({ url: 'pages/MovieDetailPage', params: { id: id } });
  }

  private goto(pageUrl: string): void {
    router.pushUrl({ url: pageUrl });
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        // 顶部标题栏 + 功能入口
        Row() {
          Column({ space: 2 }) {
            Text('HarmonyCine')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#22242E')
            Text(`片单 ${this.counts.total} 部`)
              .fontSize(12)
              .fontColor('#8A8F9E')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text('统计')
            .fontSize(13)
            .fontColor('#444652')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#E9EDFF')
            .borderRadius(14)
            .margin({ right: 6 })
            .onClick(() => {
              this.goto('pages/StatsPage');
            })
          Text('成就')
            .fontSize(13)
            .fontColor('#444652')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#FFF3D6')
            .borderRadius(14)
            .margin({ right: 6 })
            .onClick(() => {
              this.goto('pages/AchievementsPage');
            })
          Text('设置')
            .fontSize(13)
            .fontColor('#444652')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#EAF3F1')
            .borderRadius(14)
            .onClick(() => {
              this.goto('pages/SettingsPage');
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 14, bottom: 10 })
        .alignItems(VerticalAlign.Center)

        // 三态 Tab
        Row({ space: 8 }) {
          ForEach(STATUS_TABS, (status: string, index: number) => {
            Text(`${statusLabel(status)} ${this.tabCount(index)}`)
              .fontSize(14)
              .fontColor(this.currentTab === index ? '#FFFFFF' : '#666A78')
              .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(this.currentTab === index ? '#3D5AFE' : '#FFFFFF')
              .borderRadius(18)
              .onClick(() => {
                this.switchTab(index);
              })
          }, (status: string) => status)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .padding({ left: 16, right: 16, bottom: 10 })

        // 搜索框
        Row() {
          Text('⌕')
            .fontSize(18)
            .fontColor('#8A8F9E')
            .margin({ right: 8 })
          TextInput({ placeholder: '搜索片名...', text: this.keyword })
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .padding({ top: 4, bottom: 4 })
            .fontSize(14)
            .onChange((value: string) => {
              this.keyword = value;
              if (this.searchTimerId !== -1) {
                clearTimeout(this.searchTimerId);
              }
              this.searchTimerId = setTimeout(() => {
                this.searchTimerId = -1;
                this.refresh();
              }, SEARCH_DEBOUNCE_MS);
            })
        }
        .width('100%')
        .padding({ left: 14, right: 14 })
        .margin({ left: 16, right: 16, bottom: 12 })
        .backgroundColor('#FFFFFF')
        .borderRadius(22)
        .alignItems(VerticalAlign.Center)

        // 海报墙
        if (this.loaded && this.movies.length === 0) {
          Column({ space: 10 }) {
            Text('⌄')
              .fontSize(40)
              .fontColor('#C7CBD8')
            Text(this.keyword.length > 0 ? '没有找到匹配的条目' : '这个列表还是空的')
              .fontSize(14)
              .fontColor('#8A8F9E')
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          Grid() {
            ForEach(this.movies, (movie: MovieItem) => {
              GridItem() {
                MovieCard({
                  movie: movie,
                  onOpen: (id: number) => {
                    this.openDetail(id);
                  }
                })
              }
              .aspectRatio(0.62)
            }, (movie: MovieItem) => `movie_${movie.id}`)
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .padding({ left: 16, right: 16 })
          .layoutWeight(1)
          .width('100%')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F4F4F8')

      // FAB 添加按钮
      Button() {
        Text('+ 添加')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width(96)
      .height(48)
      .borderRadius(24)
      .backgroundColor('#3D5AFE')
      .shadow({ radius: 12, color: '#333D5AFE', offsetX: 0, offsetY: 4 })
      .margin({ right: 20, bottom: 28 })
      .onClick(() => {
        this.goto('pages/AddMoviePage');
      })
    }
    .width('100%')
    .height('100%')
  }
}
