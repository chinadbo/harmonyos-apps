import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ShopDatabase } from '../database/ShopDatabase';
import { ITEM_UNITS, ShoppingItem } from '../model/ShoppingItem';

const TEMPLATE_ITEMS: Array<{ name: string; category: string; unit: string }> = [
  { name: '苹果', category: '水果', unit: '斤' },
  { name: '牛奶', category: '饮品', unit: '盒' },
  { name: '纸巾', category: '日用品', unit: '包' },
  { name: '鸡蛋', category: '肉类', unit: '盒' }
];

const ITEM_CATEGORIES: string[] = ['蔬菜', '水果', '肉类', '饮品', '零食', '日用品', '其他'];

@Entry
@Component
struct AddItemPage {
  @State private listId: number = 0;
  @State private name: string = '';
  @State private quantity: number = 1;
  @State private unitIndex: number = 0;
  @State private categoryIndex: number = 6;
  @State private note: string = '';

  aboutToAppear() {
    this.listId = AppStorage.get<number>('currentListId') ?? 0;
  }

  private changeQuantity(delta: number): void {
    this.quantity = Math.max(1, this.quantity + delta);
  }

  private fillTemplate(index: number): void {
    const template = TEMPLATE_ITEMS[index];
    this.name = template.name;
    this.unitIndex = ITEM_UNITS.indexOf(template.unit);
    this.categoryIndex = Math.max(0, ITEM_CATEGORIES.indexOf(template.category));
  }

  private async saveItem(): Promise<void> {
    const trimmedName = this.name.trim();
    if (!trimmedName.length) {
      promptAction.showToast({ message: '请输入商品名称' });
      return;
    }

    await ShopDatabase.getInstance().createItem(
      new ShoppingItem(
        0,
        this.listId,
        trimmedName,
        this.quantity,
        ITEM_UNITS[this.unitIndex],
        ITEM_CATEGORIES[this.categoryIndex],
        false,
        Date.now(),
        this.note.trim()
      )
    );

    promptAction.showToast({ message: '已添加商品' });
    router.back();
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row({ space: 12 }) {
          Button('<')
            .width(40)
            .height(40)
            .fontSize(20)
            .backgroundColor('#FFFFFF')
            .fontColor('#333333')
            .onClick(() => {
              router.back();
            })

          Text('添加商品')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')

        Column({ space: 10 }) {
          Text('常用模板')
            .fontSize(16)
            .fontColor('#666666')
            .width('100%')
            .textAlign(TextAlign.Start)

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
            ForEach(TEMPLATE_ITEMS, (item: { name: string; category: string; unit: string }, index: number) => {
              Text(item.name)
                .fontSize(14)
                .fontColor('#4C9BFF')
                .backgroundColor('#EAF3FF')
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .borderRadius(16)
                .margin({ right: 10, bottom: 10 })
                .onClick(() => {
                  this.fillTemplate(index);
                })
            })
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Column({ space: 14 }) {
          Column({ space: 6 }) {
            Text('商品名称')
              .fontSize(16)
              .fontColor('#666666')
              .width('100%')
              .textAlign(TextAlign.Start)

            TextInput({ placeholder: '请输入商品名称', text: this.name })
              .onChange((value: string) => {
                this.name = value;
              })
              .height(52)
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('数量')
              .fontSize(16)
              .fontColor('#666666')
              .width('100%')
              .textAlign(TextAlign.Start)

            Row({ space: 12 }) {
              Button('-')
                .width(44)
                .height(44)
                .backgroundColor('#F1F3F5')
                .fontColor('#333333')
                .onClick(() => {
                  this.changeQuantity(-1);
                })

              Text(`${this.quantity}`)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .width(60)
                .textAlign(TextAlign.Center)

              Button('+')
                .width(44)
                .height(44)
                .backgroundColor('#F1F3F5')
                .fontColor('#333333')
                .onClick(() => {
                  this.changeQuantity(1);
                })
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 6 }) {
            Text('单位')
              .fontSize(16)
              .fontColor('#666666')
              .width('100%')
              .textAlign(TextAlign.Start)

            Select([
              { value: '个' },
              { value: '斤' },
              { value: '千克' },
              { value: '袋' },
              { value: '盒' },
              { value: '瓶' },
              { value: '包' }
            ])
              .selected(this.unitIndex)
              .value(ITEM_UNITS[this.unitIndex])
              .onSelect((index: number) => {
                this.unitIndex = index;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 6 }) {
            Text('分类')
              .fontSize(16)
              .fontColor('#666666')
              .width('100%')
              .textAlign(TextAlign.Start)

            Select([
              { value: '蔬菜' },
              { value: '水果' },
              { value: '肉类' },
              { value: '饮品' },
              { value: '零食' },
              { value: '日用品' },
              { value: '其他' }
            ])
              .selected(this.categoryIndex)
              .value(ITEM_CATEGORIES[this.categoryIndex])
              .onSelect((index: number) => {
                this.categoryIndex = index;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 6 }) {
            Text('备注')
              .fontSize(16)
              .fontColor('#666666')
              .width('100%')
              .textAlign(TextAlign.Start)

            TextInput({ placeholder: '选填', text: this.note })
              .onChange((value: string) => {
                this.note = value;
              })
              .height(88)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Button('保存商品')
          .width('100%')
          .height(52)
          .backgroundColor('#4C9BFF')
          .fontColor('#FFFFFF')
          .borderRadius(26)
          .onClick(() => {
            this.saveItem();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 24, bottom: 24 })
      .backgroundColor('#F5F7FA')
      .alignItems(HorizontalAlign.Start)
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }
}

export default AddItemPage;
