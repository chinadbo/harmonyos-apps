import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formBindingData from '@ohos.app.form.formBindingData';
import { PlayerService } from '../service/PlayerService';
import { PlayerViewModel } from '../viewmodel/PlayerViewModel';
import { SongInfo } from '../model/SongInfo';

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(): formBindingData.FormBindingData {
    const currentSong: SongInfo | null = AppStorage.get(PlayerViewModel.KEY_CURRENT_SONG) as SongInfo | null;
    return formBindingData.createFormBindingData({
      title: currentSong?.title ?? 'HarmonyPlayer',
      artist: currentSong?.artist ?? '未在播放',
      isPlaying: AppStorage.get(PlayerViewModel.KEY_IS_PLAYING) as boolean
    });
  }

  async onFormEvent(_formId: string, message: string): Promise<void> {
    if (message === 'toggle') {
      await PlayerService.getInstance().togglePlayPause();
    }
  }
}
