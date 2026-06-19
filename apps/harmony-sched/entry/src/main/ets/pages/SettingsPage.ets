import common from '@ohos.app.ability.common';
import notificationManager from '@ohos.notificationManager';
import { appStateService } from '../services/AppStateService';
import { courseService } from '../services/CourseService';
import { scheduleService } from '../services/ScheduleService';

@Component
export struct SettingsPage {
  @State currentWeek: number = 1;
  @State scheduleName: string = '-';
  @State courseCount: number = 0;
  @State statusText: string = '未执行操作';

  aboutToAppear(): void {
    this.currentWeek = appStateService.getCurrentWeek();
    Promise.all([
      scheduleService.getCurrentSchedule(),
      courseService.listCourses()
    ]).then(([schedule, courses]) => {
      this.scheduleName = schedule?.name ?? '-';
      this.courseCount = courses.length;
    });
  }

  private requestNotificationInfo(): void {
    notificationManager.isNotificationEnabled().then((enabled: boolean) => {
      this.statusText = enabled ? '通知已启用' : '通知未启用';
    }).catch((error: Error) => {
      this.statusText = `读取通知状态失败: ${JSON.stringify(error)}`;
    });
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 8 }) {
          Text('当前课表')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
          Text(this.scheduleName)
            .fontColor($r('app.color.text_secondary'))
          Text(`课程数量：${this.courseCount}`)
            .fontColor($r('app.color.text_secondary'))
          Text(`当前周次：${this.currentWeek}`)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .padding(18)
        .backgroundColor($r('app.color.surface'))
        .borderRadius(20)

        Row({ space: 12 }) {
          Button('周次 -1')
            .layoutWeight(1)
            .onClick(() => {
              if (this.currentWeek > 1) {
                this.currentWeek -= 1;
                appStateService.setCurrentWeek(this.currentWeek);
              }
            })
          Button('周次 +1')
            .layoutWeight(1)
            .onClick(() => {
              this.currentWeek += 1;
              appStateService.setCurrentWeek(this.currentWeek);
            })
        }
        .width('100%')

        Button('检查通知权限状态')
          .width('100%')
          .backgroundColor($r('app.color.brand_primary'))
          .fontColor(Color.White)
          .onClick(() => this.requestNotificationInfo())

        Text(this.statusText)
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.surface_alt'))
  }
}
