import { BasicDataSource } from '../components/BasicDataSource'
import { PlantCard } from '../components/PlantCard'
import { Plant } from '../model/Plant'
import { PlantService } from '../service/PlantService'

@Component
export struct PlantListPage {
  @Prop stack: NavPathStack = new NavPathStack()
  @State plants: Plant[] = []
  private dataSource: BasicDataSource<Plant> = new BasicDataSource<Plant>([])

  async aboutToAppear(): Promise<void> {
    await this.loadPlants()
  }

  private async loadPlants(): Promise<void> {
    this.plants = await PlantService.getInstance().listPlants()
    this.dataSource.reload(this.plants)
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text(`共 ${this.plants.length} 株植物`)
          .fontSize(14)
          .fontColor('#666666')
        Blank()
        Button('添加植物')
          .height(36)
          .backgroundColor('#4CAF50')
          .fontColor(Color.White)
          .borderRadius(18)
          .onClick(() => {
            this.stack.pushPath({ name: 'pages/AddPlantPage', param: { plantId: 0 } })
          })
      }

      if (this.plants.length === 0) {
        Column({ space: 8 }) {
          Text('还没有植物档案')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          Text('添加第一株植物，开始记录养护日常。')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .padding(24)
        .backgroundColor(Color.White)
        .borderRadius(20)
      } else {
        List({ space: 12 }) {
          LazyForEach(this.dataSource, (item: Plant) => {
            ListItem() {
              PlantCard({
                plant: item,
                onClick: () => {
                  this.stack.pushPath({ name: 'pages/PlantDetailPage', param: { plantId: item.id } })
                },
                onWater: async () => {
                  await PlantService.getInstance().logCare(item.id, 'water', '列表快捷浇水')
                  await this.loadPlants()
                }
              })
            }
          }, (item: Plant) => `${item.id}`)
        }
        .layoutWeight(1)
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
