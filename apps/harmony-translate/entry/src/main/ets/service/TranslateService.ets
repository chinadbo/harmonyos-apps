import { http } from '@ohos.net.http';
import { HttpUtil } from '../utils/HttpUtil';
import { DictEntry } from '../model/DictEntry';

export class TranslateService {
  private dictMap: Map<string, string> = new Map();
  private dictLoaded: boolean = false;

  async loadDictionary(context: Context): Promise<void> {
    if (this.dictLoaded) return;
    try {
      const rawFile = context.resourceManager.getRawFileContent('dict.json');
      const text = rawFile.toString();
      const entries: DictEntry[] = JSON.parse(text);
      entries.forEach(entry => {
        this.dictMap.set(entry.en.toLowerCase(), entry.zh);
      });
      this.dictLoaded = true;
    } catch (e) {
      console.error('Failed to load dictionary:', e);
    }
  }

  async translate(text: string, sourceLang: string, targetLang: string): Promise<string> {
    if (!text.trim()) return '';

    try {
      const url = `https://api.mymemory.translated.net/get?q=${encodeURIComponent(text)}&langpair=${sourceLang}|${targetLang}`;
      const result = await HttpUtil.request(url);
      const json = JSON.parse(result);
      if (json.responseStatus === 200 && json.responseData?.translatedText) {
        return json.responseData.translatedText;
      }
      throw new Error('API response invalid');
    } catch (e) {
      console.warn('Online translation failed, fallback to offline dict:', e);
      return this.offlineTranslate(text, sourceLang, targetLang);
    }
  }

  private offlineTranslate(text: string, sourceLang: string, targetLang: string): string {
    if (sourceLang === 'en' && targetLang === 'zh') {
      const lower = text.trim().toLowerCase();
      if (this.dictMap.has(lower)) {
        return this.dictMap.get(lower) as string;
      }
      const words = lower.split(/\s+/);
      const translated = words.map(w => this.dictMap.get(w) || w);
      return translated.join(' ');
    }
    if (sourceLang === 'zh' && targetLang === 'en') {
      for (const [en, zh] of this.dictMap.entries()) {
        if (zh === text.trim()) return en;
      }
      return text;
    }
    return text;
  }
}
