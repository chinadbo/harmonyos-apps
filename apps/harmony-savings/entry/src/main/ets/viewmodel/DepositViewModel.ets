import { DatabaseHelper } from '../database/DatabaseHelper'
import { Deposit, DepositInput } from '../model/Deposit'

export class DepositViewModel {
  private database: DatabaseHelper = DatabaseHelper.getInstance()

  async getDeposits(goalId: number): Promise<Deposit[]> {
    return this.database.getDepositsByGoalId(goalId)
  }

  async addDeposit(input: DepositInput): Promise<number> {
    return this.database.createDeposit(input)
  }

  async updateDeposit(deposit: Deposit): Promise<void> {
    await this.database.updateDeposit(deposit)
  }

  async deleteDeposit(goalId: number, depositId: number): Promise<void> {
    await this.database.deleteDeposit(goalId, depositId)
  }

  formatCurrency(amountInCent: number): string {
    return `¥${(amountInCent / 100).toFixed(2)}`
  }
}
