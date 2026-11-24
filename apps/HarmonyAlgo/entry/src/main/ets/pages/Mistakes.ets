import common from '@ohos.app.ability.common';
import { Database } from '../model/Database';
import { Problem } from '../model/Problem';
import { ProblemCard } from '../components/ProblemCard';
import { EmptyView } from '../components/EmptyView';
import { Theme } from '../common/Theme';
import { openProblem } from '../common/RouterUtil';

/** 错题本（作为首页 Tab 内容） */
@Component
export struct MistakesView {
  @Prop @Watch('onTick') refreshTick: number = 0;
  @State problems: Problem[] = [];
  @State statusMap: Map<number, number> = new Map<number, number>();
  @State wrongMap: Map<number, number> = new Map<number, number>();
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
    const ids = await db.getWrongProblemIds();
    const list = await db.getProblemsByIds(ids);
    const status = await db.getStatusMap();
    const wrong = await db.getWrongCountMap();
    this.problems = list;
    this.statusMap = status;
    this.wrongMap = wrong;
    this.loaded = true;
  }

  statusOf(id: number): number {
    const s = this.statusMap.get(id);
    return s === undefined ? 0 : s;
  }

  wrongOf(id: number): number {
    const w = this.wrongMap.get(id);
    return w === undefined ? 0 : w;
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text('错题本')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.text)
          Text(this.problems.length + ' 道待巩固')
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
        EmptyView({ title: '错题本是空的', subtitle: '在题目详情页点击「记错题」，未掌握的题目会汇集到这里' })
      } else {
        List({ space: 10 }) {
          ForEach(this.problems, (item: Problem) => {
            ListItem() {
              ProblemCard({
                problem: item,
                status: this.statusOf(item.id),
                wrongCount: this.wrongOf(item.id),
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
