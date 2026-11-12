import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { CharEntry, CharRepository, Stroke, StrokePoint } from '../model/CharData';
import { CharStat, PracticeRecord } from '../model/PracticeRecord';
import { DbHelper } from '../db/DbHelper';
import { AppTheme } from '../common/Theme';
import { Constants } from '../common/Constants';
import { AppSettings, HapticUtil, SettingsUtil, ToastUtil } from '../common/AppUtil';
import { TraceMatcher, StrokeMatch } from '../engine/TraceMatcher';
import { StrokeScorer } from '../engine/StrokeScorer';
import { ScorePanel } from '../components/ScorePanel';

interface PracticeParams {
  char: string;
}

@Entry
@Component
struct Practice {
  @State charName: string = '';
  @State entry: CharEntry = { char: '', pinyin: '', grade: 1, strokes: [] };
  @State hasEntry: boolean = false;
  @State currentIndex: number = 0;
  @State liveHint: string = '从第一笔开始，沿半透明底字书写';
  @State liveLevel: number = 0;
  @State liveScore: number = 0;
  @State mistakes: number = 0;
  @State hintVisible: boolean = false;
  @State showScore: boolean = false;
  @State finalScore: number = 0;
  @State orderRate: number = 0;
  @State directionRate: number = 0;
  @State coverageRate: number = 0;
  @State panelBest: number = 0;
  @State previousBest: number = 0;
  @State durationSec: number = 0;
  @State vibrateEnabled: boolean = Constants.VIBRATE_DEFAULT;
  private userPoints: StrokePoint[] = [];
  private completedPaths: StrokePoint[][] = [];
  private feedbackPoints: StrokePoint[] = [];
  private perStrokeScores: number[] = [];
  private startRatios: number[] = [];
  private directionRatios: number[] = [];
  private coverageRatios: number[] = [];
  private activeId: number = -1;
  private isDrawing: boolean = false;
  private moveTick: number = 0;
  private startTs: number = 0;
  private settings: AppSettings = SettingsUtil.defaultSettings();
  private feedbackTimer: number = -1;
  private hintTimer: number = -1;
  private canvasSize: number = 300;
  private canvasReady: boolean = false;
  private settingsCtx: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settingsCtx);

  aboutToAppear(): void {
    const raw: Object = router.getParams();
    if (raw !== undefined && raw !== null) {
      const params: PracticeParams = raw as PracticeParams;
      if (params.char !== undefined) {
        this.charName = params.char;
      }
    }
    this.loadData();
  }

  onPageShow(): void {
    this.loadSettings();
  }

  aboutToDisappear(): void {
    if (this.feedbackTimer >= 0) {
      clearTimeout(this.feedbackTimer);
    }
    if (this.hintTimer >= 0) {
      clearTimeout(this.hintTimer);
    }
  }

  private async loadSettings(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    this.settings = await SettingsUtil.load(context);
    this.vibrateEnabled = this.settings.vibrateEnabled;
    if (this.canvasReady) {
      this.drawScene();
    }
  }

  private async loadData(): Promise<void> {
    if (this.charName.length === 0) {
      return;
    }
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    await CharRepository.getInstance().load(context);
    const found: CharEntry | undefined = CharRepository.getInstance().getByChar(this.charName);
    if (found === undefined) {
      return;
    }
    this.entry = found;
    this.hasEntry = true;
    this.settings = await SettingsUtil.load(context);
    this.vibrateEnabled = this.settings.vibrateEnabled;
    await DbHelper.getInstance().init(context);
    await this.loadBestScore();
    this.resetProgress();
  }

  private async loadBestScore(): Promise<void> {
    const stats: CharStat[] = await DbHelper.getInstance().getCharStats();
    for (let i = 0; i < stats.length; i++) {
      if (stats[i].char === this.charName) {
        this.previousBest = stats[i].bestScore;
        return;
      }
    }
    this.previousBest = 0;
  }

  private resetProgress(): void {
    this.currentIndex = 0;
    this.userPoints = [];
    this.completedPaths = [];
    this.feedbackPoints = [];
    this.perStrokeScores = [];
    this.startRatios = [];
    this.directionRatios = [];
    this.coverageRatios = [];
    this.mistakes = 0;
    this.liveHint = '从第一笔开始，沿半透明底字书写';
    this.liveLevel = 0;
    this.liveScore = 0;
    this.hintVisible = false;
    this.showScore = false;
    this.finalScore = 0;
    this.panelBest = 0;
    this.startTs = Date.now();
    this.isDrawing = false;
    this.activeId = -1;
    if (this.feedbackTimer >= 0) {
      clearTimeout(this.feedbackTimer);
      this.feedbackTimer = -1;
    }
    if (this.hintTimer >= 0) {
      clearTimeout(this.hintTimer);
      this.hintTimer = -1;
    }
    if (this.canvasReady) {
      this.drawScene();
    }
  }

  private currentStandard(): Stroke {
    return this.entry.strokes[Math.min(this.currentIndex, this.entry.strokes.length - 1)];
  }

  private touchPoint(event: TouchEvent): TouchObject | undefined {
    let list: TouchObject[];
    if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      list = event.changedTouches.length > 0 ? event.changedTouches : event.touches;
    } else {
      list = event.touches.length > 0 ? event.touches : event.changedTouches;
    }
    if (list.length === 0) {
      return undefined;
    }
    if (this.activeId !== -1) {
      for (let i = 0; i < list.length; i++) {
        if (list[i].id === this.activeId) {
          return list[i];
        }
      }
    }
    return list[0];
  }

  private handleTouch(event: TouchEvent): void {
    if (!this.hasEntry || this.showScore || this.entry.strokes.length === 0) {
      return;
    }
    const touch: TouchObject | undefined = this.touchPoint(event);
    if (touch === undefined) {
      return;
    }
    const rawX: number = touch.x / this.canvasSize * Constants.NORM_MAX;
    const rawY: number = touch.y / this.canvasSize * Constants.NORM_MAX;
    const x: number = Math.max(0, Math.min(Constants.NORM_MAX, rawX));
    const y: number = Math.max(0, Math.min(Constants.NORM_MAX, rawY));

    if (event.type === TouchType.Down) {
      if (this.isDrawing) {
        return;
      }
      this.isDrawing = true;
      this.activeId = touch.id;
      this.userPoints = [{ x: x, y: y }];
      this.feedbackPoints = [];
      this.liveScore = 0;
      this.liveLevel = 0;
      this.liveHint = '正在书写…';
      this.drawScene();
      return;
    }

    if (this.activeId !== -1 && touch.id !== this.activeId) {
      return;
    }

    if (event.type === TouchType.Move) {
      if (!this.isDrawing) {
        return;
      }
      this.appendPoint(x, y);
      this.moveTick++;
      if (this.moveTick % 2 === 0) {
        this.updateLiveFeedback();
      }
      this.drawScene();
      return;
    }

    if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      if (!this.isDrawing) {
        return;
      }
      this.isDrawing = false;
      this.activeId = -1;
      this.appendPoint(x, y);
      this.evaluateStroke();
    }
  }

  private appendPoint(x: number, y: number): void {
    const last: StrokePoint | undefined = this.userPoints.length > 0 ?
      this.userPoints[this.userPoints.length - 1] : undefined;
    if (last !== undefined) {
      const dx: number = x - last.x;
      const dy: number = y - last.y;
      if (Math.sqrt(dx * dx + dy * dy) < 0.35) {
        return;
      }
    }
    this.userPoints.push({ x: x, y: y });
  }

  private updateLiveFeedback(): void {
    if (this.userPoints.length < 3 || this.currentIndex >= this.entry.strokes.length) {
      return;
    }
    const standard: Stroke = this.currentStandard();
    const match: StrokeMatch = TraceMatcher.matchStroke(this.userPoints, standard);
    this.liveScore = StrokeScorer.liveScore(this.userPoints, standard);
    if (match.startDistance >= Constants.START_TOLERANCE) {
      this.liveHint = '起笔偏离，请从金色圆点起笔';
      this.liveLevel = 3;
    } else if (match.directionRatio < 0.35) {
      this.liveHint = '方向不对，调整笔势';
      this.liveLevel = 2;
    } else if (match.coverageRatio < 0.45) {
      this.liveHint = '轨迹偏离标准笔画';
      this.liveLevel = 2;
    } else {
      this.liveHint = '笔迹贴合，继续保持';
      this.liveLevel = 1;
    }
  }

  private evaluateStroke(): void {
    if (this.currentIndex >= this.entry.strokes.length) {
      return;
    }
    if (this.userPoints.length < 2) {
      this.userPoints = [];
      this.liveHint = '这一笔太短了，请完整书写';
      this.liveLevel = 3;
      this.drawScene();
      return;
    }
    const standard: Stroke = this.currentStandard();
    const match: StrokeMatch = TraceMatcher.matchStroke(this.userPoints, standard);
    const score: number = StrokeScorer.scoreStroke(this.userPoints, standard,
      this.currentIndex + 1).total;
    const passed: boolean = StrokeScorer.isPassed(score) && match.sequenceOk &&
      match.directionRatio >= 0.3;

    if (passed) {
      this.completedPaths.push(this.userPoints);
      this.perStrokeScores.push(score);
      this.startRatios.push(match.startRatio);
      this.directionRatios.push(match.directionRatio);
      this.coverageRatios.push(match.coverageRatio);
      this.userPoints = [];
      this.feedbackPoints = [];
      this.currentIndex++;
      this.liveScore = 0;
      this.liveLevel = 1;
      HapticUtil.tick(this.settings.vibrateEnabled);
      if (this.currentIndex >= this.entry.strokes.length) {
        this.liveHint = '书写完成，正在评分…';
        this.completeChar();
      } else {
        this.liveHint = `第 ${this.currentIndex} 笔正确，接着写第 ${this.currentIndex + 1} 笔`;
        this.drawScene();
      }
      return;
    }

    this.mistakes++;
    this.feedbackPoints = this.userPoints;
    this.userPoints = [];
    this.liveScore = score;
    this.liveLevel = 3;
    if (match.startDistance >= Constants.START_TOLERANCE) {
      this.liveHint = '起笔位置不对，请从金色圆点起笔';
    } else if (match.directionRatio < 0.4) {
      this.liveHint = '笔顺方向不对，再试一次';
    } else if (match.coverageRatio < 0.5) {
      this.liveHint = '笔迹偏离标准笔画，再试一次';
    } else {
      this.liveHint = '这一笔还差一点，再试一次';
    }
    this.drawScene();
    if (this.feedbackTimer >= 0) {
      clearTimeout(this.feedbackTimer);
    }
    this.feedbackTimer = setTimeout(() => {
      this.feedbackPoints = [];
      this.feedbackTimer = -1;
      this.drawScene();
    }, 750);
  }

  private averageRate(values: number[]): number {
    if (values.length === 0) {
      return 0;
    }
    let sum: number = 0;
    for (let i = 0; i < values.length; i++) {
      sum += values[i];
    }
    return Math.round(sum / values.length * 100);
  }

  private completeChar(): void {
    if (this.perStrokeScores.length === 0) {
      return;
    }
    let sum: number = 0;
    for (let i = 0; i < this.perStrokeScores.length; i++) {
      sum += this.perStrokeScores[i];
    }
    const average: number = sum / this.perStrokeScores.length;
    const bonus: number = this.mistakes === 0 ? 5 : 0;
    const score: number = Math.min(100, Math.round(average + bonus));
    this.finalScore = score;
    this.orderRate = this.averageRate(this.startRatios);
    this.directionRate = this.averageRate(this.directionRatios);
    this.coverageRate = this.averageRate(this.coverageRatios);
    this.panelBest = this.previousBest;
    this.previousBest = Math.max(this.previousBest, score);
    this.durationSec = Math.max(1, Math.round((Date.now() - this.startTs) / 1000));
    this.showScore = true;
    this.drawScene();

    const record: PracticeRecord = {
      char: this.charName,
      score: score,
      strokeCount: this.entry.strokes.length,
      durationMs: Date.now() - this.startTs,
      createdAt: Date.now()
    };
    this.saveRecord(record);
  }

  private async saveRecord(record: PracticeRecord): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    await DbHelper.getInstance().init(context);
    const ok: boolean = await DbHelper.getInstance().insertRecord(record);
    if (!ok) {
      ToastUtil.show('练习记录保存失败');
    }
  }

  private toggleHint(): void {
    if (this.showScore) {
      return;
    }
    this.hintVisible = !this.hintVisible;
    if (this.hintTimer >= 0) {
      clearTimeout(this.hintTimer);
      this.hintTimer = -1;
    }
    if (this.hintVisible) {
      this.hintTimer = setTimeout(() => {
        this.hintVisible = false;
        this.hintTimer = -1;
        this.drawScene();
      }, 2600);
    }
    this.drawScene();
  }

  private goNextChar(): void {
    const next: CharEntry | undefined =
      CharRepository.getInstance().getNextChar(this.charName, this.entry.grade);
    if (next === undefined) {
      ToastUtil.show('没有更多字了');
      return;
    }
    const params: PracticeParams = { char: next.char };
    router.replaceUrl({ url: 'pages/Practice', params: params }).catch(() => {
      ToastUtil.show('页面跳转失败');
    });
  }

  private hintColor(): string {
    if (this.liveLevel === 1) {
      return AppTheme.LIVE_GOOD;
    }
    if (this.liveLevel === 2) {
      return AppTheme.LIVE_WARN;
    }
    if (this.liveLevel === 3) {
      return AppTheme.LIVE_BAD;
    }
    return AppTheme.INK_LIGHT;
  }

  private drawPath(points: StrokePoint[], color: string, width: number, alpha: number,
    dashed: boolean): void {
    if (points.length < 2) {
      return;
    }
    const s: number = this.canvasSize;
    this.ctx.save();
    this.ctx.globalAlpha = alpha;
    this.ctx.beginPath();
    this.ctx.moveTo(AppTheme.toCanvas(points[0].x, s), AppTheme.toCanvas(points[0].y, s));
    for (let i = 1; i < points.length; i++) {
      this.ctx.lineTo(AppTheme.toCanvas(points[i].x, s), AppTheme.toCanvas(points[i].y, s));
    }
    this.ctx.strokeStyle = color;
    this.ctx.lineWidth = width;
    this.ctx.lineCap = 'round';
    this.ctx.lineJoin = 'round';
    if (dashed) {
      this.ctx.setLineDash([6, 5]);
    } else {
      this.ctx.setLineDash([]);
    }
    this.ctx.stroke();
    this.ctx.restore();
  }

  private drawScene(): void {
    if (!this.canvasReady) {
      return;
    }
    const s: number = this.canvasSize;
    this.ctx.clearRect(0, 0, s, s);
    AppTheme.drawTianGrid(this.ctx, s, true);

    if (this.hasEntry && this.entry.char.length > 0) {
      this.ctx.save();
      this.ctx.globalAlpha = 0.10;
      this.ctx.fillStyle = AppTheme.INK;
      this.ctx.textAlign = 'center';
      this.ctx.textBaseline = 'middle';
      this.ctx.font = `${Math.round(s * 0.68)}px sans-serif`;
      this.ctx.fillText(this.entry.char, s / 2, s / 2 + s * 0.02);
      this.ctx.restore();

      // 已完成笔画
      for (let i = 0; i < this.completedPaths.length; i++) {
        this.drawPath(this.completedPaths[i], AppTheme.INK, this.settings.brushWidth, 0.88, false);
      }

      // 写错的回放
      if (this.feedbackPoints.length > 1) {
        this.drawPath(this.feedbackPoints, AppTheme.ACCENT, this.settings.brushWidth, 0.7, false);
      }

      // 当前轨迹
      if (this.userPoints.length > 1) {
        let color: string = AppTheme.ACCENT;
        if (this.liveLevel === 1) {
          color = AppTheme.LIVE_GOOD;
        } else if (this.liveLevel === 2) {
          color = AppTheme.LIVE_WARN;
        }
        this.drawPath(this.userPoints, color, this.settings.brushWidth, 0.95, false);
      }

      // 提示：标准笔画虚线 + 起笔点
      if (this.currentIndex < this.entry.strokes.length && !this.showScore) {
        const standard: Stroke = this.entry.strokes[this.currentIndex];
        if (this.hintVisible) {
          this.drawPath(standard.points, AppTheme.ACCENT, 4, 0.6, true);
        }
        const start: StrokePoint = standard.points[0];
        this.ctx.beginPath();
        this.ctx.arc(AppTheme.toCanvas(start.x, s), AppTheme.toCanvas(start.y, s), 6, 0, Math.PI * 2);
        this.ctx.fillStyle = AppTheme.GOLD;
        this.ctx.fill();
        this.ctx.strokeStyle = '#FFFFFF';
        this.ctx.lineWidth = 2;
        this.ctx.stroke();
      }
    } else {
      this.ctx.fillStyle = AppTheme.INK_FAINT;
      this.ctx.textAlign = 'center';
      this.ctx.textBaseline = 'middle';
      this.ctx.font = '15px sans-serif';
      this.ctx.fillText('正在载入汉字…', s / 2, s / 2);
    }
  }

  @Builder
  strokeSegment(index: number) {
    Row()
      .height(5)
      .layoutWeight(1)
      .borderRadius(3)
      .backgroundColor(index < this.currentIndex ? AppTheme.ACCENT :
        (index === this.currentIndex ? AppTheme.GOLD : AppTheme.CARD_ALT))
      .margin({ right: index < this.entry.strokes.length - 1 ? 4 : 0 })
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
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
            Row({ space: 8 }) {
              Text(this.hasEntry ? this.entry.char : '练习')
                .fontSize(26)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppTheme.INK)
              if (this.hasEntry) {
                Text(this.entry.pinyin)
                  .fontSize(13)
                  .fontColor(AppTheme.INK_LIGHT)
                Text(`第 ${Math.min(this.currentIndex + 1, this.entry.strokes.length)} / ${this.entry.strokes.length} 笔`)
                  .fontSize(11)
                  .fontColor(AppTheme.ACCENT)
                  .backgroundColor(AppTheme.ACCENT_SOFT)
                  .borderRadius(9)
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              }
            }
            Text('临摹练习 · 逐笔评分')
              .fontSize(11)
              .fontColor(AppTheme.INK_FAINT)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Text('重写')
            .fontSize(13)
            .fontColor(AppTheme.INK_LIGHT)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(AppTheme.CARD)
            .borderRadius(14)
            .onClick(() => {
              this.resetProgress();
            })
        }
        .width('100%')
        .padding({ left: 8, right: 16, top: 12, bottom: 8 })

        if (this.hasEntry && this.entry.strokes.length > 0) {
          Row({ space: 0 }) {
            ForEach(this.entry.strokes, (stroke: Stroke, index: number) => {
              this.strokeSegment(index)
            }, (stroke: Stroke, index: number) => `seg${index}`)
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }

        Scroll() {
          Column({ space: 12 }) {
            Row({ space: 8 }) {
              Row()
                .width(8)
                .height(8)
                .borderRadius(4)
                .backgroundColor(this.hintColor())
              Text(this.liveHint)
                .fontSize(13)
                .fontColor(this.hintColor())
                .layoutWeight(1)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              if (this.liveScore > 0 && !this.showScore) {
                Text(`${this.liveScore} 分`)
                  .fontSize(11)
                  .fontColor(this.hintColor())
                  .backgroundColor(AppTheme.CARD)
                  .borderRadius(10)
                  .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              }
            }
            .width('100%')
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(AppTheme.CARD_ALT)
            .borderRadius(12)

            Column() {
              Canvas(this.ctx)
                .width(this.canvasSize)
                .height(this.canvasSize)
                .onReady(() => {
                  this.canvasReady = true;
                  this.drawScene();
                })
                .onTouch((event: TouchEvent) => {
                  this.handleTouch(event);
                })
            }
            .padding(10)
            .backgroundColor(AppTheme.CARD)
            .borderRadius(18)
            .shadow({ radius: 14, color: '#14000000', offsetY: 4 })

            Row({ space: 10 }) {
              Text('提示')
                .fontSize(13)
                .fontColor(this.hintVisible ? AppTheme.ACCENT : AppTheme.INK_LIGHT)
                .backgroundColor(this.hintVisible ? AppTheme.ACCENT_SOFT : AppTheme.CARD)
                .borderRadius(16)
                .padding({ left: 18, right: 18, top: 9, bottom: 9 })
                .onClick(() => {
                  this.toggleHint();
                })
              Text('重写此字')
                .fontSize(13)
                .fontColor(AppTheme.INK_LIGHT)
                .backgroundColor(AppTheme.CARD)
                .borderRadius(16)
                .padding({ left: 18, right: 18, top: 9, bottom: 9 })
                .onClick(() => {
                  this.resetProgress();
                })
              Blank()
              Text('触觉反馈：' + (this.vibrateEnabled ? '开' : '关'))
                .fontSize(10)
                .fontColor(AppTheme.INK_FAINT)
            }
            .width('100%')
            .padding({ left: 2, right: 2 })

            Text('提示：起笔靠近金色圆点，沿半透明底字书写。每笔通过后自动进入下一笔。')
              .fontSize(10)
              .fontColor(AppTheme.INK_FAINT)
              .lineHeight(16)
              .padding({ left: 4, right: 4, bottom: 12 })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .enableScrollInteraction(false)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppTheme.BG)

      if (this.showScore) {
        ScorePanel({
          score: this.finalScore,
          charText: this.entry.char,
          pinyin: this.entry.pinyin,
          orderRate: this.orderRate,
          directionRate: this.directionRate,
          coverageRate: this.coverageRate,
          mistakes: this.mistakes,
          durationSec: this.durationSec,
          previousBest: this.panelBest,
          onRetry: () => {
            this.resetProgress();
          },
          onNext: () => {
            this.goNextChar();
          },
          onBack: () => {
            router.back();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
