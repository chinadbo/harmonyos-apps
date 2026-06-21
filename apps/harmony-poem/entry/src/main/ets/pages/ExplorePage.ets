import common from '@ohos.app.ability.common';
import { Poem } from '../model/Poem';
import { PoemService } from '../service/PoemService';
import { PoemDataSource } from '../datasource/PoemDataSource';
import { PoemCard } from '../components/PoemCard';
import { EmptyView } from '../components/EmptyView';

@Component
export struct ExplorePage {
  @State poems: Poem[] = [];
  @State dataSource: PoemDataSource = new PoemDataSource([]);
  @State dimensionIndex: number = 0;
  @State selectedDynasty: string = '全部';
  @State selectedAuthor: string = '全部';
  @State selectedGenre: string = '全部';
  @State dynasties: string[] = ['全部'];
  @State authors: string[] = ['全部'];
  @State genres: string[] = ['全部'];

  aboutToAppear(): void {
    this.loadPoems();
  }

  async loadPoems(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    this.poems = await PoemService.loadPoems(context);
    this.dynasties = ['全部', ...Array.from(new Set(this.poems.map((item: Poem) => item.dynasty)))];
    this.authors = ['全部', ...Array.from(new Set(this.poems.map((item: Poem) => item.author)))];
    this.genres = ['全部', ...Array.from(new Set(this.poems.map((item: Poem) => item.genre)))];
    this.applyFilter();
  }

  applyFilter(): void {
    let result = this.poems;
    if (this.dimensionIndex === 0) {
      result = PoemService.filterByDynasty(this.poems, this.selectedDynasty);
    } else if (this.dimensionIndex === 1) {
      result = PoemService.filterByAuthor(this.poems, this.selectedAuthor);
    } else {
      result = PoemService.filterByGenre(this.poems, this.selectedGenre);
    }
    this.dataSource.updatePoems(result);
  }

  @Builder
  FilterChips(items: string[], selected: string, onSelected: (value: string) => void) {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(items, (item: string) => {
          Text(item)
            .fontSize(13)
            .fontColor(item === selected ? Color.White : $r('app.color.theme_primary'))
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(item === selected ? $r('app.color.theme_primary') : '#F6E7D7')
            .borderRadius(18)
            .onClick(() => {
              onSelected(item);
            })
        }, (item: string) => item)
      }
      .padding({ right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  build() {
    Column({ space: 12 }) {
      Text('探索诗词')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.theme_primary'))
        .width('100%')

      Tabs({ index: this.dimensionIndex }) {
        TabContent() {
          Column({ space: 12 }) {
            this.FilterChips(this.dynasties, this.selectedDynasty, (value: string) => {
              this.selectedDynasty = value;
              this.applyFilter();
            })
          }
        }
        .tabBar('朝代')

        TabContent() {
          Column({ space: 12 }) {
            this.FilterChips(this.authors, this.selectedAuthor, (value: string) => {
              this.selectedAuthor = value;
              this.applyFilter();
            })
          }
        }
        .tabBar('作者')

        TabContent() {
          Column({ space: 12 }) {
            this.FilterChips(this.genres, this.selectedGenre, (value: string) => {
              this.selectedGenre = value;
              this.applyFilter();
            })
          }
        }
        .tabBar('体裁')
      }
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.dimensionIndex = index;
        this.applyFilter();
      })

      if (this.dataSource.totalCount() === 0) {
        EmptyView({ title: '没有找到对应诗词', description: '请切换分类维度或筛选条件。' })
      } else {
        List({ space: 12 }) {
          LazyForEach(this.dataSource, (item: Poem) => {
            ListItem() {
              PoemCard({ poem: item })
            }
          }, (item: Poem) => `${item.id}`)
        }
        .layoutWeight(1)
        .width('100%')
        .divider({ strokeWidth: 0 })
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.theme_background'))
  }
}
