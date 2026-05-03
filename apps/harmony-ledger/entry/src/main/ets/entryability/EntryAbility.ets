import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import Want from '@ohos.app.ability.Want';
import { DatabaseHelper } from '../data/DatabaseHelper';

export default class EntryAbility extends UIAbility {
  private startPage: string = 'pages/Index';

  onCreate(want: Want): void {
    DatabaseHelper.getInstance().setContext(this.context);
    void DatabaseHelper.getInstance().init(this.context);
    const targetPage = want?.parameters?.['targetPage'];
    this.startPage = targetPage === 'add' ? 'pages/AddTransaction' : 'pages/Index';
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent(this.startPage);
  }

  onWindowStageDestroy(): void {
  }
}
