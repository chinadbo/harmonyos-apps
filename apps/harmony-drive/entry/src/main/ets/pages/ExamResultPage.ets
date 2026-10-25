/**
 * 成绩单：分数、合格判定、薄弱章节、再考一次
 */
import router from '@ohos.router'
import { ExamReport } from '../data/ExamEngine'
import { ExamResultCard } from '../components/ExamResultCard'

@Entry
@Component
struct ExamResultPage {
  @State report: ExamReport | undefined = undefined
  @StorageLink('refreshKey') refreshKey: number = 0

  aboutToAppear(): void {
    const r = AppStorage.get('lastExamReport') as ExamReport
    if (r !== undefined) {
      this.report = r
    } else {
      router.replaceUrl({ url: 'pages/Index' })
    }
  }

  aboutToDisappear(): void {
    this.refreshKey = this.refreshKey + 1
  }

  build() {
    Column() {
      Text('考试成绩')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2937')
        .margin({ top: 16, bottom: 12 })

      Scroll() {
        Column() {
          if (this.report !== undefined) {
            ExamResultCard({ report: this.report })

            Text(`共 ${this.report.total} 题 · 用时记录已保存，错题已自动加入错题本`)
              .fontSize(12)
              .fontColor('#9CA3AF')
              .margin({ top: 16 })

            Row() {
              Button('再考一次')
                .fontSize(15)
                .height(44)
                .layoutWeight(1)
                .fontColor('#FFFFFF')
                .backgroundColor('#1C64F2')
                .borderRadius(22)
                .onClick(() => {
                  router.replaceUrl({ url: 'pages/ExamPage' })
                })
              Button('回首页')
                .fontSize(15)
                .height(44)
                .layoutWeight(1)
                .fontColor('#1F2937')
                .backgroundColor('#F3F4F6')
                .borderRadius(22)
                .margin({ left: 12 })
                .onClick(() => {
                  router.replaceUrl({ url: 'pages/Index' })
                })
            }
            .width('100%')
            .margin({ top: 24 })

            Button(`查看错题本（${this.report.wrongQids.length} 题已加入）`)
              .fontSize(14)
              .height(40)
              .width('100%')
              .fontColor('#DC2626')
              .backgroundColor('#FEF2F2')
              .borderRadius(20)
              .margin({ top: 12, bottom: 30 })
              .onClick(() => {
                router.replaceUrl({ url: 'pages/WrongBookPage' })
              })
          }
        }
        .padding({ left: 16, right: 16 })
        .constraintSize({ minWidth: '100%' })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
