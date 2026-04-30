import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { DatabaseHelper } from '../database/DatabaseHelper';
import { PermissionUtils } from '../utils/PermissionUtils';
import { PlayerService } from '../service/PlayerService';
import { MediaScanService } from '../service/MediaScanService';

export default class EntryAbility extends UIAbility {
  async onCreate(): Promise<void> {
    console.info('[EntryAbility] onCreate');
    try {
      await DatabaseHelper.getInstance().init(this.context);
      await PlayerService.getInstance().init(this.context);
      const granted = await PermissionUtils.ensureMediaPermission(this.context);
      AppStorage.setOrCreate('mediaPermissionGranted', granted);
      if (granted) {
        const songs = await MediaScanService.getInstance().scanLocalMusic(this.context);
        AppStorage.setOrCreate('librarySongs', songs);
      }
    } catch (error) {
      console.error(`[EntryAbility] onCreate failed: ${JSON.stringify(error)}`);
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    console.info('[EntryAbility] onWindowStageCreate');
    windowStage.loadContent('pages/Index', (error) => {
      if (error.code) {
        console.error(`[EntryAbility] loadContent failed: ${JSON.stringify(error)}`);
      }
    });
  }

  onWindowStageDestroy(): void {
    console.info('[EntryAbility] onWindowStageDestroy');
  }

  onDestroy(): void {
    console.info('[EntryAbility] onDestroy');
  }
}
