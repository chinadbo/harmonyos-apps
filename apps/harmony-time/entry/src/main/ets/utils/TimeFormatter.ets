export class TimeFormatter {
  static formatDuration(totalSeconds: number): string {
    const seconds: number = Math.max(0, totalSeconds);
    const hours: number = Math.floor(seconds / 3600);
    const minutes: number = Math.floor((seconds % 3600) / 60);
    const remainingSeconds: number = seconds % 60;
    const hh: string = hours.toString().padStart(2, '0');
    const mm: string = minutes.toString().padStart(2, '0');
    const ss: string = remainingSeconds.toString().padStart(2, '0');
    return `${hh}:${mm}:${ss}`;
  }

  static formatDurationShort(totalSeconds: number): string {
    const seconds: number = Math.max(0, totalSeconds);
    const hours: number = Math.floor(seconds / 3600);
    const minutes: number = Math.floor((seconds % 3600) / 60);
    if (hours > 0) {
      return `${hours}h ${minutes}m`;
    }
    return `${minutes}m`;
  }
}
