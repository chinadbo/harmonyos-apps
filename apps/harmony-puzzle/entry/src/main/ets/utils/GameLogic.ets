export interface PuzzlePiece {
  id: number
  correctIndex: number
  currentIndex: number
  isEmpty: boolean
}

export function createSolvedPieces(difficulty: number): PuzzlePiece[] {
  const total = difficulty * difficulty
  const pieces: PuzzlePiece[] = []
  for (let index = 0; index < total; index++) {
    pieces.push({
      id: index,
      correctIndex: index,
      currentIndex: index,
      isEmpty: index === total - 1
    })
  }
  return pieces
}

export function isAdjacent(firstIndex: number, secondIndex: number, difficulty: number): boolean {
  const firstRow = Math.floor(firstIndex / difficulty)
  const firstColumn = firstIndex % difficulty
  const secondRow = Math.floor(secondIndex / difficulty)
  const secondColumn = secondIndex % difficulty
  const rowDistance = Math.abs(firstRow - secondRow)
  const columnDistance = Math.abs(firstColumn - secondColumn)
  return rowDistance + columnDistance === 1
}

export function swapPiecePositions(pieces: PuzzlePiece[], firstIndex: number, secondIndex: number): PuzzlePiece[] {
  const nextPieces = pieces.map((piece: PuzzlePiece) => ({ ...piece }))
  const firstPiece = nextPieces.find((piece: PuzzlePiece) => piece.currentIndex === firstIndex)
  const secondPiece = nextPieces.find((piece: PuzzlePiece) => piece.currentIndex === secondIndex)
  if (!firstPiece || !secondPiece) {
    return nextPieces
  }
  firstPiece.currentIndex = secondIndex
  secondPiece.currentIndex = firstIndex
  return nextPieces.sort((left: PuzzlePiece, right: PuzzlePiece) => left.currentIndex - right.currentIndex)
}

export function findEmptyIndex(pieces: PuzzlePiece[]): number {
  const emptyPiece = pieces.find((piece: PuzzlePiece) => piece.isEmpty)
  return emptyPiece ? emptyPiece.currentIndex : pieces.length - 1
}

export function isSolved(pieces: PuzzlePiece[]): boolean {
  return pieces.every((piece: PuzzlePiece) => piece.currentIndex === piece.correctIndex)
}

export function shufflePieces(difficulty: number, moveCount: number = difficulty * difficulty * 20): PuzzlePiece[] {
  let pieces = createSolvedPieces(difficulty)
  let emptyIndex = findEmptyIndex(pieces)
  let previousIndex = -1
  for (let step = 0; step < moveCount; step++) {
    const candidates = pieces
      .filter((piece: PuzzlePiece) => !piece.isEmpty)
      .filter((piece: PuzzlePiece) => isAdjacent(piece.currentIndex, emptyIndex, difficulty))
      .map((piece: PuzzlePiece) => piece.currentIndex)
      .filter((index: number) => index !== previousIndex)

    const movableIndices = candidates.length > 0 ? candidates : pieces
      .filter((piece: PuzzlePiece) => !piece.isEmpty && isAdjacent(piece.currentIndex, emptyIndex, difficulty))
      .map((piece: PuzzlePiece) => piece.currentIndex)

    const randomIndex = movableIndices[Math.floor(Math.random() * movableIndices.length)]
    previousIndex = emptyIndex
    pieces = swapPiecePositions(pieces, randomIndex, emptyIndex)
    emptyIndex = randomIndex
  }

  if (isSolved(pieces)) {
    const fallbackIndex = pieces
      .filter((piece: PuzzlePiece) => !piece.isEmpty && isAdjacent(piece.currentIndex, emptyIndex, difficulty))
      .map((piece: PuzzlePiece) => piece.currentIndex)[0]
    pieces = swapPiecePositions(pieces, fallbackIndex, emptyIndex)
  }

  return pieces.sort((left: PuzzlePiece, right: PuzzlePiece) => left.currentIndex - right.currentIndex)
}
