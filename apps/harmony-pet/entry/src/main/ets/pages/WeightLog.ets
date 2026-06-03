import router from '@ohos.router'
import common from '@ohos.app.ability.common'
import { WeightDao } from '../database/WeightDao'
import type { WeightRecord } from '../model/WeightRecord'
import { DateUtils } from '../common/DateUtils'
import { WeightChart } from '../components/WeightChart'

@Entry
@Component
export struct WeightLog {
  @StorageLink('dataVersion') dataVersion: number = 0
  @State petId: number = 0
  @State records: WeightRecord[] = []
  @State dialogVisible: boolean = false
  @State weightText: string = ''
  @State recordDate: string = DateUtils.today()
  @State note: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, number>
    this.petId = Number(params?.petId ?? AppStorage.get<number>('activePetId') ?? 0)
    this.loadRecords()
  }

  private getAbilityContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext
  }

  private async loadRecords(): Promise<void> {
    if (this.petId <= 0) {
      return
    }
    const dao: WeightDao = new WeightDao(this.getAbilityContext())
    this.records = await dao.queryByPetId(this.petId)
  }

  private goBack(): void {
    const stack = AppStorage.get<NavPathStack>('navPathStack') as unknown as Record<string, Function>
    if (stack && typeof stack.pop === 'function') {
      stack.pop()
    }
    router.back()
  }

  private async addRecord(): Promise<void> {
    const weight: number = Number(this.weightText)
    if (!weight || this.petId <= 0) {
      return
    }
    const dao: WeightDao = new WeightDao(this.getAbilityContext())
    await dao.insert({
      petId: this.petId,
      weight,
      recordDate: this.recordDate,
      note: this.note,
      createdAt: DateUtils.nowTimestamp()
    })
    AppStorage.setOrCreate('dataVersion', (AppStorage.get<number>('dataVersion') ?? 0) + 1)
    this.dialogVisible = false
    this.weightText = ''
    this.note = ''
    await this.loadRecords()
  }

  @Builder
  recordDialog() {
    Column({ space: 12 }) {
      Text('添加体重')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      TextInput({ placeholder: '体重（kg）', text: this.weightText })
        .onChange((value: string) => this.weightText = value)
      TextInput({ placeholder: '备注', text: this.note })
        .onChange((value: string) => this.note = value)
      DatePicker({ start: new Date('2010-01-01'), end: new Date(), selected: new Date(`${this.recordDate}T00:00:00`) })
        .onChange((value: Date) => this.recordDate = DateUtils.toDateOnly(value))
      Row({ space: 10 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor('#F3F3F3')
          .fontColor('#666666')
          .onClick(() => this.dialogVisible = false)
        Button('保存')
          .layoutWeight(1)
          .onClick(() => this.addRecord())
      }
    }
    .padding(20)
    .width('100%')
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Button('返回')
          .type(ButtonType.Capsule)
          .backgroundColor('#FFFFFF')
          .fontColor('#666666')
          .onClick(() => this.goBack())
        Blank()
        Text('体重记录')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
        Blank()
      }

      WeightChart({ data: this.records })

      Text('最近记录')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .width('100%')

      List({ space: 10 }) {
        ForEach(this.records, (item: WeightRecord) => {
          ListItem() {
            Row() {
              Column({ space: 4 }) {
                Text(`${item.weight.toFixed(1)} kg`)
                  .fontSize(17)
                  .fontWeight(FontWeight.Medium)
                Text(item.recordDate)
                  .fontSize(12)
                  .fontColor('#888888')
                if (item.note) {
                  Text(item.note)
                    .fontSize(12)
                    .fontColor('#999999')
                }
              }
              .layoutWeight(1)
            }
            .padding(14)
            .borderRadius(16)
            .backgroundColor('#FFFFFF')
          }
        }, (item: WeightRecord) => `${item.id}`)
      }
      .layoutWeight(1)
      .width('100%')

      Button('添加体重')
        .width('100%')
        .height(48)
        .onClick(() => this.dialogVisible = true)
    }
    .padding(16)
    .backgroundColor('#F6F7FB')
    .height('100%')
    .bindContentCover($$this.dialogVisible, this.recordDialog(), { modalTransition: ModalTransition.DEFAULT })
  }
}
