import router from '@ohos.router';
import { TaskItem, TaskStatus } from '../database/TaskModel';
import { CategoryItem } from '../database/CategoryModel';
import { TaskDatabase } from '../database/TaskDatabase';
import { TaskService } from '../services/TaskService';
import { TaskCard } from '../components/TaskCard';
import { CategoryTag } from '../components/CategoryTag';
import { EmptyState } from '../components/EmptyState';

@Entry
@Component
struct Index {
  @State tasks: TaskItem[] = [];
  @State categories: CategoryItem[] = [];
  @State selectedCategoryId: number = -1; // -1 = 全部
  @State searchKeyword: string = '';
  @State isSearching: boolean = false;
  @State currentTab: number = 0;
  private taskService: TaskService = new TaskService();

  async aboutToAppear(): Promise<void> {
    const db = TaskDatabase.getInstance();
    await db.initialize(getContext(this));
    await this.loadData();
  }

  async loadData(): Promise<void> {
    this.categories = await this.taskService.getAllCategories();
    if (this.searchKeyword) {
      this.tasks = await this.taskService.searchTasks(this.searchKeyword);
    } else if (this.selectedCategoryId >= 0) {
      this.tasks = await this.taskService.getTasksByCategory(this.selectedCategoryId);
    } else {
      this.tasks = await this.taskService.getAllTasks();
    }
  }

  private getCategoryInfo(categoryId: number): CategoryItem | undefined {
    return this.categories.find(c => c.id === categoryId);
  }

  build() {
    Column() {
      // Header
      Row() {
        Text('鸿蒙待办')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Image($r('sys.media.ohos_ic_public_search_filled'))
          .width(24)
          .height(24)
          .fillColor('#666666')
          .onClick(() => {
            this.isSearching = !this.isSearching;
            if (!this.isSearching) {
              this.searchKeyword = '';
              this.loadData();
            }
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      // 搜索栏
      if (this.isSearching) {
        Row() {
          TextInput({ placeholder: '搜索任务...', text: this.searchKeyword })
            .layoutWeight(1)
            .height(40)
            .backgroundColor('#F5F5F5')
            .borderRadius(20)
            .onChange((value: string) => {
              this.searchKeyword = value;
              this.loadData();
            })
        }
        .padding({ left: 16, right: 16, bottom: 8 })
      }

      // 分类筛选
      Scroll() {
        Row() {
          CategoryTag({
            name: '全部',
            color: '#666666',
            selected: this.selectedCategoryId === -1,
            onTap: () => {
              this.selectedCategoryId = -1;
              this.loadData();
            }
          })

          ForEach(this.categories, (cat: CategoryItem) => {
            CategoryTag({
              name: cat.name,
              color: cat.color,
              selected: this.selectedCategoryId === cat.id,
              onTap: () => {
                this.selectedCategoryId = cat.id!;
                this.loadData();
              }
            })
              .margin({ left: 8 })
          }, (cat: CategoryItem) => cat.id!.toString())
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: 16, right: 16, bottom: 12 })

      // 任务列表
      if (this.tasks.length === 0) {
        EmptyState({ message: '暂无任务，点击下方按钮添加', icon: '✨' })
      } else {
        List({ space: 12 }) {
          ForEach(this.tasks, (task: TaskItem) => {
            ListItem() {
              TaskCard({
                title: task.title,
                description: task.description,
                priority: task.priority,
                status: task.status,
                dueDate: task.dueDate,
                categoryName: this.getCategoryInfo(task.categoryId)?.name || '',
                categoryColor: this.getCategoryInfo(task.categoryId)?.color || '#999999',
                onComplete: () => {
                  this.taskService.completeTask(task).then(() => {
                    this.loadData();
                  });
                },
                onTap: () => {
                  router.pushUrl({
                    url: 'pages/TaskEditPage',
                    params: { taskId: task.id }
                  });
                }
              })
            }
          }, (task: TaskItem) => task.id!.toString())
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }

      // 底部导航
      Row() {
        Column() {
          Image($r('sys.media.ohos_ic_public_home'))
            .width(24).height(24).fillColor('#4ECDC4')
          Text('全部').fontSize(10).fontColor('#4ECDC4').margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Image($r('sys.media.ohos_ic_public_clock'))
            .width(24).height(24).fillColor('#666666')
          Text('今日').fontSize(10).fontColor('#666666').margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          router.pushUrl({ url: 'pages/TodayPage' });
        })

        Column() {
          Stack() {
            Circle().width(48).height(48).fill('#4ECDC4')
            Text('+').fontSize(28).fontColor(Color.White)
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          router.pushUrl({ url: 'pages/TaskEditPage' });
        })

        Column() {
          Image($r('sys.media.ohos_ic_public_drawer'))
            .width(24).height(24).fillColor('#666666')
          Text('统计').fontSize(10).fontColor('#666666').margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          router.pushUrl({ url: 'pages/StatsPage' });
        })

        Column() {
          Image($r('sys.media.ohos_ic_public_settings'))
            .width(24).height(24).fillColor('#666666')
          Text('设置').fontSize(10).fontColor('#666666').margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          router.pushUrl({ url: 'pages/SettingsPage' });
        })
      }
      .width('100%')
      .height(60)
      .padding({ top: 8, bottom: 8 })
      .backgroundColor(Color.White)
      .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: -2 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}
