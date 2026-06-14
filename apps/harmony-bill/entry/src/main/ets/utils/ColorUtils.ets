export class ColorUtils {
  private static readonly COLORS: string[] = [
    '#FF6B6B',
    '#4ECDC4',
    '#45B7D1',
    '#96CEB4',
    '#FFEAA7',
    '#DDA0DD',
    '#98D8C8',
    '#F7DC6F'
  ];

  static getColor(colorIndex: number): string {
    let index = colorIndex;
    if (index < 0) {
      index = 0;
    }
    return ColorUtils.COLORS[index % ColorUtils.COLORS.length];
  }

  static getInitial(name: string): string {
    if (!name || name.trim().length === 0) {
      return '?';
    }
    return name.trim().substring(0, 1).toUpperCase();
  }
}
