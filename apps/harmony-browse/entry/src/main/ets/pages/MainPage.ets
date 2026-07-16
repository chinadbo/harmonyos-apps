import web_webview from '@ohos.web.webview';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Constants } from '../utils/Constants';
import { TabItem } from '../model/TabItem';
import { BrowserDatabase } from '../database/BrowserDatabase';
import { AddressBar } from '../components/AddressBar';
import { NavigationBar } from '../components/NavigationBar';

@Entry
@Component
struct MainPage {
  @State currentUrl: string = Constants.HOME_PAGE;
  @State currentTitle: string = '';
  @State canGoBack: boolean = false;
  @State canGoForward: boolean = false;
  @State tabs: TabItem[] = [{ id: 0, url: Constants.HOME_PAGE, title: '主页', canGoBack: false, canGoForward: false }];
  @State currentTabIndex: number = 0;
  @State showMenuDialog: boolean = false;
  controller: web_webview.WebviewController = new web_webview.WebviewController();

  aboutToAppear() {
    BrowserDatabase.getInstance().init(getContext(this) as Context);
  }

  updateTabState(url: string, title: string) {
    const newTabs = [...this.tabs];
    newTabs[this.currentTabIndex] = {
      id: this.tabs[this.currentTabIndex].id,
      url: url,
      title: title || url,
      canGoBack: this.canGoBack,
      canGoForward: this.canGoForward
    };
    this.tabs = newTabs;
  }

  async addToHistory(url: string, title: string) {
    if (url && url !== 'about:blank') {
      await BrowserDatabase.getInstance().insertHistory({
        id: 0,
        url: url,
        title: title || url,
        visitTime: Date.now()
      });
    }
  }

  navigateTo(url: string) {
    this.currentUrl = url;
    this.controller.loadUrl(url);
    this.updateTabState(url, '');
  }

  async addBookmark() {
    if (!this.currentUrl || this.currentUrl === 'about:blank') {
      promptAction.showToast({ message: '当前页面无法添加书签' });
      return;
    }
    await BrowserDatabase.getInstance().insertBookmark({
      id: 0,
      url: this.currentUrl,
      title: this.currentTitle || this.currentUrl,
      folder: Constants.BOOKMARK_FOLDER_DEFAULT,
      createTime: Date.now()
    });
    promptAction.showToast({ message: '已添加书签' });
  }

  build() {
    Stack() {
      Column() {
        AddressBar({
          currentUrl: this.currentUrl,
          onGo: (url: string) => this.navigateTo(url)
        })

        Web({ src: this.currentUrl, controller: this.controller })
          .width('100%')
          .layoutWeight(1)
          .javaScriptAccess(true)
          .onPageBegin((event) => {
            if (event) {
              this.currentUrl = event.url;
              this.canGoBack = this.controller.accessBackward();
              this.canGoForward = this.controller.accessForward();
              this.updateTabState(event.url, this.currentTitle);
            }
          })
          .onPageEnd((event) => {
            if (event) {
              this.currentTitle = event.title || event.url;
              this.currentUrl = event.url;
              this.canGoBack = this.controller.accessBackward();
              this.canGoForward = this.controller.accessForward();
              this.updateTabState(event.url, this.currentTitle);
              this.addToHistory(event.url, this.currentTitle);
            }
          })
          .onErrorReceive((error) => {
            if (error) {
              console.error('Web error', error.error.getErrorInfo());
            }
          })

        NavigationBar({
          canGoBack: $canGoBack,
          canGoForward: $canGoForward,
          onBack: () => {
            if (this.controller.accessBackward()) {
              this.controller.backward();
            }
          },
          onForward: () => {
            if (this.controller.accessForward()) {
              this.controller.forward();
            }
          },
          onRefresh: () => this.controller.refresh(),
          onHome: () => this.navigateTo(Constants.HOME_PAGE),
          onMenu: () => this.showMenuDialog = true
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f5f5f5')

      if (this.showMenuDialog) {
        Column() {
          Column() {
            Text('菜单')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 16 })

            Button('添加书签')
              .width('80%')
              .height(44)
              .margin({ bottom: 8 })
              .backgroundColor('#2196F3')
              .onClick(() => {
                this.addBookmark();
                this.showMenuDialog = false;
              })

            Button('书签管理')
              .width('80%')
              .height(44)
              .margin({ bottom: 8 })
              .backgroundColor('#2196F3')
              .onClick(() => {
                this.showMenuDialog = false;
                router.pushUrl({ url: 'pages/BookmarkListPage' });
              })

            Button('浏览历史')
              .width('80%')
              .height(44)
              .margin({ bottom: 8 })
              .backgroundColor('#2196F3')
              .onClick(() => {
                this.showMenuDialog = false;
                router.pushUrl({ url: 'pages/HistoryPage' });
              })

            Button('设置')
              .width('80%')
              .height(44)
              .margin({ bottom: 8 })
              .backgroundColor('#2196F3')
              .onClick(() => {
                this.showMenuDialog = false;
                router.pushUrl({ url: 'pages/SettingsPage' });
              })

            Button('关闭')
              .width('80%')
              .height(44)
              .margin({ top: 8 })
              .backgroundColor('#999999')
              .onClick(() => this.showMenuDialog = false)
          }
          .width('70%')
          .padding(24)
          .backgroundColor('#ffffff')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#33000000', offsetX: 0, offsetY: 4 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#66000000')
        .onClick(() => this.showMenuDialog = false)
      }
    }
    .width('100%')
    .height('100%')
  }
}
