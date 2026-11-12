import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { CharEntry, CharRepository, CharUtil } from '../model/CharData';
import { CharStat, MasteryUtil, OverallStats, PracticeRecord } from '../model/PracticeRecord';
import { DbHelper } from '../db/DbHelper';
import { AppTheme } from '../common/Theme';
import { Constants } from '../common/Constants';
import { DateUtil, ToastUtil } from '../common/AppUtil';
import { ProgressRing } from '../components/ProgressRing';
import { GridCell } from '../components/GridCell';

interface ListParams {
  grade: number;
}

interface DetailParams {
  char: string;
}

@Entry
@Component
struct Index {
  @State chars: CharEntry[] = [];
  @State selectedGrade: number = 1;
  @State daily: CharEntry = { char: '', pinyin: '', grade: 1, strokes: [] };
  @State hasDaily: boolean = false;
  @State dailyMastery: number = 0;
  @State dailyBest: number = 0;
  @State dailyAttempts: number = 0;
  @State stats: OverallStats = {
    totalAttempts: 0,
    totalChars: 0,
    avgScore: 0,
    todayCount: 0,
    masteredCount: 0
  };
  @State recent: PracticeRecord[] = [];
  @State loading: boolean = true;
  private grades: number[] = [1, 2, 3, 4, 5, 6];

  onPageShow(): void {
    this.refresh();
  }

  private async refresh(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    this.chars = await CharRepository.getInstance().load(context);
    await DbHelper.getInstance().init(context);
    this.stats = await DbHelper.getInstance().getOverallStats();
    this.recent = await DbHelper.getInstance().getRecentRecords(3);
    const charStats: CharStat[] = await DbHelper.getInstance().getCharStats();
    this.updateDaily(this.selectedGrade, charStats);
    this.loading = false;
  }

  private updateDaily(grade: number, charStats: CharStat[]): void {
    const entry: CharEntry | undefined = CharRepository.getInstance().getDailyChar(grade);
    if (entry === undefined) {
      this.hasDaily = false;
      this.daily = { char: '', pinyin: '', grade: grade, strokes: [] };
      this.dailyMastery = 0;
      this.dailyBest = 0;
      this.dailyAttempts = 0;
      return;
    }
    this.daily = entry;
    this.hasDaily = true;
    this.dailyMastery = 0;
    this.dailyBest = 0;
    this.dailyAttempts = 0;
    for (let i = 0; i < charStats.length; i++) {
      if (charStats[i].char === entry.char) {
        this.dailyBest = charStats[i].bestScore;
        this.dailyAttempts = charStats[i].attempts;
        this.dailyMastery = MasteryUtil.mastery(charStats[i].bestScore, charStats[i].attempts);
      }
    }
  }

  private async selectGrade(grade: number): Promise<void> {
    this.selectedGrade = grade;
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const charStats: CharStat[] = await DbHelper.getInstance().getCharStats();
    this.updateDaily(grade, charStats);
  }

  private openList(): void {
    const params: ListParams = { grade: this.selectedGrade };
    router.pushUrl({ url: 'pages/CharList', params: params }).catch(() => {
      ToastUtil.show('页面打开失败');
    });
  }

  private openStats(): void {
    router.pushUrl({ url: 'pages/Stats' }).catch(() => {
      ToastUtil.show('页面打开失败');
    });
  }

  private openSettings(): void {
    router.pushUrl({ url: 'pages/Settings' }).catch(() => {
      ToastUtil.show('页面打开失败');
    });
  }

  private openDetail(char: string): void {
    const params: DetailParams = { char: char };
    router.pushUrl({ url: 'pages/CharDetail', params: params }).catch(() => {
      ToastUtil.show('页面打开失败');
    });
  }

  @Builder
  gradeChip(grade: number) {
    Text(`${grade}年级`)
      .fontSize(13)
      .fontColor(this.selectedGrade === grade ? '#FFFFFF' : AppTheme.INK_LIGHT)
      .backgroundColor(this.selectedGrade === grade ? AppTheme.INK : AppTheme.CARD)
      .borderRadius(16)
      .padding({ left: 14, right: 14, top: 7, bottom: 7 })
      .border({ width: 1, color: this.selectedGrade === grade ? AppTheme.INK : AppTheme.GRID_DASH })
      .onClick(() => {
        this.selectGrade(grade);
      })
  }

  @Builder
  statCell(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.INK)
      Text(label)
        .fontSize(11)
        .fontColor(AppTheme.INK_FAINT)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  private navigateQuick(target: string): void {
    if (target === 'list') {
      this.openList();
    } else if (target === 'stats') {
      this.openStats();
    } else {
      this.openSettings();
    }
  }

  @Builder
  quickEntry(title: string, subtitle: string, color: string, target: string) {
    Column({ space: 8 }) {
      Text(title.substring(0, 1))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .width(38)
        .height(38)
        .textAlign(TextAlign.Center)
        .backgroundColor(AppTheme.CARD)
        .borderRadius(12)
      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.INK)
      Text(subtitle)
        .fontSize(11)
        .fontColor(AppTheme.INK_FAINT)
    }
    .layoutWeight(1)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor(AppTheme.CARD_ALT)
    .borderRadius(16)
    .onClick(() => {
      this.navigateQuick(target);
    })
  }

  @Builder
  recentRow(record: PracticeRecord) {
    Row({ space: 12 }) {
      Text(record.char)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.INK)
        .width(44)
        .height(44)
        .textAlign(TextAlign.Center)
        .backgroundColor(AppTheme.CARD_ALT)
        .borderRadius(10)
      Column({ space: 3 }) {
        Text(`得分 ${record.score}`)
          .fontSize(14)
          .fontColor(AppTheme.scoreColor(record.score))
          .fontWeight(FontWeight.Medium)
        Text(DateUtil.formatDateTime(record.createdAt))
          .fontSize(11)
          .fontColor(AppTheme.INK_FAINT)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Text(`${record.strokeCount} 笔`)
        .fontSize(11)
        .fontColor(AppTheme.INK_FAINT)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: 18 }) {
          Row() {
            Column({ space: 4 }) {
              Text(Constants.APP_NAME)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppTheme.INK)
              Text(Constants.APP_SUBTITLE)
                .fontSize(12)
                .fontColor(AppTheme.INK_FAINT)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Column({ space: 4 }) {
              Text(DateUtil.greeting())
                .fontSize(12)
                .fontColor(AppTheme.INK_LIGHT)
              Text(CharUtil.todayLabel())
                .fontSize(11)
                .fontColor(AppTheme.INK_FAINT)
            }
            .alignItems(HorizontalAlign.End)
          }
          .width('100%')
          .margin({ top: 12 })

          // 今日推荐
          Column({ space: 16 }) {
            Row() {
              Text('今日推荐')
                .fontSize(13)
                .fontColor(AppTheme.ACCENT)
                .fontWeight(FontWeight.Medium)
              Blank()
              Text('每日一字')
                .fontSize(11)
                .fontColor(AppTheme.INK_FAINT)
            }
            .width('100%')

            if (this.hasDaily) {
              Row({ space: 16 }) {
                Column() {
                  GridCell({
                    character: this.daily.char,
                    size: 92,
                    showDiagonal: true,
                    guideAlpha: 0.9
                  })
                }
                .backgroundColor('#FFFDF8')
                .borderRadius(18)
                Column({ space: 6 }) {
                  Row({ space: 8 }) {
                    Text(this.daily.pinyin)
                      .fontSize(16)
                      .fontColor(AppTheme.INK_LIGHT)
                    Text(Constants.gradeLabel(this.daily.grade))
                      .fontSize(10)
                      .fontColor(AppTheme.ACCENT)
                      .backgroundColor(AppTheme.ACCENT_SOFT)
                      .borderRadius(8)
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  }
                  Text(`共 ${this.daily.strokes.length} 笔 · ${CharUtil.typeSummary(this.daily)}`)
                    .fontSize(11)
                    .fontColor(AppTheme.INK_FAINT)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(this.dailyAttempts > 0 ? `已练习 ${this.dailyAttempts} 次 · 最佳 ${this.dailyBest} 分` :
                    '还没有练过这个字')
                    .fontSize(11)
                    .fontColor(AppTheme.INK_LIGHT)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                ProgressRing({
                  percent: this.dailyMastery,
                  size: 62,
                  ringWidth: 6,
                  label: '掌握'
                })
              }
              .width('100%')

              Button('开始练习')
                .width('100%')
                .height(44)
                .type(ButtonType.Capsule)
                .fontSize(15)
                .fontColor('#FFFFFF')
                .backgroundColor(AppTheme.ACCENT)
                .onClick(() => {
                  this.openDetail(this.daily.char);
                })
            } else {
              Column({ space: 8 }) {
                Text('该年级字库正在整理')
                  .fontSize(15)
                  .fontColor(AppTheme.INK_LIGHT)
                Text('当前内置一、二年级常用字，可切换年级查看')
                  .fontSize(12)
                  .fontColor(AppTheme.INK_FAINT)
              }
              .width('100%')
              .padding({ top: 20, bottom: 20 })
            }
          }
          .width('100%')
          .padding(18)
          .linearGradient({
            angle: 135,
            colors: [['#FFF9EF', 0], ['#F1E5D0', 1]]
          })
          .borderRadius(22)
          .shadow({ radius: 16, color: '#1A8A6D4F', offsetY: 6 })

          // 年级选择
          Column({ space: 10 }) {
            Row() {
              Text('选择年级')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(AppTheme.INK)
              Blank()
              Text('字库')
                .fontSize(12)
                .fontColor(AppTheme.ACCENT)
                .onClick(() => {
                  this.openList();
                })
            }
            .width('100%')
            Row({ space: 8 }) {
              ForEach(this.grades, (grade: number) => {
                this.gradeChip(grade)
              }, (grade: number) => `${grade}`)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppTheme.CARD)
          .borderRadius(18)

          // 学习概览
          Column({ space: 12 }) {
            Row() {
              Text('学习进度')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(AppTheme.INK)
              Blank()
              Text(this.stats.todayCount > 0 ? `今日已练 ${this.stats.todayCount} 次` : '今日还没动笔')
                .fontSize(11)
                .fontColor(this.stats.todayCount > 0 ? AppTheme.GREEN : AppTheme.INK_FAINT)
            }
            .width('100%')
            Row() {
              this.statCell(`${this.stats.totalAttempts}`, '练习次数')
              Divider().vertical(true).height(24).color(AppTheme.CARD_ALT)
              this.statCell(`${this.stats.totalChars}`, '已练字数')
              Divider().vertical(true).height(24).color(AppTheme.CARD_ALT)
              this.statCell(`${this.stats.masteredCount}`, '已掌握')
              Divider().vertical(true).height(24).color(AppTheme.CARD_ALT)
              this.statCell(this.stats.avgScore > 0 ? `${this.stats.avgScore}` : '—', '平均分')
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppTheme.CARD)
          .borderRadius(18)

          // 快捷入口
          Row({ space: 12 }) {
            this.quickEntry('字库', '按年级与笔画筛选', AppTheme.ACCENT, 'list')
            this.quickEntry('统计', '掌握度热力图', AppTheme.GREEN, 'stats')
            this.quickEntry('设置', '速度与触感', AppTheme.GOLD, 'settings')
          }
          .width('100%')

          // 最近练习
          Column({ space: 4 }) {
            Row() {
              Text('最近练习')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(AppTheme.INK)
              Blank()
              if (this.recent.length > 0) {
                Text('查看统计')
                  .fontSize(12)
                  .fontColor(AppTheme.ACCENT)
                  .onClick(() => {
                    this.openStats();
                  })
              }
            }
            .width('100%')
            .padding({ bottom: 4 })
            if (this.recent.length === 0) {
              Text(this.loading ? '正在载入字库…' : '还没有练习记录，从今日推荐开始吧')
                .fontSize(12)
                .fontColor(AppTheme.INK_FAINT)
                .padding({ top: 12, bottom: 12 })
            } else {
              ForEach(this.recent, (record: PracticeRecord) => {
                this.recentRow(record)
              }, (record: PracticeRecord) => `${record.id}`)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppTheme.CARD)
          .borderRadius(18)

          Text(`HarmonyInk v${Constants.VERSION} · 纯离线 · 仅震动权限`)
            .fontSize(10)
            .fontColor(AppTheme.INK_FAINT)
            .padding({ top: 8, bottom: 20 })
        }
        .width('100%')
        .padding({ left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING })
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BG)
  }
}
