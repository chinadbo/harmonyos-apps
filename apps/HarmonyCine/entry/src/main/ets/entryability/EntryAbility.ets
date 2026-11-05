/**
 * EntryAbility：应用入口。
 * onCreate 中向 DbService 注入上下文；loadContent 使用 promise 版本并
 * 以 try/catch 捕获 BusinessError（不直接访问未判空的 err.code）。
 */
import UIAbility from '@ohos.app.ability.UIAbility';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import { BusinessError } from '@ohos.base';
import { initDb } from '../data/DbService';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    initDb(this.context);
  }

  onDestroy(): void {
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    try {
      await windowStage.loadContent('pages/Index');
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyCine] loadContent failed, code=${e.code} message=${e.message}`);
    }
  }

  onWindowStageDestroy(): void {
  }

  onForeground(): void {
  }

  onBackground(): void {
  }
}
