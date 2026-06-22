import router from '@ohos.router';
import { CheckIn, GoalDetail, KeyResult } from '../model/GoalModel';
import { RingProgress } from '../components/RingProgress';
import { KRItem } from '../components/KRItem';
import { EmptyState } from '../components/EmptyState';
import { DateUtils } from '../utils/DateUtils';
import { goalViewModel } from '../viewmodel/GoalViewModel';

@Entry
@Component
struct GoalDetailPage {
  @StorageProp('selectedGoalDetail') detail: GoalDetail | null = null;
  @StorageProp('selectedGoalId') selectedGoalId: number = 0;

  aboutToAppear(): void {
    let params = router.getParams() as Record<string, Object>;
    let goalId: number = Number(params?.goalId ?? this.selectedGoalId ?? 0);
    if (goalId > 0) {
      goalViewModel.loadGoalDetail(goalId);
    }
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
          Text(this.detail?.goal.title ?? '目标详情')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .margin({ left: 12 })
          Button('编辑')
            .height(36)
            .backgroundColor('#EDF2FF')
            .fontColor('#4C7DFF')
            .onClick(() => {
              if (this.selectedGoalId > 0) {
                router.pushUrl({ url: 'pages/CreateGoalPage', params: { goalId: this.selectedGoalId } });
              }
            })
        }
        .width('100%')

        if (this.detail) {
          Column({ space: 16 }) {
            Column({ space: 12 }) {
              RingProgress({
                progress: this.detail!.goal.progress,
                size: 160,
                strokeWidth: 16,
                color: this.detail!.goal.color,
                backgroundColor: '#E7ECF5',
                label: '总进度'
              })
              Text(this.detail!.goal.description.length > 0 ? this.detail!.goal.description : '让每一个关键结果都可见、可衡量、可复盘。')
                .fontSize(14)
                .fontColor('#5E6B7A')
                .textAlign(TextAlign.Center)
              Row({ space: 12 }) {
                this.infoTag(`周期 ${this.detail!.goal.period}`)
                this.infoTag(`截止 ${DateUtils.formatChineseDate(this.detail!.goal.deadline)}`)
                this.infoTag(`状态 ${this.detail!.goal.status}`)
              }
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(20)

            Row({ space: 8 }) {
              Button('新增 KR')
                .layoutWeight(1)
                .backgroundColor(this.detail!.goal.color)
                .onClick(() => router.pushUrl({ url: 'pages/CreateKRPage', params: { goalId: this.selectedGoalId } }))
              Button('今日回顾')
                .layoutWeight(1)
                .backgroundColor('#EDF2FF')
                .fontColor('#4C7DFF')
                .onClick(() => router.pushUrl({ url: 'pages/CheckInPage', params: { goalId: this.selectedGoalId } }))
              Button('删除目标')
                .layoutWeight(1)
                .backgroundColor('#FFF1F1')
                .fontColor('#FF6B6B')
                .onClick(async () => {
                  await goalViewModel.deleteGoal(this.selectedGoalId);
                  router.back();
                })
            }
            .width('100%')

            Column({ space: 12 }) {
              Row() {
                Text('关键结果')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)
                Text(`${this.detail!.keyResults.length} 项`)
                  .fontSize(13)
                  .fontColor('#5E6B7A')
              }
              .width('100%')

              if (this.detail!.keyResults.length === 0) {
                EmptyState({
                  title: '还没有关键结果',
                  description: '把目标拆成可衡量的结果，你才能更容易持续推进。',
                  actionText: '新增 KR',
                  onAction: () => router.pushUrl({ url: 'pages/CreateKRPage', params: { goalId: this.selectedGoalId } })
                })
              } else {
                Column({ space: 10 }) {
                  ForEach(this.detail!.keyResults, (item: KeyResult) => {
                    KRItem({
                      item: item,
                      accentColor: this.detail!.goal.color,
                      onProgressChange: async (krId: number, value: number) => {
                        await goalViewModel.updateKrProgress(this.selectedGoalId, krId, value);
                      },
                      onEdit: (krId: number) => {
                        router.pushUrl({ url: 'pages/CreateKRPage', params: { goalId: this.selectedGoalId, krId: krId } });
                      },
                      onDelete: async (krId: number) => {
                        await goalViewModel.deleteKeyResult(this.selectedGoalId, krId);
                      }
                    })
                  }, (item: KeyResult) => `${item.id}`)
                }
              }
            }
            .width('100%')

            Column({ space: 12 }) {
              Row() {
                Text('回顾历史')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)
                Text(`${this.detail!.checkIns.length} 条`)
                  .fontSize(13)
                  .fontColor('#5E6B7A')
              }
              .width('100%')

              if (this.detail!.checkIns.length === 0) {
                EmptyState({
                  title: '还没有回顾记录',
                  description: '每天写一点复盘，目标的变化轨迹才会越来越清晰。',
                  actionText: '立即回顾',
                  onAction: () => router.pushUrl({ url: 'pages/CheckInPage', params: { goalId: this.selectedGoalId } })
                })
              } else {
                Column({ space: 10 }) {
                  ForEach(this.detail!.checkIns, (item: CheckIn) => {
                    Column({ space: 8 }) {
                      Row() {
                        Text(DateUtils.formatChineseDate(item.date))
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                          .layoutWeight(1)
                        Text(`${item.progress}%`)
                          .fontSize(14)
                          .fontColor(this.detail!.goal.color)
                      }
                      .width('100%')
                      Text(item.note)
                        .fontSize(13)
                        .fontColor('#5E6B7A')
                      Button('删除记录')
                        .height(30)
                        .fontSize(12)
                        .backgroundColor('#FFF1F1')
                        .fontColor('#FF6B6B')
                        .onClick(async () => {
                          await goalViewModel.deleteCheckIn(this.selectedGoalId, item.id);
                        })
                    }
                    .width('100%')
                    .padding(14)
                    .backgroundColor('#FFFFFF')
                    .borderRadius(16)
                  }, (item: CheckIn) => `${item.id}`)
                }
              }
            }
            .width('100%')
          }
          .width('100%')
        }
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
  private infoTag(text: string) {
    Text(text)
      .fontSize(12)
      .fontColor('#5E6B7A')
      .backgroundColor('#F3F5F8')
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .borderRadius(12)
  }
}
