import { Step } from './RecipeModel';

export interface TimerState {
  recipeId: number;
  recipeName: string;
  currentStep: number;
  totalSteps: number;
  totalSeconds: number;
  remainingSeconds: number;
  isRunning: boolean;
}

export interface StepTimerPayload {
  recipeId: number;
  recipeName: string;
  steps: Step[];
}
