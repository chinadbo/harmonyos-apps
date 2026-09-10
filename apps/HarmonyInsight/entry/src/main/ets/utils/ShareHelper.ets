import share from '@ohos.share';
import fileAccess from '@ohos.file.fileAccess';
import common from '@ohos.app.ability.common';

/**
 * 图片分享辅助类
 */
export class ShareHelper {
  private static context = getContext(this) as common.UIAbilityContext;

  /**
   * 分享图片
   * @param imageUri 图片 URI
   * @param title 分享标题
   */
  static async shareImage(imageUri: string, title: string = 'HarmonyInsight 图表'): Promise<void> {
    try {
      const shareOptions = {
        type: 'image/png',
        uri: imageUri,
        title: title
      };
      await share.share(shareOptions, {
        context: this.context
      });
      console.info('ShareHelper', `Image shared: ${imageUri}`);
    } catch (err) {
      console.error('ShareHelper', `Share failed: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 分享文本
   * @param text 分享文本
   * @param title 分享标题
   */
  static async shareText(text: string, title: string = 'HarmonyInsight'): Promise<void> {
    try {
      const shareOptions = {
        type: 'text/plain',
        text: text,
        title: title
      };
      await share.share(shareOptions, {
        context: this.context
      });
      console.info('ShareHelper', `Text shared: ${text.substring(0, 50)}...`);
    } catch (err) {
      console.error('ShareHelper', `Share text failed: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 分享 CSV 数据
   * @param csvContent CSV 内容
   * @param fileName 文件名
   */
  static async shareCSV(csvContent: string, fileName: string = 'chart_data.csv'): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const filePath = context.filesDir + '/exports/' + fileName;

      const file = await import('@ohos.file.fs').then(fs => {
        return fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      });
      const buffer = new TextEncoder().encode(csvContent);
      const uint8 = new Uint8Array(buffer);
      await import('@ohos.file.fs').then(fs => fs.writeSync(file.fd, uint8));

      await this.shareImage('file://' + filePath, fileName);
    } catch (err) {
      console.error('ShareHelper', `Share CSV failed: ${JSON.stringify(err)}`);
    }
  }
}
