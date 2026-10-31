import { BabyProfileStore } from '../database/BabyProfileStore';
import { DatabaseHelper } from '../database/DatabaseHelper';
import {
  BabyProfile,
  BabyGender,
  PeriodRecords,
  DaySummary,
  DailyRecord,
  buildDailyRecords
} from '../model/Models';
import { Theme } from '../utils/Theme';
import { TimeUtils } from '../utils/TimeUtils';
import { StatChart } from '../components/StatChart';
import { RecordCard } from '../components/RecordCard';
import { FeedPage } from './FeedPage';
import { DiaperPage } from './DiaperPage';
import { SleepPage } from './SleepPage';
import { GrowthPage } from './GrowthPage';
import { HistoryPage } from './HistoryPage';

/**
 * 首页：今日看板 + 5 个功能 Tab 的容器
 */
@Entry
@Component
struct Index {
  @StorageLink('dataVersion') @Watch('onReload') dataVersion: number = 0;
  @StorageProp('babyName') @Watch('onProfileReload') babyName: string = '';
  @StorageProp('babyBirthday') @Watch('onProfileReload') babyBirthday: number = 0;
  @StorageProp('babyGender') babyGender: string = BabyGender.Boy;
  @State currentTabIndex: number = 0;
  @State todayRecords: PeriodRecords = new PeriodRecords();
  @State recentRecords: DailyRecord[] = [];
  @State weekSummaries: DaySummary[] = [];
  @State weekFeedCounts: number[] = [];
  @State weekLabels: string[] = [];
  @State ongoingSleepStart: number = 0;
  @State profileEditing: boolean = false;
  @State dialogName: string = '';
  @State dialogGender: string = BabyGender.Boy;
  @State dialogBirthday: number = 0;

  aboutToAppear(): void {
    BabyProfileStore.ensureAppStorageKeys();
    BabyProfileStore.ensureDataVersionKey();
    this.initProfile();
    this.loadAll();
  }

  onReload(): void {
    this.loadAll();
  }

  onProfileReload(): void {
    // 档案变化无需重查数据库，仅刷新展示
  }

  private initProfile(): void {
    BabyProfileStore.getInstance().getProfile()
      .then((p: BabyProfile) => {
        BabyProfileStore.syncToAppStorage(p);
        if (p.birthday <= 0) {
          // 首次启动，引导填写宝宝档案
          this.dialogName = p.name.length > 0 ? p.name : '';
          this.dialogGender = p.gender;
          const now = new Date();
          this.dialogBirthday = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 30).getTime();
          this.profileEditing = true;
        }
      })
      .catch((e: Object) => {
        console.error('Index initProfile failed: ' + e);
      });
  }

  private async loadAll(): Promise<void> {
    try {
      const start = TimeUtils.todayStart();
      const records: PeriodRecords =
        await DatabaseHelper.getInstance().queryPeriodRecords(start, start + TimeUtils.DAY);
      this.todayRecords = records;
      this.recentRecords = buildDailyRecords(records);
      this.ongoingSleepStart = 0;
      const sleeps = records.sleeps;
      for (let i = 0; i < sleeps.length; i++) {
        if (sleeps[i].endTime === 0) {
          this.ongoingSleepStart = sleeps[i].startTime;
        }
      }
      const summaries = await DatabaseHelper.getInstance().queryDaySummaries(7);
      this.weekSummaries = summaries;
      const counts: number[] = [];
      const labels: string[] = [];
      for (let i = 0; i < summaries.length; i++) {
        counts.push(summaries[i].feedCount);
        labels.push(summaries[i].label);
      }
      this.weekFeedCounts = counts;
      this.weekLabels = labels;
    } catch (e) {
      console.error('Index loadAll failed: ' + e);
    }
  }

  private todayFeedCount(): number {
    return this.todayRecords.feeds.length;
  }

  private todayFeedMl(): number {
    return DatabaseHelper.calcTotalFeedMl(this.todayRecords.feeds);
  }

  private todayDiaperCount(): number {
    return this.todayRecords.diapers.length;
  }

  private todaySleepMs(): number {
    return DatabaseHelper.calcTotalSleepMs(this.todayRecords.sleeps);
  }

  private genderEmoji(): string {
    return this.babyGender === BabyGender.Girl ? '👧' : '👦';
  }

  private ageText(): string {
    return TimeUtils.ageText(this.babyBirthday, Date.now());
  }

  private saveProfile(): void {
    const name = this.dialogName.trim();
    if (name.length === 0 || this.dialogBirthday <= 0) {
      return;
    }
    const p = new BabyProfile();
    p.name = name;
    p.birthday = this.dialogBirthday;
    p.gender = this.dialogGender;
    BabyProfileStore.getInstance().saveProfile(p)
      .then(() => {
        BabyProfileStore.syncToAppStorage(p);
        this.profileEditing = false;
      })
      .catch((e: Object) => {
        console.error('Index saveProfile failed: ' + e);
      });
  }

  @Builder
  tabBarBuilder(label: string, index: number) {
    Column() {
      Text(label)
        .fontSize(13)
        .fontWeight(this.currentTabIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentTabIndex === index ? Theme.PRIMARY : Theme.TEXT_LIGHT)
        .margin({ top: 4 })
    }
    .width('100%')
    .height(52)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  statCell(value: string, label: string, color: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .maxLines(1)
      Text(label)
        .fontSize(11)
        .fontColor(Theme.TEXT_SUB)
        .margin({ top: 2 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor(Theme.CARD)
    .borderRadius(14)
  }

  @Builder
  sectionHeader(title: string, extra: string) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.TEXT)
      Blank()
      Text(extra)
        .fontSize(12)
        .fontColor(Theme.TEXT_SUB)
    }
    .width('100%')
    .margin({ top: 20, bottom: 10 })
  }

  @Builder
  dashboardBuilder() {
    Scroll() {
      Column() {
        // 宝宝档案卡
        Row() {
          Text(this.genderEmoji())
            .fontSize(38)
            .width(64)
            .height(64)
            .textAlign(TextAlign.Center)
            .backgroundColor('rgba(255,255,255,0.35)')
            .borderRadius(32)
          Column() {
            Text(this.babyName.length > 0 ? this.babyName : '未命名宝宝')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
            Text(this.ageText())
              .fontSize(13)
              .fontColor('rgba(255,255,255,0.9)')
              .margin({ top: 4 })
            Text('今天 ' + TimeUtils.formatDate(Date.now()))
              .fontSize(11)
              .fontColor('rgba(255,255,255,0.75)')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 14 })

          Text('✎')
            .fontSize(18)
            .fontColor(Color.White)
            .width(36)
            .height(36)
            .textAlign(TextAlign.Center)
            .backgroundColor('rgba(255,255,255,0.25)')
            .borderRadius(18)
            .onClick(() => {
              this.dialogName = this.babyName;
              this.dialogGender = this.babyGender;
              this.dialogBirthday = this.babyBirthday > 0
                ? this.babyBirthday
                : Date.now() - 30 * TimeUtils.DAY;
              this.profileEditing = true;
            })
        }
        .width('100%')
        .padding(16)
        .linearGradient({
          angle: 135,
          colors: [[Theme.PRIMARY, 0], [Theme.PINK, 1]]
        })
        .borderRadius(18)

        // 睡眠中提示
        if (this.ongoingSleepStart > 0) {
          Row() {
            Text('😴')
              .fontSize(18)
            Text('宝宝睡眠中 · ' + TimeUtils.formatTime(this.ongoingSleepStart) + ' 入睡，去睡眠页结束打卡')
              .fontSize(12)
              .fontColor(Theme.PURPLE)
              .margin({ left: 8 })
          }
          .width('100%')
          .padding({ top: 10, bottom: 10, left: 14, right: 14 })
          .backgroundColor(Theme.PURPLE_LIGHT)
          .borderRadius(12)
          .margin({ top: 12 })
        }

        // 今日统计
        Row({ space: 10 }) {
          this.statCell(String(this.todayFeedCount()), '喂养次数', Theme.PRIMARY)
          this.statCell(this.todayFeedMl() + 'ml', '奶量/辅食', Theme.YELLOW)
        }
        .width('100%')
        .margin({ top: 12 })

        Row({ space: 10 }) {
          this.statCell(String(this.todayDiaperCount()), '换尿布', Theme.BLUE)
          this.statCell(TimeUtils.formatDurationShort(this.todaySleepMs()), '睡眠时长', Theme.PURPLE)
        }
        .width('100%')
        .margin({ top: 10 })

        // 近 7 天喂养柱状图
        this.sectionHeader('近 7 天喂养次数', '')
        StatChart({
          values: this.weekFeedCounts,
          labels: this.weekLabels,
          mode: 'bar',
          chartColor: Theme.PRIMARY,
          unit: '次',
          decimals: 0
        })

        // 今日动态
        this.sectionHeader('今日动态', this.recentRecords.length + ' 条')
        if (this.recentRecords.length === 0) {
          Text('今天还没有记录，去「喂养」「尿布」或「睡眠」页打卡吧')
            .fontSize(13)
            .fontColor(Theme.TEXT_LIGHT)
            .margin({ top: 24, bottom: 24 })
        } else {
          List() {
            ForEach(this.recentRecords, (item: DailyRecord) => {
              ListItem() {
                RecordCard({
                  icon: item.icon,
                  title: item.title,
                  subtitle: item.subtitle,
                  timeMs: item.timeMs
                })
              }
              .margin({ bottom: 8 })
            }, (item: DailyRecord) => item.kind + item.recordId.toString())
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
  }

  @Builder
  profileDialogBuilder() {
    Column() {
      Text('宝宝档案')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.TEXT)

      TextInput({ placeholder: '宝宝昵称', text: this.dialogName })
        .height(42)
        .fontSize(14)
        .backgroundColor(Theme.GRAY_BG)
        .margin({ top: 16 })
        .onChange((value: string) => {
          this.dialogName = value;
        })

      Row() {
        Text('性别')
          .fontSize(14)
          .fontColor(Theme.TEXT_SUB)
        Blank()
        Text('👦 男孩')
          .fontSize(14)
          .fontColor(this.dialogGender === BabyGender.Boy ? Color.White : Theme.TEXT)
          .backgroundColor(this.dialogGender === BabyGender.Boy ? Theme.PRIMARY : Theme.GRAY_BG)
          .borderRadius(14)
          .padding({ left: 14, right: 14, top: 6, bottom: 6 })
          .onClick(() => {
            this.dialogGender = BabyGender.Boy;
          })
        Text('👧 女孩')
          .fontSize(14)
          .fontColor(this.dialogGender === BabyGender.Girl ? Color.White : Theme.TEXT)
          .backgroundColor(this.dialogGender === BabyGender.Girl ? Theme.PINK : Theme.GRAY_BG)
          .borderRadius(14)
          .padding({ left: 14, right: 14, top: 6, bottom: 6 })
          .margin({ left: 10 })
          .onClick(() => {
            this.dialogGender = BabyGender.Girl;
          })
      }
      .width('100%')
      .margin({ top: 14 })

      Column() {
        Text('出生日期')
          .fontSize(12)
          .fontColor(Theme.TEXT_SUB)
        DatePicker({
          start: new Date(2020, 0, 1),
          end: new Date(),
          selected: new Date(this.dialogBirthday)
        })
          .lunar(false)
          .onChange((value: Date) => {
            this.dialogBirthday = value.getTime();
          })
      }
      .width('100%')
      .margin({ top: 6 })

      Row() {
        Button('取消')
          .height(40)
          .fontSize(14)
          .layoutWeight(1)
          .backgroundColor(Theme.GRAY_BG)
          .fontColor(Theme.TEXT_SUB)
          .onClick(() => {
            this.profileEditing = false;
          })
        Button('保存')
          .height(40)
          .fontSize(14)
          .layoutWeight(1)
          .backgroundColor(Theme.PRIMARY)
          .margin({ left: 10 })
          .enabled(this.dialogName.trim().length > 0 && this.dialogBirthday > 0)
          .opacity(this.dialogName.trim().length > 0 && this.dialogBirthday > 0 ? 1 : 0.5)
          .onClick(() => {
            this.saveProfile();
          })
      }
      .width('100%')
      .margin({ top: 16 })
    }
    .width('86%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(20)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Tabs({ barPosition: BarPosition.End, index: this.currentTabIndex }) {
          TabContent() {
            this.dashboardBuilder()
          }
            .tabBar(this.tabBarBuilder('今日', 0))

          TabContent() {
            FeedPage()
          }
            .tabBar(this.tabBarBuilder('喂养', 1))

          TabContent() {
            DiaperPage()
          }
            .tabBar(this.tabBarBuilder('尿布', 2))

          TabContent() {
            SleepPage()
          }
            .tabBar(this.tabBarBuilder('睡眠', 3))

          TabContent() {
            GrowthPage()
          }
            .tabBar(this.tabBarBuilder('成长', 4))

          TabContent() {
            HistoryPage()
          }
            .tabBar(this.tabBarBuilder('月历', 5))
        }
        .width('100%')
        .layoutWeight(1)
        .barHeight(56)
        .onChange((index: number) => {
          this.currentTabIndex = index;
        })
      }
      .width('100%')
      .height('100%')

      if (this.profileEditing) {
        Column() {
          this.profileDialogBuilder()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.4)')
        .justifyContent(FlexAlign.Center)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.profileEditing = false;
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }
}
