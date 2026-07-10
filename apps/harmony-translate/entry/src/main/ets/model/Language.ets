export class Language {
  code: string;
  name: string;
  flag: string;

  constructor(code: string, name: string, flag: string) {
    this.code = code;
    this.name = name;
    this.flag = flag;
  }
}

export const LANGUAGES: Language[] = [
  new Language('zh', '中文', '🇨🇳'),
  new Language('en', 'English', '🇺🇸'),
  new Language('ja', '日本語', '🇯🇵'),
  new Language('ko', '한국어', '🇰🇷'),
  new Language('fr', 'Français', '🇫🇷'),
  new Language('de', 'Deutsch', '🇩🇪'),
  new Language('es', 'Español', '🇪🇸'),
  new Language('ru', 'Русский', '🇷🇺'),
];

export function getLanguageName(code: string): string {
  const lang = LANGUAGES.find(l => l.code === code);
  return lang ? lang.name : code;
}

export function getLanguageFlag(code: string): string {
  const lang = LANGUAGES.find(l => l.code === code);
  return lang ? lang.flag : '🌐';
}
