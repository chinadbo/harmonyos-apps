/**
 * EntryAbility.ets — 应用入口 UIAbility
 * 负责：初始化数据库、加载偏好设置、加载首页。
 */
import UIAbility from '@ohos.app.ability.UIAbility';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import { BusinessError } from '@ohos.base';
import { Db } from '../model/Db';
import { Prefs } from '../common/Prefs';
import { Logger } from '../common/Logger';

const TAG: string = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'onCreate');
    this.bootstrap();
  }

  private async bootstrap(): Promise<void> {
    try {
      await Db.init(this.context);
      await Prefs.init(this.context);
      await Prefs.loadIntoSettings();
      Logger.info(TAG, 'bootstrap complete');
    } catch (err) {
      Logger.error(TAG, 'bootstrap failed: ' + JSON.stringify(err));
    }
  }

  onDestroy(): void {
    Logger.info(TAG, 'onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, 'onWindowStageCreate');
    this.loadWhenReady(windowStage);
  }

  /** 等待数据库就绪后再加载首页，避免首帧读到空库 */
  private async loadWhenReady(windowStage: window.WindowStage): Promise<void> {
    try {
      await Db.waitReady(5000);
    } catch (err) {
      Logger.warn(TAG, 'waitReady failed, load anyway');
    }
    windowStage.loadContent('pages/Index', (err: BusinessError) => {
      if (err && err.code) {
        Logger.error(TAG, 'loadContent failed: ' + err.code + ' ' + err.message);
        return;
      }
      Logger.info(TAG, 'loadContent success');
    });
  }

  onWindowStageDestroy(): void {
    Logger.info(TAG, 'onWindowStageDestroy');
  }

  onForeground(): void {
    Logger.info(TAG, 'onForeground');
  }

  onBackground(): void {
    Logger.info(TAG, 'onBackground');
  }
}
