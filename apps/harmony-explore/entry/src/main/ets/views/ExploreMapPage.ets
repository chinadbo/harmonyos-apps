import { DatabaseService } from '../service/DatabaseService'
import { SpotModel } from '../model/SpotModel'
import { SpotCard } from '../components/SpotCard'
import { RouteNames } from '../utils/Constants'

@Component
export struct ExploreMapPage {
  @Prop pathStack: NavPathStack
  @Watch('onRefreshChanged') @StorageLink('refreshToken') refreshToken: number = 0
  @State private spots: SpotModel[] = []
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private isCanvasReady: boolean = false
  private readonly databaseService: DatabaseService = DatabaseService.getInstance()

  aboutToAppear(): void {
    this.loadSpots()
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Column({ space: 6 }) {
          Text($r('app.string.title_explore'))
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
          Text($r('app.string.subtitle_explore'))
            .fontSize(14)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Button($r('app.string.button_add_spot'))
          .height(40)
          .onClick(() => {
            this.pathStack.pushPathByName(RouteNames.ADD_SPOT, null)
          })
      }
      .width('100%')

      Canvas(this.context2D)
        .width('100%')
        .height(220)
        .backgroundColor('#FFFFFF')
        .borderRadius(24)
        .onReady(() => {
          this.isCanvasReady = true
          this.drawDensityGrid()
        })

      if (this.spots.length === 0) {
        Column() {
          Text($r('app.string.empty_spot'))
            .fontSize(14)
            .fontColor('#8A8A8A')
        }
        .width('100%')
        .padding(24)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
      } else {
        List({ space: 12 }) {
          ForEach(this.spots, (spot: SpotModel) => {
            ListItem() {
              SpotCard({ spot })
            }
          }, (spot: SpotModel) => `${spot.id}`)
        }
        .width('100%')
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  private onRefreshChanged(): void {
    this.loadSpots()
  }

  private async loadSpots(): Promise<void> {
    this.spots = await this.databaseService.getAllSpots()
    this.drawDensityGrid()
  }

  private drawDensityGrid(): void {
    if (!this.isCanvasReady) {
      return
    }
    this.context2D.clearRect(0, 0, 720, 440)
    this.context2D.fillStyle = '#FFFFFF'
    this.context2D.fillRect(0, 0, 720, 440)
    const columns: number = 6
    const rows: number = 4
    const cellWidth: number = 104
    const cellHeight: number = 82
    for (let row: number = 0; row < rows; row++) {
      for (let column: number = 0; column < columns; column++) {
        const index: number = row * columns + column
        const spot: SpotModel | undefined = this.spots[index]
        const intensity: number = spot ? Math.min(spot.checkInCount, 6) : 0
        this.context2D.fillStyle = intensity > 0 ? `rgba(10, 89, 247, ${0.18 + intensity * 0.1})` : '#EEF2F7'
        this.context2D.fillRect(24 + column * (cellWidth + 8), 24 + row * (cellHeight + 8), cellWidth, cellHeight)
        if (spot) {
          this.context2D.fillStyle = '#182431'
          this.context2D.font = '20px sans-serif'
          this.context2D.fillText(spot.name.substring(0, 4), 36 + column * (cellWidth + 8), 70 + row * (cellHeight + 8))
        }
      }
    }
  }
}
