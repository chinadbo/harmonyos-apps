import router from '@ohos.router';
import { BusinessError } from '@ohos.base';
import { Theme } from '../model/Theme';
import { ResultParams, PracticeParams, WrongItem, AchievementDef } from '../model/Models';
import { ACHIEVEMENT_DEFS, checkAchievements } from '../model/Achievements';
import { RdbHelper } from '../data/RdbHelper';
import { PreferencesUtil } from '../data/PreferencesUtil';
import { BadgeComponent } from '../components/BadgeComponent';
import { todayYMD } from '../utils/DateUtil';

@Entry
@Component
struct ResultPage {
  @State score: number = 0;
  @State correct: number = 0;
  @State total: number = 0;
  @State durationSec: number = 0;
  @State accuracy: number = 0;
  @State streakDays: number = 0;
  @State wrongItems: WrongItem[] = [];
  @State unlockedKeys: string[] = [];
  @State newKeys: string[] = [];
  @State saveMsg: string = '正在保存成绩…';

  private mode: string = 'addsub';
  private difficulty: number = 1;
  private limitSec: number = 0;

  aboutToAppear(): void {
    const p: ResultParams = router.getParams() as ResultParams;
    if (p !== undefined && p !== null) {
      this.mode = p.mode === undefined ? 'addsub' : p.mode;
      this.difficulty = p.difficulty === undefined ? 1 : p.difficulty;
      this.limitSec = p.limitSec === undefined ? 0 : p.limitSec;
      this.total = p.total === undefined ? 0 : p.total;
      this.correct = p.correct === undefined ? 0 : p.correct;
      this.durationSec = p.durationSec === undefined ? 0 : p.durationSec;
      this.wrongItems = p.wrongItems === undefined ? [] : p.wrongItems;
    }
    this.score = this.correct * 10;
    this.accuracy = this.total > 0 ? Math.round(this.correct * 100 / this.total) : 0;
    this.persist();
  }

  private async persist(): Promise<void> {
    try {
      const rdb: RdbHelper = RdbHelper.getInstance();
      await rdb.ready();
      await rdb.insertRecord(todayYMD(), this.mode, this.difficulty,
        this.total, this.correct, this.durationSec);
      await rdb.insertWrongQuestions(this.wrongItems);

      const prefs: PreferencesUtil = PreferencesUtil.getInstance();
      await prefs.ready();
      this.streakDays = await prefs.updateStreak(todayYMD());

      const rows = await rdb.queryRecordRows();
      let totalQuestions: number = 0;
      for (const row of rows) {
        totalQuestions += row.total;
      }
      const should: string[] = checkAchievements(rows.length, totalQuestions,
        this.streakDays, this.total, this.correct);
      const newly: string[] = [];
      for (const key of should) {
        const isNew: boolean = await rdb.unlockAchievement(key);
        if (isNew) {
          newly.push(key);
        }
      }
      this.newKeys = newly;
      this.unlockedKeys = await rdb.queryAchievements();
      this.saveMsg = '本次成绩、错题与打卡已保存';
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      this.saveMsg = `保存失败：${e.message}`;
      console.error(`[ResultPage] persist failed, code=${e.code}`);
    }
  }

  build() {
    Column({ space: 14 }) {
      Scroll() {
        Column({ space: 14 }) {
          Text($r('app.string.title_result'))
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT_DARK)
            .width('100%')

          Column({ space: 8 }) {
            Text(`${this.score}`)
              .fontSize(64)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.accuracy >= 60 ? Theme.PRIMARY : Theme.WARNING)
            Text('分')
              .fontSize(14)
              .fontColor(Theme.TEXT_SECONDARY)
            Text(this.comment())
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.TEXT_DARK)
          }
          .width('100%')
          .padding({ top: 20, bottom: 20 })
          .borderRadius(20)
          .backgroundColor(Color.White)

          Row({ space: 10 }) {
            this.StatCell(`${this.accuracy}%`, '正确率')
            this.StatCell(this.durationText(), '用时')
            this.StatCell(`${this.correct}/${this.total}`, '答对题数')
          }
          .width('100%')

          Column({ space: 8 }) {
            Text(`连续打卡 ${this.streakDays} 天 · ${this.saveMsg}`)
              .fontSize(12)
              .fontColor(Theme.TEXT_SECONDARY)
              .width('100%')

            Text('成就徽章')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.TEXT_DARK)
              .width('100%')

            Row({ space: 8 }) {
              ForEach(ACHIEVEMENT_DEFS, (def: AchievementDef) => {
                BadgeComponent({
                  unlocked: this.unlockedKeys.indexOf(def.key) >= 0,
                  isNew: this.newKeys.indexOf(def.key) >= 0,
                  label: def.label,
                  icon: def.icon
                })
              }, (def: AchievementDef) => def.key)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .padding(14)
          .borderRadius(16)
          .backgroundColor(Color.White)

          if (this.wrongItems.length > 0) {
            Column({ space: 10 }) {
              Text(`错题摘要（${this.wrongItems.length} 题）`)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.TEXT_DARK)
                .width('100%')
              ForEach(this.wrongItems, (item: WrongItem, index: number) => {
                Row() {
                  Text(item.stem)
                    .fontSize(15)
                    .fontColor(Theme.TEXT_DARK)
                    .layoutWeight(1)
                  Text(`答 ${item.userAnswer} · 正确 ${item.answer}`)
                    .fontSize(12)
                    .fontColor(Theme.DANGER)
                }
                .width('100%')
                .padding({ top: 6, bottom: 6, left: 10, right: 10 })
                .borderRadius(10)
                .backgroundColor(Theme.DANGER_LIGHT)
              }, (item: WrongItem, index: number) => `${index}_${item.stem}`)
            }
            .width('100%')
            .padding(14)
            .borderRadius(16)
            .backgroundColor(Color.White)
            .alignItems(HorizontalAlign.Start)
          }

          Row({ space: 12 }) {
            Button('再来一组')
              .layoutWeight(1)
              .height(44)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .backgroundColor(Theme.PRIMARY)
              .onClick(() => {
                this.againPractice();
              })
            Button('返回首页')
              .layoutWeight(1)
              .height(44)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .backgroundColor(Color.White)
              .fontColor(Theme.PRIMARY)
              .borderRadius(10)
              .onClick(() => {
                router.back();
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.TopStart)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  @Builder
  StatCell(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.TEXT_DARK)
      Text(label)
        .fontSize(11)
        .fontColor(Theme.TEXT_SECONDARY)
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
    .borderRadius(12)
    .backgroundColor(Theme.PRIMARY_LIGHT)
  }

  private comment(): string {
    if (this.total === 0) {
      return '没有完成题目，再试一次吧';
    }
    if (this.accuracy === 100) {
      return '太棒了，全部答对！';
    }
    if (this.accuracy >= 80) {
      return '很不错的成绩！';
    }
    if (this.accuracy >= 60) {
      return '不错的开始，继续加油！';
    }
    return '多多练习，会越来越好';
  }

  private durationText(): string {
    const minutes: number = Math.floor(this.durationSec / 60);
    const seconds: number = this.durationSec % 60;
    if (minutes > 0) {
      return `${minutes}分${seconds}秒`;
    }
    return `${seconds}秒`;
  }

  private againPractice(): void {
    router.replaceUrl({
      url: 'pages/PracticePage',
      params: {
        mode: this.mode,
        difficulty: this.difficulty,
        limitSec: this.limitSec
      } as PracticeParams
    });
  }
}
