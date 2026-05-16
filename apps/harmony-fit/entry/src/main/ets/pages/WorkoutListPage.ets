import promptAction from '@ohos.promptAction'
import { DatabaseService } from '../service/DatabaseService'
import { WorkoutRecord } from '../model/WorkoutRecord'
import { WorkoutCard } from '../components/WorkoutCard'
import { WorkoutDataSource } from '../viewmodel/WorkoutDataSource'
import { AddWorkoutDialog } from '../components/AddWorkoutDialog'

@Component
export struct WorkoutListPage {
  private dataSource: WorkoutDataSource = new WorkoutDataSource()
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: AddWorkoutDialog({
      confirm: (record: WorkoutRecord) => {
        this.handleAddRecord(record)
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true
  })

  @State private currentDate: string = ''
  @State private records: WorkoutRecord[] = []

  async aboutToAppear(): Promise<void> {
    this.currentDate = this.formatDate(new Date())
    await this.loadRecords()
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Column({ space: 4 }) {
          Text('运动记录')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
          Text(this.currentDate)
            .fontSize(14)
            .fontColor('#6B7280')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button('添加')
          .height(40)
          .backgroundColor('#4F46E5')
          .fontColor('#FFFFFF')
          .borderRadius(20)
          .onClick(() => {
            this.dialogController.open()
          })
      }
      .width('100%')

      if (this.records.length === 0) {
        Column({ space: 12 }) {
          Text('🏃')
            .fontSize(54)
          Text('还没有运动记录')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
          Text('迈出第一步，记录今天的运动吧')
            .fontSize(14)
            .fontColor('#6B7280')
        }
        .width('100%')
        .padding({ top: 80 })
      } else {
        List({ space: 12 }) {
          LazyForEach(this.dataSource, (item: WorkoutRecord, index: number) => {
            ListItem() {
              WorkoutCard({ record: item })
            }
            .swipeAction({ end: this.deleteAction(index, item) })
          }, (item: WorkoutRecord) => `${item.id ?? item.startTime}`)
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F3F6FA')
  }

  @Builder
  private deleteAction(index: number, item: WorkoutRecord) {
    Row() {
      Button('删除')
        .width(84)
        .height('100%')
        .backgroundColor('#EF4444')
        .fontColor('#FFFFFF')
        .onClick(async () => {
          if (item.id !== undefined) {
            try {
              await DatabaseService.getInstance().deleteRecord(item.id)
              this.dataSource.removeRecord(index)
              this.records = this.dataSource.getAllData()
            } catch (error) {
              promptAction.showToast({ message: '删除失败' })
              console.error(`deleteRecord failed: ${JSON.stringify(error)}`)
            }
          }
        })
    }
    .height(110)
  }

  private async loadRecords(): Promise<void> {
    try {
      const records = await DatabaseService.getInstance().queryByDate(this.currentDate)
      this.records = records
      this.dataSource.setData(records)
    } catch (error) {
      promptAction.showToast({ message: '加载失败' })
      console.error(`loadRecords failed: ${JSON.stringify(error)}`)
    }
  }

  private async handleAddRecord(record: WorkoutRecord): Promise<void> {
    try {
      const id = await DatabaseService.getInstance().insertRecord(record)
      record.id = id
      await this.loadRecords()
      promptAction.showToast({ message: '保存成功' })
    } catch (error) {
      promptAction.showToast({ message: '保存失败' })
      console.error(`handleAddRecord failed: ${JSON.stringify(error)}`)
    }
  }

  private formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = `${date.getMonth() + 1}`.padStart(2, '0')
    const day = `${date.getDate()}`.padStart(2, '0')
    return `${year}-${month}-${day}`
  }
}
