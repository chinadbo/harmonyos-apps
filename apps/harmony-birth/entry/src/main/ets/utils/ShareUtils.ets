import pasteboard from '@ohos.pasteboard';
import promptAction from '@ohos.promptAction';

export class ShareUtils {
  static buildMessage(template: string, name: string): string {
    return template.replace(/\{name\}/g, name || '朋友');
  }

  static async copyText(text: string, message: string = '已复制到剪贴板'): Promise<void> {
    try {
      let pb = pasteboard.getSystemPasteboard();
      let data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
      await pb.setData(data);
      promptAction.showToast({ message });
    } catch (err) {
      console.error(`copyText failed: ${JSON.stringify(err)}`);
      promptAction.showToast({ message: '复制失败，请手动复制' });
    }
  }

  static async shareText(text: string): Promise<void> {
    await this.copyText(text, '已复制，可直接粘贴到社交应用分享');
  }
}
