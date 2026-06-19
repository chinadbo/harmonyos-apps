import { ColorPicker } from '../components/ColorPicker';
import { PRESET_COLORS, Course, CourseDraft } from '../data/CourseModel';
import { appStateService } from '../services/AppStateService';
import { courseService } from '../services/CourseService';

@Entry
@Component
struct CourseEditPage {
  @State editingId: number = 0;
  @State scheduleId: number = 0;
  @State name: string = '';
  @State teacher: string = '';
  @State location: string = '';
  @State dayOfWeek: number = 1;
  @State startSection: number = 1;
  @State duration: number = 2;
  @State startWeek: number = 1;
  @State endWeek: number = 16;
  @State weekType: number = 0;
  @State color: string = PRESET_COLORS[0];
  @State reminderEnabled: boolean = true;
  @State reminderMinutes: string = '15';
  @State note: string = '';
  @State loaded: boolean = false;

  aboutToAppear(): void {
    this.scheduleId = appStateService.getCurrentScheduleId();
    this.editingId = appStateService.getEditingCourseId();
    if (this.editingId <= 0) {
      this.loaded = true;
      return;
    }
    courseService.getCourseById(this.editingId).then((item: Course | undefined) => {
      if (item) {
        this.name = item.name;
        this.teacher = item.teacher;
        this.location = item.location;
        this.dayOfWeek = item.dayOfWeek;
        this.startSection = item.startSection;
        this.duration = item.duration;
        this.startWeek = item.startWeek;
        this.endWeek = item.endWeek;
        this.weekType = item.weekType;
        this.color = item.color;
        this.reminderEnabled = item.reminderEnabled;
        this.reminderMinutes = item.reminderMinutes.toString();
        this.note = item.note;
      }
      this.loaded = true;
    }).catch((error: Error) => {
      this.loaded = true;
      console.error(`Failed to load course editor: ${JSON.stringify(error)}`);
    });
  }

  private buildDraft(): CourseDraft {
    return {
      id: this.editingId > 0 ? this.editingId : undefined,
      scheduleId: this.scheduleId,
      name: this.name,
      teacher: this.teacher,
      location: this.location,
      dayOfWeek: this.dayOfWeek,
      startSection: this.startSection,
      duration: this.duration,
      startWeek: this.startWeek,
      endWeek: this.endWeek,
      weekType: this.weekType,
      color: this.color,
      reminderEnabled: this.reminderEnabled,
      reminderMinutes: Number(this.reminderMinutes) || 15,
      note: this.note
    };
  }

  private save(): void {
    if (this.name.trim().length === 0) {
      return;
    }
    const draft = this.buildDraft();
    const action = this.editingId > 0 ? courseService.updateCourse(draft) : courseService.createCourse(draft).then(() => undefined);
    action.then(() => {
      this.getUIContext().getRouter().back();
    }).catch((error: Error) => {
      console.error(`Failed to save course: ${JSON.stringify(error)}`);
    });
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text(this.editingId > 0 ? '编辑课程' : '新建课程')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .width('100%')

        if (!this.loaded) {
          LoadingProgress()
        } else {
          TextInput({ placeholder: '课程名称', text: this.name })
            .backgroundColor($r('app.color.surface'))
            .onChange((value: string) => this.name = value)
          TextInput({ placeholder: '教师', text: this.teacher })
            .backgroundColor($r('app.color.surface'))
            .onChange((value: string) => this.teacher = value)
          TextInput({ placeholder: '地点', text: this.location })
            .backgroundColor($r('app.color.surface'))
            .onChange((value: string) => this.location = value)

          Row({ space: 12 }) {
            Text('星期')
            Slider({ value: this.dayOfWeek, min: 1, max: 7, step: 1 })
              .layoutWeight(1)
              .onChange((value: number) => this.dayOfWeek = Math.round(value))
            Text(`${this.dayOfWeek}`)
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface'))
          .borderRadius(16)

          Row({ space: 12 }) {
            Text('开始节次')
            Slider({ value: this.startSection, min: 1, max: 12, step: 1 })
              .layoutWeight(1)
              .onChange((value: number) => this.startSection = Math.round(value))
            Text(`${this.startSection}`)
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface'))
          .borderRadius(16)

          Row({ space: 12 }) {
            Text('持续节数')
            Slider({ value: this.duration, min: 1, max: 4, step: 1 })
              .layoutWeight(1)
              .onChange((value: number) => this.duration = Math.round(value))
            Text(`${this.duration}`)
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface'))
          .borderRadius(16)

          Row({ space: 12 }) {
            TextInput({ placeholder: '开始周', text: this.startWeek.toString() })
              .type(InputType.Number)
              .layoutWeight(1)
              .backgroundColor($r('app.color.surface'))
              .onChange((value: string) => this.startWeek = Number(value) || 1)
            TextInput({ placeholder: '结束周', text: this.endWeek.toString() })
              .type(InputType.Number)
              .layoutWeight(1)
              .backgroundColor($r('app.color.surface'))
              .onChange((value: string) => this.endWeek = Number(value) || 16)
          }
          .width('100%')

          Row({ space: 8 }) {
            Text('每周')
              .padding(10)
              .backgroundColor(this.weekType === 0 ? $r('app.color.brand_primary') : $r('app.color.surface'))
              .fontColor(this.weekType === 0 ? Color.White : $r('app.color.text_primary'))
              .borderRadius(12)
              .onClick(() => this.weekType = 0)
            Text('单周')
              .padding(10)
              .backgroundColor(this.weekType === 1 ? $r('app.color.brand_primary') : $r('app.color.surface'))
              .fontColor(this.weekType === 1 ? Color.White : $r('app.color.text_primary'))
              .borderRadius(12)
              .onClick(() => this.weekType = 1)
            Text('双周')
              .padding(10)
              .backgroundColor(this.weekType === 2 ? $r('app.color.brand_primary') : $r('app.color.surface'))
              .fontColor(this.weekType === 2 ? Color.White : $r('app.color.text_primary'))
              .borderRadius(12)
              .onClick(() => this.weekType = 2)
          }
          .width('100%')

          Column({ space: 8 }) {
            Text('课程颜色')
              .width('100%')
              .fontColor($r('app.color.text_primary'))
            ColorPicker({ selectedColor: this.color })
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface'))
          .borderRadius(16)

          Row({ space: 12 }) {
            Text('课前提醒')
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.reminderEnabled })
              .onChange((value: boolean) => this.reminderEnabled = value)
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface'))
          .borderRadius(16)

          TextInput({ placeholder: '提前多少分钟提醒', text: this.reminderMinutes })
            .type(InputType.Number)
            .backgroundColor($r('app.color.surface'))
            .onChange((value: string) => this.reminderMinutes = value)

          TextArea({ placeholder: '备注', text: this.note })
            .height(120)
            .backgroundColor($r('app.color.surface'))
            .onChange((value: string) => this.note = value)

          Button('保存课程')
            .width('100%')
            .backgroundColor($r('app.color.brand_primary'))
            .fontColor(Color.White)
            .onClick(() => this.save())
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
