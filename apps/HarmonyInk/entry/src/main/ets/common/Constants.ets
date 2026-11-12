/**
 * HarmonyInk 全局常量与通用枚举工具。
 * 坐标统一使用 0-100 归一化空间，渲染时按画布尺寸换算。
 */
export class Constants {
  static readonly APP_NAME: string = '墨迹笔顺';
  static readonly APP_SUBTITLE: string = 'HarmonyInk · 汉字笔顺练习';
  static readonly VERSION: string = '1.0.0';

  // 归一化坐标系
  static readonly NORM_MAX: number = 100;
  static readonly CANVAS_SIZE: number = 320;

  // 评分阈值
  static readonly START_TOLERANCE: number = 15;
  static readonly DIR_TOLERANCE: number = 45;
  static readonly COVER_TOLERANCE: number = 18;
  static readonly PASS_SCORE: number = 60;
  static readonly EXCELLENT_SCORE: number = 90;

  // 掌握度
  static readonly MASTER_SCORE: number = 85;
  static readonly MASTER_TIMES: number = 3;

  // 设置默认值
  static readonly ANIM_SPEED_DEFAULT: number = 900;
  static readonly ANIM_SPEED_MIN: number = 300;
  static readonly ANIM_SPEED_MAX: number = 1800;
  static readonly BRUSH_WIDTH_DEFAULT: number = 7;
  static readonly BRUSH_WIDTH_MIN: number = 3;
  static readonly BRUSH_WIDTH_MAX: number = 14;
  static readonly VIBRATE_DEFAULT: boolean = true;

  // 持久化
  static readonly PREF_NAME: string = 'harmonyink_settings';
  static readonly KEY_ANIM_SPEED: string = 'anim_speed';
  static readonly KEY_BRUSH_WIDTH: string = 'brush_width';
  static readonly KEY_VIBRATE: string = 'vibrate_enabled';
  static readonly DB_NAME: string = 'harmonyink.db';
  static readonly TABLE_PRACTICE: string = 'practice';
  static readonly SQL_CREATE_PRACTICE: string =
    'CREATE TABLE IF NOT EXISTS practice (' +
      'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      'char text NOT NULL, ' +
      'score integer NOT NULL, ' +
      'stroke_count integer NOT NULL, ' +
      'duration_ms integer NOT NULL, ' +
      'created_at integer NOT NULL)';

  static gradeLabel(grade: number): string {
    if (grade <= 0) {
      return '全部年级';
    }
    return `${grade}年级`;
  }

  static difficultyLabel(strokeCount: number): string {
    if (strokeCount <= 3) {
      return '简单 · 1-3画';
    }
    if (strokeCount <= 6) {
      return '适中 · 4-6画';
    }
    return '进阶 · 7画以上';
  }

  static scoreLabel(score: number): string {
    if (score >= 95) {
      return '形神兼备';
    }
    if (score >= Constants.EXCELLENT_SCORE) {
      return '笔笔到位';
    }
    if (score >= 80) {
      return '有模有样';
    }
    if (score >= Constants.PASS_SCORE) {
      return '继续加油';
    }
    return '再试一次';
  }

  /** 同一天内保持稳定的推荐索引 */
  static dailySeed(): number {
    const now = new Date();
    return now.getFullYear() * 10000 + (now.getMonth() + 1) * 100 + now.getDate();
  }
}
