import { PlantListPage } from './PlantListPage'
import { RemindersPage } from './RemindersPage'
import { DiaryListPage } from './DiaryListPage'
import { PlantDetailPage } from './PlantDetailPage'
import { AddPlantPage } from './AddPlantPage'
import { CareLogPage } from './CareLogPage'
import { AddDiaryPage } from './AddDiaryPage'

@Entry
@Component
export struct Index {
  @State currentIndex: number = 0
  private stack: NavPathStack = new NavPathStack()

  @Builder
  buildPlants() {
    PlantListPage({ stack: this.stack })
  }

  @Builder
  buildReminders() {
    RemindersPage({ stack: this.stack })
  }

  @Builder
  buildDiaries() {
    DiaryListPage({ stack: this.stack })
  }

  @Builder
  pageMap(name: string, param?: Record<string, Object>) {
    if (name === 'pages/PlantDetailPage') {
      PlantDetailPage({ stack: this.stack, plantId: Number(param?.plantId ?? 0) })
    } else if (name === 'pages/AddPlantPage') {
      AddPlantPage({ stack: this.stack, plantId: Number(param?.plantId ?? 0) })
    } else if (name === 'pages/CareLogPage') {
      CareLogPage({ stack: this.stack, plantId: Number(param?.plantId ?? 0) })
    } else if (name === 'pages/AddDiaryPage') {
      AddDiaryPage({ stack: this.stack, plantId: Number(param?.plantId ?? 0) })
    }
  }

  build() {
    Navigation(this.stack) {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
          this.buildPlants()
        }
        .tabBar('植物')

        TabContent() {
          this.buildReminders()
        }
        .tabBar('提醒')

        TabContent() {
          this.buildDiaries()
        }
        .tabBar('日志')
      }
      .vertical(false)
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }
    .title('HarmonyPlant')
    .mode(NavigationMode.Stack)
    .navDestination(this.pageMap)
  }
}
