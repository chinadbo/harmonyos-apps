import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { CharEntry, CharRepository, Stroke } from '../model/CharData';
import { CharStat, MasteryUtil, PracticeRecord } from '../model/PracticeRecord';
import { DbHelper } from '../db/DbHelper';
import { AppTheme } from '../common/Theme';
import { Constants } from '../common/Constants';
import { AppSettings, DateUtil, SettingsUtil, ToastUtil } from '../common/AppUtil';
import { StrokeAnim } from '../components/StrokeAnim';
import { ProgressRing } from '../components/ProgressRing';

interface DetailParams {
  char: string;
}

interface PracticeParams {
  char: string;
}

@Entry
@Component
struct CharDetail {
  @State charName: string = '';
  @State entry: CharEntry = { char: '', pinyin: '', grade: 1, strokes: [] };
  @State hasEntry: boolean = false;
  @State speed: number = Constants.ANIM_SPEED_DEFAULT;
  @State brushWidth: number = Constants.BRUSH_WIDTH_DEFAULT;
  @State bestScore: number = 0;
  @State attempts: number = 0;
  @State mastery: number = 0;
  @State records: PracticeRecord[] = [];
  private settings: AppSettings = SettingsUtil.defaultSettings();

  aboutToAppear(): void {
    const raw: Object = router.getParams();
    if (raw !== undefined && raw !== null) {
      const params: DetailParams = raw as DetailParams;
      if (params.char !== undefined) {
        this.charName = params.char;
      }
    }
  }

  onPageShow(): void {
    this.loadData();
  }

  private async loadData(): Promise<void> {
    if (this.charName.length === 0) {
      return;
    }
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    await CharRepository.getInstance().load(context);
    const found: CharEntry | undefined = CharRepository.getInstance().getByChar(this.charName);
    if (found !== undefined) {
      this.entry = found;
      this.hasEntry = true;
    }
    this.settings = await SettingsUtil.load(context);
    this.speed = this.settings.animSpeed;
    this.brushWidth = this.settings.brushWidth;

    await DbHelper.getInstance().init(context);
    const stats: CharStat[] = await DbHelper.getInstance().getCharStats();
    this.bestScore = 0;
    this.attempts = 0;
    this.mastery = 0;
    for (let i = 0; i < stats.length; i++) {
      if (stats[i].char === this.charName) {
        this.bestScore = stats[i].bestScore;
        this.attempts = stats[i].attempts;
        this.mastery = MasteryUtil.mastery(stats[i].bestScore, stats[i].attempts);
      }
    }
    this.records = await DbHelper.getInstance().getRecordsForChar(this.charName, 3);
  }

  private async saveSpeed(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    this.settings.animSpeed = this.speed;
    await SettingsUtil.save(context, this.settings);
  }

  private startPractice(): void {
    const params: PracticeParams = { char: this.charName };
    router.pushUrl({ url: 'pages/Practice', params: params }).catch(() => {
      ToastUtil.show('页面打开失败');
    });
  }

  @Builder
  strokeChip(index: number, type: string) {
    Row({ space: 5 }) {
      Text(`${index}`)
        .fontSize(10)
        .fontColor('#FFFFFF')
        .width(16)
        .height(16)
        .textAlign(TextAlign.Center)
        .backgroundColor(AppTheme.INK_LIGHT)
        .borderRadius(8)
      Text(type)
        .fontSize(12)
        .fontColor(AppTheme.INK)
    }
    .padding({ left: 8, right: 10, top: 5, bottom: 5 })
    .backgroundColor(AppTheme.CARD_ALT)
    .borderRadius(12)
    .margin({ right: 6, bottom: 6 })
  }

  @Builder
  recordRow(record: PracticeRecord) {
    Row({ space: 10 }) {
      Text(`${record.score}`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.scoreColor(record.score))
        .width(44)
      Column({ space: 2 }) {
        Text(`得分 ${record.score} · ${Constants.scoreLabel(record.score)}`)
          .fontSize(12)
          .fontColor(AppTheme.INK)
        Text(`${DateUtil.formatDateTime(record.createdAt)} · 用时 ${Math.max(1, Math.round(record.durationMs / 1000))} 秒`)
          .fontSize(10)
          .fontColor(AppTheme.INK_FAINT)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Text('‹')
          .fontSize(30)
          .fontColor(AppTheme.INK)
          .width(32)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            router.back();
          })
        Column({ space: 2 }) {
          Text('字详情')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.INK)
          Text(this.hasEntry ? '笔顺演示与笔画拆解' : '正在载入…')
            .fontSize(11)
            .fontColor(AppTheme.INK_FAINT)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: 16, top: 12, bottom: 10 })

      if (!this.hasEntry) {
        Column({ space: 12 }) {
          Text('未找到这个字')
            .fontSize(16)
            .fontColor(AppTheme.INK_LIGHT)
          Button('返回字库')
            .type(ButtonType.Capsule)
            .backgroundColor(AppTheme.INK)
            .fontColor('#FFFFFF')
            .onClick(() => {
              router.back();
            })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 14 }) {
            Row({ space: 16 }) {
              Text(this.entry.char)
                .fontSize(60)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppTheme.INK)
                .width(86)
                .height(86)
                .textAlign(TextAlign.Center)
                .backgroundColor(AppTheme.CARD_ALT)
                .borderRadius(16)
              Column({ space: 6 }) {
                Row({ space: 8 }) {
                  Text(this.entry.pinyin)
                    .fontSize(18)
                    .fontColor(AppTheme.INK_LIGHT)
                  Text(Constants.gradeLabel(this.entry.grade))
                    .fontSize(10)
                    .fontColor(AppTheme.ACCENT)
                    .backgroundColor(AppTheme.ACCENT_SOFT)
                    .borderRadius(8)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                }
                Text(`共 ${this.entry.strokes.length} 笔`)
                  .fontSize(12)
                  .fontColor(AppTheme.INK_FAINT)
                Text(this.bestScore > 0 ? `最佳 ${this.bestScore} 分 · 练习 ${this.attempts} 次` :
                  '尚未练习')
                  .fontSize(12)
                  .fontColor(AppTheme.INK_LIGHT)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              ProgressRing({ percent: this.mastery, size: 68, ringWidth: 7, label: '掌握' })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(AppTheme.CARD)
            .borderRadius(18)

            Column({ space: 10 }) {
              Row() {
                Text('笔顺演示')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(AppTheme.INK)
                Blank()
                Text(this.speed <= 500 ? '速度：快' :
                  (this.speed >= 1200 ? '速度：慢' : '速度：适中'))
                  .fontSize(11)
                  .fontColor(AppTheme.INK_FAINT)
              }
              .width('100%')
              StrokeAnim({
                entry: this.entry,
                size: 280,
                speedMs: this.speed,
                brushWidth: this.brushWidth,
                onFinished: () => {
                }
              })
              Row({ space: 8 }) {
                Text('慢')
                  .fontSize(10)
                  .fontColor(AppTheme.INK_FAINT)
                Slider({
                  value: this.speed,
                  min: Constants.ANIM_SPEED_MIN,
                  max: Constants.ANIM_SPEED_MAX,
                  step: 100,
                  style: SliderStyle.OutSet
                })
                  .layoutWeight(1)
                  .selectedColor(AppTheme.ACCENT)
                  .trackColor(AppTheme.CARD_ALT)
                  .blockColor(AppTheme.ACCENT)
                  .onChange((value: number, mode: SliderChangeMode) => {
                    this.speed = value;
                    if (mode === SliderChangeMode.End) {
                      this.saveSpeed();
                    }
                  })
                Text('快')
                  .fontSize(10)
                  .fontColor(AppTheme.INK_FAINT)
              }
              .width('100%')
              Text('播放可观看完整笔顺；单步可逐笔核对起笔位置')
                .fontSize(10)
                .fontColor(AppTheme.INK_FAINT)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(AppTheme.CARD)
            .borderRadius(18)

            Column({ space: 8 }) {
              Row() {
                Text('笔画拆解')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(AppTheme.INK)
                Blank()
                Text(`${this.entry.strokes.length} 笔`)
                  .fontSize(11)
                  .fontColor(AppTheme.INK_FAINT)
              }
              .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.entry.strokes, (stroke: Stroke, index: number) => {
                  this.strokeChip(index + 1, stroke.type)
                }, (stroke: Stroke, index: number) => `${index}`)
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(AppTheme.CARD)
            .borderRadius(18)

            if (this.records.length > 0) {
              Column({ space: 4 }) {
                Text('最近练习')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(AppTheme.INK)
                  .width('100%')
                ForEach(this.records, (record: PracticeRecord) => {
                  this.recordRow(record)
                }, (record: PracticeRecord) => `${record.id}`)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(AppTheme.CARD)
              .borderRadius(18)
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 16 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        Row({ space: 12 }) {
          Button('返回字库')
            .layoutWeight(1)
            .height(46)
            .type(ButtonType.Capsule)
            .fontSize(14)
            .fontColor(AppTheme.INK)
            .backgroundColor(AppTheme.CARD_ALT)
            .onClick(() => {
              router.back();
            })
          Button('开始练习')
            .layoutWeight(2)
            .height(46)
            .type(ButtonType.Capsule)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor(AppTheme.ACCENT)
            .onClick(() => {
              this.startPractice();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
        .backgroundColor(AppTheme.BG)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BG)
  }
}
