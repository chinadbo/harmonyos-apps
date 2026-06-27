import router from '@ohos.router'

interface ResultRouteParams {
  difficulty?: number
  timeSeconds?: number
  steps?: number
  imageIndex?: number
  imageTitle?: string
  isBest?: boolean
}

@Component
export struct ResultPage {
  @State difficulty: number = 3
  @State timeSeconds: number = 0
  @State steps: number = 0
  @State imageIndex: number = 0
  @State imageTitle: string = 'Puzzle'
  @State isBest: boolean = false

  aboutToAppear() {
    const params = router.getParams() as ResultRouteParams
    this.difficulty = params.difficulty ?? 3
    this.timeSeconds = params.timeSeconds ?? 0
    this.steps = params.steps ?? 0
    this.imageIndex = params.imageIndex ?? 0
    this.imageTitle = params.imageTitle ?? 'Puzzle'
    this.isBest = params.isBest ?? false
  }

  private formatTime(totalSeconds: number): string {
    const minutes = Math.floor(totalSeconds / 60)
    const seconds = totalSeconds % 60
    const minuteText = minutes < 10 ? `0${minutes}` : `${minutes}`
    const secondText = seconds < 10 ? `0${seconds}` : `${seconds}`
    return `${minuteText}:${secondText}`
  }

  private playAgain(): void {
    router.replaceUrl({
      url: 'pages/GamePage',
      params: {
        difficulty: this.difficulty,
        imageIndex: this.imageIndex,
        imageTitle: this.imageTitle
      }
    })
  }

  build() {
    Column({ space: 18 }) {
      Text('Congratulations!')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#182431')
        .margin({ top: 24 })

      Text(`You solved the ${this.difficulty}x${this.difficulty} puzzle.`)
        .fontSize(18)
        .fontColor('#5b6b7d')

      Column({ space: 12 }) {
        Row() {
          Text('Time')
            .fontSize(18)
          Blank()
          Text(this.formatTime(this.timeSeconds))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')

        Row() {
          Text('Steps')
            .fontSize(18)
          Blank()
          Text(`${this.steps}`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#ffffff')
      .borderRadius(18)

      if (this.isBest) {
        Text('New Record!')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')
          .backgroundColor('#37b37e')
          .borderRadius(14)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      }

      Button('Play Again')
        .width('100%')
        .height(50)
        .backgroundColor('#4f7cff')
        .fontColor('#ffffff')
        .onClick(() => {
          this.playAgain()
        })

      Button('Back to Home')
        .width('100%')
        .height(50)
        .backgroundColor('#dfe8ff')
        .fontColor('#224099')
        .onClick(() => {
          router.clear()
          router.pushUrl({
            url: 'pages/IndexPage'
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(24)
    .backgroundColor('#f5f7fb')
  }
}
