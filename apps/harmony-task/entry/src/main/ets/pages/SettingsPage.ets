import router from '@ohos.router';
import preferences from '@ohos.data.preferences';
import { TaskDatabase } from '../database/TaskDatabase';
import { ReminderService } from '../services/ReminderService';
import promptAction from '@ohos.promptAction';

const PREFS_NAME: string = 'task_settings';
const KEY_REMINDER_ENABLED: string = 'reminder_enabled';
const KEY_DEFAULT_REMINDER_TIME: string = 'default_reminder_time';

@Entry
@Component
struct SettingsPage {
  @State reminderEnabled: boolean = true;
  @State defaultReminderTime: number = 15;
  private reminderService: ReminderService = new ReminderService();

  async aboutToAppear(): Promise<void> {
    await this.loadSettings();
  }

  async loadSettings(): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(this), PREFS_NAME);
      this.reminderEnabled = (await prefs.get(KEY_REMINDER_ENABLED, true)) as boolean;
      this.defaultReminderTime = (await prefs.get(KEY_DEFAULT_REMINDER_TIME, 15)) as number;
    } catch (err) {
      // use defaults
    }
  }

  async saveSettings(): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(this), PREFS_NAME);
      await prefs.put(KEY_REMINDER_ENABLED, this.reminderEnabled);
      await prefs.put(KEY_DEFAULT_REMINDER_TIME, this.defaultReminderTime);
      await prefs.flush();
    } catch (err) {
      // ignore
    }
  }

  async clearCompleted(): Promise<void> {
    const db = TaskDatabase.getInstance();
    const count = await db.clearCompletedTasks();
    promptAction.showToast({ message: `已清除 ${count} 条已完成任务` });
  }

  async clearAllReminders(): Promise<void> {
    await this.reminderService.cancelAllReminders();
    promptAction.showToast({ message: '已清除所有提醒' });
  }

  build() {
    Column() {
      // Header
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })

        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 12 })
      }
      .width('100%')
      .padding(16)

      List({ space: 1 }) {
        // 提醒开关
        ListItem() {
          Row() {
            Column() {
              Text('任务提醒')
                .fontSize(16)
                .fontColor('#333333')
              Text('开启后将在任务到期前发送通知提醒')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Toggle({ type: ToggleType.Switch, isOn: this.reminderEnabled })
              .selectedColor('#4ECDC4')
              .onChange((isOn: boolean) => {
                this.reminderEnabled = isOn;
                this.saveSettings();
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
        }

        // 默认提醒时间
        ListItem() {
          Column() {
            Text('默认提醒时间')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            Row() {
              ForEach([
                { label: '5分钟', value: 5 },
                { label: '15分钟', value: 15 },
                { label: '30分钟', value: 30 },
                { label: '1小时', value: 60 }
              ], (item: { label: string; value: number }) => {
                Text(item.label)
                  .fontSize(13)
                  .fontColor(this.defaultReminderTime === item.value ? Color.White : '#666666')
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor(this.defaultReminderTime === item.value ? '#4ECDC4' : '#F0F0F0')
                  .borderRadius(14)
                  .margin({ right: 8 })
                  .onClick(() => {
                    this.defaultReminderTime = item.value;
                    this.saveSettings();
                  })
              }, (item: { label: string; value: number }) => item.value.toString())
            }
            .margin({ top: 12 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .alignItems(HorizontalAlign.Start)
        }

        // 分类管理入口
        ListItem() {
          Row() {
            Text('分类管理')
              .fontSize(16)
              .fontColor('#333333')
              .layoutWeight(1)

            Image($r('sys.media.ohos_ic_public_arrow_right'))
              .width(20)
              .height(20)
              .fillColor('#CCCCCC')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .onClick(() => {
            router.pushUrl({ url: 'pages/CategoryPage' });
          })
        }

        // 清除已完成任务
        ListItem() {
          Row() {
            Text('清除已完成任务')
              .fontSize(16)
              .fontColor('#FF4757')
              .layoutWeight(1)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .onClick(() => {
            this.clearCompleted();
          })
        }

        // 清除所有提醒
        ListItem() {
          Row() {
            Text('清除所有提醒')
              .fontSize(16)
              .fontColor('#FF4757')
              .layoutWeight(1)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .onClick(() => {
            this.clearAllReminders();
          })
        }

        // 关于
        ListItem() {
          Column() {
            Text('鸿蒙待办 v1.0.0')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 24 })
            Text('HarmonyOS ArkUI 开发')
              .fontSize(12)
              .fontColor('#CCCCCC')
              .margin({ top: 4 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
      }
      .layoutWeight(1)
      .divider({ strokeWidth: 0.5, color: '#F0F0F0', startMargin: 16, endMargin: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}
