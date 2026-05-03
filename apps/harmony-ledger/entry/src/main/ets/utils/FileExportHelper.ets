import fileIo from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { DateUtils } from './DateUtils';

export class FileExportHelper {
  static async exportCsv(context: common.Context, fileName: string, content: string): Promise<string> {
    const dir: string = `${context.filesDir}/exports`;
    try {
      await fileIo.access(dir);
    } catch (error) {
      await fileIo.mkdir(dir);
    }
    const path: string = `${dir}/${DateUtils.compactDateString(DateUtils.currentDateString())}-${fileName}`;
    const file: fileIo.File = await fileIo.open(path, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
    await fileIo.write(file.fd, content);
    await fileIo.close(file);
    return path;
  }
}
