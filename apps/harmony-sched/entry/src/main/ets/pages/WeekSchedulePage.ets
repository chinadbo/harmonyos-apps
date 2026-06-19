import router from '@ohos.router';
import { Course, CourseBlock } from '../data/CourseModel';
import { EmptyState } from '../components/EmptyState';
import { CourseBlockCard } from '../components/CourseBlockCard';
import { WeekStrip } from '../components/WeekStrip';
import { appStateService } from '../services/AppStateService';
import { courseService } from '../services/CourseService';
import { scheduleService } from '../services/ScheduleService';

@Component
export struct WeekSchedulePage {
  @State courses: Course[] = [];
  @State blocks: CourseBlock[] = [];
  @State currentWeek: number = 1;
  @State totalWeeks: number = 20;
  @State loading: boolean = true;

  private readonly weekLabels: string[] = ['一', '二', '三', '四', '五', '六', '日'];
  private readonly gridCells: number[] = [
    0, 1, 2, 3, 4, 5, 6,
    7, 8, 9, 10, 11, 12, 13,
    14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 26, 27,
    28, 29, 30, 31, 32, 33, 34,
    35, 36, 37, 38, 39, 40, 41,
    42, 43, 44, 45, 46, 47, 48,
    49, 50, 51, 52, 53, 54, 55,
    56, 57, 58, 59, 60, 61, 62,
    63, 64, 65, 66, 67, 68, 69,
    70, 71, 72, 73, 74, 75, 76,
    77, 78, 79, 80, 81, 82, 83
  ];
  private readonly rowTemplate: string = '1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr';

  aboutToAppear(): void {
    this.currentWeek = appStateService.getCurrentWeek();
    this.loadData();
  }

  private loadData(): void {
    this.loading = true;
    Promise.all([
      scheduleService.getCurrentSchedule(),
      courseService.listCourses()
    ]).then(([schedule, courses]) => {
      this.totalWeeks = schedule?.weeks ?? 20;
      this.courses = courseService.filterCoursesForWeek(courses, this.currentWeek);
      this.blocks = courseService.buildWeekBlocks(this.courses);
      this.loading = false;
    }).catch((error: Error) => {
      this.loading = false;
      console.error(`Failed to load weekly schedule: ${JSON.stringify(error)}`);
    });
  }

  private openCourse(block: CourseBlock): void {
    appStateService.setEditingCourseId(block.id);
    router.pushUrl({ url: 'pages/CourseEditPage' }).catch((err: Error) => {
      console.error(`Failed to navigate to CourseEditPage: ${JSON.stringify(err)}`);
    });
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        WeekStrip({ currentWeek: this.currentWeek, maxWeeks: this.totalWeeks })

        Button('刷新本周课程')
          .width('100%')
          .backgroundColor($r('app.color.brand_primary'))
          .fontColor(Color.White)
          .onClick(() => {
            appStateService.setCurrentWeek(this.currentWeek);
            this.loadData();
          })

        if (this.loading) {
          LoadingProgress()
        } else if (this.blocks.length === 0) {
          EmptyState({
            title: '本周暂无课程',
            description: '请先添加课程，或切换周次查看。'
          })
        } else {
          Column({ space: 8 }) {
            Grid() {
              ForEach(this.weekLabels, (label: string) => {
                GridItem() {
                  Text(label)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('app.color.text_primary'))
                }
              }, (label: string) => label)
            }
            .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
            .rowsGap(8)
            .columnsGap(8)
            .height(36)

            Stack() {
              Grid() {
                ForEach(this.gridCells, (index: number) => {
                  GridItem() {
                    Row()
                      .width('100%')
                      .height(48)
                      .backgroundColor(index < 7 ? '#00FFFFFF' : Color.Transparent)
                      .border({ width: 0.5, color: $r('app.color.divider') })
                  }
                }, (index: number) => index.toString())
              }
              .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
              .rowsTemplate(this.rowTemplate)
              .columnsGap(8)
              .rowsGap(8)

              ForEach(this.blocks, (block: CourseBlock) => {
                Row() {
                  CourseBlockCard({ block: block, onTap: () => this.openCourse(block) })
                }
                .position({
                  x: `${(block.dayOfWeek - 1) * 14.2857}%`,
                  y: `${block.topPercent}%`
                })
                .width('14.2857%')
                .height(`${block.heightPercent}%`)
                .padding({ left: 4, right: 4, top: 2, bottom: 2 })
              }, (block: CourseBlock) => block.id.toString())
            }
            .width('100%')
            .height(664)
            .backgroundColor($r('app.color.surface'))
            .borderRadius(18)
            .padding(8)
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.surface_alt'))
  }
}
