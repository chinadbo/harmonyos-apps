import router from '@ohos.router';
import { Goal, GoalFormData, GoalStatus, GoalPeriod } from '../model/GoalModel';
import { goalViewModel } from '../viewmodel/GoalViewModel';

@Entry
@Component
struct CreateGoalPage {
  @StorageProp('goals') goals: Goal[] = [];
  @State goalId: number = 0;
  @State title: string = '';
  @State description: string = '';
  @State period: GoalPeriod = 'month';
  @State color: string = '#4C7DFF';
  @State status: GoalStatus = 'in_progress';
  @State deadline: string = '';
  @State errorMessage: string = '';

  aboutToAppear(): void {
    let params = router.getParams() as Record<string, Object>;
    this.goalId = Number(params?.goalId ?? 0);
    let currentGoal: Goal | undefined = this.goals.find((item: Goal) => item.id === this.goalId);
    let form: GoalFormData = goalViewModel.getGoalFormData(currentGoal ?? null);
    this.title = form.title;
    this.description = form.description;
    this.period = form.period;
    this.color = form.color;
    this.status = form.status;
    this.deadline = form.deadline;
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorMessage = '请输入目标标题';
      return;
    }
    if (this.deadline.trim().length === 0) {
      this.errorMessage = '请输入截止日期，格式为 YYYY-MM-DD';
      return;
    }
    this.errorMessage = '';
    let payload: GoalFormData = {
      title: this.title.trim(),
      description: this.description.trim(),
      period: this.period,
      color: this.color,
      status: this.status,
      deadline: this.deadline.trim()
    };
    if (this.goalId > 0) {
      await goalViewModel.updateGoal(this.goalId, payload);
    } else {
      await goalViewModel.createGoal(payload);
    }
    router.back();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('返回')
            .height(36)
            .backgroundColor('#F3F5F8')
            .fontColor('#18202A')
            .onClick(() => router.back())
          Text(this.goalId > 0 ? '编辑目标' : '新建目标')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 12 })
        }
        .width('100%')

        Column({ space: 10 }) {
          Text('标题')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
          TextInput({ text: this.title, placeholder: '例如：提升英语口语表达' })
            .height(44)
            .backgroundColor('#FFFFFF')
            .onChange((value: string) => this.title = value)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        Column({ space: 10 }) {
          Text('描述')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
          TextArea({ text: this.description, placeholder: '描述这个目标的意义和范围' })
            .height(100)
            .backgroundColor('#FFFFFF')
            .onChange((value: string) => this.description = value)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        Column({ space: 10 }) {
          Text('周期')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
          Row({ space: 8 }) {
            this.optionButton('week', this.period === 'week', () => this.period = 'week')
            this.optionButton('month', this.period === 'month', () => this.period = 'month')
            this.optionButton('quarter', this.period === 'quarter', () => this.period = 'quarter')
            this.optionButton('year', this.period === 'year', () => this.period = 'year')
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        Column({ space: 10 }) {
          Text('状态')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
          Row({ space: 8 }) {
            this.optionButton('not_started', this.status === 'not_started', () => this.status = 'not_started')
            this.optionButton('in_progress', this.status === 'in_progress', () => this.status = 'in_progress')
          }
          Row({ space: 8 }) {
            this.optionButton('completed', this.status === 'completed', () => this.status = 'completed')
            this.optionButton('paused', this.status === 'paused', () => this.status = 'paused')
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        Column({ space: 10 }) {
          Text('颜色')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
          Row({ space: 10 }) {
            ForEach(['#4C7DFF', '#20C997', '#8E6CFF', '#FF9F43', '#FF6B6B'], (item: string) => {
              Row()
                .width(36)
                .height(36)
                .backgroundColor(item)
                .borderRadius(18)
                .border({ width: this.color === item ? 3 : 0, color: '#18202A' })
                .onClick(() => this.color = item)
            }, (item: string) => item)
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        Column({ space: 10 }) {
          Text('截止日期')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
          TextInput({ text: this.deadline, placeholder: 'YYYY-MM-DD' })
            .height(44)
            .backgroundColor('#FFFFFF')
            .onChange((value: string) => this.deadline = value)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(13)
            .fontColor('#FF6B6B')
        }

        Button(this.goalId > 0 ? '保存修改' : '创建目标')
          .width('100%')
          .height(46)
          .backgroundColor(this.color)
          .onClick(async () => await this.save())
      }
      .padding(16)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F8FB')
  }

  @Builder
  private optionButton(label: string, selected: boolean, action: () => void) {
    Button(label)
      .height(34)
      .backgroundColor(selected ? '#4C7DFF' : '#F3F5F8')
      .fontColor(selected ? '#FFFFFF' : '#18202A')
      .onClick(action)
  }
}
