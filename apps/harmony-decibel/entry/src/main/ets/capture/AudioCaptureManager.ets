import audio from '@ohos.multimedia.audio';

class AudioCaptureManager {
  private audioCapturer: audio.AudioCapturer | null = null;
  private isCapturing: boolean = false;
  private onDataCallback: ((buffer: ArrayBuffer) => void) | null = null;

  async init(): Promise<boolean> {
    try {
      const streamInfo: audio.AudioStreamInfo = {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_44100,
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      };
      const capturerInfo: audio.AudioCapturerInfo = {
        source: audio.SourceType.SOURCE_TYPE_MIC,
        capturerFlags: 0
      };
      this.audioCapturer = await audio.createAudioCapturer(streamInfo, capturerInfo);
      console.info('AudioCapturer created successfully');
      return true;
    } catch (err) {
      console.error('Failed to create AudioCapturer:', err);
      return false;
    }
  }

  setOnDataCallback(callback: (buffer: ArrayBuffer) => void): void {
    this.onDataCallback = callback;
  }

  async start(): Promise<boolean> {
    if (!this.audioCapturer) {
      console.error('AudioCapturer not initialized');
      return false;
    }
    try {
      this.audioCapturer.on('readData', (buffer: ArrayBuffer) => {
        if (this.onDataCallback) {
          this.onDataCallback(buffer);
        }
      });
      await this.audioCapturer.start();
      this.isCapturing = true;
      console.info('Audio capture started');
      return true;
    } catch (err) {
      console.error('Failed to start audio capture:', err);
      return false;
    }
  }

  async stop(): Promise<void> {
    this.isCapturing = false;
    if (this.audioCapturer) {
      try {
        this.audioCapturer.off('readData');
        await this.audioCapturer.stop();
        console.info('Audio capture stopped');
      } catch (err) {
        console.error('Failed to stop audio capture:', err);
      }
    }
  }

  async release(): Promise<void> {
    await this.stop();
    if (this.audioCapturer) {
      try {
        await this.audioCapturer.release();
        this.audioCapturer = null;
        console.info('AudioCapturer released');
      } catch (err) {
        console.error('Failed to release AudioCapturer:', err);
      }
    }
  }

  getIsCapturing(): boolean {
    return this.isCapturing;
  }
}

export default new AudioCaptureManager();
