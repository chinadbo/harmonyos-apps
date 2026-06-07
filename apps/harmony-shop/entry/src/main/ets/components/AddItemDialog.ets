import promptAction from '@ohos.promptAction';
import { ShopDatabase } from '../database/ShopDatabase';
import { SHOPPING_LIST_CATEGORIES, ShoppingList, ShoppingListCategory } from '../model/ShoppingList';

@Component
export struct AddItemDialog {
  onSuccess?: () => void;
  onClose?: () => void;

  @State private name: string = '';
  @State private categoryIndex: number = 0;

  private async submit(): Promise<void> {
    const trimmedName = this.name.trim();
    if (!trimmedName.length) {
      promptAction.showToast({ message: '请输入清单名称' });
      return;
    }

    await ShopDatabase.getInstance().createList(
      new ShoppingList(0, trimmedName, SHOPPING_LIST_CATEGORIES[this.categoryIndex] as ShoppingListCategory, Date.now(), false)
    );

    if (this.onSuccess) {
      this.onSuccess();
    }
  }

  build() {
    Column({ space: 16 }) {
      Text('新建购物清单')
        .fontSize(22)
        .fontWeight(FontWeight.Medium)

      TextInput({ placeholder: '例如：周末采购', text: this.name })
        .onChange((value: string) => {
          this.name = value;
        })
        .height(52)
        .fontSize(18)

      Column({ space: 8 }) {
        Text('分类')
          .fontSize(16)
          .fontColor('#666666')
          .width('100%')
          .textAlign(TextAlign.Start)

        Select([{ value: '超市' }, { value: '菜市场' }, { value: '网购' }, { value: '其他' }])
          .selected(this.categoryIndex)
          .value(SHOPPING_LIST_CATEGORIES[this.categoryIndex])
          .onSelect((index: number) => {
            this.categoryIndex = index;
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor('#F1F3F5')
          .fontColor('#333333')
          .onClick(() => {
            if (this.onClose) {
              this.onClose();
            }
          })

        Button('保存')
          .layoutWeight(1)
          .backgroundColor('#4C9BFF')
          .fontColor('#FFFFFF')
          .onClick(() => {
            this.submit();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
