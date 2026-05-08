import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import { getDB } from '../database/DatabaseHelper';
import { SeedDataService } from '../service/SeedDataService';
import { TtsService } from '../service/TtsService';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, TAG, 'onCreate');

    // 创建全局路由栈（NavPathStack 是 ArkUI 内置类型，无需 import）
    const pageStack = new NavPathStack();
    AppStorage.setOrCreate('pageStack', pageStack);

    // 初始化数据库 + 种子数据
    try {
      const store = await getDB(this.context);
      const seedService = new SeedDataService(store);
      await seedService.seedIfEmpty();
      AppStorage.setOrCreate('dbReady', true);
    } catch (e) {
      hilog.error(0x0000, TAG, 'DB init failed: %{public}s', JSON.stringify(e));
      AppStorage.setOrCreate('dbReady', false);
    }

    // 初始化 TTS（不阻塞启动）
    TtsService.getInstance().init().catch(() => {});
  }

  onDestroy(): void {
    hilog.info(0x0000, TAG, 'onDestroy');
    TtsService.getInstance().release().catch(() => {});
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, TAG, 'onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, TAG, 'Failed to load content: %{public}s', JSON.stringify(err));
      }
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, TAG, 'onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(0x0000, TAG, 'onForeground');
  }

  onBackground(): void {
    hilog.info(0x0000, TAG, 'onBackground');
  }
}
