import AbilityStage from '@ohos.app.ability.AbilityStage';
import Want from '@ohos.app.ability.Want';
import { RDBHelper } from '../data/RDBHelper';

export default class EntryAbility extends AbilityStage {
  onCreate(want: Want, launchParam: any): void {
    console.info('EntryAbility', 'onCreate');
    // 初始化数据库
    this.initDatabase();
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
