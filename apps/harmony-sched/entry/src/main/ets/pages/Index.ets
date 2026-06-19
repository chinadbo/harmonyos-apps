import common from '@ohos.app.ability.common';
import { appStateService } from '../services/AppStateService';
import { scheduleService } from '../services/ScheduleService';
import { CourseListPage } from './CourseListPage';
import { ScheduleManagePage } from './ScheduleManagePage';
import { SettingsPage } from './SettingsPage';
import { WeekSchedulePage } from './WeekSchedulePage';

@Entry
@Component
struct Index {
  @State currentTab: number = 0;
  @State initialized: boolean = false;

  aboutToAppear(): void {
    const context = getContext(this) as common.UIAbilityContext;
    scheduleService.init(context)
      .then(() => {
        appStateService.init();
        this.initialized = true;
      })
      .catch((error: Error) => {
        console.error(`Failed to initialize schedule app: ${JSON.stringify(error)}`);
      });
  }

  build() {
    Column() {
        if (!this.initialized) {
          Column({ space: 16 }) {
            LoadingProgress()
            Text('正在加载课程表...')
              .fontSize(15)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          Tabs({ barPosition: BarPosition.End, index: this.currentTab }) {
            TabContent() {
              WeekSchedulePage()
            }.tabBar('周视图')
            TabContent() {
              CourseListPage()
            }.tabBar('课程')
            TabContent() {
              ScheduleManagePage()
            }.tabBar('课表')
            TabContent() {
              SettingsPage()
            }.tabBar('设置')
          }
          .vertical(false)
          .barMode(BarMode.Fixed)
          .onChange((index: number) => {
            this.currentTab = index;
          })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.surface_alt'))
  }
}
