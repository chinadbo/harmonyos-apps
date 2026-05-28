import dataPreferences from '@ohos.data.preferences';
import promptAction from '@ohos.promptAction';
import DatabaseService, { SleepRecordInput } from '../service/DatabaseService';
import { SleepRecord, formatDuration } from '../model/SleepRecord';
import { SleepStatusCard } from '../components/SleepStatusCard';
import { WeeklySummary } from '../components/WeeklySummary';
import RecordsPage from './RecordsPage';
import StatsPage from './StatsPage';
import SettingsPage from './SettingsPage';

@CustomDialog
struct QualityDialog {
  controller?: CustomDialogController;
  @State ratingValue: number = 3;
  @State noteValue: string = '';
  onConfirm?: (quality: number, note: string) => void;

  build() {
    Column({ space: 16 }) {
      Text('睡眠质量评分')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
      Row({ space: 8 }) {
        ForEach([1, 2, 3, 4, 5], (star: number) => {
          Text(star <= this.ratingValue ? '★' : '☆')
            .fontSize(32)
            .fontColor(star <= this.ratingValue ? '#FFD700' : '#CCCCCC')
            .onClick(() => {
              this.ratingValue = star;
            })
        }, (star: number) => star.toString())
      }
      TextInput({ placeholder: '备注（可选）', text: this.noteValue })
        .onChange((val) => {
          this.noteValue = val;
        })
        .width('100%')
      Row({ space: 12 }) {
        Button('跳过')
          .backgroundColor('#F0F0F0')
          .fontColor('#888888')
          .layoutWeight(1)
          .onClick(() => {
            if (this.controller) this.controller.close();
          })
        Button('保存')
          .backgroundColor('#5B8DEF')
          .layoutWeight(1)
          .onClick(() => {
            if (this.onConfirm) this.onConfirm(this.ratingValue, this.noteValue);
            if (this.controller) this.controller.close();
          })
      }
    }
    .padding(24)
    .width('100%')
  }
}

@Entry
@Component
struct Index {
  @State currentTab: number = 0;
  @State isSleeping: boolean = false;
  @State sleepStartTime: number = 0;
  @State lastRecord: SleepRecord = {
    id: 0, sleepTime: 0, wakeTime: 0, duration: 0, quality: 0, note: '', createdAt: 0
  };
  @State weeklyRecords: SleepRecord[] = [];
  @State pendingRecordId: number = -1;
  private prefs: dataPreferences.Preferences | null = null;

  private qualityDialog: CustomDialogController = new CustomDialogController({
    builder: QualityDialog({
      onConfirm: (quality: number, note: string) => {
        this.saveQuality(quality, note);
      }
    }),
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: 0 }
  });

  async aboutToAppear(): Promise<void> {
    try {
      this.prefs = await dataPreferences.getPreferences(getContext(this), { name: 'sleep_settings' });
      const isSleeping = await this.prefs.get('isSleeping', false) as boolean;
      const sleepStartTime = await this.prefs.get('sleepStartTime', 0) as number;
      this.isSleeping = isSleeping;
      this.sleepStartTime = sleepStartTime;
      await this.loadData();
    } catch (err) {
      console.error('[Index] aboutToAppear error:', JSON.stringify(err));
    }
  }

  async loadData(): Promise<void> {
    try {
      const todayRecord = await DatabaseService.instance().getTodayRecord();
      if (todayRecord) {
        this.lastRecord = todayRecord;
      } else {
        const records = await DatabaseService.instance().getRecords(1, 0);
        if (records.length > 0) {
          this.lastRecord = records[0];
        }
      }
      this.weeklyRecords = await DatabaseService.instance().getWeeklyStats();
    } catch (err) {
      console.error('[Index] loadData error:', JSON.stringify(err));
    }
  }

  async onSleepStart(): Promise<void> {
    this.sleepStartTime = Date.now();
    this.isSleeping = true;
    try {
      if (this.prefs) {
        await this.prefs.put('isSleeping', true);
        await this.prefs.put('sleepStartTime', this.sleepStartTime);
        await this.prefs.flush();
      }
    } catch (err) {
      console.error('[Index] onSleepStart error:', JSON.stringify(err));
    }
  }

  async onWakeUp(): Promise<void> {
    const wakeTime = Date.now();
    const duration = Math.round((wakeTime - this.sleepStartTime) / 60000);
    this.isSleeping = false;
    try {
      if (this.prefs) {
        await this.prefs.put('isSleeping', false);
        await this.prefs.flush();
      }
      const newId = await DatabaseService.instance().insertRecord({
        sleepTime: this.sleepStartTime,
        wakeTime: wakeTime,
        duration: duration,
        quality: 0,
        note: '',
        createdAt: Date.now()
      });
      this.pendingRecordId = newId;
      await this.loadData();
      this.qualityDialog.open();
    } catch (err) {
      console.error('[Index] onWakeUp error:', JSON.stringify(err));
    }
  }

  async saveQuality(quality: number, note: string): Promise<void> {
    if (this.pendingRecordId > 0) {
      await DatabaseService.instance().updateQuality(this.pendingRecordId, quality, note);
      await this.loadData();
      this.pendingRecordId = -1;
    }
  }

  @Builder
  TodayTab() {
    Scroll() {
      Column({ space: 16 }) {
        SleepStatusCard({
          isSleeping: this.isSleeping,
          sleepStartTime: this.sleepStartTime,
          lastRecord: this.lastRecord
        })
          .margin({ top: 16 })

        if (!this.isSleeping) {
          Button('开始睡眠')
            .width('100%')
            .height(52)
            .backgroundColor('#5B8DEF')
            .borderRadius(26)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.onSleepStart();
            })
        } else {
          Button('我起床了')
            .width('100%')
            .height(52)
            .backgroundColor('#4CAF50')
            .borderRadius(26)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.onWakeUp();
            })
        }

        WeeklySummary({
          records: this.weeklyRecords,
          targetDuration: 480
        })
      }
      .padding({ horizontal: 16, bottom: 24 })
      .width('100%')
    }
    .scrollBar(BarState.Off)
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentTab }) {
      TabContent() {
        this.TodayTab()
      }
      .tabBar(this.TabBarItem('今日', 0, '🌙'))

      TabContent() {
        RecordsPage()
      }
      .tabBar(this.TabBarItem('记录', 1, '📋'))

      TabContent() {
        StatsPage()
      }
      .tabBar(this.TabBarItem('统计', 2, '📊'))

      TabContent() {
        SettingsPage()
      }
      .tabBar(this.TabBarItem('设置', 3, '⚙️'))
    }
    .barWidth('100%')
    .barHeight(60)
    .backgroundColor('#F8F9FA')
    .onChange((index) => {
      this.currentTab = index;
    })
  }

  @Builder
  TabBarItem(label: string, index: number, icon: string) {
    Column({ space: 2 }) {
      Text(icon)
        .fontSize(20)
      Text(label)
        .fontSize(11)
        .fontColor(this.currentTab === index ? '#5B8DEF' : '#888888')
    }
    .padding({ vertical: 8 })
  }
}
