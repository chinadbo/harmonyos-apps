import router from '@ohos.router';
import { Category } from '../data/DataModels';
import { CategoryRepo } from '../data/CategoryRepo';
import { TransactionRepo } from '../data/TransactionRepo';
import { CategoryPicker } from '../components/CategoryPicker';
import { DateUtils } from '../utils/DateUtils';

@Entry
@Component
struct AddTransaction {
  private categoryRepo: CategoryRepo = CategoryRepo.getInstance();
  private transactionRepo: TransactionRepo = TransactionRepo.getInstance();
  @State type: 'income' | 'expense' = 'expense';
  @State amountText: string = '';
  @State note: string = '';
  @State date: string = DateUtils.currentDateString();
  @State categories: Category[] = [];
  @State selectedCategoryId: number = 1;
  @State editingId: number = 0;
  @State createdAt: number = 0;

  async aboutToAppear(): Promise<void> {
    const params = router.getParams() as Record<string, number | string>;
    if (params && params['id']) {
      this.editingId = Number(params['id']);
      const transaction = await this.transactionRepo.getById(this.editingId);
      if (transaction) {
        this.type = transaction.type;
        this.amountText = transaction.amount.toFixed(2);
        this.note = transaction.note;
        this.date = transaction.date;
        this.selectedCategoryId = transaction.categoryId;
        this.createdAt = transaction.createdAt;
      }
    }
    await this.loadCategories();
  }

  private async loadCategories(): Promise<void> {
    this.categories = await this.categoryRepo.listForType(this.type);
    if (this.categories.length > 0 && this.categories.findIndex((item: Category) => item.id === this.selectedCategoryId) < 0) {
      this.selectedCategoryId = this.categories[0].id;
    }
  }

  private async save(): Promise<void> {
    const amount: number = Number(this.amountText);
    if (amount <= 0 || this.selectedCategoryId <= 0) {
      return;
    }
    if (this.editingId > 0) {
      await this.transactionRepo.update({
        id: this.editingId,
        type: this.type,
        amount,
        categoryId: this.selectedCategoryId,
        note: this.note,
        date: this.date,
        createdAt: this.createdAt
      });
    } else {
      await this.transactionRepo.create({
        type: this.type,
        amount,
        categoryId: this.selectedCategoryId,
        note: this.note,
        date: this.date
      });
    }
    router.back();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text(this.editingId > 0 ? '编辑账单' : '新增账单')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)

        Row({ space: 12 }) {
          Button('支出')
            .layoutWeight(1)
            .backgroundColor(this.type === 'expense' ? '#5C6BC0' : '#E0E0E0')
            .onClick(async () => {
              this.type = 'expense';
              await this.loadCategories();
            })
          Button('收入')
            .layoutWeight(1)
            .backgroundColor(this.type === 'income' ? '#5C6BC0' : '#E0E0E0')
            .onClick(async () => {
              this.type = 'income';
              await this.loadCategories();
            })
        }

        TextInput({ placeholder: '金额', text: this.amountText })
          .type(InputType.Number)
          .fontSize(24)
          .height(56)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .onChange((value: string) => {
            this.amountText = value;
          })

        CategoryPicker({ categories: this.categories, selectedCategoryId: $selectedCategoryId })

        TextInput({ placeholder: '备注', text: this.note })
          .backgroundColor(Color.White)
          .borderRadius(16)
          .onChange((value: string) => {
            this.note = value;
          })

        TextInput({ placeholder: '日期 YYYY-MM-DD', text: this.date })
          .backgroundColor(Color.White)
          .borderRadius(16)
          .onChange((value: string) => {
            this.date = value;
          })

        Button(this.editingId > 0 ? '保存修改' : '保存')
          .width('100%')
          .height(52)
          .backgroundColor('#5C6BC0')
          .fontColor(Color.White)
          .onClick(async () => {
            await this.save();
          })
      }
      .padding(16)
      .width('100%')
    }
    .backgroundColor('#F6F7FB')
  }
}
