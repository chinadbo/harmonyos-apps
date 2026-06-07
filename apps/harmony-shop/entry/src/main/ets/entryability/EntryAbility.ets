import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { ShopDatabase } from '../database/ShopDatabase';

export default class EntryAbility extends UIAbility {
  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    AppStorage.SetOrCreate('abilityContext', this.context);
    AppStorage.SetOrCreate('currentListId', 0);
    AppStorage.SetOrCreate('currentListName', '');

    await ShopDatabase.getInstance().init(this.context);

    windowStage.loadContent('pages/Index', (error) => {
      if (error && error.code) {
        console.error(`Failed to load the content. Code: ${error.code}, message: ${error.message}`);
      }
    });
  }
}
