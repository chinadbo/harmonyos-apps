import { FoodItem } from '../model/FoodItem';
import { Constants } from '../common/Constants';
import { FoodItemDao } from '../database/FoodItemDao';
import { DateUtils } from '../common/DateUtils';
import { ExpiryChecker } from '../service/ExpiryChecker';

@Component
export struct ItemEditPage {
  @Prop item: FoodItem = FoodItem.createEmpty();
  @Prop onSaved: () => void = () => {};
  @State draft: FoodItem = FoodItem.createEmpty();
  private foodItemDao: FoodItemDao = new FoodItemDao();

  aboutToAppear(): void {
    this.draft = new FoodItem(this.item);
    if (this.draft.createdAt === 0) {
      this.draft.createdAt = Date.now();
      this.draft.expiryDate = DateUtils.todayText();
    }
  }

  private async save(): Promise<void> {
    this.draft.updatedAt = Date.now();
    await this.foodItemDao.save(this.draft);
    await ExpiryChecker.getInstance().refreshAll();
    this.onSaved();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text(this.draft.id > 0 ? '编辑食材' : '新增食材')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#20331E')
          .width('100%')
          .textAlign(TextAlign.Start)

        TextInput({ placeholder: '食材名称', text: this.draft.name })
          .onChange((value: string) => {
            this.draft.name = value;
          })
        TextInput({ placeholder: '数量', text: `${this.draft.quantity}` })
          .type(InputType.Number)
          .onChange((value: string) => {
            this.draft.quantity = Number(value) || 1;
          })

        Row({ space: 12 }) {
          Select([{ value: this.draft.unit }, ...Constants.DEFAULT_UNITS.filter((unit: string) => unit !== this.draft.unit).map((unit: string) => ({ value: unit }))])
            .selected(0)
            .value(this.draft.unit)
            .onSelect((index: number, value: string) => {
              this.draft.unit = value;
            })
          Select([{ value: this.draft.category }, ...Constants.CATEGORIES.filter((category: string) => category !== this.draft.category).map((category: string) => ({ value: category }))])
            .selected(0)
            .value(this.draft.category)
            .onSelect((index: number, value: string) => {
              this.draft.category = value;
            })
        }

        Row({ space: 12 }) {
          Select([{ value: this.draft.storageArea }, ...Constants.STORAGE_AREAS.filter((area: string) => area !== this.draft.storageArea).map((area: string) => ({ value: area }))])
            .selected(0)
            .value(this.draft.storageArea)
            .onSelect((index: number, value: string) => {
              this.draft.storageArea = value;
            })
          DatePicker({ start: new Date(2024, 0, 1), end: new Date(2099, 11, 31), selected: DateUtils.toDate(this.draft.expiryDate) })
            .onDateChange((value: Date) => {
              this.draft.expiryDate = DateUtils.toDateText(value);
            })
        }

        TextInput({ placeholder: '备注', text: this.draft.note })
          .onChange((value: string) => {
            this.draft.note = value;
          })

        Button('保存')
          .width('100%')
          .height(48)
          .backgroundColor('#5E8F5A')
          .onClick(() => {
            this.save();
          })
      }
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F8F4')
  }
}
