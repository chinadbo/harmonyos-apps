import { AchievementDef } from './Models';

export const ACHIEVEMENT_DEFS: AchievementDef[] = [
  { key: 'first_practice', label: '首次练习', icon: '启' },
  { key: 'streak_3', label: '连击3天', icon: '叁' },
  { key: 'streak_7', label: '连击7天', icon: '柒' },
  { key: 'total_100', label: '百题斩', icon: '百' },
  { key: 'total_1000', label: '千题王', icon: '千' },
  { key: 'perfect_10', label: '全对一轮', icon: '满' }
];

export function checkAchievements(recordCount: number, totalQuestions: number,
  streakDays: number, roundTotal: number, roundCorrect: number): string[] {
  const unlocked: string[] = [];
  if (recordCount >= 1) {
    unlocked.push('first_practice');
  }
  if (streakDays >= 3) {
    unlocked.push('streak_3');
  }
  if (streakDays >= 7) {
    unlocked.push('streak_7');
  }
  if (totalQuestions >= 100) {
    unlocked.push('total_100');
  }
  if (totalQuestions >= 1000) {
    unlocked.push('total_1000');
  }
  if (roundTotal >= 10 && roundTotal === roundCorrect) {
    unlocked.push('perfect_10');
  }
  return unlocked;
}
