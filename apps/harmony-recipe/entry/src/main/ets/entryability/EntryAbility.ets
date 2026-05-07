import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import hilog from '@ohos.hilog';
import PresetDataService from '../service/PresetDataService';

const DOMAIN = 0xFF12;
const TAG = 'HarmonyRecipe';

export default class EntryAbility extends UIAbility {
  async onCreate(): Promise<void> {
    // AppStorage 是 ArkUI 框架内置全局对象，无需 import 直接使用
    AppStorage.setOrCreate('dataReady', false);
    try {
      await PresetDataService.getInstance().importIfNeeded(this.context);
      AppStorage.setOrCreate('dataReady', true);
    } catch (error) {
      const message = JSON.stringify(error);
      hilog.error(DOMAIN, TAG, `failed to prepare preset data: ${message}`);
      AppStorage.setOrCreate('dataReady', false);
    }
  }

  onDestroy(): void {
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err && err.code) {
        hilog.error(DOMAIN, TAG, `failed to load index page: ${JSON.stringify(err)}`);
      }
    });
  }

  onWindowStageDestroy(): void {
  }
}
