import vibrator from '@ohos.vibrator';
import audio from '@ohos.multimedia.audio';

class ThresholdAlertService {
  private lastAlertTime: number = 0;
  private readonly alertCooldown: number = 3000; // 3 seconds cooldown
  private alertTonePlayer: audio.AudioRenderer | null = null;

  async init(): Promise<void> {
    try {
      const streamInfo: audio.AudioStreamInfo = {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_44100,
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      };
      const rendererInfo: audio.AudioRendererInfo = {
        content: audio.ContentType.CONTENT_TYPE_SONIFICATION,
        usage: audio.StreamUsage.STREAM_USAGE_NOTIFICATION,
        rendererFlags: 0
      };
      this.alertTonePlayer = await audio.createAudioRenderer(streamInfo, rendererInfo);
      console.info('Alert tone player initialized');
    } catch (err) {
      console.error('Failed to init alert tone player:', err);
    }
  }

  async triggerAlert(enableVibration: boolean): Promise<void> {
    const now = Date.now();
    if (now - this.lastAlertTime < this.alertCooldown) {
      return;
    }
    this.lastAlertTime = now;

    if (enableVibration) {
      this.vibrate();
    }
    this.playAlertTone();
  }

  private vibrate(): void {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 200
      }, {
        id: 0,
        usage: 'alarm'
      });
    } catch (err) {
      console.error('Vibration failed:', err);
    }
  }

  private async playAlertTone(): Promise<void> {
    if (!this.alertTonePlayer) return;
    try {
      // Generate a simple 1kHz sine wave beep (100ms)
      const sampleRate = 44100;
      const duration = 100; // ms
      const numSamples = Math.floor(sampleRate * duration / 1000);
      const buffer = new ArrayBuffer(numSamples * 2); // 16-bit
      const int16View = new Int16Array(buffer);
      const frequency = 1000;
      const amplitude = 8000;
      for (let i = 0; i < numSamples; i++) {
        int16View[i] = Math.sin(2 * Math.PI * frequency * i / sampleRate) * amplitude;
      }
      await this.alertTonePlayer.start();
      await this.alertTonePlayer.write(buffer);
      await this.alertTonePlayer.stop();
    } catch (err) {
      console.error('Alert tone failed:', err);
    }
  }

  async release(): Promise<void> {
    if (this.alertTonePlayer) {
      try {
        await this.alertTonePlayer.release();
        this.alertTonePlayer = null;
      } catch (err) {
        console.error('Failed to release alert player:', err);
      }
    }
  }
}

export default new ThresholdAlertService();
