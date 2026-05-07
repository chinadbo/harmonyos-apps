import router from '@ohos.router';
import { EMPTY_RECIPE, Recipe, Step } from '../model/RecipeModel';
import DatabaseService from '../service/DatabaseService';
import NotificationService from '../service/NotificationService';

@Entry
@Component
struct CookingTimer {
  @State recipe: Recipe = EMPTY_RECIPE;
  @State currentStep: number = 0;
  @State remainingSeconds: number = 0;
  @State totalSeconds: number = 1;
  @State isRunning: boolean = false;
  @State reminderId: number = -1;
  private intervalId: number = -1;

  async aboutToAppear(): Promise<void> {
    const params = router.getParams() as Record<string, number>;
    const recipeId = Number(params.recipeId ?? 0);
    const recipe = await DatabaseService.getInstance().getRecipeById(recipeId);
    if (recipe) {
      this.recipe = recipe;
      this.resetToStep(0);
    }
  }

  aboutToDisappear(): void {
    this.clearTicker();
  }

  private getCurrentStepData(): Step {
    return this.recipe.steps[this.currentStep] ?? { index: 1, description: '', duration: 1 };
  }

  private resetToStep(stepIndex: number): void {
    this.clearTicker();
    this.currentStep = stepIndex;
    const step = this.getCurrentStepData();
    this.totalSeconds = Math.max(step.duration, 1);
    this.remainingSeconds = Math.max(step.duration, 1);
    this.isRunning = false;
  }

  private startTimer(): void {
    if (this.isRunning) {
      return;
    }
    this.isRunning = true;
    this.clearTicker();
    this.intervalId = setInterval(async () => {
      if (this.remainingSeconds > 1) {
        this.remainingSeconds -= 1;
        return;
      }
      this.remainingSeconds = 0;
      this.clearTicker();
      this.reminderId = await NotificationService.getInstance().publishTimer(
        1,
        `${this.recipe.name} - 第${this.getCurrentStepData().index}步完成`,
        this.getCurrentStepData().description
      );
    }, 1000) as number;
  }

  private pauseTimer(): void {
    this.clearTicker();
  }

  private clearTicker(): void {
    if (this.intervalId !== -1) {
      clearInterval(this.intervalId);
      this.intervalId = -1;
    }
    this.isRunning = false;
  }

  private switchStep(offset: number): void {
    const nextIndex = this.currentStep + offset;
    if (nextIndex < 0 || nextIndex >= this.recipe.steps.length) {
      return;
    }
    this.resetToStep(nextIndex);
  }

  private formatTime(seconds: number): string {
    const minute = Math.floor(seconds / 60);
    const second = seconds % 60;
    return `${minute.toString().padStart(2, '0')}:${second.toString().padStart(2, '0')}`;
  }

  private get current(): import('../model/RecipeModel').Step {
    return this.getCurrentStepData();
  }

  private get progressValue(): number {
    return ((this.totalSeconds - this.remainingSeconds) / this.totalSeconds) * 100;
  }

  build() {
    Column({ space: 18 }) {
      Text('烹饪计时')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2B1F19')
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(this.recipe.name)
        .fontSize(18)
        .fontColor('#8A7367')
        .width('100%')
        .textAlign(TextAlign.Start)

      Column({ space: 12 }) {
        Text(`当前步骤 ${this.currentStep + 1}/${this.recipe.steps.length || 1}`)
          .fontSize(16)
          .fontColor('#7A6659')
        Text(this.current.description)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2B1F19')
          .textAlign(TextAlign.Center)
        Text(this.formatTime(this.remainingSeconds))
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF8A3D')
        Progress({ value: this.progressValue, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(10)
          .color('#FF8A3D')
          .backgroundColor('#F2E2D5')
      }
      .padding(24)
      .width('100%')
      .backgroundColor('#FFFDF8')
      .borderRadius(28)

      Row({ space: 12 }) {
        Button('上一步')
          .layoutWeight(1)
          .backgroundColor('#F0E1D4')
          .fontColor('#6A5242')
          .onClick(() => {
            this.switchStep(-1);
          })
        if (this.isRunning) {
          Button('暂停')
            .layoutWeight(1)
            .backgroundColor('#FFD5B3')
            .fontColor('#8A4B15')
            .onClick(() => {
              this.pauseTimer();
            })
        } else {
          Button('开始')
            .layoutWeight(1)
            .backgroundColor('#FF8A3D')
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.startTimer();
            })
        }
        Button('下一步')
          .layoutWeight(1)
          .backgroundColor('#F0E1D4')
          .fontColor('#6A5242')
          .onClick(() => {
            this.switchStep(1);
          })
      }
      .width('100%')

      if (this.reminderId > 0) {
        Text('当前步骤已创建完成提醒通知。')
          .fontSize(14)
          .fontColor('#7A6659')
          .width('100%')
      }
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF9F4')
  }
}
