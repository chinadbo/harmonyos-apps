import router from '@ohos.router';
import { TabItem } from '../model/TabItem';
import { TabCard } from '../components/TabCard';
import { Constants } from '../utils/Constants';

@Entry
@Component
struct TabOverviewPage {
  @State tabs: TabItem[] = [{ id: 0, url: Constants.HOME_PAGE, title: '主页', canGoBack: false, canGoForward: false }];

  build() {
    Column() {
      Row() {
        Button('返回')
          .fontSize(14)
          .backgroundColor(Color.Transparent)
          .fontColor('#2196F3')
          .onClick(() => router.back())

        Text('标签页')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('新建')
          .fontSize(14)
          .backgroundColor(Color.Transparent)
          .fontColor('#2196F3')
          .onClick(() => {
            const newId = this.tabs.length > 0 ? Math.max(...this.tabs.map(t => t.id)) + 1 : 0;
            this.tabs = [...this.tabs, {
              id: newId,
              url: Constants.HOME_PAGE,
              title: '新标签页',
              canGoBack: false,
              canGoForward: false
            }];
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#ffffff')

      Scroll() {
        Column() {
          ForEach(this.tabs, (item: TabItem, index: number) => {
            TabCard({
              tab: item,
              onSelect: () => {
                router.back();
              },
              onClose: () => {
                if (this.tabs.length > 1) {
                  this.tabs = this.tabs.filter((_, i) => i !== index);
                }
              }
            })
          }, (item: TabItem) => item.id.toString())
        }
        .width('100%')
        .padding(12)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
