// 日程详情页，支持创建、编辑、删除和提醒设置
import * as router from '@ohos.router';
import common from '@ohos.app.ability.common';
import StorageManager from '../data/StorageManager';
import NotificationManager from '../data/NotificationManager';
import { createEmptyEventModel, EventModel, RepeatType } from '../models/EventModel';
import { TagModel } from '../models/TagModel';
import { EVENT_PRESET_COLORS, REPEAT_OPTIONS, REPEAT_OPTION_LABELS, REMINDER_OPTIONS, STORAGE_KEY_DEFAULT_REMINDER, getReminderLabel } from '../utils/Constants';
import { formatDateTime } from '../utils/DateUtils';

@Component
struct EventDetailPage {
  @StorageLink(STORAGE_KEY_DEFAULT_REMINDER) defaultReminderMinutes: number = 15;
  @State eventForm: EventModel = createEmptyEventModel();
  @State tags: TagModel[] = [];
  @State pageTitle: string = '新建日程';
  @State isEditing: boolean = false;
  @State customReminderText: string = '';
  @State errorMessage: string = '';

  aboutToAppear(): void {
    this.initializePage();
  }

  async initializePage(): Promise<void> {
    await StorageManager.initialize(getContext(this) as common.UIAbilityContext);
    await this.loadData();
  }

  async loadData(): Promise<void> {
    const params: Record<string, number> = router.getParams() as Record<string, number>;
    this.tags = await StorageManager.getAllTags();
    if (params && params.eventId) {
      const event: EventModel | null = await StorageManager.getEventById(params.eventId);
      if (event) {
        this.eventForm = { ...event };
        this.pageTitle = '编辑日程';
        this.isEditing = true;
        return;
      }
    }
    const startTime: number = params?.startTime ?? Date.now();
    const endTime: number = params?.endTime ?? startTime + 60 * 60 * 1000;
    this.eventForm = createEmptyEventModel(startTime, endTime);
    this.eventForm.tagId = this.tags.length > 0 ? this.tags[0].id : 0;
    this.eventForm.reminderTimes = [this.defaultReminderMinutes];
  }

  updateReminder(reminderMinutes: number): void {
    const exists: boolean = this.eventForm.reminderTimes.includes(reminderMinutes);
    if (exists) {
      this.eventForm.reminderTimes = this.eventForm.reminderTimes.filter((item: number) => item !== reminderMinutes);
    } else {
      this.eventForm.reminderTimes = [...this.eventForm.reminderTimes, reminderMinutes].sort((first: number, second: number) => first - second);
    }
  }

  addCustomReminder(): void {
    const value: number = Number(this.customReminderText);
    if (!value || value <= 0) {
      return;
    }
    if (!this.eventForm.reminderTimes.includes(value)) {
      this.eventForm.reminderTimes = [...this.eventForm.reminderTimes, value].sort((first: number, second: number) => first - second);
    }
    this.customReminderText = '';
  }

  shiftTime(isStart: boolean, minutes: number): void {
    const offset: number = minutes * 60 * 1000;
    if (isStart) {
      this.eventForm.startTime += offset;
      if (this.eventForm.endTime <= this.eventForm.startTime) {
        this.eventForm.endTime = this.eventForm.startTime + 60 * 60 * 1000;
      }
      return;
    }
    this.eventForm.endTime += offset;
  }

  async saveEvent(): Promise<void> {
    if (this.eventForm.title.trim().length === 0) {
      this.errorMessage = '请输入日程标题';
      return;
    }
    if (this.eventForm.endTime <= this.eventForm.startTime) {
      this.errorMessage = '结束时间必须晚于开始时间';
      return;
    }
    this.errorMessage = '';
    const savedId: number = await StorageManager.saveEvent({
      ...this.eventForm,
      updatedAt: Date.now()
    });
    this.eventForm.id = savedId;
    await NotificationManager.scheduleEventReminders(this.eventForm);
    router.back();
  }

  async deleteEvent(): Promise<void> {
    if (!this.isEditing || this.eventForm.id <= 0) {
      return;
    }
    await NotificationManager.cancelEventReminders(this.eventForm.id);
    await StorageManager.deleteEvent(this.eventForm.id);
    router.back();
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Text(this.pageTitle)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
          Blank()
          Button('保存')
            .backgroundColor('#4A90D9')
            .fontColor('#FFFFFF')
            .borderRadius(18)
            .onClick(() => {
              this.saveEvent();
            })
        }
        .width('100%')

        if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(13)
            .fontColor('#D64545')
            .width('100%')
            .padding(12)
            .backgroundColor('#FFF1F1')
            .borderRadius(14)
        }

        this.buildInputSection('标题', this.eventForm.title, (value: string) => {
          this.eventForm.title = value;
        })
        this.buildInputSection('描述', this.eventForm.description, (value: string) => {
          this.eventForm.description = value;
        })
        this.buildInputSection('地点', this.eventForm.location, (value: string) => {
          this.eventForm.location = value;
        })

        Column({ space: 12 }) {
          Text('时间')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .width('100%')
          Text(`开始：${formatDateTime(this.eventForm.startTime)}`)
            .fontSize(14)
            .fontColor('#5B6770')
            .onClick(() => {
              this.shiftTime(true, 30);
            })
          Text(`结束：${formatDateTime(this.eventForm.endTime)}`)
            .fontSize(14)
            .fontColor('#5B6770')
            .onClick(() => {
              this.shiftTime(false, 30);
            })
          Toggle({ type: ToggleType.Switch, isOn: this.eventForm.isAllDay })
            .onChange((value: boolean) => {
              this.eventForm.isAllDay = value;
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Column({ space: 12 }) {
          Text('标签')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
            ForEach(this.tags, (tag: TagModel) => {
              Text(tag.name)
                .fontSize(13)
                .fontColor(this.eventForm.tagId === tag.id ? '#FFFFFF' : tag.color)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.eventForm.tagId === tag.id ? tag.color : '#FFFFFF')
                .borderRadius(16)
                .border({ width: 1, color: tag.color })
                .onClick(() => {
                  this.eventForm.tagId = tag.id;
                })
            })
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Column({ space: 12 }) {
          Text('提醒')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(REMINDER_OPTIONS, (minutes: number) => {
              Text(getReminderLabel(minutes))
                .fontSize(13)
                .fontColor(this.eventForm.reminderTimes.includes(minutes) ? '#FFFFFF' : '#4A90D9')
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.eventForm.reminderTimes.includes(minutes) ? '#4A90D9' : '#E8F3FF')
                .borderRadius(16)
                .onClick(() => {
                  this.updateReminder(minutes);
                })
            })
            ForEach(this.eventForm.reminderTimes.filter((minutes: number) => !REMINDER_OPTIONS.includes(minutes)), (minutes: number) => {
              Text(getReminderLabel(minutes))
                .fontSize(13)
                .fontColor('#FFFFFF')
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor('#8B5CF6')
                .borderRadius(16)
                .onClick(() => {
                  this.updateReminder(minutes);
                })
            })
          }
          Row({ space: 8 }) {
            TextInput({ placeholder: '自定义分钟数', text: this.customReminderText })
              .layoutWeight(1)
              .backgroundColor('#F5F7FB')
              .borderRadius(16)
              .onChange((value: string) => {
                this.customReminderText = value;
              })
            Button('添加')
              .backgroundColor('#4A90D9')
              .fontColor('#FFFFFF')
              .borderRadius(16)
              .onClick(() => {
                this.addCustomReminder();
              })
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Column({ space: 12 }) {
          Text('重复')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .width('100%')
          Row({ space: 8 }) {
            ForEach(REPEAT_OPTIONS, (repeatType: RepeatType, index: number) => {
              Text(REPEAT_OPTION_LABELS[index])
                .fontSize(13)
                .fontColor(this.eventForm.repeatType === repeatType ? '#FFFFFF' : '#4A90D9')
                .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                .backgroundColor(this.eventForm.repeatType === repeatType ? '#4A90D9' : '#E8F3FF')
                .borderRadius(16)
                .onClick(() => {
                  this.eventForm.repeatType = repeatType;
                })
            })
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Column({ space: 12 }) {
          Text('颜色')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .width('100%')
          Row({ space: 12 }) {
            ForEach(EVENT_PRESET_COLORS, (color: string) => {
              Circle()
                .width(28)
                .height(28)
                .fill(color)
                .stroke(this.eventForm.color === color ? '#182431' : '#FFFFFF', this.eventForm.color === color ? 3 : 1)
                .onClick(() => {
                  this.eventForm.color = color;
                })
            })
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        if (this.isEditing) {
          Button('删除日程')
            .width('100%')
            .backgroundColor('#FFF1F1')
            .fontColor('#D64545')
            .borderRadius(18)
            .onClick(() => {
              this.deleteEvent();
            })
        }
      }
      .width('100%')
      .padding(20)
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FB')
  }

  @Builder
  buildInputSection(title: string, value: string, onChange: (value: string) => void) {
    Column({ space: 10 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .width('100%')
      TextInput({ placeholder: `请输入${title}`, text: value })
        .backgroundColor('#F5F7FB')
        .borderRadius(16)
        .onChange((text: string) => {
          onChange(text);
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
