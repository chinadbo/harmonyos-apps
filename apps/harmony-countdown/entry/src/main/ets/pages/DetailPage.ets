import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import DatabaseService from '../service/DatabaseService';
import { CountdownEvent, createDefaultEvent } from '../model/CountdownEvent';
import { DateUtils } from '../utils/DateUtils';
import { IconConstants } from '../utils/IconConstants';
import { ShareUtils } from '../utils/ShareUtils';

@Entry
@Component
struct DetailPage {
  @State event: CountdownEvent = createDefaultEvent();
  @State loaded: boolean = false;

  async aboutToAppear(): Promise<void> {
    let params = router.getParams() as Object;
    let context = getContext(this) as common.UIAbilityContext;
    await DatabaseService.init(context);
    let id = Number((params as Record<string, Object>)['id'] ?? 0);
    let event = await DatabaseService.getEventById(id);
    if (event) {
      this.event = event;
    }
    this.loaded = true;
  }

  build() {
    let dayInfo = DateUtils.calculateDayInfo(this.event);
    Column({ space: 18 }) {
      Row() {
        Button('返回').backgroundColor('#FFFFFF').fontColor('#333333').onClick(() => {
          router.back();
        });
        Blank();
        Button('编辑').backgroundColor('#FFFFFF').fontColor('#333333').onClick(() => {
          router.pushUrl({ url: 'pages/EditPage', params: { id: this.event.id } });
        });
        Button('分享').margin({ left: 8 }).backgroundColor('#FF5B4D').onClick(async () => {
          let context = getContext(this) as common.UIAbilityContext;
          await ShareUtils.shareEventCard(context, this.event);
        });
      }
      .width('100%');
      if (this.loaded) {
        Column({ space: 16 }) {
          Text(IconConstants.getSymbol(this.event.icon)).fontSize(54).fontColor(this.event.color);
          Text(this.event.title).fontSize(30).fontWeight(FontWeight.Bold).fontColor('#222222');
          Text(dayInfo.displayText).fontSize(42).fontWeight(FontWeight.Bold).fontColor(dayInfo.isToday ? '#0A9B57' : this.event.color);
          Text(DateUtils.formatDisplayDate(this.event.targetDate)).fontSize(18).fontColor('#666666');
          Text(this.event.note.length > 0 ? this.event.note : '未填写备注').fontSize(16).fontColor('#444444');
        }
        .width('100%')
        .padding(24)
        .borderRadius(24)
        .backgroundColor('#FFFFFF');
        Column({ space: 12 }) {
          this.buildInfoRow('提醒状态', this.event.isReminderEnabled ? '已开启' : '未开启');
          this.buildInfoRow('提醒时间', `${DateUtils.pad(this.event.reminderHour)}:${DateUtils.pad(this.event.reminderMinute)}`);
          this.buildInfoRow('重复规则', this.event.isRepeatYearly ? '每年重复' : '单次事件');
        }
        .width('100%')
        .padding(20)
        .borderRadius(24)
        .backgroundColor('#FFFFFF');
      } else {
        Text('加载中...').fontSize(18);
      }
      Blank();
      Button('删除事件').width('100%').height(50).backgroundColor('#2F2F2F').onClick(async () => {
        let context = getContext(this) as common.UIAbilityContext;
        await DatabaseService.init(context);
        await DatabaseService.deleteEvent(this.event.id);
        promptAction.showToast({ message: '已删除' });
        router.back();
      });
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF7F7F9');
  }

  @Builder
  buildInfoRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(16).fontColor('#666666');
      Blank();
      Text(value).fontSize(16).fontColor('#222222');
    }
  }
}
