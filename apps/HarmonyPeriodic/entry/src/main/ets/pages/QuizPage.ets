import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';
import { Element, loadElements } from '../model/Element';
import { dbHelper } from '../utils/db';

const DOMAIN: number = 0x0000;
const TAG: string = 'QuizPage';
const QUESTION_COUNT: number = 10;
const OPTION_COUNT: number = 4;
const KINDS: string[] = ['symbol', 'name', 'category'];
const OPTION_LETTERS: string[] = ['A', 'B', 'C', 'D'];

const CATEGORY_LABELS: Map<string, string> = new Map<string, string>();
CATEGORY_LABELS.set('alkali-metal', '碱金属');
CATEGORY_LABELS.set('alkaline-earth', '碱土金属');
CATEGORY_LABELS.set('transition', '过渡金属');
CATEGORY_LABELS.set('post-transition', '后过渡金属');
CATEGORY_LABELS.set('metalloid', '类金属');
CATEGORY_LABELS.set('nonmetal', '非金属');
CATEGORY_LABELS.set('halogen', '卤素');
CATEGORY_LABELS.set('noble-gas', '稀有气体');
CATEGORY_LABELS.set('lanthanide', '镧系');
CATEGORY_LABELS.set('actinide', '锕系');

interface QuizQuestion {
  kindLabel: string;
  prompt: string;
  correctAnswer: string;
  options: string[];
}

interface ResultParams {
  correct: number;
  total: number;
}

function categoryLabel(category: string): string {
  const label = CATEGORY_LABELS.get(category);
  return label === undefined ? category : label;
}

function shuffleElements(list: Element[]): void {
  for (let i = list.length - 1; i > 0; i--) {
    const j: number = Math.floor(Math.random() * (i + 1));
    const tmp: Element = list[i];
    list[i] = list[j];
    list[j] = tmp;
  }
}

function shuffleStrings(list: string[]): void {
  for (let i = list.length - 1; i > 0; i--) {
    const j: number = Math.floor(Math.random() * (i + 1));
    const tmp: string = list[i];
    list[i] = list[j];
    list[j] = tmp;
  }
}

@Entry
@Component
struct QuizPage {
  @State questions: QuizQuestion[] = [];
  @State currentIndex: number = 0;
  @State selectedOption: string = '';
  @State correctCount: number = 0;
  @State loading: boolean = true;
  @State errorMessage: string = '';
  private recordTask: Promise<void> | null = null;
  private finishing: boolean = false;

  aboutToAppear(): void {
    this.loadQuiz();
  }

  private async loadQuiz(): Promise<void> {
    this.loading = true;
    this.errorMessage = '';
    this.questions = [];
    this.currentIndex = 0;
    this.selectedOption = '';
    this.correctCount = 0;
    this.recordTask = null;
    this.finishing = false;
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const elements: Element[] = await loadElements(context);
      if (elements.length < OPTION_COUNT) {
        throw new Error('element data is not enough');
      }
      this.questions = this.buildQuestions(elements);
    } catch (err) {
      this.errorMessage = '测验题目加载失败，请重试';
      hilog.error(DOMAIN, TAG, 'load quiz failed: %{public}s', JSON.stringify(err));
    } finally {
      this.loading = false;
    }
  }

  private buildQuestions(elements: Element[]): QuizQuestion[] {
    const pool: Element[] = [];
    for (const element of elements) {
      pool.push(element);
    }
    shuffleElements(pool);
    const count: number = Math.min(QUESTION_COUNT, pool.length);
    const categories: string[] = [];
    for (const element of elements) {
      const label: string = categoryLabel(element.category);
      if (categories.indexOf(label) < 0) {
        categories.push(label);
      }
    }
    const questions: QuizQuestion[] = [];
    for (let i = 0; i < count; i++) {
      questions.push(this.buildQuestion(pool[i], KINDS[i % KINDS.length], elements, categories));
    }
    return questions;
  }

  private buildQuestion(element: Element, kind: string, all: Element[],
    categories: string[]): QuizQuestion {
    if (kind === 'name') {
      const pool: string[] = [];
      for (const item of all) {
        pool.push(item.symbol);
      }
      const correctAnswer: string = element.symbol;
      return {
        kindLabel: '中文名 → 元素符号',
        prompt: '元素「' + element.nameZh + '」的符号是？',
        correctAnswer: correctAnswer,
        options: this.composeOptions(pool, correctAnswer)
      };
    }
    if (kind === 'category') {
      const correctAnswer: string = categoryLabel(element.category);
      return {
        kindLabel: '原子序数 → 类别',
        prompt: '原子序数为 ' + element.atomicNumber.toString() + ' 的元素属于哪一类？',
        correctAnswer: correctAnswer,
        options: this.composeOptions(categories, correctAnswer)
      };
    }
    const pool: string[] = [];
    for (const item of all) {
      pool.push(item.nameZh);
    }
    const correctAnswer: string = element.nameZh;
    return {
      kindLabel: '元素符号 → 中文名',
      prompt: '元素符号「' + element.symbol + '」对应的中文名是？',
      correctAnswer: correctAnswer,
      options: this.composeOptions(pool, correctAnswer)
    };
  }

  private composeOptions(pool: string[], correctAnswer: string): string[] {
    const candidates: string[] = [];
    for (const item of pool) {
      if (item !== correctAnswer && candidates.indexOf(item) < 0) {
        candidates.push(item);
      }
    }
    shuffleStrings(candidates);
    const options: string[] = candidates.slice(0, OPTION_COUNT - 1);
    options.push(correctAnswer);
    shuffleStrings(options);
    return options;
  }

  private currentQuestion(): QuizQuestion {
    return this.questions[this.currentIndex];
  }

  private isAnswered(): boolean {
    return this.selectedOption.length > 0;
  }

  private isCurrentCorrect(): boolean {
    return this.selectedOption === this.currentQuestion().correctAnswer;
  }

  private progressPercent(): string {
    if (this.questions.length === 0) {
      return '0%';
    }
    const done: number = this.currentIndex + (this.isAnswered() ? 1 : 0);
    return (done * 100 / this.questions.length).toFixed(1) + '%';
  }

  private selectOption(option: string): void {
    if (this.isAnswered() || this.questions.length === 0) {
      return;
    }
    this.selectedOption = option;
    if (option === this.currentQuestion().correctAnswer) {
      this.correctCount++;
    }
    if (this.currentIndex === this.questions.length - 1) {
      this.saveRecord();
    }
  }

  private goNext(): void {
    if (!this.isAnswered()) {
      return;
    }
    if (this.currentIndex < this.questions.length - 1) {
      this.currentIndex++;
      this.selectedOption = '';
      return;
    }
    this.finishQuiz();
  }

  private saveRecord(): Promise<void> {
    if (this.recordTask === null) {
      this.recordTask = this.insertRecord();
    }
    return this.recordTask;
  }

  private async insertRecord(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      await dbHelper.init(context);
      await dbHelper.insertQuizRecord(
        new Date().toISOString(), this.questions.length, this.correctCount);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'save quiz record failed: %{public}s', JSON.stringify(err));
    }
  }

  private async finishQuiz(): Promise<void> {
    if (this.finishing) {
      return;
    }
    this.finishing = true;
    await this.saveRecord();
    const params: ResultParams = { correct: this.correctCount, total: this.questions.length };
    router.replaceUrl({ url: 'pages/QuizResult', params: params }).catch((err: Error) => {
      this.finishing = false;
      hilog.error(DOMAIN, TAG, 'open quiz result failed: %{public}s', err.message);
    });
  }

  private optionBackground(option: string): string {
    if (!this.isAnswered()) {
      return '#FFFFFF';
    }
    if (option === this.currentQuestion().correctAnswer) {
      return '#E3F4E8';
    }
    if (option === this.selectedOption) {
      return '#FDECE9';
    }
    return '#FFFFFF';
  }

  private optionBorderColor(option: string): string {
    if (!this.isAnswered()) {
      return '#1A000000';
    }
    if (option === this.currentQuestion().correctAnswer) {
      return '#66BB6A';
    }
    if (option === this.selectedOption) {
      return '#E84026';
    }
    return '#1A000000';
  }

  private optionTextColor(option: string): string {
    if (!this.isAnswered()) {
      return '#E6000000';
    }
    if (option === this.currentQuestion().correctAnswer) {
      return '#1F7A3D';
    }
    if (option === this.selectedOption) {
      return '#C7361F';
    }
    return '#66000000';
  }

  private optionBadgeBackground(option: string): string {
    if (!this.isAnswered()) {
      return '#F1F3F5';
    }
    if (option === this.currentQuestion().correctAnswer) {
      return '#C8E6C9';
    }
    if (option === this.selectedOption) {
      return '#F9D2CC';
    }
    return '#F1F3F5';
  }

  private optionBadgeTextColor(option: string): string {
    if (!this.isAnswered()) {
      return '#66000000';
    }
    if (option === this.currentQuestion().correctAnswer) {
      return '#1F7A3D';
    }
    if (option === this.selectedOption) {
      return '#C7361F';
    }
    return '#66000000';
  }

  build() {
    Column() {
      this.Header()
      if (this.loading) {
        Column({ space: 8 }) {
          LoadingProgress()
            .width(36)
            .height(36)
            .color('#0A59F7')
          Text('正在生成测验题目')
            .fontSize(13)
            .fontColor('#99000000')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.questions.length === 0) {
        Column({ space: 12 }) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#99000000')
            .textAlign(TextAlign.Center)
          Button('重新加载', { type: ButtonType.Normal })
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#0A59F7')
            .borderRadius(10)
            .onClick(() => {
              this.loadQuiz();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .padding({ left: 24, right: 24 })
      } else {
        Scroll() {
          Column({ space: 12 }) {
            this.ProgressCard()
            this.QuestionCard()
            this.OptionsCard()
            if (this.isAnswered()) {
              this.FeedbackCard()
            }
          }
          .width('100%')
          .padding({ left: 14, right: 14, top: 10, bottom: 16 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)

        this.BottomAction()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }

  @Builder
  Header() {
    Row() {
      Text('返回')
        .fontSize(14)
        .fontColor('#0A59F7')
        .padding({ left: 4, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          router.back();
        })
      Column({ space: 2 }) {
        Text('元素测验')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E6000000')
        if (this.questions.length > 0) {
          Text('共 ' + this.questions.length.toString() + ' 题 · 每题四选一')
            .fontSize(11)
            .fontColor('#99000000')
        }
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      if (this.questions.length > 0) {
        Text('已答对 ' + this.correctCount.toString())
          .fontSize(12)
          .fontColor('#1F7A3D')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#E3F4E8')
          .borderRadius(10)
      }
    }
    .width('100%')
    .padding({ left: 10, right: 14, top: 10, bottom: 8 })
  }

  @Builder
  ProgressCard() {
    Column({ space: 6 }) {
      Row() {
        Text('第 ' + (this.currentIndex + 1).toString() + ' / ' +
          this.questions.length.toString() + ' 题')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#E6000000')
        Blank()
        Text(this.currentQuestion().kindLabel)
          .fontSize(11)
          .fontColor('#0A59F7')
      }
      .width('100%')

      Row() {
        Row()
          .height(6)
          .width(this.progressPercent())
          .backgroundColor('#0A59F7')
          .borderRadius(3)
      }
      .width('100%')
      .height(6)
      .backgroundColor('#DDE2E9')
      .borderRadius(3)
    }
    .width('100%')
  }

  @Builder
  QuestionCard() {
    Column({ space: 8 }) {
      Text('选择题')
        .fontSize(11)
        .fontColor('#66000000')
        .width('100%')
        .textAlign(TextAlign.Start)
      Text(this.currentQuestion().prompt)
        .fontSize(19)
        .fontWeight(FontWeight.Bold)
        .fontColor('#E6000000')
        .lineHeight(27)
        .width('100%')
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
  }

  @Builder
  OptionsCard() {
    Column({ space: 10 }) {
      ForEach(this.currentQuestion().options, (option: string, index: number) => {
        this.OptionRow(option, index)
      }, (option: string, index: number) => this.currentIndex.toString() + '-' + index.toString())
    }
    .width('100%')
  }

  @Builder
  OptionRow(option: string, index: number) {
    Row({ space: 12 }) {
      Text(OPTION_LETTERS[index])
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.optionBadgeTextColor(option))
        .width(26)
        .height(26)
        .textAlign(TextAlign.Center)
        .backgroundColor(this.optionBadgeBackground(option))
        .borderRadius(13)
      Text(option)
        .fontSize(15)
        .fontColor(this.optionTextColor(option))
        .layoutWeight(1)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      if (this.isAnswered() && option === this.currentQuestion().correctAnswer) {
        Text('正确')
          .fontSize(11)
          .fontColor('#1F7A3D')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor('#C8E6C9')
          .borderRadius(9)
      } else if (this.isAnswered() && option === this.selectedOption) {
        Text('误选')
          .fontSize(11)
          .fontColor('#C7361F')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor('#F9D2CC')
          .borderRadius(9)
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.optionBackground(option))
    .borderRadius(12)
    .border({ width: 1, color: this.optionBorderColor(option) })
    .onClick(() => {
      this.selectOption(option);
    })
  }

  @Builder
  FeedbackCard() {
    Column({ space: 6 }) {
      Text(this.isCurrentCorrect() ? '回答正确' : '回答错误')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isCurrentCorrect() ? '#1F7A3D' : '#C7361F')
        .width('100%')
        .textAlign(TextAlign.Start)
      if (!this.isCurrentCorrect()) {
        Text('正确答案是「' + this.currentQuestion().correctAnswer + '」')
          .fontSize(13)
          .fontColor('#99000000')
          .width('100%')
          .textAlign(TextAlign.Start)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(14)
    .backgroundColor(this.isCurrentCorrect() ? '#E3F4E8' : '#FDECE9')
    .borderRadius(12)
  }

  @Builder
  BottomAction() {
    Column() {
      Divider()
        .width('100%')
        .color('#14000000')
      Row() {
        if (!this.isAnswered()) {
          Text('请从上方选择一个答案')
            .fontSize(13)
            .fontColor('#99000000')
            .width('100%')
            .height(46)
            .textAlign(TextAlign.Center)
        } else {
          Button(this.currentIndex === this.questions.length - 1 ? '查看结果' : '下一题',
            { type: ButtonType.Normal })
            .width('100%')
            .height(46)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor('#0A59F7')
            .borderRadius(12)
            .onClick(() => {
              this.goNext();
            })
        }
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 10, bottom: 12 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }
}
