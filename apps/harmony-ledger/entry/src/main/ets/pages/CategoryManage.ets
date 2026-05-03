import { Category, CategoryType } from '../data/DataModels';
import { CategoryRepo } from '../data/CategoryRepo';

const ICON_OPTIONS: string[] = ['🍔', '🚕', '📚', '🎬', '🏃', '🐱', '💳', '💡'];
const COLOR_OPTIONS: string[] = ['#FF7043', '#42A5F5', '#AB47BC', '#26A69A', '#EC407A', '#66BB6A', '#FFA726', '#5C6BC0'];

@Entry
@Component
struct CategoryManage {
  private categoryRepo: CategoryRepo = CategoryRepo.getInstance();
  @State categories: Category[] = [];
  @State name: string = '';
  @State iconIndex: number = 0;
  @State colorIndex: number = 0;
  @State typeIndex: number = 0;

  async aboutToAppear(): Promise<void> {
    await this.reload();
  }

  private async reload(): Promise<void> {
    this.categories = await this.categoryRepo.listAll();
  }

  private selectedType(): CategoryType {
    if (this.typeIndex === 1) {
      return 'income';
    }
    if (this.typeIndex === 2) {
      return 'both';
    }
    return 'expense';
  }

  private async addCategory(): Promise<void> {
    if (this.name.trim().length === 0) {
      return;
    }
    await this.categoryRepo.create({
      name: this.name.trim(),
      icon: ICON_OPTIONS[this.iconIndex],
      color: COLOR_OPTIONS[this.colorIndex],
      type: this.selectedType(),
      sortOrder: this.categories.length + 1
    });
    this.name = '';
    await this.reload();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('分类管理')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)

        Column({ space: 12 }) {
          TextInput({ placeholder: '分类名称', text: this.name })
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .onChange((value: string) => {
              this.name = value;
            })
          Text('图标')
            .fontSize(14)
            .fontColor('#616161')
            .width('100%')
            .textAlign(TextAlign.Start)
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(ICON_OPTIONS, (item: string, index: number) => {
              Button(item)
                .type(ButtonType.Capsule)
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.iconIndex === index ? '#5C6BC0' : '#E0E0E0')
                .fontColor(this.iconIndex === index ? Color.White : '#212121')
                .onClick(() => {
                  this.iconIndex = index;
                })
            }, (item: string, index: number) => `${item}-${index}`)
          }
          Text('颜色')
            .fontSize(14)
            .fontColor('#616161')
            .width('100%')
            .textAlign(TextAlign.Start)
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(COLOR_OPTIONS, (item: string, index: number) => {
              Row()
                .width(36)
                .height(36)
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(item)
                .borderRadius(18)
                .border({ width: this.colorIndex === index ? 3 : 0, color: '#212121' })
                .onClick(() => {
                  this.colorIndex = index;
                })
            }, (item: string, index: number) => `${item}-${index}`)
          }
          Text('类型')
            .fontSize(14)
            .fontColor('#616161')
            .width('100%')
            .textAlign(TextAlign.Start)
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(['支出', '收入', '通用'], (item: string, index: number) => {
              Button(item)
                .type(ButtonType.Capsule)
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.typeIndex === index ? '#5C6BC0' : '#E0E0E0')
                .fontColor(this.typeIndex === index ? Color.White : '#212121')
                .onClick(() => {
                  this.typeIndex = index;
                })
            }, (item: string, index: number) => `${item}-${index}`)
          }
          Button('新增分类')
            .width('100%')
            .backgroundColor('#5C6BC0')
            .fontColor(Color.White)
            .onClick(async () => {
              await this.addCategory();
            })
        }
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(24)

        ForEach(this.categories, (category: Category) => {
          Row() {
            Row() {
              Text(category.icon)
                .fontSize(22)
              Column({ space: 4 }) {
                Text(category.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                Text(category.isSystem ? '系统分类' : '自定义分类')
                  .fontSize(12)
                  .fontColor('#757575')
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
            }
            .layoutWeight(1)
            if (!category.isSystem) {
              Button('删除')
                .type(ButtonType.Capsule)
                .fontSize(12)
                .backgroundColor('#FDECEC')
                .fontColor('#D32F2F')
                .onClick(async () => {
                  await this.categoryRepo.delete(category.id);
                  await this.reload();
                })
            }
          }
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(16)
        }, (category: Category) => `${category.id}`)
      }
      .padding(16)
      .width('100%')
    }
    .backgroundColor('#F6F7FB')
  }
}
