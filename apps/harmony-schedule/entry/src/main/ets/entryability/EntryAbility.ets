import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';

// 应用入口能力，负责创建主窗口
export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/HomePage', (error) => {
      if (error && error.code) {
        console.error(`Failed to load the content. Cause: ${JSON.stringify(error)}`);
      }
    });
  }
}
