import { PuzzlePiece, findEmptyIndex, isAdjacent, isSolved, shufflePieces, swapPiecePositions } from '../utils/GameLogic'

@Component
export struct PuzzleGrid {
  @Prop difficulty: number
  @Prop imageSource: ResourceStr
  @Prop tileSize: number
  @Link steps: number
  @Link @Watch('onResetSignalChange') resetSignal: number
  @Event onWin: (steps: number) => void = () => {}
  @State pieces: PuzzlePiece[] = []
  @State boardVersion: number = 0

  aboutToAppear() {
    this.initializeBoard()
  }

  private onResetSignalChange(): void {
    if (this.boardVersion !== this.resetSignal) {
      this.initializeBoard()
      this.boardVersion = this.resetSignal
    }
  }

  private initializeBoard(): void {
    this.pieces = shufflePieces(this.difficulty)
    this.steps = 0
  }

  private movePiece(piece: PuzzlePiece): void {
    const emptyIndex = findEmptyIndex(this.pieces)
    if (!isAdjacent(piece.currentIndex, emptyIndex, this.difficulty)) {
      return
    }
    animateTo({ duration: 180, curve: Curve.EaseInOut }, () => {
      this.pieces = swapPiecePositions(this.pieces, piece.currentIndex, emptyIndex)
    })
    this.steps += 1
    if (isSolved(this.pieces)) {
      this.onWin(this.steps)
    }
  }

  private tileOffset(index: number): number {
    return index * this.tileSize
  }

  build() {
    const boardSize = this.tileSize * this.difficulty
    Column() {
      Stack() {
        ForEach(this.pieces, (piece: PuzzlePiece) => {
          if (!piece.isEmpty) {
            Stack({ alignContent: Alignment.TopStart }) {
              Image(this.imageSource)
                .width(boardSize)
                .height(boardSize)
                .objectFit(ImageFit.Cover)
                .offset({
                  x: -this.tileOffset(piece.correctIndex % this.difficulty),
                  y: -this.tileOffset(Math.floor(piece.correctIndex / this.difficulty))
                })
            }
            .width(this.tileSize - 4)
            .height(this.tileSize - 4)
            .clip(true)
            .backgroundColor('#ffffff')
            .borderRadius(10)
            .border({ width: 1, color: '#d5dff5' })
            .shadow({ radius: 8, color: '#33000000', offsetX: 0, offsetY: 2 })
            .position({
              x: (piece.currentIndex % this.difficulty) * this.tileSize + 2,
              y: Math.floor(piece.currentIndex / this.difficulty) * this.tileSize + 2
            })
            .onClick(() => {
              this.movePiece(piece)
            })
          } else {
            Row()
              .width(this.tileSize - 4)
              .height(this.tileSize - 4)
              .backgroundColor('#dbe6ff')
              .borderRadius(10)
              .position({
                x: (piece.currentIndex % this.difficulty) * this.tileSize + 2,
                y: Math.floor(piece.currentIndex / this.difficulty) * this.tileSize + 2
              })
          }
        }, (piece: PuzzlePiece) => `${piece.id}`)
      }
      .width(boardSize)
      .height(boardSize)
      .backgroundColor('#e8eefc')
      .borderRadius(16)
      .clip(true)
      .padding(2)
    }
  }
}
