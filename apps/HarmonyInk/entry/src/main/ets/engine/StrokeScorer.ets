import { Stroke, StrokePoint } from '../model/CharData';
import { Constants } from '../common/Constants';
import { TraceMatcher, StrokeMatch } from './TraceMatcher';

/** 单笔评分（顺序 40 + 方向 30 + 覆盖 30） */
export interface StrokeScore {
  order: number;
  type: string;
  total: number;
  startRatio: number;
  directionRatio: number;
  coverageRatio: number;
  sequenceOk: boolean;
  startDistance: number;
  directionDiff: number;
  coverageDistance: number;
}

/** 整字评分 */
export interface CharScore {
  total: number;
  strokeScores: StrokeScore[];
  average: number;
  orderBonus: number;
  allOrdered: boolean;
  label: string;
}

/**
 * 笔顺评分器：把 TraceMatcher 的三维比率加权成 0-100 分。
 * 单笔分 = 40×顺序 + 30×方向 + 30×覆盖。
 * 整字分 = Σ单笔分 / 笔数，全对顺序额外 +5，封顶 100。
 */
export class StrokeScorer {
  private static toStrokeScore(orderIndex: number, type: string, match: StrokeMatch): StrokeScore {
    const total: number =
      match.startRatio * 40 +
      match.directionRatio * 30 +
      match.coverageRatio * 30;
    const score: StrokeScore = {
      order: orderIndex,
      type: type,
      total: Math.round(total),
      startRatio: match.startRatio,
      directionRatio: match.directionRatio,
      coverageRatio: match.coverageRatio,
      sequenceOk: match.sequenceOk,
      startDistance: Math.round(match.startDistance * 10) / 10,
      directionDiff: Math.round(match.directionDiff),
      coverageDistance: Math.round(match.coverageDistance * 10) / 10
    };
    return score;
  }

  static scoreStroke(userPoints: StrokePoint[], standard: Stroke, orderIndex: number): StrokeScore {
    const match: StrokeMatch = TraceMatcher.matchStroke(userPoints, standard);
    return StrokeScorer.toStrokeScore(orderIndex, standard.type, match);
  }

  static emptyScore(standard: Stroke, orderIndex: number): StrokeScore {
    const score: StrokeScore = {
      order: orderIndex,
      type: standard.type,
      total: 0,
      startRatio: 0,
      directionRatio: 0,
      coverageRatio: 0,
      sequenceOk: false,
      startDistance: 999,
      directionDiff: 180,
      coverageDistance: 999
    };
    return score;
  }

  /** 整字评分：逐笔匹配后取平均，全部起笔顺序正确再 +5 */
  static scoreChar(userStrokes: StrokePoint[][], standards: Stroke[]): CharScore {
    const strokeScores: StrokeScore[] = [];
    let allOrdered: boolean = standards.length > 0;
    for (let i = 0; i < standards.length; i++) {
      let score: StrokeScore;
      if (i < userStrokes.length) {
        score = StrokeScorer.scoreStroke(userStrokes[i], standards[i], i + 1);
      } else {
        score = StrokeScorer.emptyScore(standards[i], i + 1);
      }
      if (!score.sequenceOk) {
        allOrdered = false;
      }
      strokeScores.push(score);
    }
    let sum: number = 0;
    for (let i = 0; i < strokeScores.length; i++) {
      sum += strokeScores[i].total;
    }
    const average: number = strokeScores.length > 0 ? sum / strokeScores.length : 0;
    const orderBonus: number = allOrdered ? 5 : 0;
    const total: number = Math.min(100, Math.round(average + orderBonus));
    const result: CharScore = {
      total: total,
      strokeScores: strokeScores,
      average: Math.round(average),
      orderBonus: orderBonus,
      allOrdered: allOrdered,
      label: Constants.scoreLabel(total)
    };
    return result;
  }

  /**
   * 练习页使用：按已通过的单笔分汇总。
   * 全程无错误才获得「顺序全对」+5 奖励。
   */
  static finalize(perStrokeScores: number[], mistakes: number): CharScore {
    const scores: StrokeScore[] = [];
    let sum: number = 0;
    for (let i = 0; i < perStrokeScores.length; i++) {
      sum += perStrokeScores[i];
      const item: StrokeScore = {
        order: i + 1,
        type: '',
        total: Math.round(perStrokeScores[i]),
        startRatio: 1,
        directionRatio: 1,
        coverageRatio: 1,
        sequenceOk: true,
        startDistance: 0,
        directionDiff: 0,
        coverageDistance: 0
      };
      scores.push(item);
    }
    const average: number = perStrokeScores.length > 0 ? sum / perStrokeScores.length : 0;
    const orderBonus: number = (mistakes === 0 && perStrokeScores.length > 0) ? 5 : 0;
    const total: number = Math.min(100, Math.round(average + orderBonus));
    const result: CharScore = {
      total: total,
      strokeScores: scores,
      average: Math.round(average),
      orderBonus: orderBonus,
      allOrdered: mistakes === 0,
      label: Constants.scoreLabel(total)
    };
    return result;
  }

  /** 实时提示：根据当前轨迹返回 0-100 的即时分数 */
  static liveScore(userPoints: StrokePoint[], standard: Stroke): number {
    if (userPoints.length < 2) {
      return 0;
    }
    return StrokeScorer.scoreStroke(userPoints, standard, standard.index + 1).total;
  }

  static isPassed(score: number): boolean {
    return score >= Constants.PASS_SCORE;
  }
}
