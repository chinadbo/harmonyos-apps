import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { CountdownEvent, createDefaultEvent } from '../model/CountdownEvent';
import { EditViewModel } from '../viewmodel/EditViewModel';
import { IconConstants } from '../utils/IconConstants';

@Entry
@Component
struct EditPage {
  @State event: CountdownEvent = createDefaultEvent();
  private viewModel: EditViewModel = new EditViewModel();

  async aboutToAppear(): Promise<void> {
    let params = router.getParams() as Object;
    let context = getContext(this) as common.UIAbilityContext;
    let id = Number((params as Record<string, Object>)['id'] ?? 0);
    this.event = await this.viewModel.load(context, id);
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Button('返回').backgroundColor('#FFFFFF').fontColor('#333333').onClick(() => {
            router.back();
          });
          Blank();
          Text(this.event.id > 0 ? '编辑事件' : '新建事件').fontSize(26).fontWeight(FontWeight.Bold);
          Blank();
          Button('保存').backgroundColor('#FF5B4D').onClick(async () => {
            if (this.event.title.trim().length === 0) {
              promptAction.showToast({ message: '请输入标题' });
              return;
            }
            let context = getContext(this) as common.UIAbilityContext;
            await this.viewModel.save(context, this.event);
            promptAction.showToast({ message: '保存成功' });
            router.back();
          });
        }
        .width('100%');
        this.buildField('标题');
        TextInput({ text: this.event.title, placeholder: '例如：结婚纪念日' })
          .width('100%')
          .height(52)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .onChange((value: string) => {
            this.event.title = value;
          });
        this.buildField('目标日期');
        DatePicker({ start: new Date(2000, 0, 1), end: new Date(2100, 11, 31), selected: new Date(this.event.targetDate) })
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .onDateChange((value: DatePickerResult) => {
            // month 是 0-indexed（0=1月），需要 +1
            this.event.targetDate = `${value.year}-${this.pad(value.month + 1)}-${this.pad(value.day)}`;
          });
        this.buildField('备注');
        TextInput({ text: this.event.note, placeholder: '记录一点心情或计划' })
          .width('100%')
          .height(88)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .onChange((value: string) => {
            this.event.note = value;
          });
        this.buildField('图标');
        Row({ space: 10 }) {
          ForEach(IconConstants.ICONS, (icon: string) => {
            Text(IconConstants.getSymbol(icon))
              .fontSize(26)
              .width(44)
              .height(44)
              .textAlign(TextAlign.Center)
              .borderRadius(22)
              .backgroundColor(this.event.icon === icon ? '#FFF0EE' : '#FFFFFF')
              .onClick(() => {
                this.event.icon = icon;
              });
          }, (icon: string) => icon)
        }
        .width('100%');
        this.buildField('提醒');
        Row() {
          Text('开启系统提醒').fontSize(16);
          Blank();
          Toggle({ type: ToggleType.Switch, isOn: this.event.isReminderEnabled }).onChange((value: boolean) => {
            this.event.isReminderEnabled = value;
          });
        }
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(16);
        if (this.event.isReminderEnabled) {
          Row() {
            Text('提醒时间').fontSize(16);
            Blank();
            Text(`${this.pad(this.event.reminderHour)}:${this.pad(this.event.reminderMinute)}`).fontSize(18).fontColor('#FF5B4D');
          }
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(16);
          Row({ space: 12 }) {
            Button('小时 -').backgroundColor('#FFFFFF').fontColor('#333333').onClick(() => {
              this.event.reminderHour = this.event.reminderHour === 0 ? 23 : this.event.reminderHour - 1;
            });
            Button('小时 +').backgroundColor('#FFFFFF').fontColor('#333333').onClick(() => {
              this.event.reminderHour = this.event.reminderHour === 23 ? 0 : this.event.reminderHour + 1;
            });
            Button('分钟 -').backgroundColor('#FFFFFF').fontColor('#333333').onClick(() => {
              this.event.reminderMinute = this.event.reminderMinute === 0 ? 59 : this.event.reminderMinute - 1;
            });
            Button('分钟 +').backgroundColor('#FFFFFF').fontColor('#333333').onClick(() => {
              this.event.reminderMinute = this.event.reminderMinute === 59 ? 0 : this.event.reminderMinute + 1;
            });
          }
          .width('100%');
        }
        Row() {
          Text('每年重复').fontSize(16);
          Blank();
          Toggle({ type: ToggleType.Switch, isOn: this.event.isRepeatYearly }).onChange((value: boolean) => {
            this.event.isRepeatYearly = value;
          });
        }
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(16);
      }
      .padding(16)
      .width('100%')
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF7F7F9');
  }

  @Builder
  buildField(label: string) {
    Text(label).fontSize(15).fontWeight(FontWeight.Medium).fontColor('#444444');
  }

  pad(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }
}
