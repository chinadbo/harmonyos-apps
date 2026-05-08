import textToSpeech from '@ohos.ai.textToSpeech';

let ttsEngine: textToSpeech.TextToSpeechEngine | null = null;
let ttsAvailable = false;

export class TtsService {
  private static instance: TtsService;
  private enabled: boolean = true;

  static getInstance(): TtsService {
    if (!TtsService.instance) {
      TtsService.instance = new TtsService();
    }
    return TtsService.instance;
  }

  async init(): Promise<void> {
    // canIUse 门控
    if (!canIUse('SystemCapability.AI.TextToSpeech')) {
      ttsAvailable = false;
      return;
    }
    try {
      const params: textToSpeech.CreateEngineParams = {
        language: 'en-US',
        person: 0,
        online: 0
      };
      ttsEngine = await textToSpeech.createEngine(params);
      ttsAvailable = true;
    } catch (e) {
      ttsAvailable = false;
    }
  }

  setEnabled(enabled: boolean): void {
    this.enabled = enabled;
  }

  isAvailable(): boolean {
    return ttsAvailable && this.enabled;
  }

  async speak(text: string): Promise<void> {
    if (!this.isAvailable() || !ttsEngine) {
      return;
    }
    try {
      const params: textToSpeech.SpeakParams = {
        requestId: `flash_${Date.now()}`
      };
      ttsEngine.speak(text, params);
    } catch (e) {
      // 静默降级
    }
  }

  async stop(): Promise<void> {
    if (ttsEngine) {
      try {
        ttsEngine.stop();
      } catch (e) {
        // ignore
      }
    }
  }

  async release(): Promise<void> {
    if (ttsEngine) {
      try {
        ttsEngine.shutdown();
      } catch (e) {
        // ignore
      }
      ttsEngine = null;
      ttsAvailable = false;
    }
  }
}
