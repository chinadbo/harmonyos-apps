import router from '@ohos.router';
import { AddItemDialog } from '../components/AddItemDialog';
import { ShoppingListCard } from '../components/ShoppingListCard';
import { ShopDatabase } from '../database/ShopDatabase';
import { ShoppingList } from '../model/ShoppingList';

interface ListStats {
  total: number;
  completed: number;
}

@Entry
@Component
struct Index {
  @State private lists: ShoppingList[] = [];
  @State private stats: Record<number, ListStats> = {};
  @State private showAddDialog: boolean = false;

  aboutToAppear() {
    this.loadLists();
  }

  private async loadLists(): Promise<void> {
    const db = ShopDatabase.getInstance();
    const lists = await db.getLists();
    const nextStats: Record<number, ListStats> = {};

    for (let i = 0; i < lists.length; i++) {
      const list = lists[i];
      nextStats[list.id] = {
        total: await db.getTotalCount(list.id),
        completed: await db.getCompletedCount(list.id)
      };
    }

    this.lists = lists;
    this.stats = nextStats;
  }

  private openList(list: ShoppingList): void {
    AppStorage.SetOrCreate('currentListId', list.id);
    AppStorage.SetOrCreate('currentListName', list.name);
    router.pushUrl({ url: 'pages/ListDetailPage' });
  }

  private async deleteList(id: number): Promise<void> {
    await ShopDatabase.getInstance().deleteList(id);
    this.loadLists();
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column({ space: 16 }) {
        Row() {
          Text('购物清单')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)

          Text(`共 ${this.lists.length} 个`)
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')

        if (this.lists.length === 0) {
          Column({ space: 10 }) {
            Text('还没有购物清单')
              .fontSize(20)
              .fontColor('#333333')

            Text('点击右下角按钮开始创建')
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .height('70%')
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 14 }) {
            ForEach(this.lists, (list: ShoppingList) => {
              ListItem() {
                ShoppingListCard({
                  list,
                  totalCount: this.stats[list.id]?.total ?? 0,
                  completedCount: this.stats[list.id]?.completed ?? 0,
                  onClick: () => {
                    this.openList(list);
                  }
                })
              }
              .swipeAction({
                end: {
                  builder: () => {
                    Button('删除')
                      .width(72)
                      .height('100%')
                      .backgroundColor('#FF5A5A')
                      .fontColor('#FFFFFF')
                      .onClick(() => {
                        this.deleteList(list.id);
                      })
                  }
                }
              })
            }, (list: ShoppingList) => `${list.id}`)
          }
          .width('100%')
          .layoutWeight(1)
          .divider({ strokeWidth: 0 })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 20, right: 20, top: 24, bottom: 24 })
      .backgroundColor('#F5F7FA')
      .alignItems(HorizontalAlign.Start)

      if (this.showAddDialog) {
        Column() {
          Blank()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#66000000')
        .onClick(() => {
          this.showAddDialog = false;
        })

        Column() {
          AddItemDialog({
            onClose: () => {
              this.showAddDialog = false;
            },
            onSuccess: () => {
              this.showAddDialog = false;
              this.loadLists();
            }
          })
        }
        .width('84%')
        .padding(0)
        .margin({ bottom: 120 })
      }

      Button('+')
        .width(56)
        .height(56)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#4C9BFF')
        .fontColor('#FFFFFF')
        .borderRadius(28)
        .margin({ right: 24, bottom: 24 })
        .onClick(() => {
          this.showAddDialog = true;
        })
    }
    .width('100%')
    .height('100%')
  }
}
