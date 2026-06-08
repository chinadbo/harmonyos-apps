import { TaskDatabase } from '../database/TaskDatabase';
import { TaskItem, TaskStatus, getDefaultTask } from '../database/TaskModel';
import { CategoryItem } from '../database/CategoryModel';
import { ReminderService } from './ReminderService';

export class TaskService {
  private db: TaskDatabase;
  private reminderService: ReminderService;

  constructor() {
    this.db = TaskDatabase.getInstance();
    this.reminderService = new ReminderService();
  }

  async createTask(task: TaskItem): Promise<number> {
    task.createdAt = Date.now();
    task.updatedAt = Date.now();
    const taskId = await this.db.insertTask(task);
    if (taskId > 0 && task.dueDate > 0 && task.reminderTime > 0) {
      const reminderId = await this.reminderService.publishReminder(
        task.title,
        task.dueDate,
        task.reminderTime
      );
      if (reminderId >= 0) {
        task.id = taskId;
        task.reminderId = reminderId;
        await this.db.updateTask(task);
      }
    }
    return taskId;
  }

  async updateTask(task: TaskItem): Promise<number> {
    task.updatedAt = Date.now();
    // 取消旧提醒
    if (task.reminderId >= 0) {
      await this.reminderService.cancelReminder(task.reminderId);
      task.reminderId = -1;
    }
    // 设置新提醒
    if (task.dueDate > 0 && task.reminderTime > 0 && task.status !== TaskStatus.COMPLETED) {
      const reminderId = await this.reminderService.publishReminder(
        task.title,
        task.dueDate,
        task.reminderTime
      );
      if (reminderId >= 0) {
        task.reminderId = reminderId;
      }
    }
    return await this.db.updateTask(task);
  }

  async completeTask(task: TaskItem): Promise<number> {
    task.status = TaskStatus.COMPLETED;
    task.completedAt = Date.now();
    task.updatedAt = Date.now();
    if (task.reminderId >= 0) {
      await this.reminderService.cancelReminder(task.reminderId);
      task.reminderId = -1;
    }
    return await this.db.updateTask(task);
  }

  async deleteTask(task: TaskItem): Promise<number> {
    if (!task.id) return -1;
    if (task.reminderId >= 0) {
      await this.reminderService.cancelReminder(task.reminderId);
    }
    return await this.db.deleteTask(task.id);
  }

  async getAllTasks(): Promise<TaskItem[]> {
    return await this.db.queryAllTasks();
  }

  async getTasksByCategory(categoryId: number): Promise<TaskItem[]> {
    return await this.db.queryTasksByCategory(categoryId);
  }

  async getTodayTasks(): Promise<TaskItem[]> {
    return await this.db.queryTodayTasks();
  }

  async getPendingTasks(limit: number = 5): Promise<TaskItem[]> {
    return await this.db.queryPendingTasks(limit);
  }

  async searchTasks(keyword: string): Promise<TaskItem[]> {
    return await this.db.searchTasks(keyword);
  }

  async postponeTask(task: TaskItem, days: number): Promise<number> {
    if (task.dueDate > 0) {
      task.dueDate = task.dueDate + days * 24 * 60 * 60 * 1000;
    }
    return await this.updateTask(task);
  }

  // Category operations
  async getAllCategories(): Promise<CategoryItem[]> {
    return await this.db.queryAllCategories();
  }

  async createCategory(category: CategoryItem): Promise<number> {
    return await this.db.insertCategory(category);
  }

  async updateCategory(category: CategoryItem): Promise<number> {
    return await this.db.updateCategory(category);
  }

  async deleteCategory(categoryId: number): Promise<number> {
    return await this.db.deleteCategory(categoryId);
  }
}
