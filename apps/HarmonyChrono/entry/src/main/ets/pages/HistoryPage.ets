import router from '@ohos.router'
import { SessionCard } from '../components/SessionCard'
import { SessionRecord } from '../common/constants'
import { AppStyles } from '../common/styles'
import { sessionModel } from '../model/SessionModel'

interface SessionSummary {
  session: SessionRecord
  lapCount: number
}

@Component
export struct HistoryPage {
  @State private sessions: SessionSummary[] = []

  async aboutToAppear(): Promise<void> {
    const records = await sessionModel.getSessions()
    const summaries: SessionSummary[] = []
    for (let index = 0; index < records.length; index++) {
      const detail = await sessionModel.getSessionDetail(records[index].id)
      summaries.push({
        session: records[index],
        lapCount: detail ? detail.laps.length : 0
      })
    }
    this.sessions = summaries
  }

  private async deleteSession(sessionId: number): Promise<void> {
    await sessionModel.deleteSession(sessionId)
    await this.aboutToAppear()
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Button('Back')
          .backgroundColor('#FFFFFF')
          .fontColor('#1F2937')
          .onClick(() => router.back())
        Blank()
        Text('History')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
      }
      .width('100%')

      if (this.sessions.length === 0) {
        Column({ space: 10 }) {
          Text('No sessions yet')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
          Text('Completed stopwatch sessions will appear here.')
            .fontSize(14)
            .fontColor('#6B7280')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.sessions, (item: SessionSummary) => {
              Column({ space: 10 }) {
                SessionCard({
                  session: item.session,
                  lapCount: item.lapCount
                })
                Row({ space: 12 }) {
                  Button('Open')
                    .layoutWeight(1)
                    .backgroundColor('#4F7AF7')
                    .fontColor(Color.White)
                    .onClick(() => router.pushUrl({ url: 'pages/SessionDetailPage', params: { sessionId: item.session.id } }))
                  Button('Delete')
                    .layoutWeight(1)
                    .backgroundColor('#FEE2E2')
                    .fontColor('#B91C1C')
                    .onClick(() => {
                      this.deleteSession(item.session.id)
                    })
                }
                .width('100%')
              }
            }, (item: SessionSummary) => `${item.session.id}`)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .padding(AppStyles.PAGE_HORIZONTAL_PADDING)
    .backgroundColor(AppStyles.BACKGROUND_COLOR)
  }
}
