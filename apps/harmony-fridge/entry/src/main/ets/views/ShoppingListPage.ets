import { ShoppingEntry } from '../model/ShoppingEntry';
import { ShoppingDao } from '../database/ShoppingDao';
import { ShoppingItem } from '../components/ShoppingItem';
import { EmptyView } from '../components/EmptyView';

@Component
export struct ShoppingListPage {
  @State items: ShoppingEntry[] = [];
  private shoppingDao: ShoppingDao = new ShoppingDao();

  aboutToAppear(): void {
    this.reload();
  }

  private async reload(): Promise<void> {
    this.items = await this.shoppingDao.getAll();
  }

  private async toggle(entry: ShoppingEntry): Promise<void> {
    await this.shoppingDao.toggleCompleted(entry);
    await this.reload();
  }

  private async remove(entry: ShoppingEntry): Promise<void> {
    await this.shoppingDao.deleteById(entry.id);
    await this.reload();
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Text('购物清单')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#20331E')
      }
      .width('100%')
      if (this.items.length === 0) {
        EmptyView({ title: '购物清单为空', message: '从食材卡片中一键加入需要补货的项目' })
      } else {
        List({ space: 12 }) {
          ForEach(this.items, (entry: ShoppingEntry) => {
            ListItem() {
              ShoppingItem({
                entry,
                onToggle: (current: ShoppingEntry) => this.toggle(current),
                onDelete: (current: ShoppingEntry) => this.remove(current)
              })
            }
          }, (entry: ShoppingEntry) => `${entry.id}`)
        }
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F4F8F4')
  }
}
