/**
 * 首页：进度总览 + 功能入口 + 今日一题摘要
 */
import router from '@ohos.router'
import { Question, EXAM_SIZE } from '../data/Question'
import { QuestionBank } from '../data/QuestionBank'
import { DbHelper } from '../store/DbHelper'
import { PrefsHelper } from '../store/PrefsHelper'
import { StatsHelper } from '../data/StatsHelper'

interface HomeStats {
  todayCount: number
  wrongCount: number
  rate: number
  progress: number // 练习进度 %
}

@Component
struct FeatureEntry {
  @Prop icon: string = ''
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop color: string = '#1C64F2'
  onTap: () => void = () => {}

  build() {
    Column() {
      Text(this.icon)
        .fontSize(30)
        .width(56)
        .height(56)
        .textAlign(TextAlign.Center)
        .borderRadius(16)
        .backgroundColor(this.color + '1A')
      Text(this.title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2937')
        .margin({ top: 10 })
      Text(this.subtitle)
        .fontSize(11)
        .fontColor('#6B7280')
        .margin({ top: 2 })
    }
    .layoutWeight(1)
    .padding({ top: 16, bottom: 16 })
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
    .onClick(() => this.onTap())
  }
}

@Entry
@Component
struct Index {
  @StorageLink('currentSubject') currentSubject: number = 1
  @StorageLink('refreshKey') refreshKey: number = 0
  @State stats: HomeStats = { todayCount: 0, wrongCount: 0, rate: 0, progress: 0 }
  @State daily: Question | undefined = undefined
  @State bankSize: number = 0

  aboutToAppear(): void {
    this.refresh()
  }

  onPageShow(): void {
    this.refresh()
  }

  async refresh(): Promise<void> {
    try {
      const today = await DbHelper.todayCount()
      const wrong = await DbHelper.wrongCount(this.currentSubject)
      const answers = await DbHelper.allAnswers()
      const rate = StatsHelper.overallRate(answers)
      const done = answers.filter(r => r.subject === this.currentSubject)
      const qids = new Set(done.map(r => r.qid))
      const bank = QuestionBank.getBySubject(this.currentSubject)
      const doneInBank = bank.filter(q => qids.has(q.id)).length
      const progress = bank.length > 0 ? Math.round(doneInBank * 100 / bank.length) : 0
      this.stats = { todayCount: today, wrongCount: wrong, rate: rate, progress: progress }
      this.bankSize = bank.length
      this.daily = QuestionBank.dailyQuestion()
    } catch (err) {
    }
  }

  switchSubject(subject: number): void {
    this.currentSubject = subject
    PrefsHelper.setSubject(subject)
    this.refresh()
  }

  build() {
    Column() {
      // 顶部标题 + 科目切换
      Row() {
        Text('驾考通')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
        Blank()
        Row() {
          Text('科目一')
            .fontSize(13)
            .fontWeight(this.currentSubject === 1 ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.currentSubject === 1 ? '#FFFFFF' : '#6B7280')
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .backgroundColor(this.currentSubject === 1 ? '#1C64F2' : 'transparent')
            .borderRadius(16)
            .onClick(() => this.switchSubject(1))
          Text('科目四')
            .fontSize(13)
            .fontWeight(this.currentSubject === 4 ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.currentSubject === 4 ? '#FFFFFF' : '#6B7280')
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .margin({ left: 4 })
            .backgroundColor(this.currentSubject === 4 ? '#1C64F2' : 'transparent')
            .borderRadius(16)
            .onClick(() => this.switchSubject(4))
        }
        .borderRadius(16)
        .backgroundColor('#E8F0FE')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14 })

      Scroll() {
        Column() {
          // 进度总览卡
          Column() {
            Row() {
              Column() {
                Text(`${this.stats.progress}%`)
                  .fontSize(30)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1C64F2')
                Text('题库完成度')
                  .fontSize(12)
                  .fontColor('#6B7280')
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Center)
              Blank()
              Column() {
                Text(`${this.stats.todayCount}`)
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#F59E0B')
                Text('今日已刷')
                  .fontSize(12)
                  .fontColor('#6B7280')
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Center)
              Blank()
              Column() {
                Text(`${this.stats.wrongCount}`)
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#DC2626')
                Text('错题待消灭')
                  .fontSize(12)
                  .fontColor('#6B7280')
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Center)
              Blank()
              Column() {
                Text(`${this.stats.rate}%`)
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#16A34A')
                Text('总体正确率')
                  .fontSize(12)
                  .fontColor('#6B7280')
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)

            Progress({ value: this.stats.progress, total: 100, type: ProgressType.Linear })
              .style({ strokeWidth: 8 })
              .color('#1C64F2')
              .width('100%')
              .margin({ top: 18 })
              .borderRadius(4)

            Text(`当前科目共 ${this.bankSize} 题 · 考试 ${EXAM_SIZE} 题限时 45 分钟 · 90 分合格`)
              .fontSize(11)
              .fontColor('#9CA3AF')
              .margin({ top: 10 })
          }
          .width('100%')
          .padding(18)
          .borderRadius(20)
          .backgroundColor('#FFFFFF')
          .margin({ top: 16 })

          // 今日一题
          Column() {
            Row() {
              Text('每日一题')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1F2937')
              Blank()
              Text(this.daily === undefined ? '' : this.daily.chapter)
                .fontSize(11)
                .fontColor('#6B7280')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .constraintSize({ maxWidth: '50%' })
            }
            .width('100%')

            Text(this.daily === undefined ? '加载中…' : this.daily.stem)
              .fontSize(15)
              .fontColor('#1F2937')
              .lineHeight(23)
              .margin({ top: 10 })
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Row() {
              Text('去答题')
                .fontSize(13)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .padding({ left: 22, right: 22, top: 8, bottom: 8 })
                .borderRadius(18)
                .backgroundColor('#1C64F2')
                .onClick(() => {
                  router.pushUrl({ url: 'pages/PracticePage' })
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.End)
            .margin({ top: 12 })
          }
          .width('100%')
          .padding(16)
          .borderRadius(20)
          .backgroundColor('#FFFFFF')
          .margin({ top: 12 })
          .alignItems(HorizontalAlign.Start)

          // 四大功能入口
          Row() {
            FeatureEntry({
              icon: '📖', title: '顺序练习', subtitle: '按章节刷题',
              color: '#1C64F2',
              onTap: () => router.pushUrl({ url: 'pages/PracticePage' })
            })
            FeatureEntry({
              icon: '📝', title: '模拟考试', subtitle: `${EXAM_SIZE}题·45分钟`,
              color: '#F59E0B',
              onTap: () => router.pushUrl({ url: 'pages/ExamPage' })
            })
          }
          .width('100%')
          .margin({ top: 12 })
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            FeatureEntry({
              icon: '❌', title: '错题本', subtitle: '错题重刷',
              color: '#DC2626',
              onTap: () => router.pushUrl({ url: 'pages/WrongBookPage' })
            })
            FeatureEntry({
              icon: '🎯', title: '专项练习', subtitle: '罚款/记分/标志',
              color: '#16A34A',
              onTap: () => router.pushUrl({ url: 'pages/SpecialPage' })
            })
          }
          .width('100%')
          .margin({ top: 12 })
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            FeatureEntry({
              icon: '💡', title: '考点速记', subtitle: '高频考点卡片',
              color: '#8B5CF6',
              onTap: () => router.pushUrl({ url: 'pages/TipsPage' })
            })
            FeatureEntry({
              icon: '📊', title: '学习统计', subtitle: '趋势与掌握度',
              color: '#0EA5E9',
              onTap: () => router.pushUrl({ url: 'pages/StatsPage' })
            })
          }
          .width('100%')
          .margin({ top: 12, bottom: 24 })
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .constraintSize({ minWidth: '100%' })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
