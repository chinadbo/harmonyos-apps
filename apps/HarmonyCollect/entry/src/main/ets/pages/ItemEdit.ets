/**
 * ItemEdit.ets — 藏品新增 / 编辑表单
 */
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { CollectItem } from '../model/CollectItem';
import { Category } from '../model/Category';
import { CategoryDao, Db } from '../model/Db';
import { ItemService, SaveResult } from '../service/ItemService';
import { Format } from '../common/Format';
import { PageHeader } from '../components/PageHeader';
import { CategoryPicker } from '../components/CategoryPicker';
import { ConditionPicker } from '../components/ConditionPicker';
import { TagEditor } from '../components/TagEditor';
import { ImagePicker } from '../components/ImagePicker';
import { bumpRefresh, C_BG, C_CARD, C_LINE, C_TEXT, C_SUB, C_BRAND } from '../common/Constants';

interface EditParams {
  id: number;
}

@Entry
@Component
struct ItemEdit {
  @State form: CollectItem = new CollectItem();
  @State categories: Category[] = [];
  @State acquirePriceText: string = '';
  @State estValueText: string = '';
  @State showDatePicker: boolean = false;
  @State saving: boolean = false;
  @State loaded: boolean = false;
  @State itemId: number = 0;
  private startDate: Date = new Date(2000, 0, 1);
  private endDate: Date = new Date(2035, 11, 31);

  aboutToAppear(): void {
    this.itemId = this.readId();
    this.load();
  }

  private readId(): number {
    try {
      const params = router.getParams() as Record<string, Object>;
      const id = params['id'];
      if (typeof id === 'number') {
        return id;
      }
      return 0;
    } catch (err) {
      return 0;
    }
  }

  private async load(): Promise<void> {
    try {
      if (!Db.isReady()) {
        await Db.waitReady(4000);
      }
      this.categories = await CategoryDao.queryAll();
      if (this.itemId > 0) {
        const existing: CollectItem | null = await ItemService.detail(this.itemId);
        if (existing !== null) {
          this.form = existing;
        } else {
          this.form = ItemService.newItem();
          this.itemId = 0;
        }
      } else {
        this.form = ItemService.newItem();
      }
      this.acquirePriceText = this.form.acquirePrice > 0 ? this.form.acquirePrice.toString() : '';
      this.estValueText = this.form.estValue > 0 ? this.form.estValue.toString() : '';
      this.loaded = true;
    } catch (err) {
      this.loaded = true;
    }
  }

  private parseNum(text: string): number {
    const value: number = parseFloat(text);
    if (isNaN(value) || value < 0) {
      return 0;
    }
    return value;
  }

  private async save(): Promise<void> {
    if (this.saving) {
      return;
    }
    this.form.acquirePrice = this.parseNum(this.acquirePriceText);
    this.form.estValue = this.parseNum(this.estValueText);
    this.saving = true;
    const result: SaveResult = await ItemService.save(this.form);
    this.saving = false;
    if (result.ok) {
      bumpRefresh();
      promptAction.showToast({ message: '已保存' });
      router.back();
    } else {
      promptAction.showToast({ message: result.message });
    }
  }

  @Builder
  FieldLabel(text: string, required: boolean) {
    Row() {
      Text(text)
        .fontSize(13)
        .fontColor(C_SUB)
      if (required) {
        Text(' *')
          .fontSize(13)
          .fontColor('#B34A3C')
      }
    }
    .width('100%')
    .margin({ bottom: 8 })
  }

  build() {
    Column() {
      PageHeader({
        title: this.itemId > 0 ? '编辑藏品' : '新增藏品',
        subtitle: '记录你的收藏',
        showBack: true,
        actionText: this.saving ? '保存中…' : '保存',
        actionEnabled: !this.saving && this.loaded,
        onAction: () => { this.save(); },
        onBack: () => router.back()
      })

      if (!this.loaded) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(C_BRAND)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 14 }) {
            Column() {
              this.FieldLabel('藏品图片', false)
              ImagePicker({
                path: this.form.imageUri,
                onChange: (path: string) => this.form.imageUri = path
              })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(C_CARD)
            .borderRadius(18)
            .border({ width: 1, color: C_LINE })

            Column() {
              this.FieldLabel('名称', true)
              TextInput({ text: this.form.name, placeholder: '例如：初版钢炼手办' })
                .height(44)
                .fontSize(14)
                .fontColor(C_TEXT)
                .backgroundColor(C_BG)
                .borderRadius(10)
                .onChange((value: string) => this.form.name = value)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(C_CARD)
            .borderRadius(18)
            .border({ width: 1, color: C_LINE })

            Column() {
              this.FieldLabel('品类', true)
              CategoryPicker({
                categories: this.categories,
                selected: this.form.category,
                onChange: (key: string) => this.form.category = key
              })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(C_CARD)
            .borderRadius(18)
            .border({ width: 1, color: C_LINE })

            Column() {
              this.FieldLabel('成色', true)
              ConditionPicker({
                selected: this.form.condition,
                onChange: (condition: string) => this.form.condition = condition
              })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(C_CARD)
            .borderRadius(18)
            .border({ width: 1, color: C_LINE })

            Column() {
              this.FieldLabel('入手日期', false)
              Row() {
                Text(this.form.acquireDate.length > 0 ? this.form.acquireDate : '未选择')
                  .fontSize(14)
                  .fontColor(C_TEXT)
                  .layoutWeight(1)
                Text(this.showDatePicker ? '收起' : '选择')
                  .fontSize(13)
                  .fontColor(C_BRAND)
                  .onClick(() => this.showDatePicker = !this.showDatePicker)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)

              if (this.showDatePicker) {
                DatePicker({
                  start: this.startDate,
                  end: this.endDate,
                  selected: Format.strToDate(this.form.acquireDate)
                })
                  .width('100%')
                  .onDateChange((value: Date) => {
                    this.form.acquireDate = Format.dateToStr(value);
                  })
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(C_CARD)
            .borderRadius(18)
            .border({ width: 1, color: C_LINE })

            Column() {
              this.FieldLabel('价格（元）', false)
              Row() {
                Column() {
                  Text('入手价格')
                    .fontSize(12)
                    .fontColor(C_SUB)
                    .width('100%')
                  TextInput({ text: this.acquirePriceText, placeholder: '0.00' })
                    .type(InputType.Number)
                    .height(44)
                    .fontSize(14)
                    .backgroundColor(C_BG)
                    .borderRadius(10)
                    .margin({ top: 6 })
                    .onChange((value: string) => this.acquirePriceText = value)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Column() {
                  Text('当前估值')
                    .fontSize(12)
                    .fontColor(C_SUB)
                    .width('100%')
                  TextInput({ text: this.estValueText, placeholder: '0.00' })
                    .type(InputType.Number)
                    .height(44)
                    .fontSize(14)
                    .backgroundColor(C_BG)
                    .borderRadius(10)
                    .margin({ top: 6 })
                    .onChange((value: string) => this.estValueText = value)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(C_CARD)
            .borderRadius(18)
            .border({ width: 1, color: C_LINE })

            Column() {
              this.FieldLabel('编号 / 版本', false)
              TextInput({ text: this.form.serial, placeholder: '如：限量编号 001/500' })
                .height(44)
                .fontSize(14)
                .backgroundColor(C_BG)
                .borderRadius(10)
                .onChange((value: string) => this.form.serial = value)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(C_CARD)
            .borderRadius(18)
            .border({ width: 1, color: C_LINE })

            Column() {
              this.FieldLabel('标签', false)
              TagEditor({
                tags: this.form.tags,
                onChange: (tags: string) => this.form.tags = tags
              })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(C_CARD)
            .borderRadius(18)
            .border({ width: 1, color: C_LINE })

            Column() {
              this.FieldLabel('备注', false)
              TextArea({ text: this.form.remark, placeholder: '来源、瑕疵、包装情况等' })
                .height(100)
                .fontSize(14)
                .backgroundColor(C_BG)
                .borderRadius(10)
                .onChange((value: string) => this.form.remark = value)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(C_CARD)
            .borderRadius(18)
            .border({ width: 1, color: C_LINE })

            Button(this.saving ? '保存中…' : '保存藏品')
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontColor(0xFFFFFF)
              .backgroundColor(this.saving ? C_SUB : C_BRAND)
              .borderRadius(24)
              .enabled(!this.saving)
              .onClick(() => { this.save(); })

            Column().height(24)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 6 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(C_BG)
  }
}
