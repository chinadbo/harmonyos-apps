import router from '@ohos.router';
import { GroupDao } from '../database/GroupDao';
import { GroupSummary } from '../model/Group';
import { GroupCard } from '../components/GroupCard';

@Entry
@Component
struct MainPage {
  private groupDao: GroupDao = new GroupDao();
  @State private groups: GroupSummary[] = [];
  @State private loading: boolean = false;

  aboutToAppear(): void {
    this.loadGroups();
  }

  private async loadGroups(): Promise<void> {
    this.loading = true;
    try {
      this.groups = await this.groupDao.getAllSummaries();
    } catch (_) {
      this.groups = [];
    }
    this.loading = false;
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column({ space: 16 }) {
        Row() {
          Column({ space: 6 }) {
            Text('HarmonyBill')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
            Text('多人账单分摊 / AA 制工具')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
          }
          .layoutWeight(1)

          Button('刷新')
            .fontSize(14)
            .onClick(() => {
              this.loadGroups();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        if (this.groups.length === 0 && !this.loading) {
          Column({ space: 12 }) {
            Text('还没有分摊群组')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
            Text('点击右下角按钮，新建一个聚餐、旅行或合租分摊群组。')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .height('70%')
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: 14 }) {
              ForEach(this.groups, (group: GroupSummary) => {
                GroupCard({ group })
              }, (group: GroupSummary) => `${group.id}`)
            }
            .width('100%')
            .padding({ bottom: 100 })
          }
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .padding(20)
      .backgroundColor('#FFF5F7FB')

      Button('+')
        .width(56)
        .height(56)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFFFF')
        .backgroundColor($r('app.color.brand_color'))
        .borderRadius(28)
        .margin({ right: 20, bottom: 24 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/AddGroupPage' });
        })
    }
  }
}
