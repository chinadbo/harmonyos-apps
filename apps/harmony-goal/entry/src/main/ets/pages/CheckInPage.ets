import router from '@ohos.router';
import { GoalDetail } from '../model/GoalModel';
import { goalViewModel } from '../viewmodel/GoalViewModel';

@Entry
@Component
struct CheckInPage {
  @StorageProp('selectedGoalDetail') detail: GoalDetail | null = null;
  @State goalId: number = 0;
  @State note: string = '';
  @State errorMessage: string = '';

  aboutToAppear(): void {
    let params = router.getParams() as Record<string, Object>;
    this.goalId = Number(params?.goalId ?? AppStorage.Get<number>('selectedGoalId') ?? 0);
    if (this.goalId > 0) {
      goalViewModel.loadGoalDetail(this.goalId);
    }
  }

  private async save(): Promise<void> {
    if (this.note.trim().length === 0) {
      this.errorMessage = '请输入今日回顾';
      return;
    }
    this.errorMessage = '';
    await goalViewModel.addCheckIn(this.goalId, this.note.trim());
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
          Text('今日回顾')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 12 })
        }
        .width('100%')

        Column({ space: 8 }) {
          Text(this.detail?.goal.title ?? '当前目标')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          Text(`当前进度 ${this.detail?.goal.progress ?? 0}%`)
            .fontSize(14)
            .fontColor(this.detail?.goal.color ?? '#4C7DFF')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        Column({ space: 10 }) {
          Text('回顾内容')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
          TextArea({ text: this.note, placeholder: '记录今天推进了什么、遇到了什么阻碍、明天最重要的一步是什么。' })
            .minHeight(180)
            .backgroundColor('#FFFFFF')
            .onChange((value: string) => this.note = value)
        }
        .width('100%')

        if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(13)
            .fontColor('#FF6B6B')
        }

        Button('保存回顾')
          .width('100%')
          .height(46)
          .backgroundColor(this.detail?.goal.color ?? '#4C7DFF')
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
}
