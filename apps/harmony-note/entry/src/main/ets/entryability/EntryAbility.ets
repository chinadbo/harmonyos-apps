import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import common from '@ohos.app.ability.common';
import { NoteStore } from '../model/NoteStore';

export default class EntryAbility extends UIAbility {
  private contextRef?: common.UIAbilityContext;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.contextRef = this.context;
    try {
      NoteStore.init(this.context.filesDir);
      console.info('HarmonyNote ability created: ' + JSON.stringify({
        bundle: want.bundleName,
        launchReason: launchParam.launchReason
      }));
    } catch (error) {
      console.error('Failed to initialize NoteStore in onCreate: ' + JSON.stringify(error));
    }
  }

  onDestroy(): void {
    console.info('HarmonyNote ability destroyed');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    try {
      windowStage.loadContent('pages/Index', (error) => {
        if (error && error.code) {
          console.error('Failed to load index page: ' + JSON.stringify(error));
          return;
        }
        console.info('Index page loaded successfully');
      });
    } catch (error) {
      console.error('Failed in onWindowStageCreate: ' + JSON.stringify(error));
    }
  }

  onWindowStageDestroy(): void {
    console.info('Window stage destroyed');
  }

  onForeground(): void {
    try {
      NoteStore.reload();
    } catch (error) {
      console.error('Failed to reload in foreground: ' + JSON.stringify(error));
    }
  }

  onBackground(): void {
    console.info('HarmonyNote moved to background');
  }
}
