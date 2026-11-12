/**
 * 视觉主题：宣纸底色 + 墨色 + 印章红。
 * 同时提供田字格绘制工具，所有 Canvas 组件共用。
 */
export class AppTheme {
  static readonly BG: string = '#F7F2E7';
  static readonly CARD: string = '#FFFDF8';
  static readonly CARD_ALT: string = '#F3ECDD';
  static readonly INK: string = '#2C2A26';
  static readonly INK_LIGHT: string = '#6B655C';
  static readonly INK_FAINT: string = '#A9A094';
  static readonly ACCENT: string = '#B03A2E';
  static readonly ACCENT_SOFT: string = '#F0DDD8';
  static readonly GOLD: string = '#C9A227';
  static readonly GREEN: string = '#4F7942';
  static readonly RED_SOFT: string = '#D98B80';
  static readonly GRID_LINE: string = '#CBBCA4';
  static readonly GRID_DASH: string = '#DED3C0';
  static readonly GUIDE: string = '#BDB2A2';
  static readonly LIVE_GOOD: string = '#4F7942';
  static readonly LIVE_WARN: string = '#C9A227';
  static readonly LIVE_BAD: string = '#B03A2E';

  static readonly RADIUS: number = 18;
  static readonly PAGE_PADDING: number = 18;
  static readonly FONT_TITLE: number = 26;
  static readonly FONT_BODY: number = 15;
  static readonly FONT_SMALL: number = 12;

  static masteryColor(mastery: number): string {
    if (mastery >= 85) {
      return AppTheme.GREEN;
    }
    if (mastery >= 60) {
      return AppTheme.GOLD;
    }
    if (mastery > 0) {
      return AppTheme.ACCENT;
    }
    return AppTheme.INK_FAINT;
  }

  static scoreColor(score: number): string {
    if (score >= 90) {
      return AppTheme.GREEN;
    }
    if (score >= 75) {
      return AppTheme.GOLD;
    }
    if (score >= 60) {
      return AppTheme.ACCENT;
    }
    return AppTheme.INK_FAINT;
  }

  /** 绘制田字格：外框 + 虚线中线 + 可选对角虚线 */
  static drawTianGrid(ctx: CanvasRenderingContext2D, size: number, showDiagonal: boolean): void {
    const inset: number = 4;
    const s: number = size;
    ctx.save();
    ctx.globalAlpha = 1;
    ctx.lineCap = 'round';

    // 外框
    ctx.strokeStyle = AppTheme.GRID_LINE;
    ctx.lineWidth = 2;
    ctx.setLineDash([]);
    ctx.strokeRect(inset, inset, s - inset * 2, s - inset * 2);

    // 虚线中线
    ctx.strokeStyle = AppTheme.GRID_DASH;
    ctx.lineWidth = 1;
    ctx.setLineDash([7, 7]);
    ctx.beginPath();
    ctx.moveTo(s / 2, inset);
    ctx.lineTo(s / 2, s - inset);
    ctx.moveTo(inset, s / 2);
    ctx.lineTo(s - inset, s / 2);
    ctx.stroke();

    // 对角虚线
    if (showDiagonal) {
      ctx.globalAlpha = 0.55;
      ctx.setLineDash([5, 9]);
      ctx.beginPath();
      ctx.moveTo(inset, inset);
      ctx.lineTo(s - inset, s - inset);
      ctx.moveTo(s - inset, inset);
      ctx.lineTo(inset, s - inset);
      ctx.stroke();
    }
    ctx.setLineDash([]);
    ctx.restore();
  }

  /** 0-100 归一化坐标转画布像素 */
  static toCanvas(value: number, size: number): number {
    return value / 100 * size;
  }
}
