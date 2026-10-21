/**
 * 振动反馈封装
 */
import vibrator from '@ohos.vibrator';
import { Constants } from '../common/Constants';
import { Logger } from '../common/Logger';

const TAG = 'SoundService';

export class SoundService {
  /**
   * 短振动（受设置开关控制）
   */
  static vibrate(enabled: boolean, duration: number = Constants.VIBRATE_DURATION): void {
    if (!enabled) {
      return;
    }
    try {
      vibrator.startVibration({ type: 'time', duration: duration }, { usage: 'touch' })
        .then(() => {
          Logger.d(TAG, 'vibrate ok');
        })
        .catch((err: Error) => {
          Logger.w(TAG, 'vibrate failed: ' + err.message);
        });
    } catch (e) {
      Logger.w(TAG, 'vibrate exception: ' + JSON.stringify(e));
    }
  }

  /**
   * 走子音效（暂用振动代替；接入音频播放可扩展）
   */
  static playMove(enabled: boolean, isCapture: boolean = false): void {
    SoundService.vibrate(enabled, isCapture ? 60 : 30);
  }

  static playCheck(enabled: boolean): void {
    SoundService.vibrate(enabled, 120);
  }

  static playGameOver(enabled: boolean): void {
    SoundService.vibrate(enabled, 200);
  }
}
