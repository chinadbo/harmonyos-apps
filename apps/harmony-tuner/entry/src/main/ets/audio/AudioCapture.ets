import { audio } from '@ohos.multimedia.audio';
import promptAction from '@ohos.promptAction';

export class AudioCapture {
  private capturer: audio.AudioCapturer | null = null;
  private bufferSize: number = 2048;
  private isCapturing: boolean = false;
  private captureCallback: ((data: ArrayBuffer) => void) | null = null;

  async init(): Promise<boolean> {
    try {
      const audioStreamInfo: audio.AudioStreamInfo = {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_44100,
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      };
      const audioCapturerInfo: audio.AudioCapturerInfo = {
        source: audio.SourceType.SOURCE_TYPE_MIC,
        capturerFlags: 0
      };
      this.capturer = await audio.createAudioCapturer(audioCapturerInfo, audioStreamInfo);
      this.bufferSize = this.capturer.getBufferSize();
      return true;
    } catch (err) {
      promptAction.showToast({ message: 'Microphone init failed: ' + JSON.stringify(err) });
      return false;
    }
  }

  start(callback: (data: ArrayBuffer) => void): void {
    if (!this.capturer || this.isCapturing) return;
    this.captureCallback = callback;
    this.isCapturing = true;
    this.capturer.start();
    this.readLoop();
  }

  private async readLoop(): Promise<void> {
    while (this.isCapturing && this.capturer) {
      try {
        const data = await this.capturer.read(this.bufferSize, true);
        if (data && this.captureCallback) {
          this.captureCallback(data);
        }
      } catch (err) {
        break;
      }
    }
  }

  stop(): void {
    this.isCapturing = false;
    if (this.capturer) {
      this.capturer.stop();
    }
  }

  release(): void {
    this.isCapturing = false;
    if (this.capturer) {
      this.capturer.release();
      this.capturer = null;
    }
  }
}
