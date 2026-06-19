import router from '@ohos.router';
import { CourseDataSource } from '../data/CourseDataSource';
import { Course } from '../data/CourseModel';
import { EmptyState } from '../components/EmptyState';
import { appStateService } from '../services/AppStateService';
import { courseService } from '../services/CourseService';

@Component
export struct CourseListPage {
  @State courses: Course[] = [];
  @State loading: boolean = true;
  private dataSource: CourseDataSource = new CourseDataSource();

  aboutToAppear(): void {
    this.loadData();
  }

  private loadData(): void {
    this.loading = true;
    courseService.listCourses().then((items: Course[]) => {
      this.courses = items;
      this.dataSource.setItems(items);
      this.loading = false;
    }).catch((error: Error) => {
      this.loading = false;
      console.error(`Failed to load course list: ${JSON.stringify(error)}`);
    });
  }

  private createCourse(): void {
    appStateService.setEditingCourseId(0);
    router.pushUrl({ url: 'pages/CourseEditPage' }).catch((err: Error) => {
      console.error(`Failed to navigate to CourseEditPage: ${JSON.stringify(err)}`);
    });
  }

  private editCourse(item: Course): void {
    appStateService.setEditingCourseId(item.id);
    router.pushUrl({ url: 'pages/CourseEditPage' }).catch((err: Error) => {
      console.error(`Failed to navigate to CourseEditPage: ${JSON.stringify(err)}`);
    });
  }

  build() {
    Column({ space: 16 }) {
      Row({ space: 12 }) {
        Button('添加课程')
          .layoutWeight(1)
          .backgroundColor($r('app.color.brand_primary'))
          .fontColor(Color.White)
          .onClick(() => this.createCourse())
        Button('刷新')
          .backgroundColor($r('app.color.surface'))
          .fontColor($r('app.color.text_primary'))
          .onClick(() => this.loadData())
      }
      .width('100%')

      if (this.loading) {
        LoadingProgress()
      } else if (this.courses.length === 0) {
        EmptyState({
          title: '还没有课程',
          description: '点击上方按钮添加课程，周视图会自动显示。'
        })
      } else {
        List({ space: 12 }) {
          LazyForEach(this.dataSource, (item: Course) => {
            ListItem() {
              Column({ space: 8 }) {
                Row() {
                  Text(item.name)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('app.color.text_primary'))
                    .layoutWeight(1)
                  Text(courseService.formatWeekType(item.weekType))
                    .fontSize(12)
                    .fontColor($r('app.color.text_secondary'))
                }
                .width('100%')
                Text(`周${item.dayOfWeek} 第${item.startSection}-${item.startSection + item.duration - 1}节`)
                  .fontSize(13)
                  .fontColor($r('app.color.text_secondary'))
                Text(`${item.location} · ${item.teacher}`)
                  .fontSize(13)
                  .fontColor($r('app.color.text_secondary'))
                Button('编辑')
                  .alignSelf(ItemAlign.End)
                  .backgroundColor(item.color)
                  .fontColor(Color.White)
                  .onClick(() => this.editCourse(item))
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.surface'))
              .borderRadius(18)
            }
          }, (item: Course) => item.id.toString())
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor($r('app.color.surface_alt'))
  }
}
