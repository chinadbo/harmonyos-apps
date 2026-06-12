export class Deposit {
  id: number = 0
  goalId: number = 0
  amount: number = 0
  depositDate: string = ''
  note: string = ''
  createdAt: string = ''
}

export class DepositInput {
  goalId: number = 0
  amount: number = 0
  depositDate: string = ''
  note: string = ''
}
