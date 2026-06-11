import common from '@ohos.app.ability.common'
import promptAction from '@ohos.promptAction'
import { WaterProgressRing } from '../components/WaterProgressRing'
import { QuickAddButton } from '../components/QuickAddButton'
import { StreakBadge } from '../components/StreakBadge'
import { EmptyState } from '../components/EmptyState'
import { RecordListItem } from '../components/RecordListItem'
import { WaterRecord } from '../model/WaterRecord'
import { WaterService } from '../service/WaterService'
import { DailyGoal } from '../model/DailyGoal'
import { HistoryPage } from './HistoryPage'
import { StatsPage } from './StatsPage'
import { SettingsPage } from './SettingsPage'
import { RecordEditPage } from './RecordEditPage'

@Entry
@Component
struct Index {
  @State navPathStack: NavPathStack = new NavPathStack()
  @State records: WaterRecord[] = []
  @State todayTotal: number = 0
  @State goal: DailyGoal = new DailyGoal()
  @State streak: number = 0
  @State progressSeed: number = 0
  @State selectedRecord: WaterRecord = new WaterRecord()
  @State currentPage: string = 'home'
  @State pageHistory: string[] = []
  private waterService: WaterService = WaterService.getInstance()

  async aboutToAppear(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext
      await this.waterService.init(context)
      await this.reloadData()
    } catch (error) {
      promptAction.showToast({ message: '初始化失败' })
    }
  }

  private async reloadData(): Promise<void> {
    try {
      this.goal = await this.waterService.getGoal()
      this.records = (await this.waterService.getRecordsByDate(this.waterService.formatDate(Date.now()))).slice(0, 5)
      this.todayTotal = await this.waterService.getTodaySum()
      this.streak = await this.waterService.getStreak(this.goal.amount)
      this.progressSeed++
    } catch (error) {
      promptAction.showToast({ message: '数据加载失败' })
    }
  }

  private async addWater(amount: number): Promise<void> {
    try {
      await this.waterService.addRecord(amount)
      promptAction.showToast({ message: `已记录 ${amount}ml` })
      await this.reloadData()
    } catch (error) {
      promptAction.showToast({ message: '记录失败' })
    }
  }

  private async deleteRecord(record: WaterRecord): Promise<void> {
    try {
      await this.waterService.deleteRecord(record.id)
      await this.reloadData()
    } catch (error) {
      promptAction.showToast({ message: '删除失败' })
    }
  }

  private openPage(name: string): void {
    this.pageHistory.push(this.currentPage)
    this.currentPage = name
    this.navPathStack.pushPath({ name })
  }

  private openRecordEdit(record: WaterRecord): void {
    this.selectedRecord = new WaterRecord(record.id, record.amount, record.timestamp, record.date)
    this.pageHistory.push(this.currentPage)
    this.currentPage = 'RecordEditPage'
    this.navPathStack.pushPath({ name: 'RecordEditPage' })
  }

  private closePage(): void {
    const previousPage = this.pageHistory.length > 0 ? this.pageHistory[this.pageHistory.length - 1] : 'home'
    if (this.pageHistory.length > 0) {
      this.pageHistory.pop()
    }
    this.currentPage = previousPage
    this.navPathStack.pop()
  }

  @Builder
  private buildContent() {
    if (this.currentPage === 'HistoryPage') {
      HistoryPage({
        onEdit: (record: WaterRecord) => this.openRecordEdit(record),
        onDeleted: async () => {
          await this.reloadData()
        }
      })
    } else if (this.currentPage === 'StatsPage') {
      StatsPage()
    } else if (this.currentPage === 'SettingsPage') {
      SettingsPage({
        onSaved: async () => {
          await this.reloadData()
        }
      })
    } else if (this.currentPage === 'RecordEditPage') {
      RecordEditPage({
        record: this.selectedRecord,
        onSaved: async () => {
          await this.reloadData()
          this.closePage()
        }
      })
    } else {
      Scroll() {
        Column({ space: 20 }) {
          Column({ space: 16 }) {
            Text('今日饮水追踪')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
            WaterProgressRing({ current: this.todayTotal, goal: this.goal.amount, progressSeed: this.progressSeed })
            StreakBadge({ streak: this.streak })
          }
          .width('100%')

          Column({ space: 12 }) {
            Text('快捷记录')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .width('100%')
            Row({ space: 10 }) {
              QuickAddButton({ label: '小杯', amount: 150, onTap: (amount: number) => this.addWater(amount) })
              QuickAddButton({ label: '中杯', amount: 250, onTap: (amount: number) => this.addWater(amount) })
              QuickAddButton({ label: '大杯', amount: 350, onTap: (amount: number) => this.addWater(amount) })
              QuickAddButton({ label: '运动后', amount: 500, onTap: (amount: number) => this.addWater(amount) })
            }
            .width('100%')
          }
          .width('100%')

          Column({ space: 12 }) {
            Row() {
              Text('最近记录')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
              Blank()
              Button('历史')
                .onClick(() => this.openPage('HistoryPage'))
              Button('统计')
                .margin({ left: 8 })
                .onClick(() => this.openPage('StatsPage'))
              Button('设置')
                .margin({ left: 8 })
                .onClick(() => this.openPage('SettingsPage'))
            }
            .width('100%')

            if (this.records.length === 0) {
              EmptyState({ title: '今天还没有饮水记录', subtitle: '点击上方快捷按钮添加一条记录' })
            } else {
              List({ space: 10 }) {
                ForEach(this.records, (record: WaterRecord) => {
                  ListItem() {
                    RecordListItem({
                      record,
                      onEdit: (selected: WaterRecord) => this.openRecordEdit(selected),
                      onDelete: (selected: WaterRecord) => this.deleteRecord(selected)
                    })
                  }
                }, (record: WaterRecord) => `${record.id}`)
              }
              .height(320)
            }
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
      }
    }
  }

  build() {
    Navigation(this.navPathStack) {
      Column() {
        if (this.currentPage !== 'home') {
          Row() {
            Button('返回')
              .onClick(() => this.closePage())
            Blank()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12 })
        }
        this.buildContent()
      }
      .width('100%')
      .height('100%')
    }
    .title('HarmonyHydrate')
    .mode(NavigationMode.Stack)
  }
}
