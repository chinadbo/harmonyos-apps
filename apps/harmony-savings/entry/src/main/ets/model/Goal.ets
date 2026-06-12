export class Goal {
  id: number = 0
  name: string = ''
  targetAmount: number = 0
  currentAmount: number = 0
  deadline: string = ''
  note: string = ''
  color: string = '#4F7DFF'
  createdAt: string = ''
  updatedAt: string = ''
  completedAt: string = ''
}

export class GoalWithStats extends Goal {
  progress: number = 0
  remainingAmount: number = 0
  depositCount: number = 0
  lastDepositDate: string = ''
}

export class GoalInput {
  id: number = 0
  name: string = ''
  targetAmount: number = 0
  deadline: string = ''
  note: string = ''
  color: string = '#4F7DFF'
}
