import { TimerPage } from './TimerPage'
import { HistoryPage } from './HistoryPage'
import { StatsPage } from './StatsPage'
import router from '@ohos.router'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0

  @Builder
  TabBarBuilder(title: string, icon: Resource | string, index: number) {
    Column() {
      Text(icon as string)
        .fontSize(24)
      Text(title)
        .fontSize(11)
        .fontColor(this.currentIndex === index ? '#4FC3F7' : '#999999')
        .margin({ top: 2 })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column() {
      // Top bar
      Row() {
        Text('HarmonyTime')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)

        Button('项目')
          .type(ButtonType.Normal)
          .fontSize(14)
          .fontColor('#4FC3F7')
          .backgroundColor('transparent')
          .onClick(() => {
            router.pushUrl({ url: 'pages/ProjectsPage' })
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // Tabs
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          TimerPage()
        }
        .tabBar(this.TabBarBuilder('计时', '⏱', 0))

        TabContent() {
          HistoryPage()
        }
        .tabBar(this.TabBarBuilder('历史', '📋', 1))

        TabContent() {
          StatsPage()
        }
        .tabBar(this.TabBarBuilder('统计', '📊', 2))
      }
      .layoutWeight(1)
      .barHeight(56)
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
