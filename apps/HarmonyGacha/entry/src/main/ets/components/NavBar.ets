import router from '@ohos.router';
import { colorsOf } from '../common/Theme';

const NAV_LABELS: string[] = ['总览', '记录', '录入', '统计', '卡池', '设置'];
const NAV_URLS: string[] = [
  'pages/Index',
  'pages/RecordPage',
  'pages/AddRecordPage',
  'pages/StatsPage',
  'pages/PoolPage',
  'pages/SettingsPage'
];

@Component
export struct NavBar {
  @Prop active: number = 0;
  @StorageLink("gachaTheme") themeNum: number = 0;

  private go(idx: number): void {
    if (idx === this.active) {
      return;
    }
    router.replaceUrl({ url: NAV_URLS[idx] }).catch(() => {
    });
  }

  build() {
    Row() {
      ForEach(NAV_LABELS, (label: string, idx: number) => {
        Text(label)
          .fontSize(13)
          .fontWeight(idx === this.active ? 700 : 400)
          .fontColor(idx === this.active ? colorsOf(this.themeNum).primary : colorsOf(this.themeNum).textSub)
          .padding({ left: 8, right: 8, top: 8, bottom: 8 })
          .borderRadius(8)
          .backgroundColor(idx === this.active ? colorsOf(this.themeNum).cardDeep : Color.Transparent)
          .onClick(() => this.go(idx))
      }, (label: string) => label)
    }
    .width('100%')
    .height(52)
    .justifyContent(FlexAlign.SpaceAround)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(colorsOf(this.themeNum).card)
    .border({ width: { top: 1 }, color: { top: colorsOf(this.themeNum).border } })
  }
}
