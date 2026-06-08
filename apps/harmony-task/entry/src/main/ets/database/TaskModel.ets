export interface TaskItem {
  id?: number;
  title: string;
  description: string;
  categoryId: number;
  priority: number; // 0=低 1=中 2=高
  status: number; // 0=待办 1=进行中 2=已完成
  dueDate: number; // timestamp ms
  reminderTime: number; // 提前提醒分钟数
  reminderId: number; // 系统提醒ID，-1表示无提醒
  createdAt: number;
  updatedAt: number;
  completedAt: number;
}

export enum TaskPriority {
  LOW = 0,
  MEDIUM = 1,
  HIGH = 2
}

export enum TaskStatus {
  TODO = 0,
  IN_PROGRESS = 1,
  COMPLETED = 2
}

export function getDefaultTask(): TaskItem {
  const now = Date.now();
  return {
    title: '',
    description: '',
    categoryId: 0,
    priority: TaskPriority.MEDIUM,
    status: TaskStatus.TODO,
    dueDate: 0,
    reminderTime: 15,
    reminderId: -1,
    createdAt: now,
    updatedAt: now,
    completedAt: 0
  };
}
