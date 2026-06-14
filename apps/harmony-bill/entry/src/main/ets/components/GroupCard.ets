import router from '@ohos.router';
import { GroupSummary, GROUP_SCENE_LABELS } from '../model/Group';
import { FormatUtils } from '../utils/FormatUtils';

@Component
export struct GroupCard {
  @Prop clickable: boolean = true;
  @Prop group: GroupSummary = {
    id: 0,
    name: '',
    scene: 'other',
    createdAt: 0,
    isSettled: 0,
    memberCount: 0,
    billCount: 0,
    totalAmount: 0
  };

  build() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 6 }) {
          Text(this.group.name)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .alignSelf(ItemAlign.Start)
          Text(GROUP_SCENE_LABELS[this.group.scene] ?? '其他')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .backgroundColor('#FFF3F4F6')
            .borderRadius(12)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        }
        .layoutWeight(1)

        Text(this.group.isSettled === 1 ? '已结清' : '未结清')
          .fontSize(12)
          .fontColor(this.group.isSettled === 1 ? $r('app.color.success_color') : $r('app.color.warning_color'))
          .backgroundColor(this.group.isSettled === 1 ? '#FFE8FFF4' : '#FFFFF7E6')
          .borderRadius(12)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Top)

      Row() {
        this.buildMetric('成员', `${this.group.memberCount}`)
        this.buildMetric('账单', `${this.group.billCount}`)
        this.buildMetric('总额', FormatUtils.formatCurrency(this.group.totalAmount))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.surface_color'))
    .borderRadius(20)
    .shadow({ radius: 12, color: '#14000000', offsetX: 0, offsetY: 4 })
    .onClick(() => {
      if (!this.clickable) {
        return;
      }
      router.pushUrl({
        url: 'pages/GroupDetailPage',
        params: { groupId: this.group.id }
      });
    })
  }

  @Builder
  private buildMetric(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
    }
  }
}
