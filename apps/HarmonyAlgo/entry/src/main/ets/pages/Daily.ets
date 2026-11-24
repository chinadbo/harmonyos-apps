import common from '@ohos.app.ability.common';
import { Database, TrendData } from '../model/Database';
import { Problem } from '../model/Problem';
import { STATUS_MASTERED } from '../model/Record';
import { DiffBadge } from '../components/DiffBadge';
import { Theme } from '../common/Theme';
import { openProblem } from '../common/RouterUtil';

/** 每日推荐页（作为首页 Tab 内容） */
@Component
export struct DailyView {
  @Prop @Watch('onTick') refreshTick: number = 0;
  @State rec: Problem = new Problem(0, '', '', 1, '', '', '', '', '');
  @State hasRec: boolean = false;
  @State recStatus: number = 0;
  @State todayCount: number = 0;
  @State unsolvedCount: number = 0;
  private allProblems: Problem[] = [];
  private unsolved: Problem[] = [];

  aboutToAppear(): void {
    this.load();
  }

  onTick(): void {
    this.load();
  }

  private dayOfYear(): number {
    const now = new Date();
    const start = new Date(now.getFullYear(), 0, 0).getTime();
    return Math.floor((now.getTime() - start) / (24 * 60 * 60 * 1000));
  }

  dateText(): string {
    const now = new Date();
    const week: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return (now.getMonth() + 1).toString() + ' 月 ' + now.getDate().toString() + ' 日 · ' + week[now.getDay()];
  }

  async load(): Promise<void> {
    const db = Database.getInstance();
    await db.init(getContext(this) as common.UIAbilityContext);
    const problems = await db.getAllProblems();
    const statusMap = await db.getStatusMap();
    const trend: TrendData = await db.getLast7DayTrend();

    this.allProblems = problems;
    const unsolved: Problem[] = [];
    for (let i = 0; i < problems.length; i++) {
      const s = statusMap.get(problems[i].id);
      if (s === undefined || s === 0) {
        unsolved.push(problems[i]);
      }
    }
    this.unsolved = unsolved;
    this.unsolvedCount = unsolved.length;
    this.todayCount = trend.values.length > 0 ? trend.values[trend.values.length - 1] : 0;

    const pool: Problem[] = unsolved.length > 0 ? unsolved : problems;
    if (pool.length > 0) {
      const rec = pool[this.dayOfYear() % pool.length];
      this.rec = rec;
      const st = statusMap.get(rec.id);
      this.recStatus = st === undefined ? 0 : st;
      this.hasRec = true;
    }
  }

  pickRandom(): void {
    const pool: Problem[] = this.unsolved.length > 0 ? this.unsolved : this.allProblems;
    if (pool.length === 0) {
      return;
    }
    let idx = Math.floor(Math.random() * pool.length);
    if (pool.length > 1 && pool[idx].id === this.rec.id) {
      idx = (idx + 1) % pool.length;
    }
    this.rec = pool[idx];
    this.recStatus = 0;
  }

  build() {
    Scroll() {
      Column() {
        Text('每日推荐')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.text)
          .width('100%')
        Text(this.dateText())
          .fontSize(13)
          .fontColor(Theme.subText)
          .width('100%')
          .margin({ top: 6, bottom: 16 })

        // 今日概览
        Row({ space: 12 }) {
          Column() {
            Text(this.todayCount.toString())
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.primary)
            Text('今日完成')
              .fontSize(12)
              .fontColor(Theme.subText)
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .padding({ top: 16, bottom: 16 })
          .backgroundColor(Theme.card)
          .borderRadius(14)
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text(this.unsolvedCount.toString())
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.star)
            Text('待学习')
              .fontSize(12)
              .fontColor(Theme.subText)
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .padding({ top: 16, bottom: 16 })
          .backgroundColor(Theme.card)
          .borderRadius(14)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')

        if (this.hasRec) {
          // 推荐题目卡片
          Column() {
            Row() {
              Text('今日一题')
                .fontSize(12)
                .fontColor('#FFFFFF')
                .backgroundColor(Theme.primary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .borderRadius(8)
              Blank()
              DiffBadge({ difficulty: this.rec.difficulty })
            }
            .width('100%')

            Text(this.rec.title)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.text)
              .width('100%')
              .margin({ top: 14 })

            Row() {
              Text(this.rec.category)
                .fontSize(12)
                .fontColor(Theme.subText)
              if (this.recStatus === STATUS_MASTERED) {
                Text('已掌握')
                  .fontSize(11)
                  .fontColor(Theme.success)
                  .margin({ left: 10 })
              }
            }
            .width('100%')
            .margin({ top: 6 })

            Text(this.rec.description)
              .fontSize(13)
              .fontColor(Theme.subText)
              .lineHeight(20)
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
              .margin({ top: 12 })

            if (this.rec.tags.length > 0) {
              Text(this.rec.tags.split(',').join('  ·  '))
                .fontSize(11)
                .fontColor(Theme.primary)
                .width('100%')
                .margin({ top: 12 })
            }

            Row({ space: 12 }) {
              Button('开始学习')
                .fontSize(15)
                .fontColor('#FFFFFF')
                .backgroundColor(Theme.primary)
                .layoutWeight(1)
                .height(44)
                .onClick(() => {
                  openProblem(this.rec.id);
                })
              Button('换一题')
                .fontSize(15)
                .fontColor(Theme.primary)
                .backgroundColor(Theme.primaryLight)
                .layoutWeight(1)
                .height(44)
                .onClick(() => {
                  this.pickRandom();
                })
            }
            .width('100%')
            .margin({ top: 20 })
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Theme.card)
          .borderRadius(16)
          .margin({ top: 16 })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor(Theme.bg)
  }
}
