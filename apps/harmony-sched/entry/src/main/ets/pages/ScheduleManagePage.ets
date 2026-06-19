import { EmptyState } from '../components/EmptyState';
import { ScheduleProfile } from '../data/ScheduleModel';
import { scheduleService } from '../services/ScheduleService';

@Component
export struct ScheduleManagePage {
  @State schedules: ScheduleProfile[] = [];
  @State loading: boolean = true;

  aboutToAppear(): void {
    this.loadData();
  }

  private loadData(): void {
    this.loading = true;
    scheduleService.listSchedules().then((items: ScheduleProfile[]) => {
      this.schedules = items;
      this.loading = false;
    }).catch((error: Error) => {
      this.loading = false;
      console.error(`Failed to load schedules: ${JSON.stringify(error)}`);
    });
  }

  private createSchedule(): void {
    scheduleService.createSchedule({
      name: `课表 ${this.schedules.length + 1}`,
      termName: '新学期',
      startDate: '2026-09-01',
      weeks: 20,
      isActive: false
    }).then(() => this.loadData());
  }

  private activateSchedule(item: ScheduleProfile): void {
    scheduleService.switchSchedule(item.id).then(() => {
      this.loadData();
    }).catch((error: Error) => {
      console.error(`Failed to switch schedule: ${JSON.stringify(error)}`);
    });
  }

  build() {
    Column({ space: 16 }) {
      Button('新增课表')
        .width('100%')
        .backgroundColor($r('app.color.brand_primary'))
        .fontColor(Color.White)
        .onClick(() => this.createSchedule())

      if (this.loading) {
        LoadingProgress()
      } else if (this.schedules.length === 0) {
        EmptyState({ title: '没有课表', description: '先创建一个课表开始使用。' })
      } else {
        List({ space: 12 }) {
          ForEach(this.schedules, (item: ScheduleProfile) => {
            ListItem() {
              Column({ space: 8 }) {
                Row() {
                  Text(item.name)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .layoutWeight(1)
                    .fontColor($r('app.color.text_primary'))
                  if (item.isActive) {
                    Text('当前使用')
                      .fontSize(12)
                      .fontColor($r('app.color.brand_primary'))
                  }
                }
                .width('100%')
                Text(`${item.termName} · ${item.weeks}周 · ${item.startDate}`)
                  .fontSize(13)
                  .fontColor($r('app.color.text_secondary'))
                Button(item.isActive ? '已启用' : '切换到此课表')
                  .backgroundColor(item.isActive ? $r('app.color.surface_alt') : $r('app.color.brand_secondary'))
                  .fontColor(item.isActive ? $r('app.color.text_secondary') : Color.White)
                  .onClick(() => this.activateSchedule(item))
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.surface'))
              .borderRadius(18)
            }
          }, (item: ScheduleProfile) => item.id.toString())
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
