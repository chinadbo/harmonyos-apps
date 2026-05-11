import { DiaryMood, MoodOption } from '../model/DiaryModel';

const MOOD_OPTIONS: MoodOption[] = [
  { mood: DiaryMood.Happy, label: '开心', shortLabel: '开心', icon: '☺', color: '#F59E0B', textColor: '#7C2D12' },
  { mood: DiaryMood.Calm, label: '平静', shortLabel: '平静', icon: '☁', color: '#60A5FA', textColor: '#1E3A8A' },
  { mood: DiaryMood.Sad, label: '低落', shortLabel: '低落', icon: '☂', color: '#818CF8', textColor: '#312E81' },
  { mood: DiaryMood.Angry, label: '烦躁', shortLabel: '烦躁', icon: '⚡', color: '#F87171', textColor: '#7F1D1D' },
  { mood: DiaryMood.Excited, label: '兴奋', shortLabel: '兴奋', icon: '✦', color: '#EC4899', textColor: '#831843' },
  { mood: DiaryMood.Anxious, label: '焦虑', shortLabel: '焦虑', icon: '◌', color: '#A78BFA', textColor: '#4C1D95' },
  { mood: DiaryMood.Grateful, label: '感恩', shortLabel: '感恩', icon: '❤', color: '#34D399', textColor: '#064E3B' }
];

export function getMoodOptions(): MoodOption[] {
  return MOOD_OPTIONS;
}

export function getMoodOption(mood: DiaryMood): MoodOption {
  const option = MOOD_OPTIONS.find((item: MoodOption) => item.mood === mood);
  return option ?? MOOD_OPTIONS[0];
}
