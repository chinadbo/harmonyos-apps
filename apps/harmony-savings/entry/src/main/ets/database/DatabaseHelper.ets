import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common'
import { Goal, GoalInput, GoalWithStats } from '../model/Goal'
import { Deposit, DepositInput } from '../model/Deposit'
import { DateUtils } from '../utils/DateUtils'

const DB_NAME: string = 'harmony_savings.db'
const DB_VERSION: number = 1

interface GoalRow {
  id: number
  name: string
  target_amount: number
  current_amount: number
  deadline: string
  note: string
  color: string
  created_at: string
  updated_at: string
  completed_at: string
}

interface DepositRow {
  id: number
  goal_id: number
  amount: number
  deposit_date: string
  note: string
  created_at: string
}

export class DatabaseHelper {
  private static instance: DatabaseHelper = new DatabaseHelper()
  private store: relationalStore.RdbStore | null = null

  private constructor() {
  }

  static getInstance(): DatabaseHelper {
    return DatabaseHelper.instance
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.store !== null) {
      return
    }

    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }

    this.store = await relationalStore.getRdbStore(context, config)

    await this.store.executeSql(`CREATE TABLE IF NOT EXISTS goals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      target_amount INTEGER NOT NULL,
      current_amount INTEGER NOT NULL DEFAULT 0,
      deadline TEXT NOT NULL,
      note TEXT NOT NULL DEFAULT '',
      color TEXT NOT NULL DEFAULT '#4F7DFF',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      completed_at TEXT NOT NULL DEFAULT ''
    )`)
    await this.store.executeSql(`CREATE TABLE IF NOT EXISTS deposits (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      goal_id INTEGER NOT NULL,
      amount INTEGER NOT NULL,
      deposit_date TEXT NOT NULL,
      note TEXT NOT NULL DEFAULT '',
      created_at TEXT NOT NULL,
      FOREIGN KEY(goal_id) REFERENCES goals(id) ON DELETE CASCADE
    )`)

    await this.store.executeSql('CREATE INDEX IF NOT EXISTS idx_deposits_goal_id ON deposits(goal_id)')
    await this.store.executeSql('CREATE INDEX IF NOT EXISTS idx_deposits_date ON deposits(deposit_date)')
  }

  private getStore(): relationalStore.RdbStore {
    if (this.store === null) {
      throw new Error('Database is not initialized')
    }
    return this.store
  }

  private mapGoal(row: GoalRow): Goal {
    const g = new Goal()
    g.id = row.id
    g.name = row.name
    g.targetAmount = row.target_amount
    g.currentAmount = row.current_amount
    g.deadline = row.deadline
    g.note = row.note
    g.color = row.color
    g.createdAt = row.created_at
    g.updatedAt = row.updated_at
    g.completedAt = row.completed_at
    return g
  }

  private mapDeposit(row: DepositRow): Deposit {
    const d = new Deposit()
    d.id = row.id
    d.goalId = row.goal_id
    d.amount = row.amount
    d.depositDate = row.deposit_date
    d.note = row.note
    d.createdAt = row.created_at
    return d
  }

  private cursorToGoals(resultSet: relationalStore.ResultSet): Goal[] {
    const list: Goal[] = []
    if (resultSet.rowCount === 0) {
      resultSet.close()
      return list
    }
    resultSet.goToFirstRow()
    do {
      list.push(this.mapGoal({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        target_amount: resultSet.getLong(resultSet.getColumnIndex('target_amount')),
        current_amount: resultSet.getLong(resultSet.getColumnIndex('current_amount')),
        deadline: resultSet.getString(resultSet.getColumnIndex('deadline')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        color: resultSet.getString(resultSet.getColumnIndex('color')),
        created_at: resultSet.getString(resultSet.getColumnIndex('created_at')),
        updated_at: resultSet.getString(resultSet.getColumnIndex('updated_at')),
        completed_at: resultSet.getString(resultSet.getColumnIndex('completed_at'))
      }))
    } while (resultSet.goToNextRow())
    resultSet.close()
    return list
  }

  private cursorToDeposits(resultSet: relationalStore.ResultSet): Deposit[] {
    const list: Deposit[] = []
    if (resultSet.rowCount === 0) {
      resultSet.close()
      return list
    }
    resultSet.goToFirstRow()
    do {
      list.push(this.mapDeposit({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        goal_id: resultSet.getLong(resultSet.getColumnIndex('goal_id')),
        amount: resultSet.getLong(resultSet.getColumnIndex('amount')),
        deposit_date: resultSet.getString(resultSet.getColumnIndex('deposit_date')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        created_at: resultSet.getString(resultSet.getColumnIndex('created_at'))
      }))
    } while (resultSet.goToNextRow())
    resultSet.close()
    return list
  }

  async getAllGoals(): Promise<Goal[]> {
    const resultSet: relationalStore.ResultSet = await this.getStore().querySql('SELECT * FROM goals ORDER BY updated_at DESC, id DESC')
    return this.cursorToGoals(resultSet)
  }

  async getGoalById(goalId: number): Promise<Goal | null> {
    const resultSet: relationalStore.ResultSet = await this.getStore().querySql(`SELECT * FROM goals WHERE id = ${goalId} LIMIT 1`)
    const goals: Goal[] = this.cursorToGoals(resultSet)
    return goals.length > 0 ? goals[0] : null
  }

  async getGoalsWithStats(): Promise<GoalWithStats[]> {
    const sql: string = `SELECT
      g.id,
      g.name,
      g.target_amount,
      g.current_amount,
      g.deadline,
      g.note,
      g.color,
      g.created_at,
      g.updated_at,
      g.completed_at,
      COUNT(d.id) AS deposit_count,
      COALESCE(MAX(d.deposit_date), '') AS last_deposit_date
      FROM goals g
      LEFT JOIN deposits d ON g.id = d.goal_id
      GROUP BY g.id
      ORDER BY g.updated_at DESC, g.id DESC`
    const resultSet: relationalStore.ResultSet = await this.getStore().querySql(sql)
    const list: GoalWithStats[] = []
    if (resultSet.rowCount === 0) {
      resultSet.close()
      return list
    }
    resultSet.goToFirstRow()
    do {
      const targetAmount: number = resultSet.getLong(resultSet.getColumnIndex('target_amount'))
      const currentAmount: number = resultSet.getLong(resultSet.getColumnIndex('current_amount'))
      list.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        targetAmount,
        currentAmount,
        deadline: resultSet.getString(resultSet.getColumnIndex('deadline')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        color: resultSet.getString(resultSet.getColumnIndex('color')),
        createdAt: resultSet.getString(resultSet.getColumnIndex('created_at')),
        updatedAt: resultSet.getString(resultSet.getColumnIndex('updated_at')),
        completedAt: resultSet.getString(resultSet.getColumnIndex('completed_at')),
        progress: targetAmount <= 0 ? 0 : Math.min(currentAmount / targetAmount, 1),
        remainingAmount: Math.max(targetAmount - currentAmount, 0),
        depositCount: resultSet.getLong(resultSet.getColumnIndex('deposit_count')),
        lastDepositDate: resultSet.getString(resultSet.getColumnIndex('last_deposit_date'))
      })
    } while (resultSet.goToNextRow())
    resultSet.close()
    return list
  }

  async createGoal(input: GoalInput): Promise<number> {
    const now: string = DateUtils.today()
    const values = {
      name: input.name,
      target_amount: input.targetAmount,
      current_amount: 0,
      deadline: input.deadline,
      note: input.note,
      color: input.color,
      created_at: now,
      updated_at: now,
      completed_at: ''
    }
    const rowId: number = await this.getStore().insert('goals', values)
    return rowId
  }

  async updateGoal(input: GoalInput): Promise<void> {
    if (input.id === undefined) {
      throw new Error('Goal id is required')
    }
    const goal: Goal | null = await this.getGoalById(input.id)
    if (goal === null) {
      throw new Error('Goal not found')
    }
    const currentAmount: number = goal.currentAmount
    const completedAt: string = currentAmount >= input.targetAmount ? DateUtils.today() : ''
    const predicates = new relationalStore.RdbPredicates('goals')
    predicates.equalTo('id', input.id)
    await this.getStore().update({
      name: input.name,
      target_amount: input.targetAmount,
      deadline: input.deadline,
      note: input.note,
      color: input.color,
      updated_at: DateUtils.today(),
      completed_at: completedAt
    }, predicates)
  }

  async deleteGoal(goalId: number): Promise<void> {
    const depositPredicates = new relationalStore.RdbPredicates('deposits')
    depositPredicates.equalTo('goal_id', goalId)
    await this.getStore().delete(depositPredicates)

    const goalPredicates = new relationalStore.RdbPredicates('goals')
    goalPredicates.equalTo('id', goalId)
    await this.getStore().delete(goalPredicates)
  }

  async getDepositsByGoalId(goalId: number): Promise<Deposit[]> {
    const resultSet: relationalStore.ResultSet = await this.getStore().querySql(`SELECT * FROM deposits WHERE goal_id = ${goalId} ORDER BY deposit_date DESC, id DESC`)
    return this.cursorToDeposits(resultSet)
  }

  async createDeposit(input: DepositInput): Promise<number> {
    const createdAt: string = DateUtils.today()
    const rowId: number = await this.getStore().insert('deposits', {
      goal_id: input.goalId,
      amount: input.amount,
      deposit_date: input.depositDate,
      note: input.note,
      created_at: createdAt
    })
    await this.syncGoalAmount(input.goalId)
    return rowId
  }

  async updateDeposit(deposit: Deposit): Promise<void> {
    if (deposit.id === undefined) {
      throw new Error('Deposit id is required')
    }
    const predicates = new relationalStore.RdbPredicates('deposits')
    predicates.equalTo('id', deposit.id)
    await this.getStore().update({
      amount: deposit.amount,
      deposit_date: deposit.depositDate,
      note: deposit.note
    }, predicates)
    await this.syncGoalAmount(deposit.goalId)
  }

  async deleteDeposit(goalId: number, depositId: number): Promise<void> {
    const predicates = new relationalStore.RdbPredicates('deposits')
    predicates.equalTo('id', depositId)
    await this.getStore().delete(predicates)
    await this.syncGoalAmount(goalId)
  }

  async getGoalWithDeposits(goalId: number): Promise<{ goal: Goal | null; deposits: Deposit[] }> {
    const goal: Goal | null = await this.getGoalById(goalId)
    const deposits: Deposit[] = await this.getDepositsByGoalId(goalId)
    return { goal, deposits }
  }

  async syncGoalAmount(goalId: number): Promise<void> {
    const sumResult: relationalStore.ResultSet = await this.getStore().querySql(`SELECT COALESCE(SUM(amount), 0) AS total_amount FROM deposits WHERE goal_id = ${goalId}`)
    let totalAmount: number = 0
    if (sumResult.rowCount > 0) {
      sumResult.goToFirstRow()
      totalAmount = sumResult.getLong(sumResult.getColumnIndex('total_amount'))
    }
    sumResult.close()

    const goal: Goal | null = await this.getGoalById(goalId)
    if (goal === null) {
      return
    }

    const completedAt: string = totalAmount >= goal.targetAmount ? DateUtils.today() : ''
    const predicates = new relationalStore.RdbPredicates('goals')
    predicates.equalTo('id', goalId)
    await this.getStore().update({
      current_amount: totalAmount,
      updated_at: DateUtils.today(),
      completed_at: completedAt
    }, predicates)
  }
}
