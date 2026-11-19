import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { LoanPlan, loanTypeLabel, repayModeLabel } from '../model/LoanTypes';
import { LoanCalculator } from '../model/LoanCalculator';
import PlanService from '../service/PlanService';

@Entry
@Component
struct HistoryPage {
  @State plans: LoanPlan[] = [];
  @State selectedIds: number[] = [];
  @State comparePlans: LoanPlan[] = [];
  @State loaded: boolean = false;

  onPageShow(): void {
    this.loadPlans();
  }

  private async loadPlans(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    try {
      const plans = await PlanService.listPlans(context);
      this.plans = plans;
      const selected: number[] = [];
      for (let i = 0; i < plans.length; i++) {
        const id = plans[i].id;
        if (id !== undefined && this.selectedIds.indexOf(id) >= 0) {
          selected.push(id);
        }
      }
      this.selectedIds = selected;
      this.loaded = true;
    } catch (e) {
      console.error(`list plans failed: ${JSON.stringify(e)}`);
      promptAction.showToast({ message: '读取历史方案失败' });
      this.loaded = true;
    }
  }

  private isSelected(id: number): boolean {
    return this.selectedIds.indexOf(id) >= 0;
  }

  private toggleSelect(id: number): void {
    const index = this.selectedIds.indexOf(id);
    const next = this.selectedIds.slice();
    if (index >= 0) {
      next.splice(index, 1);
    } else {
      next.push(id);
    }
    this.selectedIds = next;
  }

  private compareSelected(): void {
    if (this.selectedIds.length < 2) {
      promptAction.showToast({ message: '请至少选择两个方案' });
      return;
    }
    const selected: LoanPlan[] = [];
    for (let i = 0; i < this.plans.length; i++) {
      const plan = this.plans[i];
      if (plan.id !== undefined && this.selectedIds.indexOf(plan.id) >= 0) {
        selected.push(plan);
      }
    }
    this.comparePlans = selected;
  }

  private minInterest(): number {
    let min = -1;
    for (let i = 0; i < this.comparePlans.length; i++) {
      const value = this.comparePlans[i].totalInterestFen;
      if (min < 0 || value < min) {
        min = value;
      }
    }
    return min;
  }

  private dateText(timestamp: number): string {
    const date = new Date(timestamp);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const hour = date.getHours();
    const minute = date.getMinutes();
    const minuteText = minute < 10 ? '0' + minute.toString() : minute.toString();
    return date.getFullYear().toString() + '/' + month.toString() + '/' + day.toString() +
      ' ' + hour.toString() + ':' + minuteText;
  }

  private async doDelete(ids: number[]): Promise<void> {
    if (ids.length === 0) {
      return;
    }
    const context = getContext(this) as common.UIAbilityContext;
    try {
      await PlanService.deletePlans(context, ids);
      this.selectedIds = [];
      this.comparePlans = [];
      await this.loadPlans();
      promptAction.showToast({ message: '已删除 ' + ids.length.toString() + ' 个方案' });
    } catch (e) {
      console.error(`delete plans failed: ${JSON.stringify(e)}`);
      promptAction.showToast({ message: '删除失败' });
    }
  }

  private confirmDelete(plan: LoanPlan): void {
    AlertDialog.show({
      title: '删除方案',
      message: '确定删除「' + plan.name + '」吗？删除后不可恢复。',
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#E5484D',
        action: () => {
          const id = plan.id;
          if (id !== undefined) {
            this.doDelete([id]);
          }
        }
      }
    });
  }

  private confirmDeleteSelected(): void {
    if (this.selectedIds.length === 0) {
      return;
    }
    const ids = this.selectedIds.slice();
    AlertDialog.show({
      title: '删除所选方案',
      message: '确定删除选中的 ' + ids.length.toString() + ' 个方案吗？',
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#E5484D',
        action: () => {
          this.doDelete(ids);
        }
      }
    });
  }

  @Builder
  header() {
    Row() {
      Text('‹')
        .fontSize(28)
        .fontColor('#111827')
        .width(36)
        .height('100%')
        .textAlign(TextAlign.Center)
        .onClick(() => {
          router.back();
        })
      Text('历史方案')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111827')
      Blank()
      Text('共 ' + this.plans.length.toString() + ' 个')
        .fontSize(11)
        .fontColor('#9CA3AF')
    }
    .width('100%')
    .height(52)
    .padding({ left: 6, right: 16 })
    .backgroundColor(Color.White)
  }

  @Builder
  planCard(plan: LoanPlan) {
    Row({ space: 10 }) {
      Text(this.isSelected(plan.id !== undefined ? plan.id : 0) ? '✓' : '')
        .width(22)
        .height(22)
        .borderRadius(11)
        .backgroundColor(this.isSelected(plan.id !== undefined ? plan.id : 0) ? '#2B6CF6' : '#F1F3F8')
        .fontColor(Color.White)
        .fontSize(13)
        .textAlign(TextAlign.Center)
        .border({
          width: 1,
          color: this.isSelected(plan.id !== undefined ? plan.id : 0) ? '#2B6CF6' : '#D5DAE3'
        })
        .onClick(() => {
          const id = plan.id;
          if (id !== undefined) {
            this.toggleSelect(id);
          }
        })

      Column({ space: 5 }) {
        Text(plan.name)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row({ space: 8 }) {
          Text('月供 ¥' + LoanCalculator.fenToYuanNoDecimal(plan.monthlyFen))
            .fontSize(11)
            .fontColor('#2B6CF6')
          Text('总利息 ¥' + LoanCalculator.fenToYuanNoDecimal(plan.totalInterestFen))
            .fontSize(11)
            .fontColor('#FF8A3D')
        }
        .width('100%')
        Text(loanTypeLabel(plan.input.type) + ' · ' + repayModeLabel(plan.input.mode) + ' · ' +
          plan.input.months.toString() + '期 · ' + this.dateText(plan.createdAt))
          .fontSize(10)
          .fontColor('#9CA3AF')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .onClick(() => {
        const id = plan.id;
        if (id !== undefined) {
          this.toggleSelect(id);
        }
      })

      Text('删除')
        .fontSize(11)
        .fontColor('#E5484D')
        .padding({ left: 6, right: 2, top: 8, bottom: 8 })
        .onClick(() => {
          this.confirmDelete(plan);
        })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(14)
    .border({ width: 1, color: this.isSelected(plan.id !== undefined ? plan.id : 0) ? '#BBD0FF' : '#00000000' })
  }

  @Builder
  compareCard() {
    Column({ space: 10 }) {
      Row() {
        Text('方案对比')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
        Blank()
        Text('收起')
          .fontSize(11)
          .fontColor('#2B6CF6')
          .onClick(() => {
            this.comparePlans = [];
          })
      }
      .width('100%')

      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.comparePlans, (plan: LoanPlan) => {
            Column({ space: 5 }) {
              Row() {
                Text(plan.name)
                  .fontSize(11)
                  .fontColor('#111827')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .layoutWeight(1)
                if (plan.totalInterestFen === this.minInterest()) {
                  Text('利息最低')
                    .fontSize(9)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#FF8A3D')
                    .borderRadius(6)
                    .padding({ left: 5, right: 5, top: 2, bottom: 2 })
                }
              }
              .width('100%')

              Text('月供 ¥' + LoanCalculator.fenToYuanNoDecimal(plan.monthlyFen))
                .fontSize(12)
                .fontColor('#2B6CF6')
                .width('100%')
              Text('总利息 ¥' + LoanCalculator.fenToYuanNoDecimal(plan.totalInterestFen))
                .fontSize(11)
                .fontColor('#FF8A3D')
                .width('100%')
              Text(repayModeLabel(plan.input.mode) + ' · ' + plan.input.months.toString() + '期')
                .fontSize(10)
                .fontColor('#9CA3AF')
                .width('100%')
            }
            .width(190)
            .padding(10)
            .backgroundColor(plan.totalInterestFen === this.minInterest() ? '#FFF7EF' : '#F8FAFF')
            .borderRadius(12)
          }, (plan: LoanPlan) => (plan.id !== undefined ? plan.id : 0).toString() + '_c')
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  @Builder
  emptyView() {
    Column({ space: 8 }) {
      Text('暂无历史方案')
        .fontSize(15)
        .fontColor('#6B7280')
      Text('在首页点击「保存当前方案」后，会出现在这里')
        .fontSize(11)
        .fontColor('#9CA3AF')
    }
    .width('100%')
    .padding({ top: 80 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  selectionBar() {
    Row({ space: 10 }) {
      Text('已选 ' + this.selectedIds.length.toString())
        .fontSize(13)
        .fontColor('#4B5563')
      Blank()
      Button('删除所选')
        .fontSize(12)
        .fontColor('#E5484D')
        .backgroundColor('#FDE8E8')
        .height(36)
        .onClick(() => {
          this.confirmDeleteSelected();
        })
      Button('对比选中')
        .fontSize(12)
        .fontColor(Color.White)
        .backgroundColor('#2B6CF6')
        .height(36)
        .enabled(this.selectedIds.length >= 2)
        .opacity(this.selectedIds.length >= 2 ? 1 : 0.5)
        .onClick(() => {
          this.compareSelected();
        })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .shadow({ radius: 10, color: '#14000000', offsetX: 0, offsetY: -2 })
  }

  build() {
    Column() {
      this.header()
      Column({ space: 10 }) {
        if (this.comparePlans.length > 0) {
          this.compareCard()
        }
        if (this.plans.length === 0 && this.loaded) {
          this.emptyView()
        } else {
          List({ space: 10 }) {
            ForEach(this.plans, (plan: LoanPlan) => {
              ListItem() {
                this.planCard(plan)
              }
            }, (plan: LoanPlan) => (plan.id !== undefined ? plan.id : 0).toString())
          }
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Off)
        }
        if (this.selectedIds.length > 0) {
          this.selectionBar()
        }
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: 12, right: 12, top: 10, bottom: 0 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }
}
