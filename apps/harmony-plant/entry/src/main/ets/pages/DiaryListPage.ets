import { PlantDiary } from '../model/PlantDiary'
import { PlantService } from '../service/PlantService'

@Component
export struct DiaryListPage {
  @Prop stack: NavPathStack = new NavPathStack()
  @State diaries: PlantDiary[] = []

  async aboutToAppear(): Promise<void> {
    await this.loadDiaries()
  }

  private async loadDiaries(): Promise<void> {
    this.diaries = await PlantService.getInstance().listDiaries()
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('植物日志')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('写日志')
          .height(36)
          .backgroundColor('#4CAF50')
          .fontColor(Color.White)
          .borderRadius(18)
          .onClick(() => {
            this.stack.pushPath({ name: 'pages/AddDiaryPage' })
          })
      }

      if (this.diaries.length === 0) {
        Column({ space: 8 }) {
          Text('还没有日志')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          Text('记录植物成长的每一个瞬间。')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .padding(24)
        .backgroundColor(Color.White)
        .borderRadius(20)
      } else {
        List({ space: 12 }) {
          ForEach(this.diaries, (diary: PlantDiary) => {
            ListItem() {
              Column({ space: 8 }) {
                Row() {
                  Text(diary.title)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                  Blank()
                  Text(diary.createdAt.slice(0, 10))
                    .fontSize(13)
                    .fontColor('#666666')
                }
                Text(diary.content)
                  .fontSize(14)
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                if (diary.photoUri.length > 0) {
                  Image(diary.photoUri)
                    .width('100%')
                    .height(140)
                    .borderRadius(14)
                    .objectFit(ImageFit.Cover)
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(18)
              .alignItems(HorizontalAlign.Start)
            }
          }, (diary: PlantDiary) => `${diary.id}`)
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
