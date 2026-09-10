import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import { RDBHelper } from '../data/RDBHelper';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: any): void {
    console.info('EntryAbility', 'onCreate');
    // 初始化数据库
    this.initDatabase();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/HomePage');
  }

  private async initDatabase(): Promise<void> {
    try {
      const context = this.context;
      await RDBHelper.init(context);
      console.info('EntryAbility', 'Database initialized');
    } catch (err) {
      console.error('EntryAbility', `Database init failed: ${JSON.stringify(err)}`);
    }
  }
}
