/**
 * WishEdit.ets — 心愿新增 / 编辑 / 已入手
 */
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { WishItem } from '../model/WishItem';
import { Category } from '../model/Category';
import { CategoryDao, Db } from '../model/Db';
import { WishService, WishSaveResult, AcquireResult } from '../service/WishService';
import { PageHeader } from '../components/PageHeader';
import { CategoryPicker } from '../components/CategoryPicker';
import { PriorityPicker } from '../components/PriorityPicker';
import { bumpRefresh, C_BG, C_CARD, C_LINE, C_TEXT, C_SUB, C_BRAND, C_SUCCESS, C_DANGER } from '../common/Constants';

interface WishParams {
  id: number;
}

@Entry
@Component
struct WishEdit {
  @State form: WishItem = new WishItem();
  @State categories: Category[] = [];
  @State targetText: string = '';
  @State saving: boolean = false;
  @State acquiring: boolean = false;
  @State loaded: boolean = false;
  @State wishId: number = 0;

  aboutToAppear(): void {
    this.wishId = this.readId();
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
      if (this.wishId > 0) {
        const existing: WishItem | null = await WishService.detail(this.wishId);
        if (existing !== null) {
          this.form = existing;
        } else {
          this.form = WishService.newWish();
          this.wishId = 0;
        }
      } else {
        this.form = WishService.newWish();
      }
      this.targetText = this.form.targetPrice > 0 ? this.form.targetPrice.toString() : '';
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
    this.form.targetPrice = this.parseNum(this.targetText);
    this.saving = true;
    const result: WishSaveResult = await WishService.save(this.form);
    this.saving = false;
    if (result.ok) {
      bumpRefresh();
      promptAction.showToast({ message: '已保存' });
      router.back();
    } else {
      promptAction.showToast({ message: result.message });
    }
  }

  private async acquire(): Promise<void> {
    if (this.acquiring || this.saving) {
      return;
    }
    this.form.targetPrice = this.parseNum(this.targetText);
    this.acquiring = true;
    const saveResult: WishSaveResult = await WishService.save(this.form);
    if (!saveResult.ok) {
      this.acquiring = false;
      promptAction.showToast({ message: saveResult.message });
      return;
    }
    this.form.id = saveResult.id;
    this.wishId = saveResult.id;
    const result: AcquireResult = await WishService.acquire(this.form);
    this.acquiring = false;
    if (result.ok) {
      bumpRefresh();
      promptAction.showToast({ message: result.message });
      router.back();
    } else {
      promptAction.showToast({ message: result.message });
    }
  }

  private remove(): void {
    promptAction.showDialog({
      title: '删除心愿',
      message: '确定删除「' + this.form.name + '」吗？',
      buttons: [
        { text: '取消', color: '#8A8175' },
        { text: '删除', color: C_DANGER }
      ]
    }).then(async (res) => {
      if (res.index !== 1) {
        return;
      }
      const ok: boolean = await WishService.remove(this.wishId);
      if (ok) {
        bumpRefresh();
        promptAction.showToast({ message: '已删除' });
        router.back();
      } else {
        promptAction.showToast({ message: '删除失败' });
      }
    });
  }

  @Builder
  FieldLabel(text: string) {
    Text(text)
      .fontSize(13)
      .fontColor(C_SUB)
      .width('100%')
      .margin({ bottom: 8 })
  }

  build() {
    Column() {
      PageHeader({
        title: this.wishId > 0 ? '编辑心愿' : '新增心愿',
        subtitle: '记录想要的好物',
        showBack: true,
        actionText: this.saving ? '保存中…' : '保存',
        actionEnabled: !this.saving && !this.acquiring && this.loaded,
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
            if (this.form.status === 1) {
              Row() {
                Text('✓')
                  .fontSize(14)
                  .fontColor(C_SUCCESS)
                Text('此心愿已入手，已生成对应藏品')
                  .fontSize(13)
                  .fontColor(C_SUCCESS)
                  .margin({ left: 8 })
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#1A3F7C6E')
              .borderRadius(14)
            }

            Column() {
              this.FieldLabel('心愿名称 *')
              TextInput({ text: this.form.name, placeholder: '例如：限定色 AJ1' })
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
              this.FieldLabel('品类')
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
              this.FieldLabel('目标价格（元）')
              TextInput({ text: this.targetText, placeholder: '0.00' })
                .type(InputType.Number)
                .height(44)
                .fontSize(14)
                .backgroundColor(C_BG)
                .borderRadius(10)
                .onChange((value: string) => this.targetText = value)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(C_CARD)
            .borderRadius(18)
            .border({ width: 1, color: C_LINE })

            Column() {
              this.FieldLabel('期待程度')
              PriorityPicker({
                priority: this.form.priority,
                onChange: (priority: number) => this.form.priority = priority
              })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(C_CARD)
            .borderRadius(18)
            .border({ width: 1, color: C_LINE })

            Column() {
              this.FieldLabel('备注')
              TextArea({ text: this.form.remark, placeholder: '版本、渠道、预期等' })
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

            if (this.form.status !== 1) {
              Button(this.acquiring ? '处理中…' : '已入手，加入藏品库')
                .width('100%')
                .height(48)
                .fontSize(16)
                .fontColor(0xFFFFFF)
                .backgroundColor(this.acquiring ? C_SUB : C_SUCCESS)
                .borderRadius(24)
                .enabled(!this.acquiring && !this.saving)
                .onClick(() => { this.acquire(); })
            }

            if (this.wishId > 0) {
              Button('删除心愿')
                .width('100%')
                .height(46)
                .fontSize(15)
                .fontColor(C_DANGER)
                .backgroundColor('#1AB34A3C')
                .borderRadius(23)
                .onClick(() => this.remove())
            }

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
