import web_webview from '@ohos.web.webview';

@Component
export struct NavigationBar {
  @Link canGoBack: boolean;
  @Link canGoForward: boolean;
  onBack: () => void = () => {};
  onForward: () => void = () => {};
  onRefresh: () => void = () => {};
  onHome: () => void = () => {};
  onMenu: () => void = () => {};

  build() {
    Row() {
      Button('←')
        .width(48)
        .height(48)
        .fontSize(20)
        .fontColor(this.canGoBack ? '#333333' : '#cccccc')
        .backgroundColor(Color.Transparent)
        .enabled(this.canGoBack)
        .onClick(() => this.onBack())

      Button('→')
        .width(48)
        .height(48)
        .fontSize(20)
        .fontColor(this.canGoForward ? '#333333' : '#cccccc')
        .backgroundColor(Color.Transparent)
        .enabled(this.canGoForward)
        .onClick(() => this.onForward())

      Button('↻')
        .width(48)
        .height(48)
        .fontSize(20)
        .fontColor('#333333')
        .backgroundColor(Color.Transparent)
        .onClick(() => this.onRefresh())

      Button('⌂')
        .width(48)
        .height(48)
        .fontSize(20)
        .fontColor('#333333')
        .backgroundColor(Color.Transparent)
        .onClick(() => this.onHome())

      Button('☰')
        .width(48)
        .height(48)
        .fontSize(20)
        .fontColor('#333333')
        .backgroundColor(Color.Transparent)
        .onClick(() => this.onMenu())
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.SpaceAround)
    .backgroundColor('#ffffff')
    .border({ width: { top: 1 }, color: '#e0e0e0' })
  }
}
