import router from '@ohos.router'
import { GameDatabase } from '../database/GameDatabase'
import type { GameRecord } from '../model/GameRecord'
import common from '@ohos.app.ability.common'

interface DifficultyOption {
  value: number
  label: string
}

interface PuzzleImageOption {
  id: number
  title: string
  source: ResourceStr
  accent: string
}

@Entry
@Component
export struct IndexPage {
  @State selectedDifficulty: number = 3
  @State selectedImageIndex: number = 0
  @State leaderboardVisible: boolean = false
  @State bestRecords: Record<number, GameRecord | null> = { 3: null, 4: null, 5: null }
  @State leaderboardRecords: GameRecord[] = []

  private readonly difficultyOptions: DifficultyOption[] = [
    { value: 3, label: '3x3' },
    { value: 4, label: '4x4' },
    { value: 5, label: '5x5' }
  ]

  private readonly imageOptions: PuzzleImageOption[] = [
    { id: 0, title: 'Aurora', source: $r('app.media.icon'), accent: '#4f7cff' },
    { id: 1, title: 'Sunrise', source: $r('app.media.icon'), accent: '#ff8f4f' },
    { id: 2, title: 'Forest', source: $r('app.media.icon'), accent: '#37b37e' },
    { id: 3, title: 'City', source: $r('app.media.icon'), accent: '#8a63ff' },
    { id: 4, title: 'Ocean', source: $r('app.media.icon'), accent: '#23a6d5' },
    { id: 5, title: 'Bloom', source: $r('app.media.icon'), accent: '#f55aa5' }
  ]

  async aboutToAppear() {
    await this.loadRecords()
  }

  private async loadRecords(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext
    this.bestRecords = await GameDatabase.getBestRecords(context)
    this.leaderboardRecords = await GameDatabase.getLeaderboard(context)
  }

  private formatTime(totalSeconds?: number): string {
    if (totalSeconds === undefined) {
      return '--:--'
    }
    const minutes = Math.floor(totalSeconds / 60)
    const seconds = totalSeconds % 60
    const minuteText = minutes < 10 ? `0${minutes}` : `${minutes}`
    const secondText = seconds < 10 ? `0${seconds}` : `${seconds}`
    return `${minuteText}:${secondText}`
  }

  private openGame(): void {
    const selectedImage = this.imageOptions[this.selectedImageIndex]
    router.pushUrl({
      url: 'pages/GamePage',
      params: {
        difficulty: this.selectedDifficulty,
        imageIndex: this.selectedImageIndex,
        imageTitle: selectedImage.title
      }
    })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: 20 }) {
          Text('HarmonyPuzzle')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
            .margin({ top: 16 })

          Text('Choose a difficulty and start sliding the tiles back into place.')
            .fontSize(16)
            .fontColor('#5b6b7d')
            .textAlign(TextAlign.Center)
            .padding({ left: 20, right: 20 })

          Column({ space: 12 }) {
            Text('Difficulty')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .width('100%')

            Row({ space: 12 }) {
              ForEach(this.difficultyOptions, (option: DifficultyOption) => {
                Button(option.label)
                  .type(ButtonType.Capsule)
                  .backgroundColor(this.selectedDifficulty === option.value ? '#4f7cff' : '#e7eefc')
                  .fontColor(this.selectedDifficulty === option.value ? '#ffffff' : '#182431')
                  .onClick(() => {
                    this.selectedDifficulty = option.value
                  })
              }, (option: DifficultyOption) => `${option.value}`)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#ffffff')
          .borderRadius(18)

          Column({ space: 12 }) {
            Text('Best Times')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .width('100%')

            ForEach(this.difficultyOptions, (option: DifficultyOption) => {
              Row() {
                Text(option.label)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                Blank()
                Text(this.formatTime(this.bestRecords[option.value]?.timeSeconds))
                  .fontSize(16)
                  .fontColor('#4f7cff')
              }
              .width('100%')
            }, (option: DifficultyOption) => `best-${option.value}`)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#ffffff')
          .borderRadius(18)

          Column({ space: 12 }) {
            Text('Puzzle Images')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .width('100%')

            GridRow({ columns: 2, gutter: 12 }) {
              ForEach(this.imageOptions, (option: PuzzleImageOption) => {
                GridCol({ span: 1 }) {
                  Column({ space: 8 }) {
                    Stack({ alignContent: Alignment.BottomStart }) {
                      Image(option.source)
                        .width('100%')
                        .height(120)
                        .objectFit(ImageFit.Cover)
                        .borderRadius(16)
                      Text(option.title)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#ffffff')
                        .margin(10)
                    }
                    .border({
                      width: this.selectedImageIndex === option.id ? 3 : 0,
                      color: option.accent
                    })
                    .borderRadius(16)
                    .backgroundColor('#eef3ff')
                  }
                  .onClick(() => {
                    this.selectedImageIndex = option.id
                  })
                }
              }, (option: PuzzleImageOption) => `${option.id}`)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#ffffff')
          .borderRadius(18)

          Row({ space: 12 }) {
            Button('Start Game')
              .layoutWeight(1)
              .height(50)
              .backgroundColor('#4f7cff')
              .fontColor('#ffffff')
              .onClick(() => {
                this.openGame()
              })

            Button('Leaderboard')
              .layoutWeight(1)
              .height(50)
              .backgroundColor('#dfe8ff')
              .fontColor('#224099')
              .onClick(async () => {
                await this.loadRecords()
                this.leaderboardVisible = true
              })
          }
          .width('100%')
          .margin({ bottom: 24 })
        }
        .width('100%')
        .padding(20)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f5f7fb')

      if (this.leaderboardVisible) {
        Column({ space: 14 }) {
          Row() {
            Text('Leaderboard')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
            Blank()
            Button('Close')
              .type(ButtonType.Capsule)
              .backgroundColor('#e7eefc')
              .fontColor('#224099')
              .onClick(() => {
                this.leaderboardVisible = false
              })
          }
          .width('100%')

          if (this.leaderboardRecords.length === 0) {
            Text('No completed games yet. Start a round to create the first record.')
              .fontSize(16)
              .fontColor('#5b6b7d')
              .width('100%')
          } else {
            Scroll() {
              Column({ space: 10 }) {
                ForEach(this.leaderboardRecords, (record: GameRecord, index: number) => {
                  Row() {
                    Text(`#${index + 1}`)
                      .width(44)
                      .fontWeight(FontWeight.Medium)
                    Text(`${record.difficulty}x${record.difficulty}`)
                      .width(64)
                    Text(this.formatTime(record.timeSeconds))
                      .layoutWeight(1)
                    Text(`${record.steps} steps`)
                      .layoutWeight(1)
                    if (record.isBest === 1) {
                      Text('BEST')
                        .fontSize(12)
                        .fontColor('#ffffff')
                        .backgroundColor('#37b37e')
                        .borderRadius(10)
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    }
                  }
                  .width('100%')
                  .padding(12)
                  .backgroundColor('#f5f7fb')
                  .borderRadius(14)
                }, (record: GameRecord) => `${record.id}`)
              }
            }
            .height(320)
            .width('100%')
          }
        }
        .width('88%')
        .padding(20)
        .backgroundColor('#ffffff')
        .borderRadius(24)
        .shadow({ radius: 24, color: '#26000000', offsetX: 0, offsetY: 8 })
        .margin({ top: 80 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
