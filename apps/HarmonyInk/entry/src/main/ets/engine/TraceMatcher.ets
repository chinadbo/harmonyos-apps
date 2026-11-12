import { Stroke, StrokePoint } from '../model/CharData';
import { Constants } from '../common/Constants';

/** 单笔三维匹配结果（比率均为 0-1） */
export interface StrokeMatch {
  startDistance: number;
  startRatio: number;
  directionDiff: number;
  directionRatio: number;
  coverageDistance: number;
  coverageRatio: number;
  sequenceOk: boolean;
}

/**
 * 轨迹匹配器：负责几何计算与「顺序 / 方向 / 覆盖度」三维判定。
 * 只做判定，不给权重分（权重在 StrokeScorer）。
 */
export class TraceMatcher {
  static clamp01(value: number): number {
    if (value < 0) {
      return 0;
    }
    if (value > 1) {
      return 1;
    }
    return value;
  }

  static distance(a: StrokePoint, b: StrokePoint): number {
    const dx: number = a.x - b.x;
    const dy: number = a.y - b.y;
    return Math.sqrt(dx * dx + dy * dy);
  }

  /** 点到线段的距离 */
  static pointToSegmentDistance(px: number, py: number, ax: number, ay: number,
    bx: number, by: number): number {
    const vx: number = bx - ax;
    const vy: number = by - ay;
    const lengthSq: number = vx * vx + vy * vy;
    if (lengthSq < 0.0001) {
      const dx0: number = px - ax;
      const dy0: number = py - ay;
      return Math.sqrt(dx0 * dx0 + dy0 * dy0);
    }
    let t: number = ((px - ax) * vx + (py - ay) * vy) / lengthSq;
    if (t < 0) {
      t = 0;
    } else if (t > 1) {
      t = 1;
    }
    const cx: number = ax + t * vx;
    const cy: number = ay + t * vy;
    const dx: number = px - cx;
    const dy: number = py - cy;
    return Math.sqrt(dx * dx + dy * dy);
  }

  /** 点到标准折线的最小距离 */
  static pointToPolylineDistance(point: StrokePoint, polyline: StrokePoint[]): number {
    if (polyline.length === 0) {
      return Number.MAX_VALUE;
    }
    if (polyline.length === 1) {
      return TraceMatcher.distance(point, polyline[0]);
    }
    let minDistance: number = Number.MAX_VALUE;
    for (let i = 0; i < polyline.length - 1; i++) {
      const d: number = TraceMatcher.pointToSegmentDistance(
        point.x, point.y,
        polyline[i].x, polyline[i].y,
        polyline[i + 1].x, polyline[i + 1].y
      );
      if (d < minDistance) {
        minDistance = d;
      }
    }
    return minDistance;
  }

  static polylineLength(points: StrokePoint[]): number {
    let total: number = 0;
    for (let i = 0; i < points.length - 1; i++) {
      total += TraceMatcher.distance(points[i], points[i + 1]);
    }
    return total;
  }

  /** 取路径前 ratio 比例的终点（按弧长） */
  static pointAtRatio(points: StrokePoint[], ratio: number): StrokePoint {
    if (points.length === 0) {
      return { x: 0, y: 0 };
    }
    if (points.length === 1) {
      return points[0];
    }
    const total: number = TraceMatcher.polylineLength(points);
    if (total < 0.0001) {
      return points[points.length - 1];
    }
    const target: number = total * ratio;
    let walked: number = 0;
    for (let i = 0; i < points.length - 1; i++) {
      const seg: number = TraceMatcher.distance(points[i], points[i + 1]);
      if (walked + seg >= target) {
        const t: number = seg < 0.0001 ? 0 : (target - walked) / seg;
        const result: StrokePoint = {
          x: points[i].x + (points[i + 1].x - points[i].x) * t,
          y: points[i].y + (points[i + 1].y - points[i].y) * t
        };
        return result;
      }
      walked += seg;
    }
    return points[points.length - 1];
  }

  static angleDeg(dx: number, dy: number): number {
    return Math.atan2(dy, dx) * 180 / Math.PI;
  }

  /** 起笔方向：首点到前 18% 弧长处向量的角度 */
  static startDirection(points: StrokePoint[]): number {
    if (points.length < 2) {
      return 0;
    }
    const head: StrokePoint = points[0];
    const tail: StrokePoint = TraceMatcher.pointAtRatio(points, 0.18);
    return TraceMatcher.angleDeg(tail.x - head.x, tail.y - head.y);
  }

  /** 两个角度差（0-180） */
  static angleDiff(a: number, b: number): number {
    let diff: number = a - b;
    while (diff > 180) {
      diff -= 360;
    }
    while (diff < -180) {
      diff += 360;
    }
    return Math.abs(diff);
  }

  /** 用户轨迹相对标准路径的平均覆盖距离 */
  static coverageDistance(userPoints: StrokePoint[], standardPoints: StrokePoint[]): number {
    if (userPoints.length === 0) {
      return Number.MAX_VALUE;
    }
    const step: number = userPoints.length > 40 ? Math.ceil(userPoints.length / 40) : 1;
    let sum: number = 0;
    let count: number = 0;
    for (let i = 0; i < userPoints.length; i += step) {
      sum += TraceMatcher.pointToPolylineDistance(userPoints[i], standardPoints);
      count++;
    }
    if (count === 0) {
      return Number.MAX_VALUE;
    }
    return sum / count;
  }

  /** 对一笔用户轨迹做完整三维匹配 */
  static matchStroke(userPoints: StrokePoint[], standard: Stroke): StrokeMatch {
    if (userPoints.length === 0 || standard.points.length === 0) {
      const empty: StrokeMatch = {
        startDistance: Number.MAX_VALUE,
        startRatio: 0,
        directionDiff: 180,
        directionRatio: 0,
        coverageDistance: Number.MAX_VALUE,
        coverageRatio: 0,
        sequenceOk: false
      };
      return empty;
    }

    // 1. 顺序：起笔是否在标准起点容差内
    const startDistance: number = TraceMatcher.distance(userPoints[0], standard.points[0]);
    const startRatio: number = TraceMatcher.clamp01(1 - startDistance / Constants.START_TOLERANCE);

    // 2. 方向：用户前段主方向 vs 标准起笔方向
    const userDir: number = TraceMatcher.startDirection(userPoints);
    const standardDir: number = standard.startDir;
    const directionDiff: number = TraceMatcher.angleDiff(userDir, standardDir);
    let directionRatio: number = TraceMatcher.clamp01(1 - directionDiff / Constants.DIR_TOLERANCE);
    if (TraceMatcher.polylineLength(userPoints) < 2) {
      directionRatio = 0;
    }

    // 3. 覆盖度：用户点到标准折线的最小距离均值
    const coverageDistance: number = TraceMatcher.coverageDistance(userPoints, standard.points);
    const coverageRatio: number = TraceMatcher.clamp01(1 - coverageDistance / Constants.COVER_TOLERANCE);

    const match: StrokeMatch = {
      startDistance: startDistance,
      startRatio: startRatio,
      directionDiff: directionDiff,
      directionRatio: directionRatio,
      coverageDistance: coverageDistance,
      coverageRatio: coverageRatio,
      sequenceOk: startDistance < Constants.START_TOLERANCE
    };
    return match;
  }
}
