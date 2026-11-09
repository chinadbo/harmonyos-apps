import UIAbility from '@ohos.app.ability.UIAbility';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import { GachaDb } from '../db/GachaDb';
import { loadThemePref } from '../common/Theme';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('gachaTheme', 0);
    AppStorage.setOrCreate('refreshFlag', 0);
    loadThemePref(this.context).then((theme: number) => {
      AppStorage.setOrCreate('gachaTheme', theme);
    }).catch(() => {
    });
    GachaDb.ensure(this.context).catch(() => {
    });
  }

  onDestroy(): void {
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        return;
      }
    });
  }

  onWindowStageDestroy(): void {
  }

  onForeground(): void {
  }

  onBackground(): void {
  }
}
