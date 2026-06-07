import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ProgressBar } from '../components/ProgressBar';
import { ShoppingItemRow } from '../components/ShoppingItemRow';
import { ShopDatabase } from '../database/ShopDatabase';
import { ShoppingItem } from '../model/ShoppingItem';

@Entry
@Component
struct ListDetailPage {
  @State private listId: number = 0;
  @State private listName: string = '';
  @State private items: ShoppingItem[] = [];
  @State private completedCount: number = 0;
  @State private totalCount: number = 0;

  aboutToAppear() {
    this.listId = AppStorage.get<number>('currentListId') ?? 0;
    this.listName = AppStorage.get<string>('currentListName') ?? '购物清单';
    this.loadItems();
  }

  private async loadItems(): Promise<void> {
    const db = ShopDatabase.getInstance();
    this.items = await db.getItemsByListId(this.listId);
    this.completedCount = await db.getCompletedCount(this.listId);
    this.totalCount = await db.getTotalCount(this.listId);
  }

  private async toggleItem(id: number, value: boolean): Promise<void> {
    await ShopDatabase.getInstance().toggleItemComplete(id, value);
    this.loadItems();
  }

  private async deleteItem(id: number): Promise<void> {
    await ShopDatabase.getInstance().deleteItem(id);
    promptAction.showToast({ message: '已删除商品' });
    this.loadItems();
  }

  private goToAddItemPage(): void {
    AppStorage.SetOrCreate('currentListId', this.listId);
    router.pushUrl({ url: 'pages/AddItemPage' });
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column({ space: 16 }) {
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

          Column({ space: 4 }) {
            Text(this.listName)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)

            Text('采购明细')
              .fontSize(14)
              .fontColor('#666666')
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')

        ProgressBar({ total: this.totalCount, completed: this.completedCount })

        if (this.items.length === 0) {
          Column({ space: 8 }) {
            Text('清单里还没有商品')
              .fontSize(20)
              .fontColor('#333333')

            Text('点击右下角添加第一项')
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 12 }) {
            ForEach(this.items, (item: ShoppingItem) => {
              ListItem() {
                ShoppingItemRow({
                  item,
                  onToggle: (id: number, value: boolean) => {
                    this.toggleItem(id, value);
                  },
                  onDelete: (id: number) => {
                    this.deleteItem(id);
                  }
                })
              }
            }, (item: ShoppingItem) => `${item.id}`)
          }
          .layoutWeight(1)
          .width('100%')
          .divider({ strokeWidth: 0 })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 20, right: 20, top: 24, bottom: 24 })
      .backgroundColor('#F5F7FA')
      .alignItems(HorizontalAlign.Start)

      Button('+ 添加商品')
        .height(52)
        .backgroundColor('#4C9BFF')
        .fontColor('#FFFFFF')
        .borderRadius(26)
        .margin({ right: 24, bottom: 24 })
        .onClick(() => {
          this.goToAddItemPage();
        })
    }
    .width('100%')
    .height('100%')
  }
}

export default ListDetailPage;
