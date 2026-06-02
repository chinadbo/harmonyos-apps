import promptAction from '@ohos.promptAction';
import { FoodItem } from '../model/FoodItem';
import { FoodItemDao } from '../database/FoodItemDao';
import { ShoppingDao } from '../database/ShoppingDao';
import { FoodDataSource } from '../common/FoodDataSource';
import { Constants } from '../common/Constants';
import { FoodItemCard } from '../components/FoodItemCard';
import { ExpiryBanner } from '../components/ExpiryBanner';
import { CategoryFilter } from '../components/CategoryFilter';
import { EmptyView } from '../components/EmptyView';
import { ItemEditPage } from './ItemEditPage';
import { ExpiryChecker } from '../service/ExpiryChecker';

@Component
export struct FridgeHomePage {
  @StorageProp(Constants.STORAGE_EXPIRED) expiredCount: number = 0;
  @StorageProp(Constants.STORAGE_EXPIRING) expiringSoonCount: number = 0;
  @State selectedCategory: string = Constants.ALL_CATEGORY;
  @State items: FoodItem[] = [];
  @State editingItem: FoodItem = FoodItem.createEmpty();
  @State showEditor: boolean = false;
  private foodItemDao: FoodItemDao = new FoodItemDao();
  private shoppingDao: ShoppingDao = new ShoppingDao();
  private dataSource: FoodDataSource = new FoodDataSource();

  aboutToAppear(): void {
    this.reload();
  }

  private async reload(): Promise<void> {
    const allItems: FoodItem[] = await this.foodItemDao.getAll();
    this.items = allItems;
    this.dataSource.setData(allItems);
  }

  private filteredItems(): FoodItem[] {
    if (this.selectedCategory === Constants.ALL_CATEGORY) {
      return this.items;
    }
    return this.items.filter((item: FoodItem) => item.category === this.selectedCategory);
  }

  private openCreate(): void {
    this.editingItem = FoodItem.createEmpty();
    this.showEditor = true;
  }

  private openEdit(item: FoodItem): void {
    this.editingItem = new FoodItem(item);
    this.showEditor = true;
  }

  private async removeItem(item: FoodItem): Promise<void> {
    await this.foodItemDao.deleteById(item.id);
    await ExpiryChecker.getInstance().refreshAll();
    await this.reload();
  }

  private async addToShopping(item: FoodItem): Promise<void> {
    await this.shoppingDao.createFromFood(item);
    promptAction.showToast({ message: `${item.name} 已加入购物清单` });
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column({ space: 16 }) {
        ExpiryBanner({
          expiredCount: this.expiredCount,
          expiringSoonCount: this.expiringSoonCount
        })
        CategoryFilter({ selectedCategory: $selectedCategory })
        if (this.filteredItems().length === 0) {
          EmptyView({ title: '冰箱还是空的', message: '添加食材后就能查看临期提醒和统计信息' })
        } else {
          List({ space: 12 }) {
            ForEach(this.filteredItems(), (item: FoodItem) => {
              ListItem() {
                FoodItemCard({
                  item,
                  onEdit: (selected: FoodItem) => this.openEdit(selected),
                  onDelete: (selected: FoodItem) => this.removeItem(selected),
                  onAddToShopping: (selected: FoodItem) => this.addToShopping(selected)
                })
              }
            }, (item: FoodItem) => `${item.id}`)
          }
          .layoutWeight(1)
          .divider({ strokeWidth: 0 })
        }
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .backgroundColor('#F4F8F4')

      Button('+')
        .width(56)
        .height(56)
        .fontSize(28)
        .backgroundColor('#5E8E5A')
        .borderRadius(28)
        .margin({ right: 20, bottom: 20 })
        .onClick(() => {
          this.openCreate();
        })
    }
    .bindSheet($$this.showEditor, {
      builder: () => {
        ItemEditPage({
          item: this.editingItem,
          onSaved: async () => {
            this.showEditor = false;
            await this.reload();
          }
        })
      },
      height: SheetSize.MEDIUM
    })
  }
}
