import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { TunerEngine, TunerResult } from '../tuner/TunerEngine';
import { InstrumentConfig, InstrumentPreset } from '../tuner/InstrumentConfig';
import { NoteDisplay } from '../components/NoteDisplay';
import { TuningHistory } from '../data/TuningHistory';
import { TuningRecord } from '../data/TuningRecord';

@Entry
@Component
struct Index {
  @State tunerEngine: TunerEngine = new TunerEngine();
  @State currentResult: TunerResult | null = null;
  @State isTuning: boolean = false;
  @State currentInstrument: InstrumentPreset = InstrumentConfig.GUITAR_STANDARD;
  @State targetNoteIndex: number = 0;
  @State history: TuningHistory = new TuningHistory();

  aboutToAppear() {
    this.tunerEngine.init().then((success: boolean) => {
      if (!success) {
        promptAction.showToast({ message: 'Failed to initialize microphone' });
      }
    });
  }

  aboutToDisappear() {
    this.tunerEngine.release();
  }

  private toggleTuning(): void {
    if (this.isTuning) {
      this.tunerEngine.stop();
      this.isTuning = false;
    } else {
      this.tunerEngine.start(
        (result: TunerResult | null) => {
          this.currentResult = result;
          if (result) {
            const record: TuningRecord = {
              id: Date.now(),
              timestamp: Date.now(),
              instrument: this.currentInstrument.name,
              targetNote: this.currentInstrument.notes[this.targetNoteIndex],
              detectedFreq: result.frequency,
              targetFreq: result.targetFreq,
              deviationCents: result.cents,
              isInTune: result.isInTune
            };
            this.history.addRecord(record);
          }
        }
      );
      this.isTuning = true;
    }
  }

  private drawNeedleGauge(ctx: CanvasRenderingContext2D): void {
    const width = 300;
    const height = 200;
    const centerX = width / 2;
    const centerY = height - 20;
    const radius = 140;

    ctx.clearRect(0, 0, width, height);

    // Arc background
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, Math.PI * 0.85, Math.PI * 0.15, false);
    ctx.lineWidth = 8;
    ctx.strokeStyle = '#E0E0E0';
    ctx.stroke();

    // Green zone (in tune)
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, Math.PI * 0.95, Math.PI * 1.05, false);
    ctx.lineWidth = 8;
    ctx.strokeStyle = '#4CAF50';
    ctx.stroke();

    // Yellow zones
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, Math.PI * 0.85, Math.PI * 0.95, false);
    ctx.lineWidth = 8;
    ctx.strokeStyle = '#FFC107';
    ctx.stroke();
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, Math.PI * 1.05, Math.PI * 1.15, false);
    ctx.lineWidth = 8;
    ctx.strokeStyle = '#FFC107';
    ctx.stroke();

    // Red zones
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, Math.PI * 1.15, Math.PI * 1.25, false);
    ctx.lineWidth = 8;
    ctx.strokeStyle = '#F44336';
    ctx.stroke();
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, Math.PI * 0.75, Math.PI * 0.85, false);
    ctx.lineWidth = 8;
    ctx.strokeStyle = '#F44336';
    ctx.stroke();

    // Needle
    const cents = this.currentResult ? this.currentResult.cents : 0;
    const angle = Math.PI / 2 - (cents / 50) * (Math.PI * 0.4);
    const needleLen = radius - 20;
    const needleX = centerX + Math.cos(angle) * needleLen;
    const needleY = centerY - Math.sin(angle) * needleLen;

    ctx.beginPath();
    ctx.moveTo(centerX, centerY);
    ctx.lineTo(needleX, needleY);
    ctx.lineWidth = 4;
    ctx.strokeStyle = this.isTuning ? '#2196F3' : '#999999';
    ctx.stroke();

    // Center dot
    ctx.beginPath();
    ctx.arc(centerX, centerY, 8, 0, Math.PI * 2);
    ctx.fillStyle = '#333333';
    ctx.fill();
  }

  @Builder
  NeedleGaugeBuilder() {
    Canvas()
      .width('100%')
      .height(200)
      .margin({ top: 20 })
      .onReady((ctx: CanvasRenderingContext2D) => {
        this.drawNeedleGauge(ctx);
      })
      .onAreaChange(() => {
        // Trigger redraw on state change
      })
  }

  build() {
    Column() {
      // AppBar
      Row() {
        Text('HarmonyTuner')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .layoutWeight(1)

        Button() {
          Text('⚙')
            .fontSize(24)
            .fontColor('#FFFFFF')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.pushUrl({ url: 'pages/SettingsPage' });
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#2196F3')
      .alignItems(VerticalAlign.Center)

      // Instrument selector
      Row() {
        Text(this.currentInstrument.name)
          .fontSize(18)
          .fontColor('#333333')
          .layoutWeight(1)

        Button('Change')
          .fontSize(14)
          .backgroundColor('#2196F3')
          .fontColor('#FFFFFF')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/InstrumentSelect',
              params: { currentInstrument: this.currentInstrument.name }
            });
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // Note display
      NoteDisplay({ result: this.currentResult })
        .margin({ top: 20 })

      // Needle gauge
      this.NeedleGaugeBuilder()

      // Target note selector
      Row() {
        ForEach(this.currentInstrument.notes, (note: string, index: number) => {
          Button(note)
            .fontSize(16)
            .backgroundColor(this.targetNoteIndex === index ? '#2196F3' : '#F0F0F0')
            .fontColor(this.targetNoteIndex === index ? '#FFFFFF' : '#333333')
            .margin({ left: 4, right: 4 })
            .onClick(() => {
              this.targetNoteIndex = index;
              this.tunerEngine.setTargetNoteIndex(index);
            })
        }, (note: string) => note)
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Center)

      // Toggle button
      Button(this.isTuning ? 'Stop Tuning' : 'Start Tuning')
        .width(200)
        .height(56)
        .fontSize(18)
        .backgroundColor(this.isTuning ? '#F44336' : '#4CAF50')
        .fontColor('#FFFFFF')
        .margin({ top: 20 })
        .onClick(() => {
          this.toggleTuning();
        })

      // Bottom nav
      Row() {
        Column() {
          Text('🎸')
            .fontSize(24)
          Text('Tuner')
            .fontSize(12)
            .fontColor('#2196F3')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('📜')
            .fontSize(24)
          Text('History')
            .fontSize(12)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          router.pushUrl({ url: 'pages/HistoryPage' });
        })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .border({ width: { top: 1 }, color: '#F0F0F0' })
      .alignItems(VerticalAlign.Center)

      Spacer()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
