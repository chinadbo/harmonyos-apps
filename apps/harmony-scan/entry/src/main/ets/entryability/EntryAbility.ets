import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import fs from '@ohos.file.fs';
import { DocumentDB } from '../database/DocumentDB';

export default class EntryAbility extends UIAbility {
  async onCreate(): Promise<void> {
    try {
      await DocumentDB.init(this.context);
    } catch (error) {
      console.error('DocumentDB init failed:', JSON.stringify(error));
    }
    this.ensureDir(`${this.context.filesDir}/scans`);
    this.ensureDir(`${this.context.filesDir}/pdfs`);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index');
  }

  private ensureDir(path: string): void {
    try {
      fs.accessSync(path);
    } catch (error) {
      fs.mkdirSync(path, true);
    }
  }
}
