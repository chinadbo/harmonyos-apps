export class TranslateRecord {
  id: number = -1;
  sourceText: string = '';
  resultText: string = '';
  sourceLang: string = 'zh';
  targetLang: string = 'en';
  isFavorite: boolean = false;
  createdAt: number = Date.now();

  constructor(sourceText: string, resultText: string, sourceLang: string, targetLang: string) {
    this.sourceText = sourceText;
    this.resultText = resultText;
    this.sourceLang = sourceLang;
    this.targetLang = targetLang;
  }
}
