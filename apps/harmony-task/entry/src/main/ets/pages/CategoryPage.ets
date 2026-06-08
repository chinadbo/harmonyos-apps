import router from '@ohos.router';
import { CategoryItem } from '../database/CategoryModel';
import { TaskService } from '../services/TaskService';

const PRESET_COLORS: string[] = [
  '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
  '#DDA0DD', '#FF7F50', '#87CEEB', '#98FB98', '#FFB6C1'
];

@Entry
@Component
struct CategoryPage {
  @State categories: CategoryItem[] = [];
  @State showAddDialog: boolean = false;
  @State editingCategory: CategoryItem | null = null;
  @State newName: string = '';
  @State newColor: string = '#FF6B6B';
  private taskService: TaskService = new TaskService();

  async aboutToAppear(): Promise<void> {
    await this.loadCategories();
  }

  async loadCategories(): Promise<void> {
    this.categories = await this.taskService.getAllCategories();
  }

  async saveCategory(): Promise<void> {
    if (!this.newName.trim()) return;
    if (this.editingCategory && this.editingCategory.id) {
      this.editingCategory.name = this.newName;
      this.editingCategory.color = this.newColor;
      await this.taskService.updateCategory(this.editingCategory);
    } else {
      const cat: CategoryItem = {
        name: this.newName,
        color: this.newColor,
        sortOrder: this.categories.length,
        createdAt: Date.now()
      };
      await this.taskService.createCategory(cat);
    }
    this.showAddDialog = false;
    this.newName = '';
    this.newColor = '#FF6B6B';
    this.editingCategory = null;
    await this.loadCategories();
  }

  async deleteCategory(category: CategoryItem): Promise<void> {
    if (category.id) {
      await this.taskService.deleteCategory(category.id);
      await this.loadCategories();
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })

        Text('分类管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 12 })

        Blank()

        Image($r('sys.media.ohos_ic_public_add'))
          .width(24)
          .height(24)
          .fillColor('#4ECDC4')
          .onClick(() => {
            this.editingCategory = null;
            this.newName = '';
            this.newColor = '#FF6B6B';
            this.showAddDialog = true;
          })
      }
      .width('100%')
      .padding(16)

      // 分类列表
      List({ space: 8 }) {
        ForEach(this.categories, (cat: CategoryItem) => {
          ListItem() {
            Row() {
              Circle()
                .width(16)
                .height(16)
                .fill(cat.color)

              Text(cat.name)
                .fontSize(16)
                .fontColor('#333333')
                .margin({ left: 12 })
                .layoutWeight(1)

              Image($r('sys.media.ohos_ic_public_edit'))
                .width(20)
                .height(20)
                .fillColor('#999999')
                .margin({ right: 16 })
                .onClick(() => {
                  this.editingCategory = cat;
                  this.newName = cat.name;
                  this.newColor = cat.color;
                  this.showAddDialog = true;
                })

              Image($r('sys.media.ohos_ic_public_delete'))
                .width(20)
                .height(20)
                .fillColor('#FF4757')
                .onClick(() => {
                  this.deleteCategory(cat);
                })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
          }
        }, (cat: CategoryItem) => cat.id!.toString())
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })

      // 新建/编辑对话框
      if (this.showAddDialog) {
        Column() {
          Column() {
            Text(this.editingCategory ? '编辑分类' : '新建分类')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 16 })

            TextInput({ placeholder: '分类名称', text: this.newName })
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(12)
              .onChange((value: string) => {
                this.newName = value;
              })

            Text('选择颜色')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 16, bottom: 8 })

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(PRESET_COLORS, (color: string) => {
                Stack() {
                  Circle()
                    .width(36)
                    .height(36)
                    .fill(color)

                  if (this.newColor === color) {
                    Image($r('sys.media.ohos_ic_public_ok'))
                      .width(16)
                      .height(16)
                      .fillColor(Color.White)
                  }
                }
                .margin({ right: 12, bottom: 12 })
                .onClick(() => {
                  this.newColor = color;
                })
              }, (color: string) => color)
            }

            Row() {
              Button('取消')
                .fontColor('#666666')
                .backgroundColor('#F0F0F0')
                .borderRadius(20)
                .layoutWeight(1)
                .onClick(() => {
                  this.showAddDialog = false;
                })

              Button('保存')
                .fontColor(Color.White)
                .backgroundColor('#4ECDC4')
                .borderRadius(20)
                .layoutWeight(1)
                .margin({ left: 12 })
                .onClick(() => {
                  this.saveCategory();
                })
            }
            .width('100%')
            .margin({ top: 20 })
          }
          .width('85%')
          .padding(24)
          .backgroundColor(Color.White)
          .borderRadius(16)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#66000000')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .position({ x: 0, y: 0 })
        .onClick(() => {
          this.showAddDialog = false;
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}
