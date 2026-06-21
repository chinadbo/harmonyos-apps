import common from '@ohos.app.ability.common';
import { Poem } from '../model/Poem';
import { PoemService } from '../service/PoemService';
import { PoemDataSource } from '../datasource/PoemDataSource';
import { PoemCard } from '../components/PoemCard';
import { EmptyView } from '../components/EmptyView';

@Component
export struct SearchPage {
  @State poems: Poem[] = [];
  @State keyword: string = '';
  @State dataSource: PoemDataSource = new PoemDataSource([]);

  aboutToAppear(): void {
    this.loadPoems();
  }

  async loadPoems(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    this.poems = await PoemService.loadPoems(context);
    this.dataSource.updatePoems(this.poems);
  }

  doSearch(): void {
    const result = PoemService.searchPoems(this.poems, this.keyword);
    this.dataSource.updatePoems(result);
  }

  build() {
    Column({ space: 14 }) {
      Text('搜索诗词')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.theme_primary'))
        .width('100%')

      Search({ value: this.keyword, placeholder: '搜索标题、作者、内容、标签' })
        .searchButton('搜索')
        .onChange((value: string) => {
          this.keyword = value;
          this.doSearch();
        })
        .onSubmit((value: string) => {
          this.keyword = value;
          this.doSearch();
        })
        .width('100%')

      if (this.dataSource.totalCount() === 0) {
        EmptyView({ title: '暂无匹配结果', description: '试试搜索作者、朝代、名句或主题。' })
      } else {
        List({ space: 12 }) {
          LazyForEach(this.dataSource, (item: Poem) => {
            ListItem() {
              PoemCard({ poem: item, keyword: this.keyword })
            }
          }, (item: Poem) => `${item.id}`)
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.theme_background'))
  }
}
