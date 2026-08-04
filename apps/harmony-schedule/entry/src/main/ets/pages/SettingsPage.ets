// 设置页面，管理默认提醒、数据导入导出和应用说明
import common from '@ohos.app.ability.common';
import StorageManager from '../data/StorageManager';
import { REMINDER_OPTIONS, STORAGE_KEY_DEFAULT_REMINDER, STORAGE_KEY_LAST_EXPORT, getReminderLabel } from '../utils/Constants';

@Component
struct SettingsPage {
  @StorageLink(STORAGE_KEY_DEFAULT_REMINDER) defaultReminderMinutes: number = 15;
  @StorageLink(STORAGE_KEY_LAST_EXPORT) lastExportJson: string = '';
  @State importJson: string = '';
  @State statusMessage: string = '';

  aboutToAppear(): void {
    this.initializePage();
  }

  async initializePage(): Promise<void> {
    await StorageManager.initialize(getContext(this) as common.UIAbilityContext);
  }

  async exportData(): Promise<void> {
    this.lastExportJson = await StorageManager.exportToJson();
    this.statusMessage = '数据已导出到页面下方 JSON 文本框，可复制保存。';
  }

  async importData(): Promise<void> {
    if (this.importJson.trim().length === 0) {
      this.statusMessage = '请先粘贴要导入的 JSON 内容。';
      return;
    }
    await StorageManager.importFromJson(this.importJson);
    this.statusMessage = 'JSON 数据导入成功。';
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Text('设置')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .width('100%')

        Column({ space: 12 }) {
          Text('默认提醒时间')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .width('100%')
          Row({ space: 8 }) {
            ForEach(REMINDER_OPTIONS, (minutes: number) => {
              Text(getReminderLabel(minutes))
                .fontSize(13)
                .fontColor(this.defaultReminderMinutes === minutes ? '#FFFFFF' : '#4A90D9')
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.defaultReminderMinutes === minutes ? '#4A90D9' : '#E8F3FF')
                .borderRadius(16)
                .onClick(() => {
                  this.defaultReminderMinutes = minutes;
                })
            })
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Column({ space: 8 }) {
          Text('深色模式')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .width('100%')
          Text('应用界面将跟随系统深色模式设置。')
            .fontSize(14)
            .fontColor('#5B6770')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Column({ space: 12 }) {
          Text('数据导出 / 导入')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .width('100%')
          Row({ space: 12 }) {
            Button('导出 JSON')
              .layoutWeight(1)
              .backgroundColor('#4A90D9')
              .fontColor('#FFFFFF')
              .borderRadius(16)
              .onClick(() => {
                this.exportData();
              })
            Button('导入 JSON')
              .layoutWeight(1)
              .backgroundColor('#43C463')
              .fontColor('#FFFFFF')
              .borderRadius(16)
              .onClick(() => {
                this.importData();
              })
          }
          TextInput({ placeholder: '粘贴要导入的 JSON', text: this.importJson })
            .backgroundColor('#F5F7FB')
            .borderRadius(16)
            .height(120)
            .onChange((value: string) => {
              this.importJson = value;
            })
          if (this.lastExportJson.length > 0) {
            Text(this.lastExportJson)
              .fontSize(12)
              .fontColor('#182431')
              .width('100%')
              .padding(12)
              .backgroundColor('#F5F7FB')
              .borderRadius(16)
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Column({ space: 8 }) {
          Text('关于应用')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .width('100%')
          Text('HarmonySchedule 是一个基于 HarmonyOS ArkUI 的日历和智能日程管理应用，支持月视图、周视图、标签管理和多提醒设置。')
            .fontSize(14)
            .fontColor('#5B6770')
          if (this.statusMessage.length > 0) {
            Text(this.statusMessage)
              .fontSize(13)
              .fontColor('#4A90D9')
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
      }
      .width('100%')
      .padding(20)
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FB')
  }
}
