import promptAction from '@ohos.promptAction'
import { WaterRecord } from '../model/WaterRecord'
import { WaterService } from '../service/WaterService'

@Component
export struct RecordEditPage {
  @Prop record: WaterRecord = new WaterRecord()
  @Prop onSaved: () => void = () => {}
  private waterService: WaterService = WaterService.getInstance()

  private async saveRecord(): Promise<void> {
    try {
      await this.waterService.updateRecord(this.record)
      promptAction.showToast({ message: '记录已更新' })
      this.onSaved()
    } catch (error) {
      promptAction.showToast({ message: '更新失败' })
    }
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Text('编辑记录')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        Column({ space: 8 }) {
          Text(`饮水量：${this.record.amount} ml`)
          Slider({ value: this.record.amount, min: 50, max: 1000, step: 50 })
            .onChange((value: number) => {
              this.record.amount = Math.round(value)
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)

        Column({ space: 8 }) {
          Text(`时间戳：${this.record.timestamp}`)
          Slider({ value: this.record.timestamp, min: Date.now() - 7 * 24 * 60 * 60 * 1000, max: Date.now(), step: 15 * 60 * 1000 })
            .onChange((value: number) => {
              this.record.timestamp = Math.round(value)
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)

        Button('保存')
          .width('100%')
          .height(48)
          .onClick(() => this.saveRecord())
      }
      .width('100%')
      .padding(16)
    }
  }
}
