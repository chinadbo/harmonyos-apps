import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { CharStat, DayStat, MasteryUtil, OverallStats, PracticeRecord } from '../model/PracticeRecord';
import { DbHelper } from '../db/DbHelper';
import { AppTheme } from '../common/Theme';
import { Constants } from '../common/Constants';
import { DateUtil, ToastUtil } from '../common/AppUtil';
import { ProgressRing } from '../components/ProgressRing';

interface HeatDay {
  key: string;
  day: number;
  count: number;
  avgScore: number;
  isToday: boolean;
}

interface MasteryRow {
  char: string;
  bestScore: number;
  attempts: number;
  mastery: number;
}

interface DetailParams {
  char: string;
}

@Entry
@Component
struct Stats {
  @State overall: OverallStats = {
    totalAttempts: 0,
    totalChars: 0,
    avgScore: 0,
    todayCount: 0,
    masteredCount: 0
  };
  @State heatDays: HeatDay[] = [];
  @State rows: MasteryRow[] = [];
  @State recent: PracticeRecord[] = [];
  @State avgMastery: number = 0;
  @State loaded: boolean = false;

  onPageShow(): void {
    this.loadData();
  }

  private async loadData(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    await DbHelper.getInstance().init(context);
    const db: DbHelper = DbHelper.getInstance();
    this.overall = await db.getOverallStats();
    this.recent = await db.getRecentRecords(8);

    const daily: DayStat[] = await db.getDailyStats(28);
    const dayMap: Map<string, DayStat> = new Map<string, DayStat>();
    for (let i = 0; i < daily.length; i++) {
      dayMap.set(daily[i].dayKey, daily[i]);
    }
    const days: HeatDay[] = [];
    for (let i = 27; i >= 0; i--) {
      const key: string = DateUtil.dayKeyOffset(-i);
      const stat: DayStat | undefined = dayMap.get(key);
      const item: HeatDay = {
        key: key,
        day: DateUtil.dayOfMonth(key),
        count: stat === undefined ? 0 : stat.count,
        avgScore: stat === undefined ? 0 : stat.avgScore,
        isToday: i === 0
      };
      days.push(item);
    }
    this.heatDays = days;

    const stats: CharStat[] = await db.getCharStats();
    const rows: MasteryRow[] = [];
    let masterySum: number = 0;
    for (let i = 0; i < stats.length; i++) {
      const mastery: number = MasteryUtil.mastery(stats[i].bestScore, stats[i].attempts);
      const row: MasteryRow = {
        char: stats[i].char,
        bestScore: stats[i].bestScore,
        attempts: stats[i].attempts,
        mastery: mastery
      };
      masterySum += mastery;
      rows.push(row);
    }
    rows.sort((a: MasteryRow, b: MasteryRow) => b.mastery - a.mastery);
    this.rows = rows;
    this.avgMastery = rows.length > 0 ? Math.round(masterySum / rows.length) : 0;
    this.loaded = true;
  }

  private heatColor(cell: HeatDay): string {
    if (cell.count === 0) {
      return AppTheme.CARD_ALT;
    }
    if (cell.avgScore >= 85) {
      return AppTheme.GREEN;
    }
    if (cell.avgScore >= 70) {
      return AppTheme.GOLD;
    }
    return AppTheme.ACCENT;
  }

  private openDetail(char: string): void {
    const params: DetailParams = { char: char };
    router.pushUrl({ url: 'pages/CharDetail', params: params }).catch(() => {
      ToastUtil.show('页面打开失败');
    });
  }

  @Builder
  summaryCard(value: string, label: string, color: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(11)
        .fontColor(AppTheme.INK_FAINT)
    }
    .layoutWeight(1)
    .height(72)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(AppTheme.CARD)
    .borderRadius(14)
  }

  @Builder
  heatCell(cell: HeatDay) {
    Column({ space: 1 }) {
      Text(`${cell.day}`)
        .fontSize(9)
        .fontColor(cell.count > 0 ? '#FFFFFF' : AppTheme.INK_FAINT)
      if (cell.count > 0) {
        Text(`${cell.count}`)
          .fontSize(10)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
      } else {
        Text('·')
          .fontSize(10)
          .fontColor(AppTheme.INK_FAINT)
      }
    }
    .width('12%')
    .aspectRatio(1)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.heatColor(cell))
    .borderRadius(6)
    .border({
      width: cell.isToday ? 2 : 0,
      color: AppTheme.GOLD
    })
    .margin({ bottom: 6 })
  }

  @Builder
  masteryRow(row: MasteryRow) {
    Row({ space: 12 }) {
      Text(row.char)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.INK)
        .width(42)
        .height(42)
        .textAlign(TextAlign.Center)
        .backgroundColor(AppTheme.CARD_ALT)
        .borderRadius(10)
      Column({ space: 5 }) {
        Row() {
          Text(`最佳 ${row.bestScore} 分 · 练习 ${row.attempts} 次`)
            .fontSize(11)
            .fontColor(AppTheme.INK_LIGHT)
          Blank()
          Text(MasteryUtil.isMastered(row.bestScore, row.attempts) ? '已掌握' : `${row.mastery}%`)
            .fontSize(11)
            .fontColor(AppTheme.masteryColor(row.mastery))
        }
        .width('100%')
        Stack({ alignContent: Alignment.Start }) {
          Row()
            .width('100%')
            .height(5)
            .backgroundColor(AppTheme.CARD_ALT)
            .borderRadius(3)
          Row()
            .width(`${row.mastery}%`)
            .height(5)
            .backgroundColor(AppTheme.masteryColor(row.mastery))
            .borderRadius(3)
        }
        .width('100%')
      }
      .layoutWeight(1)
      Text('›')
        .fontSize(20)
        .fontColor(AppTheme.INK_FAINT)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .onClick(() => {
      this.openDetail(row.char);
    })
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Text('‹')
          .fontSize(30)
          .fontColor(AppTheme.INK)
          .width(32)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            router.back();
          })
        Column({ space: 2 }) {
          Text('学习统计')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.INK)
          Text('练习记录 · 掌握度热力图')
            .fontSize(11)
            .fontColor(AppTheme.INK_FAINT)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: 16, top: 12, bottom: 10 })

      Scroll() {
        Column({ space: 14 }) {
          // 概览 + 平均掌握度
          Row({ space: 12 }) {
            Row({ space: 12 }) {
              ProgressRing({ percent: this.avgMastery, size: 66, ringWidth: 7, label: '掌握' })
              Column({ space: 4 }) {
                Text('平均掌握度')
                  .fontSize(13)
                  .fontColor(AppTheme.INK_LIGHT)
                Text(this.overall.masteredCount > 0 ? `已掌握 ${this.overall.masteredCount} 字` : '继续练习提升掌握度')
                  .fontSize(11)
                  .fontColor(AppTheme.INK_FAINT)
              }
              .alignItems(HorizontalAlign.Start)
            }
            .layoutWeight(1)
            .height(96)
            .padding({ left: 14, right: 14 })
            .backgroundColor(AppTheme.CARD)
            .borderRadius(16)
          }
          .width('100%')

          Row({ space: 10 }) {
            this.summaryCard(`${this.overall.totalAttempts}`, '总练习次数', AppTheme.INK)
            this.summaryCard(`${this.overall.todayCount}`, '今日练习', AppTheme.ACCENT)
          }
          .width('100%')
          Row({ space: 10 }) {
            this.summaryCard(`${this.overall.totalChars}`, '已练字数', AppTheme.GREEN)
            this.summaryCard(this.overall.avgScore > 0 ? `${this.overall.avgScore}` : '—', '平均得分', AppTheme.GOLD)
          }
          .width('100%')

          // 热力图
          Column({ space: 10 }) {
            Row() {
              Text('近 28 天热力图')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(AppTheme.INK)
              Blank()
              Text('颜色代表当天平均分')
                .fontSize(10)
                .fontColor(AppTheme.INK_FAINT)
            }
            .width('100%')
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.heatDays, (cell: HeatDay) => {
                this.heatCell(cell)
              }, (cell: HeatDay) => cell.key)
            }
            .width('100%')
            Row({ space: 8 }) {
              Text('未练习')
                .fontSize(9)
                .fontColor(AppTheme.INK_FAINT)
              Row().width(10).height(10).borderRadius(3).backgroundColor(AppTheme.CARD_ALT)
              Row().width(10).height(10).borderRadius(3).backgroundColor(AppTheme.ACCENT)
              Text('<70分').fontSize(9).fontColor(AppTheme.INK_FAINT)
              Row().width(10).height(10).borderRadius(3).backgroundColor(AppTheme.GOLD)
              Text('70-84').fontSize(9).fontColor(AppTheme.INK_FAINT)
              Row().width(10).height(10).borderRadius(3).backgroundColor(AppTheme.GREEN)
              Text('≥85').fontSize(9).fontColor(AppTheme.INK_FAINT)
            }
            .width('100%')
            if (this.loaded && this.overall.totalAttempts === 0) {
              Text('还没有练习数据，完成一次临摹后这里会亮起来')
                .fontSize(11)
                .fontColor(AppTheme.INK_FAINT)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppTheme.CARD)
          .borderRadius(18)

          // 掌握度排行
          Column({ space: 4 }) {
            Row() {
              Text('单字掌握度')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(AppTheme.INK)
              Blank()
              Text('≥85 分且 ≥3 次为已掌握')
                .fontSize(10)
                .fontColor(AppTheme.INK_FAINT)
            }
            .width('100%')
            if (this.rows.length === 0) {
              Text('暂无练习记录')
                .fontSize(12)
                .fontColor(AppTheme.INK_FAINT)
                .padding({ top: 16, bottom: 16 })
            } else {
              ForEach(this.rows.slice(0, 30), (row: MasteryRow) => {
                this.masteryRow(row)
              }, (row: MasteryRow) => row.char)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppTheme.CARD)
          .borderRadius(18)

          // 最近记录
          Column({ space: 4 }) {
            Text('最近练习记录')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(AppTheme.INK)
              .width('100%')
            if (this.recent.length === 0) {
              Text('暂无记录')
                .fontSize(12)
                .fontColor(AppTheme.INK_FAINT)
                .padding({ top: 12, bottom: 12 })
            } else {
              ForEach(this.recent, (record: PracticeRecord) => {
                Row({ space: 12 }) {
                  Text(record.char)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(AppTheme.INK)
                    .width(36)
                    .height(36)
                    .textAlign(TextAlign.Center)
                    .backgroundColor(AppTheme.CARD_ALT)
                    .borderRadius(8)
                  Column({ space: 2 }) {
                    Text(`${record.score} 分 · ${Constants.scoreLabel(record.score)}`)
                      .fontSize(12)
                      .fontColor(AppTheme.scoreColor(record.score))
                    Text(`${DateUtil.formatDateTime(record.createdAt)} · ${record.strokeCount} 笔 · ${Math.max(1, Math.round(record.durationMs / 1000))} 秒`)
                      .fontSize(9)
                      .fontColor(AppTheme.INK_FAINT)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .width('100%')
                .padding({ top: 6, bottom: 6 })
              }, (record: PracticeRecord) => `${record.id}`)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppTheme.CARD)
          .borderRadius(18)

          Text('掌握度 = 最佳分 × 80% + 练习频次 × 20%')
            .fontSize(10)
            .fontColor(AppTheme.INK_FAINT)
            .padding({ bottom: 20 })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BG)
  }
}
