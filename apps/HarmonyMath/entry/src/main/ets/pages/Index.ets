import router from '@ohos.router';
import { Theme } from '../model/Theme';
import { PracticeParams } from '../model/Models';
import { RdbHelper } from '../data/RdbHelper';
import { PreferencesUtil } from '../data/PreferencesUtil';
import { todayYMD } from '../utils/DateUtil';

interface ModeOption {
  title: string;
  mode: string;
  desc: string;
  color: string;
}

interface DiffOption {
  level: number;
  label: string;
  desc: string;
}

interface LimitOption {
  label: string;
  sec: number;
}

@Entry
@Component
struct Index {
  @State streakDays: number = 0;
  @State todayCount: number = 0;
  @State dailyGoal: number = 20;
  @State selectedMode: string = 'addsub';
  @State difficulty: number = 1;
  @State limitSec: number = 0;
  @State soundOn: boolean = true;
  @State vibrateOn: boolean = true;

  private modes: ModeOption[] = [
    { title: '加减法', mode: 'addsub', desc: '加法与减法', color: '#4A90D9' },
    { title: '乘除法', mode: 'muldiv', desc: '乘法与除法', color: '#E8734A' },
    { title: '混合运算', mode: 'mixed', desc: '四则混合出题', color: '#5B8C5A' },
    { title: '错题重练', mode: 'wrong', desc: '攻克错题本', color: '#9B59B6' }
  ];
  private diffs: DiffOption[] = [
    { level: 1, label: '简单', desc: '10 以内' },
    { level: 2, label: '普通', desc: '100 以内' },
    { level: 3, label: '困难', desc: '口诀 + 两步' }
  ];
  private limits: LimitOption[] = [
    { label: '不限时', sec: 0 },
    { label: '60 秒', sec: 60 },
    { label: '120 秒', sec: 120 }
  ];

  aboutToAppear(): void {
    this.refresh();
  }

  onPageShow(): void {
    this.refresh();
  }

  private async refresh(): Promise<void> {
    const prefs: PreferencesUtil = PreferencesUtil.getInstance();
    await prefs.ready();
    this.streakDays = await prefs.getStreakDays();
    this.soundOn = await prefs.getSoundOn();
    this.vibrateOn = await prefs.getVibrateOn();
    this.dailyGoal = await prefs.getDailyGoal();
    const rdb: RdbHelper = RdbHelper.getInstance();
    await rdb.ready();
    const rows = await rdb.queryRecordRows();
    const today: string = todayYMD();
    let sum: number = 0;
    for (const row of rows) {
      if (row.date === today) {
        sum += row.total;
      }
    }
    this.todayCount = sum;
  }

  build() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 2 }) {
          Text($r('app.string.title_index'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT_DARK)
          Text('每天练一组，口算快又准')
            .fontSize(12)
            .fontColor(Theme.TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Column({ space: 2 }) {
          Text(`${this.streakDays}`)
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.WARNING)
          Text('连续打卡天')
            .fontSize(11)
            .fontColor(Theme.TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')

      this.GoalCard()

      Text('练习模式')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.TEXT_DARK)
        .width('100%')

      Grid() {
        ForEach(this.modes, (m: ModeOption) => {
          GridItem() {
            Column({ space: 6 }) {
              Text(m.title)
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.selectedMode === m.mode ? Color.White : Theme.TEXT_DARK)
              Text(m.desc)
                .fontSize(11)
                .fontColor(this.selectedMode === m.mode ? '#FFFFFFCC' : Theme.TEXT_SECONDARY)
            }
            .width('100%')
            .height(86)
            .padding(12)
            .borderRadius(16)
            .backgroundColor(this.selectedMode === m.mode ? m.color : Color.White)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.selectedMode = m.mode;
            })
          }
        }, (m: ModeOption) => m.mode)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%')
      .height(184)

      Text('难度选择')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.TEXT_DARK)
        .width('100%')

      Row({ space: 10 }) {
        ForEach(this.diffs, (d: DiffOption) => {
          Column({ space: 2 }) {
            Text(d.label)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.difficulty === d.level ? Color.White : Theme.TEXT_DARK)
            Text(d.desc)
              .fontSize(10)
              .fontColor(this.difficulty === d.level ? '#FFFFFFCC' : Theme.TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .padding({ top: 8, bottom: 8 })
          .borderRadius(12)
          .backgroundColor(this.difficulty === d.level ? Theme.PRIMARY : Color.White)
          .onClick(() => {
            this.difficulty = d.level;
          })
        }, (d: DiffOption) => `${d.level}`)
      }
      .width('100%')

      Text('限时模式')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.TEXT_DARK)
        .width('100%')

      Row({ space: 10 }) {
        ForEach(this.limits, (l: LimitOption) => {
          Text(l.label)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.limitSec === l.sec ? Color.White : Theme.TEXT_DARK)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .padding({ top: 8, bottom: 8 })
            .borderRadius(12)
            .backgroundColor(this.limitSec === l.sec ? Theme.PRIMARY : Color.White)
            .onClick(() => {
              this.limitSec = l.sec;
            })
        }, (l: LimitOption) => `${l.sec}`)
      }
      .width('100%')

      Button('开始练习')
        .width('100%')
        .height(48)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(Theme.PRIMARY)
        .borderRadius(14)
        .onClick(() => {
          this.startPractice();
        })

      Blank()

      this.BottomNav()
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 12 })
    .backgroundColor(Theme.BG)
  }

  @Builder
  GoalCard() {
    Column({ space: 8 }) {
      Row() {
        Text('今日目标')
          .fontSize(13)
          .fontColor(Theme.TEXT_SECONDARY)
        Blank()
        Text(`${this.todayCount} / ${this.dailyGoal} 题`)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.PRIMARY)
      }
      .width('100%')

      Progress({ value: this.goalPercent(), total: 100, type: ProgressType.Linear })
        .color(this.todayCount >= this.dailyGoal ? Theme.SUCCESS : Theme.PRIMARY)
        .width('100%')

      if (this.todayCount >= this.dailyGoal && this.dailyGoal > 0) {
        Text('今日目标已达成，保持节奏！')
          .fontSize(11)
          .fontColor(Theme.SUCCESS)
      }
    }
    .width('100%')
    .padding(14)
    .borderRadius(16)
    .backgroundColor(Color.White)
  }

  @Builder
  BottomNav() {
    Row() {
      this.NavItem('统', '练习统计', 'pages/StatsPage')
      this.NavItem('诀', '口诀表', 'pages/TimesTablePage')
      this.NavItem('错', '错题本', 'pages/WrongBookPage')
    }
    .width('100%')
    .padding({ top: 8, bottom: 4 })
    .borderRadius(16)
    .backgroundColor(Color.White)
  }

  @Builder
  NavItem(icon: string, label: string, url: string) {
    Column({ space: 4 }) {
      Text(icon)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.PRIMARY)
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .borderRadius(20)
        .backgroundColor(Theme.PRIMARY_LIGHT)
      Text(label)
        .fontSize(12)
        .fontColor(Theme.TEXT_SECONDARY)
    }
    .layoutWeight(1)
    .onClick(() => {
      router.pushUrl({ url: url });
    })
  }

  private goalPercent(): number {
    if (this.dailyGoal <= 0) {
      return 0;
    }
    const percent: number = Math.round(this.todayCount * 100 / this.dailyGoal);
    if (percent > 100) {
      return 100;
    }
    return percent;
  }

  private startPractice(): void {
    const params: PracticeParams = {
      mode: this.selectedMode,
      difficulty: this.difficulty,
      limitSec: this.limitSec
    };
    router.pushUrl({ url: 'pages/PracticePage', params: params });
  }
}
