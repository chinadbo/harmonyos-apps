import common from '@ohos.app.ability.common';
import { Database } from '../model/Database';
import { Problem } from '../model/Problem';
import { ProblemCard } from '../components/ProblemCard';
import { EmptyView } from '../components/EmptyView';
import { Theme } from '../common/Theme';
import { openProblem } from '../common/RouterUtil';

/** 收藏页（作为首页 Tab 内容） */
@Component
export struct FavoritesView {
  @Prop @Watch('onTick') refreshTick: number = 0;
  @State problems: Problem[] = [];
  @State statusMap: Map<number, number> = new Map<number, number>();
  @State loaded: boolean = false;

  aboutToAppear(): void {
    this.load();
  }

  onTick(): void {
    this.load();
  }

  async load(): Promise<void> {
    const db = Database.getInstance();
    await db.init(getContext(this) as common.UIAbilityContext);
    const list = await db.getFavoriteProblems();
    const status = await db.getStatusMap();
    this.problems = list;
    this.statusMap = status;
    this.loaded = true;
  }

  statusOf(id: number): number {
    const s = this.statusMap.get(id);
    return s === undefined ? 0 : s;
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text('我的收藏')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.text)
          Text(this.problems.length + ' 道题目')
            .fontSize(12)
            .fontColor(Theme.subText)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 10 })

      if (this.loaded && this.problems.length === 0) {
        EmptyView({ title: '还没有收藏题目', subtitle: '在题目详情页点击右上角星标即可收藏' })
      } else {
        List({ space: 10 }) {
          ForEach(this.problems, (item: Problem) => {
            ListItem() {
              ProblemCard({
                problem: item,
                status: this.statusOf(item.id),
                favorite: true,
                onTap: () => openProblem(item.id)
              })
            }
          }, (item: Problem) => item.id.toString())
          ListItem() {
            Row().height(12)
          }
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ left: 16, right: 16 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg)
  }
}
