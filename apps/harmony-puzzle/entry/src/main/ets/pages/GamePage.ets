import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { GameDatabase } from '../database/GameDatabase'
import { PuzzleGrid } from '../components/PuzzleGrid'
import { StepCounter } from '../components/StepCounter'
import { TimerDisplay } from '../components/TimerDisplay'
import common from '@ohos.app.ability.common'

interface GameRouteParams {
  difficulty?: number
  imageIndex?: number
  imageTitle?: string
}

@Component
export struct GamePage {
  @State difficulty: number = 3
  @State imageIndex: number = 0
  @State imageTitle: string = 'Aurora'
  @State elapsedSeconds: number = 0
  @State steps: number = 0
  @State resetSignal: number = 0
  @State hintVisible: boolean = false
  @State finished: boolean = false

  aboutToAppear() {
    const params = router.getParams() as GameRouteParams
    this.difficulty = params.difficulty ?? 3
    this.imageIndex = params.imageIndex ?? 0
    this.imageTitle = params.imageTitle ?? 'Aurora'
    this.finished = false
  }

  private getImageSource(): ResourceStr {
    return $r('app.media.icon')
  }

  private getTileSize(): number {
    if (this.difficulty === 3) {
      return 104
    }
    if (this.difficulty === 4) {
      return 78
    }
    return 62
  }

  private restartGame(): void {
    this.elapsedSeconds = 0
    this.steps = 0
    this.finished = false
    this.hintVisible = false
    this.resetSignal += 1
  }

  private async handleWin(finalSteps: number): Promise<void> {
    if (this.finished) {
      return
    }
    this.finished = true
    const context = getContext(this) as common.UIAbilityContext
    const completedAt = new Date().toISOString()
    const isBest = await GameDatabase.insertRecord(context, {
      difficulty: this.difficulty,
      timeSeconds: this.elapsedSeconds,
      steps: finalSteps,
      completedAt: completedAt,
      isBest: 0
    })
    promptAction.showToast({ message: 'Puzzle solved!' })
    router.replaceUrl({
      url: 'pages/ResultPage',
      params: {
        difficulty: this.difficulty,
        timeSeconds: this.elapsedSeconds,
        steps: finalSteps,
        imageIndex: this.imageIndex,
        imageTitle: this.imageTitle,
        isBest: isBest
      }
    })
  }

  build() {
    Column({ space: 18 }) {
      Row() {
        Button('Back')
          .type(ButtonType.Capsule)
          .backgroundColor('#dfe8ff')
          .fontColor('#224099')
          .onClick(() => {
            router.back()
          })
        Blank()
        Text(`${this.difficulty}x${this.difficulty} · ${this.imageTitle}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
      }
      .width('100%')

      Row() {
        TimerDisplay({ elapsedSeconds: $elapsedSeconds, resetSignal: $resetSignal, running: !this.finished })
        Blank()
        StepCounter({ steps: this.steps })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#ffffff')
      .borderRadius(18)

      Stack({ alignContent: Alignment.Center }) {
        PuzzleGrid({
          difficulty: this.difficulty,
          imageSource: this.getImageSource(),
          tileSize: this.getTileSize(),
          steps: $steps,
          resetSignal: $resetSignal,
          onWin: (steps: number) => {
            this.handleWin(steps)
          }
        })

        if (this.hintVisible) {
          Image(this.getImageSource())
            .width(this.getTileSize() * this.difficulty)
            .height(this.getTileSize() * this.difficulty)
            .objectFit(ImageFit.Cover)
            .borderRadius(16)
            .opacity(0.94)
        }
      }

      Row({ space: 12 }) {
        Button(this.hintVisible ? 'Hide Hint' : 'Hint')
          .layoutWeight(1)
          .height(48)
          .backgroundColor('#eef3ff')
          .fontColor('#224099')
          .onClick(() => {
            this.hintVisible = !this.hintVisible
          })

        Button('Restart')
          .layoutWeight(1)
          .height(48)
          .backgroundColor('#4f7cff')
          .fontColor('#ffffff')
          .onClick(() => {
            this.restartGame()
          })
      }
      .width('100%')

      Text('Tap any tile next to the empty space to slide it into place.')
        .fontSize(15)
        .fontColor('#5b6b7d')
        .textAlign(TextAlign.Center)
        .padding({ left: 12, right: 12 })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#f5f7fb')
  }
}
