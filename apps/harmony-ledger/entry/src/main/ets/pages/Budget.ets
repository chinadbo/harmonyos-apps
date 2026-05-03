import { BudgetViewModel } from '../viewmodel/BudgetViewModel';
import { BudgetStatus, Category } from '../data/DataModels';
import { BudgetProgress } from '../components/BudgetProgress';

@Entry
@Component
struct Budget {
  private viewModel: BudgetViewModel = new BudgetViewModel();
  @State statuses: BudgetStatus[] = [];
  @State categories: Category[] = [];
  @State selectedCategoryId: number = 1;
  @State budgetAmount: string = '';
  @State currency: string = '¥';

  async aboutToAppear(): Promise<void> {
    await this.reload();
  }

  private async reload(): Promise<void> {
    await this.viewModel.load();
    this.statuses = this.viewModel.statuses;
    this.categories = this.viewModel.categories;
    this.currency = this.viewModel.currency;
    if (this.categories.length > 0 && this.selectedCategoryId <= 0) {
      this.selectedCategoryId = this.categories[0].id;
    }
  }

  private async saveBudget(): Promise<void> {
    const amount: number = Number(this.budgetAmount);
    if (amount <= 0 || this.selectedCategoryId <= 0) {
      return;
    }
    await this.viewModel.saveBudget(this.selectedCategoryId, amount);
    this.budgetAmount = '';
    this.statuses = this.viewModel.statuses;
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('预算管理')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)

        Column({ space: 12 }) {
          Text('设置分类月预算')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Start)

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.categories, (item: Category) => {
              Button(`${item.icon} ${item.name}`)
                .type(ButtonType.Capsule)
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.selectedCategoryId === item.id ? item.color : '#E0E0E0')
                .fontColor(this.selectedCategoryId === item.id ? Color.White : '#212121')
                .onClick(() => {
                  this.selectedCategoryId = item.id;
                })
            }, (item: Category) => `${item.id}`)
          }
          TextInput({ placeholder: `预算金额 (${this.currency})`, text: this.budgetAmount })
            .type(InputType.Number)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .onChange((value: string) => {
              this.budgetAmount = value;
            })
          Button('保存预算')
            .width('100%')
            .backgroundColor('#5C6BC0')
            .fontColor(Color.White)
            .onClick(async () => {
              await this.saveBudget();
            })
        }
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(24)

        Column({ space: 12 }) {
          Text('本月预算进度')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Start)
          ForEach(this.statuses, (status: BudgetStatus) => {
            BudgetProgress({ status, currency: this.currency })
          }, (status: BudgetStatus) => `${status.budget.id}`)
        }
      }
      .padding(16)
      .width('100%')
    }
    .backgroundColor('#F6F7FB')
  }
}
