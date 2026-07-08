import measurementRepository, { MeasurementSession } from '../data/MeasurementRepository'
import { UIContext } from '@ohos.arkui'

@Entry
@Component
struct History {
  @State sessions: MeasurementSession[] = []
  @State isLoading: boolean = true

  aboutToAppear() {
    this.loadSessions()
  }

  async loadSessions(): Promise<void> {
    this.isLoading = true
    await measurementRepository.init()
    this.sessions = await measurementRepository.getAllSessions()
    this.isLoading = false
  }

  async deleteSession(id: number): Promise<void> {
    await measurementRepository.deleteSession(id)
    await this.loadSessions()
  }

  formatDuration(seconds: number): string {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    if (mins > 0) {
      return `${mins}m ${secs}s`
    }
    return `${secs}s`
  }

  formatTime(timestamp: number): string {
    const date = new Date(timestamp)
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`
  }

  build() {
    Column() {
      Row() {
        Button() {
          Text('← Back')
            .fontSize(16)
            .fontColor($r('app.color.primary'))
        }
        .backgroundColor('transparent')
        .onClick(() => {
          const ctx = this.getUIContext() as UIContext
          ctx.getRouter().back()
        })

        Text('History')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Start)

      if (this.isLoading) {
        Text('Loading...')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 40 })
      } else if (this.sessions.length === 0) {
        Text($r('app.string.no_history'))
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 40 })
      } else {
        List() {
          ForEach(this.sessions, (session: MeasurementSession, index: number) => {
            ListItem() {
              Column() {
                Row() {
                  Text(this.formatTime(session.startTime))
                    .fontSize(14)
                    .fontColor($r('app.color.text_secondary'))

                  Text(`${this.formatDuration(session.duration)}`)
                    .fontSize(14)
                    .fontColor($r('app.color.text_secondary'))
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)

                Row() {
                  Column() {
                    Text('Avg')
                      .fontSize(12)
                      .fontColor($r('app.color.text_secondary'))
                    Text(`${session.avgDb.toFixed(1)} dB`)
                      .fontSize(18)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('app.color.text_primary'))
                  }
                  .layoutWeight(1)

                  Column() {
                    Text('Max')
                      .fontSize(12)
                      .fontColor($r('app.color.text_secondary'))
                    Text(`${session.maxDb.toFixed(1)} dB`)
                      .fontSize(18)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('app.color.danger'))
                  }
                  .layoutWeight(1)

                  Column() {
                    Text('Min')
                      .fontSize(12)
                      .fontColor($r('app.color.text_secondary'))
                    Text(`${session.minDb.toFixed(1)} dB`)
                      .fontSize(18)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('app.color.safe'))
                  }
                  .layoutWeight(1)

                  Button() {
                    Text('Delete')
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                  }
                  .width(60)
                  .height(32)
                  .backgroundColor($r('app.color.danger'))
                  .onClick(() => {
                    this.deleteSession(session.id)
                  })
                }
                .width('100%')
                .margin({ top: 8 })
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.card_background'))
              .borderRadius(12)
              .margin({ bottom: 12 })
            }
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}

export default History
