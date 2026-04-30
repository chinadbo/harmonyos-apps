import { SongInfo } from '../model/SongInfo';
import { LyricLine } from '../model/LyricLine';
import { PlayMode } from '../model/PlayMode';

export class PlayerViewModel {
  static readonly KEY_IS_PLAYING: string = 'isPlaying';
  static readonly KEY_CURRENT_SONG: string = 'currentSong';
  static readonly KEY_CURRENT_TIME: string = 'currentTime';
  static readonly KEY_TOTAL_TIME: string = 'totalTime';
  static readonly KEY_CURRENT_LYRIC_INDEX: string = 'currentLyricIndex';
  static readonly KEY_PLAY_QUEUE: string = 'playQueue';
  static readonly KEY_PLAY_MODE: string = 'playMode';
  static readonly KEY_LYRIC_LINES: string = 'lyricLines';
  static readonly KEY_SCAN_PATH: string = 'scanPath';
  static readonly KEY_CROSS_DEVICE: string = 'crossDeviceEnabled';
  static readonly KEY_SHOW_PRIVACY: string = 'showPrivacyDialog';
  static readonly DEFAULT_SCAN_PATH: string = '/storage/Users/currentUser/Music';

  static initializeDefaults(): void {
    AppStorage.setOrCreate(PlayerViewModel.KEY_IS_PLAYING, false);
    AppStorage.setOrCreate(PlayerViewModel.KEY_CURRENT_SONG, null as SongInfo | null);
    AppStorage.setOrCreate(PlayerViewModel.KEY_CURRENT_TIME, 0);
    AppStorage.setOrCreate(PlayerViewModel.KEY_TOTAL_TIME, 0);
    AppStorage.setOrCreate(PlayerViewModel.KEY_CURRENT_LYRIC_INDEX, 0);
    AppStorage.setOrCreate(PlayerViewModel.KEY_PLAY_QUEUE, [] as SongInfo[]);
    AppStorage.setOrCreate(PlayerViewModel.KEY_PLAY_MODE, PlayMode.SEQUENCE);
    AppStorage.setOrCreate(PlayerViewModel.KEY_LYRIC_LINES, [] as LyricLine[]);
    AppStorage.setOrCreate(PlayerViewModel.KEY_SCAN_PATH, PlayerViewModel.DEFAULT_SCAN_PATH);
    AppStorage.setOrCreate(PlayerViewModel.KEY_CROSS_DEVICE, false);
    AppStorage.setOrCreate(PlayerViewModel.KEY_SHOW_PRIVACY, false);
  }
}
