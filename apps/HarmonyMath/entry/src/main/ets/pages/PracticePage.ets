import router from '@ohos.router';
import vibration from '@ohos.vibrator';
import { BusinessError } from '@ohos.base';
import { Theme } from '../model/Theme';
import { Question, PracticeParams, ResultParams, WrongItem } from '../model/Models';
import { QuestionGenerator } from '../data/QuestionGenerator';
import { RdbHelper, WrongRow } from '../data/RdbHelper';
import { PreferencesUtil } from '../data/PreferencesUtil';
import { QuestionCard } from '../components/QuestionCard';
import { KeypadComponent } from '../components/KeypadComponent';

const QUESTION_COUNT: number = 10;
const CORRECT_DELAY_MS: number = 600;
const WRONG_DELAY_MS: number = 1500;

@Entry
@Component
struct PracticePage {
  @State questions: Question[] = [];
  @State currentIndex: number = 0;
  @State inputValue: string = '';
  @State feedback: string = '';
  @State timeLeft: number = 0;
  @State elapsed: number = 0;
  @State correctCount: number = 0;
  @State finished: boolean = false;
  @State loading: boolean = true;
  @State emptyTip: string = '';

  private mode: string = 'addsub';
  private difficulty: number = 1;
  private limitSec: number = 0;
  private wrongItems: WrongItem[] = [];
  private timerId: number = -1;
  private pendingTimer: number = -1;
  private vibrateOn: boolean = true;
  private locked: boolean = false;

  aboutToAppear(): void {
    const p: PracticeParams = router.getParams() as PracticeParams;
    if (p !== undefined && p !== null) {
      this.mode = p.mode === undefined ? 'addsub' : p.mode;
      this.difficulty = p.difficulty === undefined ? 1 : p.difficulty;
      this.limitSec = p.limitSec === undefined ? 0 : p.limitSec;
    }
    this.timeLeft = this.limitSec;
    PreferencesUtil.getInstance().getVibrateOn().then((v: boolean) => {
      this.vibrateOn = v;
    });
    this.prepareQuestions();
  }

  aboutToDisappear(): void {
    this.stopTimer();
    if (this.pendingTimer >= 0) {
      clearTimeout(this.pendingTimer);
      this.pendingTimer = -1;
    }
  }

  private async prepareQuestions(): Promise<void> {
    if (this.mode === 'wrong') {
      const rdb: RdbHelper = RdbHelper.getInstance();
      await rdb.ready();
      const rows: WrongRow[] = await rdb.queryWrongQuestions();
      const questions: Question[] = [];
      for (const row of rows) {
        if (row.mastered === 1) {
          continue;
        }
        if (questions.length >= QUESTION_COUNT) {
          break;
        }
        const q: Question = { stem: row.stem, answer: row.answer };
        questions.push(q);
      }
      if (questions.length === 0) {
        this.emptyTip = '错题本还是空的，先去练一组题吧';
        this.loading = false;
        return;
      }
      this.questions = questions;
    } else {
      this.questions = QuestionGenerator.generate(this.mode, this.difficulty, QUESTION_COUNT);
    }
    this.loading = false;
    this.startTimer();
  }

  private startTimer(): void {
    this.timerId = setInterval(() => {
      if (this.finished) {
        return;
      }
      this.elapsed += 1;
      if (this.limitSec > 0) {
        this.timeLeft = this.limitSec - this.elapsed;
        if (this.timeLeft <= 0) {
          this.timeLeft = 0;
          this.finishPractice(true);
        }
      }
    }, 1000);
  }

  private stopTimer(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private submitAnswer(): void {
    if (this.locked || this.finished || this.questions.length === 0) {
      return;
    }
    if (this.inputValue === '') {
      return;
    }
    this.locked = true;
    const q: Question = this.questions[this.currentIndex];
    const userNum: number = Number.parseInt(this.inputValue);
    if (userNum === q.answer) {
      this.feedback = 'correct';
      this.correctCount += 1;
      this.vibrate(40);
      this.pendingTimer = setTimeout(() => {
        this.pendingTimer = -1;
        this.nextQuestion();
      }, CORRECT_DELAY_MS);
    } else {
      this.feedback = 'wrong';
      const item: WrongItem = { stem: q.stem, answer: q.answer, userAnswer: userNum };
      this.wrongItems.push(item);
      this.vibrate(250);
      this.pendingTimer = setTimeout(() => {
        this.pendingTimer = -1;
        this.nextQuestion();
      }, WRONG_DELAY_MS);
    }
  }

  private nextQuestion(): void {
    if (this.finished) {
      return;
    }
    this.locked = false;
    this.inputValue = '';
    this.feedback = '';
    if (this.currentIndex + 1 >= this.questions.length) {
      this.finishPractice(false);
    } else {
      this.currentIndex += 1;
    }
  }

  private finishPractice(byTimeout: boolean): void {
    if (this.finished) {
      return;
    }
    this.finished = true;
    this.stopTimer();
    const params: ResultParams = {
      mode: this.mode,
      difficulty: this.difficulty,
      limitSec: this.limitSec,
      total: byTimeout ? this.currentIndex + 1 : this.questions.length,
      correct: this.correctCount,
      durationSec: this.elapsed,
      wrongItems: this.wrongItems
    };
    if (byTimeout) {
      console.info('[PracticePage] time out, total answered questions are recorded');
    }
    router.replaceUrl({ url: 'pages/ResultPage', params: params });
  }

  private exitPractice(): void {
    this.stopTimer();
    router.back();
  }

  private vibrate(durationMs: number): void {
    if (!this.vibrateOn) {
      return;
    }
    try {
      vibration.startVibration({ type: 'time', duration: durationMs }, { usage: 'touch' })
        .catch((err: BusinessError) => {
          console.error(`[PracticePage] startVibration failed, code=${err.code}, message=${err.message}`);
        });
    } catch (err) {
      console.error(`[PracticePage] vibrate failed: ${JSON.stringify(err)}`);
    }
  }

  private modeLabel(): string {
    if (this.mode === 'addsub') {
      return '加减法';
    }
    if (this.mode === 'muldiv') {
      return '乘除法';
    }
    if (this.mode === 'mixed') {
      return '混合运算';
    }
    if (this.mode === 'wrong') {
      return '错题重练';
    }
    return '口算练习';
  }

  build() {
    Column({ space: 12 }) {
      if (this.loading) {
        Column({ space: 12 }) {
          LoadingProgress()
            .width(48)
            .height(48)
            .color(Theme.PRIMARY)
          Text('正在出题…')
            .fontSize(14)
            .fontColor(Theme.TEXT_SECONDARY)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.emptyTip !== '') {
        Column({ space: 16 }) {
          Text(this.emptyTip)
            .fontSize(16)
            .fontColor(Theme.TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
          Button('返回首页')
            .width(160)
            .backgroundColor(Theme.PRIMARY)
            .onClick(() => {
              router.back();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Row() {
          Text('退出练习')
            .fontSize(14)
            .fontColor(Theme.TEXT_SECONDARY)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .onClick(() => {
              this.exitPractice();
            })
          Blank()
          Text(this.modeLabel())
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.PRIMARY)
        }
        .width('100%')

        QuestionCard({
          index: this.currentIndex + 1,
          total: this.questions.length,
          stem: this.questions.length > 0 ? this.questions[this.currentIndex].stem : '',
          userAnswer: this.inputValue,
          feedback: this.feedback,
          correctAnswer: this.questions.length > 0 ? this.questions[this.currentIndex].answer : 0,
          progress: this.limitSec > 0 ? this.timeLeft / this.limitSec : 1,
          limitSec: this.limitSec,
          elapsed: this.elapsed
        })

        Blank()

        KeypadComponent({
          inputValue: $inputValue,
          onConfirm: () => {
            this.submitAnswer();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 16 })
    .backgroundColor(Theme.BG)
  }
}
