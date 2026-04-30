import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import window from '@ohos.window';
import preferences from '@ohos.data.preferences';
import { PlayerViewModel } from '../viewmodel/PlayerViewModel';
import { DBHelper } from '../database/DBHelper';
import { PlayerService } from '../service/PlayerService';
import { AVSessionManager } from '../service/AVSessionManager';

export default class EntryAbility extends UIAbility {
  private prefs: preferences.Preferences | null = null;

  async onCreate(want: Want): Promise<void> {
    PlayerViewModel.initializeDefaults();
    this.prefs = await preferences.getPreferences(this.context, { name: 'harmonyplayer_preferences' });
    const agreed: boolean = this.prefs.getSync('privacyAgreed', false) as boolean;
    AppStorage.setOrCreate(PlayerViewModel.KEY_SHOW_PRIVACY, !agreed);
    await DBHelper.getInstance().initialize(this.context);
    await PlayerService.getInstance().initialize(this.context);
    await AVSessionManager.getInstance().initialize(this.context, PlayerService.getInstance());
    await this.handleInsightIntent(want);
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    windowStage.loadContent('pages/Index', async () => {
      const agreed: boolean = this.prefs?.getSync('privacyAgreed', false) as boolean;
      AppStorage.setOrCreate(PlayerViewModel.KEY_SHOW_PRIVACY, !agreed);
    });
  }

  async onNewWant(want: Want): Promise<void> {
    await this.handleInsightIntent(want);
  }

  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    const currentSong = AppStorage.get(PlayerViewModel.KEY_CURRENT_SONG) as Object | null;
    wantParam['currentSong'] = currentSong ?? {};
    wantParam['currentTime'] = AppStorage.get(PlayerViewModel.KEY_CURRENT_TIME) as number;
    return AbilityConstant.OnContinueResult.AGREE;
  }

  async onSaveState(state: Record<string, Object>): Promise<void> {
    state['currentSong'] = (AppStorage.get(PlayerViewModel.KEY_CURRENT_SONG) as Object | null) ?? {};
    state['currentTime'] = AppStorage.get(PlayerViewModel.KEY_CURRENT_TIME) as number;
  }

  async onRestoreState(state: Record<string, Object>): Promise<void> {
    if (state['currentSong'] !== undefined) {
      AppStorage.setOrCreate(PlayerViewModel.KEY_CURRENT_SONG, state['currentSong']);
    }
    if (state['currentTime'] !== undefined) {
      AppStorage.setOrCreate(PlayerViewModel.KEY_CURRENT_TIME, state['currentTime']);
    }
  }

  /**
   * P0 修复：静态方法无法安全获取 context，改为实例方法，通过 AppStorage 全局引用调用
   * 同时提供一个接受 context 参数的工具方法供外部调用
   */
  static async acceptPrivacy(context: Object): Promise<void> {
    const prefs = await preferences.getPreferences(context as Parameters<typeof preferences.getPreferences>[0], { name: 'harmonyplayer_preferences' });
    await prefs.put('privacyAgreed', true);
    await prefs.flush();
    AppStorage.setOrCreate(PlayerViewModel.KEY_SHOW_PRIVACY, false);
  }

  private async handleInsightIntent(want: Want): Promise<void> {
    const insightIntent: Record<string, Object> | string | undefined = want?.parameters?.['insightIntent'] as Record<string, Object> | string | undefined;
    if (insightIntent === undefined) {
      return;
    }
    let action: string = '';
    if (typeof insightIntent === 'string') {
      action = insightIntent;
    } else {
      action = String(insightIntent['action'] ?? '');
    }
    if (action === 'play') {
      await PlayerService.getInstance().play();
    } else if (action === 'pause') {
      await PlayerService.getInstance().pause();
    } else if (action === 'next') {
      await PlayerService.getInstance().next();
    } else if (action === 'previous') {
      await PlayerService.getInstance().previous();
    }
  }
}
