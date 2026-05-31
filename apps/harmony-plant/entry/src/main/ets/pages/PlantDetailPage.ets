import { CareButton } from '../components/CareButton'
import { Plant } from '../model/Plant'
import { CareRecord } from '../model/CareRecord'
import { PlantService } from '../service/PlantService'

@Component
export struct PlantDetailPage {
  @Prop stack: NavPathStack = new NavPathStack()
  @Prop plantId: number = 0
  @State plant: Plant = new Plant()
  @State records: CareRecord[] = []

  async aboutToAppear(): Promise<void> {
    await this.loadData()
  }

  private async loadData(): Promise<void> {
    if (this.plantId <= 0) {
      return
    }
    this.plant = (await PlantService.getInstance().getPlantById(this.plantId)) ?? new Plant()
    this.records = await PlantService.getInstance().listCareRecordsByPlant(this.plantId)
  }

  private async quickLog(type: 'water' | 'fertilize'): Promise<void> {
    await PlantService.getInstance().logCare(this.plantId, type, '详情页快捷打卡')
    await this.loadData()
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        if (this.plant.photoUri.length > 0) {
          Image(this.plant.photoUri)
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
            .borderRadius(20)
        }

        Column({ space: 8 }) {
          Text(this.plant.name)
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
          if (this.plant.species.length > 0) {
            Text(this.plant.species)
              .fontSize(16)
              .fontColor('#666666')
          }
          Text(this.plant.getWaterStatusText())
            .fontSize(15)
            .fontColor(this.plant.isWaterDueToday() ? '#D32F2F' : '#2E7D32')
          Text(this.plant.getFertilizeStatusText())
            .fontSize(15)
            .fontColor(this.plant.isFertilizeDue() ? '#EF6C00' : '#1565C0')
          if (this.plant.notes.length > 0) {
            Text(this.plant.notes)
              .fontSize(14)
              .fontColor('#444444')
          }
        }
        .width('100%')
        .padding(18)
        .backgroundColor(Color.White)
        .borderRadius(20)
        .alignItems(HorizontalAlign.Start)

        Row({ space: 12 }) {
          CareButton({ label: '浇水', careType: 'water', accentColor: '#4CAF50', onTap: async () => { await this.quickLog('water') } })
          CareButton({ label: '施肥', careType: 'fertilize', accentColor: '#FF9800', onTap: async () => { await this.quickLog('fertilize') } })
        }

        Row({ space: 12 }) {
          Button('编辑植物')
            .layoutWeight(1)
            .onClick(() => {
              this.stack.pushPath({ name: 'pages/AddPlantPage', param: { plantId: this.plantId } })
            })
          Button('养护打卡')
            .layoutWeight(1)
            .onClick(() => {
              this.stack.pushPath({ name: 'pages/CareLogPage', param: { plantId: this.plantId } })
            })
          Button('写日志')
            .layoutWeight(1)
            .onClick(() => {
              this.stack.pushPath({ name: 'pages/AddDiaryPage', param: { plantId: this.plantId } })
            })
        }

        Column({ space: 12 }) {
          Text('养护记录时间线')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          if (this.records.length === 0) {
            Text('还没有养护记录')
              .fontSize(14)
              .fontColor('#666666')
          } else {
            ForEach(this.records, (record: CareRecord) => {
              Column({ space: 4 }) {
                Row() {
                  Text(record.getTypeLabel())
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                  Blank()
                  Text(record.careDate.slice(0, 10))
                    .fontSize(13)
                    .fontColor('#666666')
                }
                if (record.note.length > 0) {
                  Text(record.note)
                    .fontSize(13)
                    .fontColor('#444444')
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Color.White)
              .borderRadius(16)
              .alignItems(HorizontalAlign.Start)
            }, (record: CareRecord) => `${record.id}`)
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
