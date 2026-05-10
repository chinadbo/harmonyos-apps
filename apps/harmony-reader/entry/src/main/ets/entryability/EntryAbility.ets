import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import PreferencesService from '../service/PreferencesService';
import DatabaseService from '../service/DatabaseService';

export default class EntryAbility extends UIAbility {
  async onCreate(_want: Want): Promise<void> {
    AppStorage.setOrCreate('navPathStack', new NavPathStack());
    AppStorage.setOrCreate('readerTheme', 'light');
    AppStorage.setOrCreate('readerFontSize', 18);
    await DatabaseService.initialize(this.context);
    await PreferencesService.initialize(this.context);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index');
  }
}
