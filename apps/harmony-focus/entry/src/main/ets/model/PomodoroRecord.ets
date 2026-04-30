import { SessionMode } from '../common/Constants'

export class PomodoroRecord {
  id: number
  taskId: number
  mode: SessionMode
  durationSeconds: number
  startTime: number
  endTime: number
  completed: boolean
  dateKey: string

  constructor(
    id: number = 0,
    taskId: number = 0,
    mode: SessionMode = SessionMode.FOCUS,
    durationSeconds: number = 0,
    startTime: number = Date.now(),
    endTime: number = Date.now(),
    completed: boolean = true,
    dateKey: string = ''
  ) {
    this.id = id
    this.taskId = taskId
    this.mode = mode
    this.durationSeconds = durationSeconds
    this.startTime = startTime
    this.endTime = endTime
    this.completed = completed
    this.dateKey = dateKey
  }

  static fromRow(row: Record<string, Object | number | string | boolean>): PomodoroRecord {
    return new PomodoroRecord(
      Number(row['id'] ?? 0),
      Number(row['task_id'] ?? 0),
      String(row['mode'] ?? SessionMode.FOCUS) as SessionMode,
      Number(row['duration_seconds'] ?? 0),
      Number(row['start_time'] ?? Date.now()),
      Number(row['end_time'] ?? Date.now()),
      Number(row['completed'] ?? 0) === 1,
      String(row['date_key'] ?? '')
    )
  }
}
