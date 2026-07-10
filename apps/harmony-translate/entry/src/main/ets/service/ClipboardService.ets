import { pasteboard } from '@ohos.pasteboard';

export class ClipboardService {
  private lastText: string = '';
  private intervalId: number = -1;
  private callback: ((text: string) => void) | null = null;

  startListening(callback: (text: string) => void): void {
    this.callback = callback;
    this.checkClipboard();
    this.intervalId = setInterval(() => {
      this.checkClipboard();
    }, 2000);
  }

  stopListening(): void {
    if (this.intervalId !== -1) {
      clearInterval(this.intervalId);
      this.intervalId = -1;
    }
    this.callback = null;
  }

  private async checkClipboard(): Promise<void> {
    try {
      const systemPasteboard = pasteboard.getSystemPasteboard();
      const data = await systemPasteboard.getData();
      const text = data.getPrimaryText();
      if (text && text !== this.lastText && text.length > 0 && text.length < 1000) {
        this.lastText = text;
        if (this.callback) {
          this.callback(text);
        }
      }
    } catch (e) {
      // Clipboard may be empty or unavailable, ignore
    }
  }

  async copyToClipboard(text: string): Promise<void> {
    try {
      const systemPasteboard = pasteboard.getSystemPasteboard();
      const data = pasteboard.createData(pasteboard.MimeType.TEXT, text);
      await systemPasteboard.setData(data);
    } catch (e) {
      console.error('Failed to copy to clipboard:', e);
    }
  }
}
