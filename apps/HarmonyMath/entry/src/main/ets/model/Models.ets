export interface Question {
  stem: string;
  answer: number;
}

export interface WrongItem {
  stem: string;
  answer: number;
  userAnswer: number;
}

export interface PracticeParams {
  mode?: string;
  difficulty?: number;
  limitSec?: number;
}

export interface ResultParams {
  mode?: string;
  difficulty?: number;
  limitSec?: number;
  total?: number;
  correct?: number;
  durationSec?: number;
  wrongItems?: WrongItem[];
}

export interface AchievementDef {
  key: string;
  label: string;
  icon: string;
}
