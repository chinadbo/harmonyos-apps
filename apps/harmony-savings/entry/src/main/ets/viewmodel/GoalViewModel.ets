import { Goal, GoalInput, GoalWithStats } from '../model/Goal'
import { DatabaseHelper } from '../database/DatabaseHelper'

export class GoalViewModel {
  private database: DatabaseHelper = DatabaseHelper.getInstance()

  async getGoals(): Promise<GoalWithStats[]> {
    return this.database.getGoalsWithStats()
  }

  async getGoal(goalId: number): Promise<Goal | null> {
    return this.database.getGoalById(goalId)
  }

  async saveGoal(input: GoalInput): Promise<number> {
    if (input.id !== undefined) {
      await this.database.updateGoal(input)
      return input.id
    }
    return this.database.createGoal(input)
  }

  async deleteGoal(goalId: number): Promise<void> {
    await this.database.deleteGoal(goalId)
  }

  getProgress(goal: Goal): number {
    if (goal.targetAmount <= 0) {
      return 0
    }
    return Math.min(goal.currentAmount / goal.targetAmount, 1)
  }

  formatCurrency(amountInCent: number): string {
    return `¥${(amountInCent / 100).toFixed(2)}`
  }
}
