import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import { DatabaseService } from '../service/DatabaseService';

/**
 * 应用入口 Ability
 * 负责数据库初始化和窗口配置
 */
export default class EntryAbility extends UIAbility {
  /** Ability 创建时初始化数据库 */
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    console.info('[EntryAbility] onCreate');
    try {
      await DatabaseService.getInstance().init(this.context);
      console.info('[EntryAbility] database initialized');
    } catch (err) {
      console.error('[EntryAbility] database init failed:', JSON.stringify(err));
    }
  }

  onDestroy(): void {
    console.info('[EntryAbility] onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    console.info('[EntryAbility] onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code !== 0) {
        console.error('[EntryAbility] loadContent failed:', JSON.stringify(err));
      }
    });
  }

  onWindowStageDestroy(): void {
    console.info('[EntryAbility] onWindowStageDestroy');
  }

  onForeground(): void {
    console.info('[EntryAbility] onForeground');
  }

  onBackground(): void {
    console.info('[EntryAbility] onBackground');
  }
}
