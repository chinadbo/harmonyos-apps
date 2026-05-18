import type common from '@ohos.app.ability.common';
import { HomeIndex } from '../views/HomeIndex';
import { DatabaseService } from '../service/DatabaseService';

@Entry
@Component
export struct Index {
  @Provide('navStack') navStack: NavPathStack = new NavPathStack();
  @State isReady: boolean = false;

  aboutToAppear(): void {
    if (this.isReady) {
      return;
    }
    AppStorage.SetOrCreate('notificationsEnabled', true);
    AppStorage.SetOrCreate('selectedPackageId', 0);
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    void DatabaseService.getInstance().init(context).then(() => {
      this.isReady = true;
    });
  }

  build() {
    Navigation(this.navStack) {
      if (this.isReady) {
        HomeIndex()
      } else {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .title('Harmony Express')
    .hideTitleBar(false)
    .mode(NavigationMode.Stack)
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F4F7')
  }
}
