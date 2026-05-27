import { TimeEntry } from '../model/TimeEntry'
import { Project } from '../model/Project'
import { EntryItem } from '../components/EntryItem'
import { DatabaseHelper } from '../database/DatabaseHelper'

// Full BasicDataSource implementation
class TimeEntryDataSource implements IDataSource {
  private dataArray: TimeEntry[] = []
  private listeners: DataChangeListener[] = []

  totalCount(): number {
    return this.dataArray.length
  }

  getData(index: number): TimeEntry {
    return this.dataArray[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  setData(data: TimeEntry[]): void {
    this.dataArray = data
    this.notifyDataReload()
  }

  deleteItem(index: number): void {
    this.dataArray.splice(index, 1)
    this.notifyDataReload()
  }

  private notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }
}

interface DayGroup {
  date: string
  entries: TimeEntry[]
}

@Component
export struct HistoryPage {
  @State dayGroups: DayGroup[] = []
  @State allEntries: TimeEntry[] = []
  @State projectMap: Map<number, Project> = new Map()
  private dataSource: TimeEntryDataSource = new TimeEntryDataSource()

  aboutToAppear(): void {
    this.loadEntries()
  }

  private async loadEntries(): Promise<void> {
    const db = DatabaseHelper.getInstance()
    const projects = await db.getAllProjects()
    const map = new Map<number, Project>()
    for (const p of projects) {
      map.set(p.id, p)
    }
    this.projectMap = map
    this.allEntries = await db.getAllTimeEntries()
    this.dataSource.setData(this.allEntries)
    this.groupByDate()
  }

  private groupByDate(): void {
    const groups: Map<string, TimeEntry[]> = new Map()
    for (const entry of this.allEntries) {
      const date = new Date(entry.startTime)
      const key = `${date.getFullYear()}-${this.pad(date.getMonth() + 1)}-${this.pad(date.getDate())}`
      if (!groups.has(key)) {
        groups.set(key, [])
      }
      groups.get(key)!.push(entry)
    }

    const result: DayGroup[] = []
    groups.forEach((entries, date) => {
      result.push({ date, entries })
    })
    result.sort((a, b) => b.date.localeCompare(a.date))
    this.dayGroups = result
  }

  private pad(n: number): string {
    return n < 10 ? '0' + n.toString() : n.toString()
  }

  private getProjectName(projectId: number): string {
    const project = this.projectMap.get(projectId)
    return project ? project.name : '未知项目'
  }

  private getProjectColor(projectId: number): string {
    const project = this.projectMap.get(projectId)
    return project ? project.color : '#999999'
  }

  private async deleteEntry(entry: TimeEntry): Promise<void> {
    const db = DatabaseHelper.getInstance()
    await db.deleteTimeEntry(entry.id)
    this.loadEntries()
  }

  build() {
    Column() {
      if (this.dayGroups.length === 0) {
        Column() {
          Text('📋')
            .fontSize(48)
            .margin({ bottom: 12 })
          Text('暂无记录')
            .fontSize(16)
            .fontColor('#999999')
          Text('开始计时后会在这里显示历史')
            .fontSize(14)
            .fontColor('#CCCCCC')
            .margin({ top: 4 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 0 }) {
          LazyForEach(this.dataSource, (entry: TimeEntry, index: number) => {
            ListItem() {
              EntryItem({
                entry: entry,
                projectName: this.getProjectName(entry.projectId),
                projectColor: this.getProjectColor(entry.projectId)
              })
            }
            .swipeAction({
              end: this.DeleteButton(entry)
            })
          }, (entry: TimeEntry) => entry.id.toString())
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0.5, color: '#F0F0F0' })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DeleteButton(entry: TimeEntry) {
    Row() {
      Button('删除')
        .type(ButtonType.Normal)
        .backgroundColor('#F44336')
        .fontColor('#FFFFFF')
        .width(80)
        .height('100%')
        .onClick(() => {
          this.deleteEntry(entry)
        })
    }
    .height('100%')
  }
}
