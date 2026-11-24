import { difficultyColor, difficultyLabel } from '../model/Problem';

function badgeBg(difficulty: number): string {
  if (difficulty === 1) {
    return '#E7F9EF';
  }
  if (difficulty === 2) {
    return '#FFF3E0';
  }
  return '#FFEAEA';
}

/** 难度徽章 */
@Component
export struct DiffBadge {
  @Prop difficulty: number = 1;

  build() {
    Text(difficultyLabel(this.difficulty))
      .fontSize(11)
      .fontColor(difficultyColor(this.difficulty))
      .backgroundColor(badgeBg(this.difficulty))
      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
      .borderRadius(6)
  }
}
