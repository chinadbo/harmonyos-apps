export class Task {
  id: number
  title: string
  note: string
  isCompleted: boolean
  createdAt: number
  updatedAt: number
  estimatedPomodoros: number
  completedPomodoros: number

  constructor(
    id: number = 0,
    title: string = '',
    note: string = '',
    isCompleted: boolean = false,
    createdAt: number = Date.now(),
    updatedAt: number = Date.now(),
    estimatedPomodoros: number = 1,
    completedPomodoros: number = 0
  ) {
    this.id = id
    this.title = title
    this.note = note
    this.isCompleted = isCompleted
    this.createdAt = createdAt
    this.updatedAt = updatedAt
    this.estimatedPomodoros = estimatedPomodoros
    this.completedPomodoros = completedPomodoros
  }

  static fromRow(row: Record<string, Object | number | string | boolean>): Task {
    return new Task(
      Number(row['id'] ?? 0),
      String(row['title'] ?? ''),
      String(row['note'] ?? ''),
      Number(row['is_completed'] ?? 0) === 1,
      Number(row['created_at'] ?? Date.now()),
      Number(row['updated_at'] ?? Date.now()),
      Number(row['estimated_pomodoros'] ?? 1),
      Number(row['completed_pomodoros'] ?? 0)
    )
  }
}
