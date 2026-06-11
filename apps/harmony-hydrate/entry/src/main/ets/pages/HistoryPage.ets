import promptAction from '@ohos.promptAction'
import { WaterRecord } from '../model/WaterRecord'
import { WaterService } from '../service/WaterService'
import { EmptyState } from '../components/EmptyState'
import { RecordListItem } from '../components/RecordListItem'

class DateGroup {
  date: string
  records: WaterRecord[]

  constructor(date: string, records: WaterRecord[]) {
    this.date = date
    this.records = records
  }
}

@Component
export struct HistoryPage {
  @Prop onEdit: (record: WaterRecord) => void = () => {}
  @Prop onDeleted: () => void = () => {}
  @State groups: DateGroup[] = []
  private waterService: WaterService = WaterService.getInstance()

  async aboutToAppear(): Promise<void> {
    await this.loadGroups()
  }

  private async loadGroups(): Promise<void> {
    try {
      const records = await this.waterService.getAllRecords()
      const grouped = new Map<string, WaterRecord[]>()
      records.forEach((record: WaterRecord) => {
        const existing = grouped.get(record.date) ?? []
        existing.push(record)
        grouped.set(record.date, existing)
      })
      this.groups = Array.from(grouped.keys()).map((date: string) => new DateGroup(date, grouped.get(date) ?? []))
    } catch (error) {
      promptAction.showToast({ message: '历史记录加载失败' })
    }
  }

  private async deleteRecord(record: WaterRecord): Promise<void> {
    try {
      await this.waterService.deleteRecord(record.id)
      await this.loadGroups()
      this.onDeleted()
    } catch (error) {
      promptAction.showToast({ message: '删除失败' })
    }
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        if (this.groups.length === 0) {
          EmptyState({ title: '暂无历史记录', subtitle: '记录饮水后会按日期展示在这里' })
        } else {
          ForEach(this.groups, (group: DateGroup) => {
            Column({ space: 10 }) {
              Text(group.date)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .width('100%')
              ForEach(group.records, (record: WaterRecord) => {
                RecordListItem({
                  record,
                  onEdit: (selected: WaterRecord) => this.onEdit(selected),
                  onDelete: (selected: WaterRecord) => this.deleteRecord(selected)
                })
              }, (record: WaterRecord) => `${record.id}`)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          })
        }
      }
      .width('100%')
      .padding(16)
    }
  }
}
