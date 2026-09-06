import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import { DataStore } from '../model/DataStore';
import { PermissionService } from '../services/PermissionService';

export default class EntryAbility extends UIAbility {
  onCreate(want: Object, launchParam: Object): void {
    const context: common.UIAbilityContext = this.context;
    AppStorage.SetOrCreate<string>('defaultExportResolution', 'original');
    AppStorage.SetOrCreate<string>('defaultExportFormat', 'mp4');
    AppStorage.SetOrCreate<boolean>('autoSaveEnabled', true);
    AppStorage.SetOrCreate<string>('editorDraftName', '');
    AppStorage.SetOrCreate<number>('currentProjectId', 0);
    PermissionService.setContext(context);
    DataStore.init(context).catch((error: Error) => {
      console.error(`Failed to initialize data store: ${JSON.stringify(error)}`);
    });
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/ProjectListPage', (error: Error) => {
      if (error && (error as BusinessError).code) {
        console.error(`Failed to load content: ${JSON.stringify(error)}`);
      }
    });
  }

  onWindowStageDestroy(): void {
  }
}

interface BusinessError {
  code: number;
  message?: string;
}
