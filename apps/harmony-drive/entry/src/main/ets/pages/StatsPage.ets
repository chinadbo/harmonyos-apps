/**
 * 学习统计：近 7 天正确率 Canvas 折线图 + 章节掌握度
 */
import router from '@ohos.router'
import { DbHelper, AnswerRecord } from '../store/DbHelper'
import { StatsHelper, ChapterMastery, DailyRate } from '../data/StatsHelper'
import { QuestionBank } from '../data/QuestionBank'
import { MasteryBar } from '../components/MasteryBar'

@Entry
@Component
struct StatsPage {
  @StorageLink('currentSubject') currentSubject: number = 1
  @State records: AnswerRecord[] = []
  @State mastery: ChapterMastery[] = []
  @State rates: DailyRate[] = []
  @State totalAnswered: number = 0
  @State totalRate: number = 0
  @State bankSize: number = 0
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private redrawKey: number = 0

  aboutToAppear(): void {
    this.reload()
  }

  onPageShow(): void {
    this.reload()
  }

  async reload(): Promise<void> {
    this.records = await DbHelper.allAnswers()
    const subjectRecords = this.records.filter(r => r.subject === this.currentSubject)
    this.mastery = StatsHelper.mastery(subjectRecords)
    this.rates = StatsHelper.recentRates(this.records)
    this.totalAnswered = this.records.length
    this.totalRate = StatsHelper.overallRate(this.records)
    this.bankSize = QuestionBank.getBySubject(this.currentSubject).length
    this.redrawKey++
    // 数据异步更新后 Canvas 已 onReady，延时重绘
    setTimeout(() => this.drawChart(), 80)
  }

  /** Canvas 折线图：onReady 与数据更新后都重绘 */
  private drawChart(): void {
    const ctx = this.canvasCtx
    const w = ctx.width
    const h = ctx.height
    ctx.clearRect(0, 0, w, h)
    const padL = 34
    const padR = 16
    const padT = 16
    const padB = 30
    const plotW = w - padL - padR
    const plotH = h - padT - padB

    // 网格线 + 纵轴刻度
    ctx.strokeStyle = '#E5E7EB'
    ctx.lineWidth = 1
    ctx.font = '10px sans-serif'
    ctx.fillStyle = '#9CA3AF'
    for (let g = 0; g <= 4; g++) {
      const y = padT + plotH * g / 4
      ctx.beginPath()
      ctx.moveTo(padL, y)
      ctx.lineTo(w - padR, y)
      ctx.stroke()
      const label = `${100 - g * 25}`
      ctx.fillText(label, 8, y + 3)
    }

    const data = this.rates
    const n = data.length
    if (n === 0) {
      return
    }
    const step = n > 1 ? plotW / (n - 1) : 0

    // 折线（跳过无记录的天：置为 0 参与连线，但单独标注）
    ctx.strokeStyle = '#1C64F2'
    ctx.lineWidth = 2
    ctx.beginPath()
    let started = false
    for (let i = 0; i < n; i++) {
      const v = data[i].rate < 0 ? 0 : data[i].rate
      const x = padL + step * i
      const y = padT + plotH * (1 - v / 100)
      if (!started) {
        ctx.moveTo(x, y)
        started = true
      } else {
        ctx.lineTo(x, y)
      }
    }
    ctx.stroke()

    // 数据点 + 底部日期
    for (let i = 0; i < n; i++) {
      const v = data[i].rate < 0 ? 0 : data[i].rate
      const x = padL + step * i
      const y = padT + plotH * (1 - v / 100)
      ctx.beginPath()
      ctx.arc(x, y, 4, 0, Math.PI * 2)
      ctx.fillStyle = data[i].rate < 0 ? '#D1D5DB' : '#1C64F2'
      ctx.fill()
      // 日期标签
      ctx.fillStyle = '#9CA3AF'
      ctx.font = '10px sans-serif'
      ctx.fillText(data[i].date, x - 14, h - 8)
      // 数值标签
      if (data[i].rate >= 0) {
        ctx.fillStyle = '#1C64F2'
        ctx.fillText(`${data[i].rate}%`, x - 10, y - 10)
      }
    }
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(26)
          .fontColor('#1F2937')
          .padding({ left: 4, right: 4 })
          .onClick(() => router.back())
        Text('学习统计')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .margin({ left: 6 })
        Blank()
        Text(this.currentSubject === 1 ? '科目一' : '科目四')
          .fontSize(12)
          .fontColor('#1C64F2')
          .backgroundColor('#E8F0FE')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .borderRadius(12)
      }
      .width('100%')
      .padding({ left: 14, right: 16, top: 10, bottom: 8 })

      Scroll() {
        Column() {
          // 概览
          Row() {
            this.StatTile(`${this.totalAnswered}`, '累计答题', '#1C64F2')
            this.StatTile(`${this.totalRate}%`, '总正确率', '#16A34A')
            this.StatTile(`${this.bankSize}`, '题库题数', '#F59E0B')
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          // 折线图
          Column() {
            Text('近 7 天正确率趋势')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F2937')
              .alignSelf(ItemAlign.Start)
            if (this.redrawKey >= 0) {
              Canvas(this.canvasCtx)
                .width('100%')
                .height(210)
                .margin({ top: 8 })
                .onReady(() => {
                  this.drawChart()
                })
                .onClick(() => this.drawChart())
            }
          }
          .width('100%')
          .padding(16)
          .borderRadius(20)
          .backgroundColor('#FFFFFF')
          .margin({ top: 14 })

          // 章节掌握度
          Column() {
            Text('章节掌握度（按薄弱优先）')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F2937')
              .alignSelf(ItemAlign.Start)
            if (this.mastery.length === 0) {
              Text('暂无答题记录，先去做几道题吧')
                .fontSize(13)
                .fontColor('#9CA3AF')
                .margin({ top: 16, bottom: 12 })
            } else {
              ForEach(this.mastery, (m: ChapterMastery) => {
                MasteryBar({ mastery: m, showRate: true })
              }, (m: ChapterMastery) => `mastery-${m.name}-${m.rate}`)
            }
          }
          .width('100%')
          .padding(16)
          .borderRadius(20)
          .backgroundColor('#FFFFFF')
          .margin({ top: 14, bottom: 24 })
        }
        .padding({ left: 14, right: 14, top: 8 })
        .constraintSize({ minWidth: '100%' })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder
  StatTile(value: string, label: string, color: string) {
    Column() {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(12)
        .fontColor('#6B7280')
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ top: 16, bottom: 16 })
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
    .margin({ right: 6 })
  }
}
