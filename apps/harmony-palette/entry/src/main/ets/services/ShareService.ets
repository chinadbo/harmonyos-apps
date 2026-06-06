import pasteboard from '@ohos.pasteboard';
import { BusinessError } from '@ohos.base';

export class ShareService {
  static copyText(text: string): Promise<void> {
    const board = pasteboard.getSystemPasteboard();
    const data = pasteboard.createData(pasteboard.MIMETEXT_PLAIN, text);
    return new Promise((resolve, reject) => {
      board.setData(data, (error?: BusinessError) => {
        if (error) {
          reject(error);
          return;
        }
        resolve();
      });
    });
  }
}
