export class IconConstants {
  static readonly ICONS: string[] = ['heart', 'star', 'gift', 'cake', 'flag', 'clock'];

  static getSymbol(icon: string): string {
    switch (icon) {
      case 'heart':
        return '♥';
      case 'star':
        return '★';
      case 'gift':
        return '🎁';
      case 'cake':
        return '🎂';
      case 'flag':
        return '⚑';
      case 'clock':
        return '⏰';
      default:
        return '•';
    }
  }
}
