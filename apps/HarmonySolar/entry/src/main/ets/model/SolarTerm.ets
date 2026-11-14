export interface Poem {
  title: string;
  author: string;
  content: string;
}

export interface SolarTerm {
  id: string;
  name: string;
  en: string;
  season: string;
  date: string;
  year: number;
  julianDay: number;
  description: string;
  yuxiang: string[];
  customs: string[];
  healthTips: string[];
  poem: Poem;
  taboos: string[];
  suitable: string[];
}

export interface TermDateEntry {
  name: string;
  en: string;
  season: string;
  date: string;
}

export interface TermDetailInfo {
  name: string;
  description: string;
  yuxiang: string[];
  customs: string[];
  healthTips: string[];
  poem: Poem;
  taboos: string[];
  suitable: string[];
}

export interface TermFile {
  terms: TermDateEntry[];
  details: TermDetailInfo[];
}

export interface TimelineItem {
  key: string;
  kind: string;
  season: string;
  year: number;
  term: SolarTerm;
}

export function emptySolarTerm(): SolarTerm {
  const term: SolarTerm = {
    id: '',
    name: '',
    en: '',
    season: '冬',
    date: '',
    year: 0,
    julianDay: 0,
    description: '',
    yuxiang: [],
    customs: [],
    healthTips: [],
    taboos: [],
    suitable: [],
    poem: {
      title: '',
      author: '',
      content: ''
    }
  };
  return term;
}
