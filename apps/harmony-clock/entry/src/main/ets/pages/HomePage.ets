import { AlarmModel } from '../models/AlarmModel'
import { TimezoneModel } from '../models/TimezoneModel'
import { AlarmService } from '../services/AlarmService'
import { StorageUtils, SettingsModel } from '../utils/StorageUtils'
import { TimeUtils } from '../utils/TimeUtils'
import { AlarmPage } from './AlarmPage'
import { SettingsPage } from './SettingsPage'
import { StopwatchPage } from './StopwatchPage'
import { TimerPage } from './TimerPage'
import { WorldClockPage } from './WorldClockPage'

enum TabIndex {
  Home = 0,
  WorldClock = 1,
  Alarm = 2,
  Stopwatch = 3,
  Timer = 4,
  Settings = 5
}

@Component
struct DashboardCard {
  @Prop title: string = ''
  @Prop value: string = ''
  @Prop detail: string = ''

  build() {
    Column({ space: 8 }) {
      Text(this.title)
        .fontSize(14)
        .fontColor('#666666')
        .width('100%')
        .textAlign(TextAlign.Start)
      Text(this.value)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)
      Text(this.detail)
        .fontSize(13)
        .fontColor('#666666')
        .width('100%')
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
    .alignItems(HorizontalAlign.Start)
  }
}

@Entry
@Component
struct HomePage {
  @State selectedTab: number = TabIndex.Home
  @State currentTime: Date = new Date()
  @State alarms: Array<AlarmModel> = []
  @State worldClocks: Array<TimezoneModel> = []
  @State use24Hour: boolean = true
  @State vibrationEnabled: boolean = true
  @State defaultTimerSeconds: number = 300
  @State stopwatchRunning: boolean = false
  @State stopwatchElapsedMilliseconds: number = 0
  @State timerRunning: boolean = false
  @State timerRemainingSeconds: number = 300
  @State timerPresetSeconds: number = 300

  private clockIntervalId: number = -1
  private stopwatchIntervalId: number = -1
  private timerIntervalId: number = -1
  private stopwatchStartTimestamp: number = 0
  private stopwatchAccumulatedMilliseconds: number = 0

  aboutToAppear(): void {
    this.reloadData()
    this.startClockTicker()
  }

  aboutToDisappear(): void {
    this.stopClockTicker()
    this.stopStopwatchTicker()
    this.stopTimerTicker()
  }

  private reloadData(): void {
    let settings: SettingsModel = StorageUtils.getSettings()
    this.alarms = AlarmService.getAllAlarms()
    this.worldClocks = StorageUtils.getWorldClocks()
    this.use24Hour = settings.use24Hour
    this.vibrationEnabled = settings.vibrationEnabled
    this.defaultTimerSeconds = settings.defaultTimerSeconds
    if (!this.timerRunning) {
      this.timerPresetSeconds = settings.defaultTimerSeconds
      this.timerRemainingSeconds = settings.defaultTimerSeconds
    }
  }

  private startClockTicker(): void {
    this.stopClockTicker()
    this.currentTime = new Date()
    this.clockIntervalId = setInterval(() => {
      this.currentTime = new Date()
    }, 1000)
  }

  private stopClockTicker(): void {
    if (this.clockIntervalId >= 0) {
      clearInterval(this.clockIntervalId)
      this.clockIntervalId = -1
    }
  }

  private startStopwatch(): void {
    if (this.stopwatchRunning) {
      return
    }
    this.stopwatchRunning = true
    this.stopwatchStartTimestamp = new Date().getTime() - this.stopwatchAccumulatedMilliseconds
    this.stopwatchIntervalId = setInterval(() => {
      this.stopwatchElapsedMilliseconds = new Date().getTime() - this.stopwatchStartTimestamp
    }, 10)
  }

  private pauseStopwatch(): void {
    if (!this.stopwatchRunning) {
      return
    }
    this.stopwatchRunning = false
    this.stopwatchAccumulatedMilliseconds = this.stopwatchElapsedMilliseconds
    this.stopStopwatchTicker()
  }

  private resetStopwatch(): void {
    this.stopwatchRunning = false
    this.stopwatchAccumulatedMilliseconds = 0
    this.stopwatchElapsedMilliseconds = 0
    this.stopStopwatchTicker()
  }

  private stopStopwatchTicker(): void {
    if (this.stopwatchIntervalId >= 0) {
      clearInterval(this.stopwatchIntervalId)
      this.stopwatchIntervalId = -1
    }
  }

  private startTimer(): void {
    if (this.timerRunning || this.timerRemainingSeconds <= 0) {
      return
    }
    this.timerRunning = true
    this.stopTimerTicker()
    this.timerIntervalId = setInterval(() => {
      if (this.timerRemainingSeconds > 0) {
        this.timerRemainingSeconds -= 1
      }
      if (this.timerRemainingSeconds <= 0) {
        this.timerRemainingSeconds = 0
        this.timerRunning = false
        this.stopTimerTicker()
      }
    }, 1000)
  }

  private pauseTimer(): void {
    this.timerRunning = false
    this.stopTimerTicker()
  }

  private resetTimer(): void {
    this.timerRunning = false
    this.timerRemainingSeconds = this.timerPresetSeconds
    this.stopTimerTicker()
  }

  private setTimerPreset(seconds: number): void {
    this.timerPresetSeconds = seconds
    if (!this.timerRunning) {
      this.timerRemainingSeconds = seconds
    }
  }

  private stopTimerTicker(): void {
    if (this.timerIntervalId >= 0) {
      clearInterval(this.timerIntervalId)
      this.timerIntervalId = -1
    }
  }

  private addAlarm(): void {
    let nextHour: number = (this.currentTime.getHours() + 1) % 24
    this.alarms = AlarmService.addAlarm(nextHour, this.currentTime.getMinutes(), 'New Alarm')
  }

  private toggleAlarm(alarmId: number, enabled: boolean): void {
    this.alarms = AlarmService.toggleAlarm(alarmId, enabled)
  }

  private deleteAlarm(alarmId: number): void {
    this.alarms = AlarmService.deleteAlarm(alarmId)
  }

  private saveSettings(): void {
    StorageUtils.saveSettings(new SettingsModel(
      this.use24Hour,
      this.vibrationEnabled,
      this.defaultTimerSeconds
    ))
  }

  @Builder
  buildHomeContent() {
    Column({ space: 12 }) {
      DashboardCard({
        title: 'Local Time',
        value: TimeUtils.formatCurrentTime(this.currentTime, this.use24Hour),
        detail: TimeUtils.formatDate(this.currentTime)
      })
      DashboardCard({
        title: 'Next Alarm',
        value: TimeUtils.getNextAlarmSummary(this.alarms, this.use24Hour),
        detail: `${this.alarms.filter((alarm: AlarmModel) => alarm.enabled).length} enabled alarms`
      })
      DashboardCard({
        title: 'Timer',
        value: TimeUtils.formatTimer(this.timerRemainingSeconds),
        detail: this.timerRunning ? 'Timer is running' : 'Ready to start'
      })
      DashboardCard({
        title: 'Stopwatch',
        value: TimeUtils.formatDuration(this.stopwatchElapsedMilliseconds),
        detail: this.stopwatchRunning ? 'Stopwatch is running' : 'Stopwatch is paused'
      })
    }
    .width('100%')
  }

  @Builder
  buildContent() {
    if (this.selectedTab === TabIndex.Home) {
      this.buildHomeContent()
    } else if (this.selectedTab === TabIndex.WorldClock) {
      WorldClockPage({
        zones: this.worldClocks,
        currentTime: this.currentTime
      })
    } else if (this.selectedTab === TabIndex.Alarm) {
      AlarmPage({
        alarms: this.alarms,
        use24Hour: this.use24Hour,
        onAddAlarm: () => this.addAlarm(),
        onToggleAlarm: (alarmId: number, enabled: boolean) => this.toggleAlarm(alarmId, enabled),
        onDeleteAlarm: (alarmId: number) => this.deleteAlarm(alarmId)
      })
    } else if (this.selectedTab === TabIndex.Stopwatch) {
      StopwatchPage({
        elapsedMilliseconds: this.stopwatchElapsedMilliseconds,
        running: this.stopwatchRunning,
        onStart: () => this.startStopwatch(),
        onPause: () => this.pauseStopwatch(),
        onReset: () => this.resetStopwatch()
      })
    } else if (this.selectedTab === TabIndex.Timer) {
      TimerPage({
        remainingSeconds: this.timerRemainingSeconds,
        running: this.timerRunning,
        presetSeconds: this.timerPresetSeconds,
        onStart: () => this.startTimer(),
        onPause: () => this.pauseTimer(),
        onReset: () => this.resetTimer(),
        onPresetChange: (seconds: number) => this.setTimerPreset(seconds)
      })
    } else {
      SettingsPage({
        use24Hour: this.use24Hour,
        vibrationEnabled: this.vibrationEnabled,
        defaultTimerSeconds: this.defaultTimerSeconds,
        onUse24HourChange: (value: boolean) => {
          this.use24Hour = value
          this.saveSettings()
        },
        onVibrationChange: (value: boolean) => {
          this.vibrationEnabled = value
          this.saveSettings()
        },
        onDefaultTimerChange: (value: number) => {
          this.defaultTimerSeconds = value
          if (!this.timerRunning) {
            this.timerPresetSeconds = value
            this.timerRemainingSeconds = value
          }
          this.saveSettings()
        }
      })
    }
  }

  build() {
    Column({ space: 16 }) {
      Column({ space: 4 }) {
        Text('HarmonyClock')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)
        Text('All your everyday clocks in one place')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .textAlign(TextAlign.Start)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Scroll() {
        Column({ space: 12 }) {
          this.buildContent()
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .width('100%')

      Row({ space: 8 }) {
        Button('Home')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .backgroundColor(this.selectedTab === TabIndex.Home ? '#317AF7' : '#FFFFFF')
          .fontColor(this.selectedTab === TabIndex.Home ? '#FFFFFF' : '#222222')
          .onClick(() => {
            this.selectedTab = TabIndex.Home
          })
        Button('World')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .backgroundColor(this.selectedTab === TabIndex.WorldClock ? '#317AF7' : '#FFFFFF')
          .fontColor(this.selectedTab === TabIndex.WorldClock ? '#FFFFFF' : '#222222')
          .onClick(() => {
            this.selectedTab = TabIndex.WorldClock
          })
        Button('Alarm')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .backgroundColor(this.selectedTab === TabIndex.Alarm ? '#317AF7' : '#FFFFFF')
          .fontColor(this.selectedTab === TabIndex.Alarm ? '#FFFFFF' : '#222222')
          .onClick(() => {
            this.selectedTab = TabIndex.Alarm
          })
      }
      .width('100%')

      Row({ space: 8 }) {
        Button('Watch')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .backgroundColor(this.selectedTab === TabIndex.Stopwatch ? '#317AF7' : '#FFFFFF')
          .fontColor(this.selectedTab === TabIndex.Stopwatch ? '#FFFFFF' : '#222222')
          .onClick(() => {
            this.selectedTab = TabIndex.Stopwatch
          })
        Button('Timer')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .backgroundColor(this.selectedTab === TabIndex.Timer ? '#317AF7' : '#FFFFFF')
          .fontColor(this.selectedTab === TabIndex.Timer ? '#FFFFFF' : '#222222')
          .onClick(() => {
            this.selectedTab = TabIndex.Timer
          })
        Button('Settings')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .backgroundColor(this.selectedTab === TabIndex.Settings ? '#317AF7' : '#FFFFFF')
          .fontColor(this.selectedTab === TabIndex.Settings ? '#FFFFFF' : '#222222')
          .onClick(() => {
            this.selectedTab = TabIndex.Settings
          })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F2F3F5')
  }
}
