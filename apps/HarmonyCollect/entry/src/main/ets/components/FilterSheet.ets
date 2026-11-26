/**
 * FilterSheet.ets — 底部筛选面板（品类 / 成色 / 估值区间 / 排序）
 * 通过 @Link 控制显隐，筛选结果经 onApply 回传父组件。
 */
import { Category } from '../model/Category';
import { SegmentBar } from './SegmentBar';
import {
  ItemFilter, defaultFilter, SORT_OPTIONS, CONDITIONS, categoryColor, conditionColor,
  C_CARD, C_TEXT, C_SUB, C_LINE, C_BRAND, C_BG
} from '../common/Constants';

@Component
export struct FilterSheet {
  @Link @Watch('onVisibleChange') show: boolean;
  @Prop @Watch('syncDraft') filter: ItemFilter = defaultFilter();
  @Prop categories: Category[] = [];
  onApply: (filter: ItemFilter) => void = (filter: ItemFilter) => {};

  @State draftCats: string[] = [];
  @State draftConds: string[] = [];
  @State minText: string = '';
  @State maxText: string = '';
  @State sortIndex: number = 0;

  aboutToAppear(): void {
    this.syncDraft();
  }

  onVisibleChange(): void {
    if (this.show) {
      this.syncDraft();
    }
  }

  syncDraft(): void {
    this.draftCats = this.filter.categories.slice();
    this.draftConds = this.filter.conditions.slice();
    this.minText = this.filter.minValue > 0 ? this.filter.minValue.toString() : '';
    this.maxText = this.filter.maxValue > 0 ? this.filter.maxValue.toString() : '';
    this.sortIndex = this.indexOfSort(this.filter.sort);
  }

  private indexOfSort(key: string): number {
    for (let i = 0; i < SORT_OPTIONS.length; i++) {
      if (SORT_OPTIONS[i].key === key) {
        return i;
      }
    }
    return 0;
  }

  private sortLabels(): string[] {
    const labels: string[] = [];
    for (let i = 0; i < SORT_OPTIONS.length; i++) {
      labels.push(SORT_OPTIONS[i].label);
    }
    return labels;
  }

  private toggleCategory(key: string): void {
    const next: string[] = this.draftCats.slice();
    const idx: number = next.indexOf(key);
    if (idx >= 0) {
      next.splice(idx, 1);
    } else {
      next.push(key);
    }
    this.draftCats = next;
  }

  private toggleCondition(cond: string): void {
    const next: string[] = this.draftConds.slice();
    const idx: number = next.indexOf(cond);
    if (idx >= 0) {
      next.splice(idx, 1);
    } else {
      next.push(cond);
    }
    this.draftConds = next;
  }

  private parseNum(text: string): number {
    const value: number = parseFloat(text);
    if (isNaN(value) || value < 0) {
      return 0;
    }
    return value;
  }

  private resetDraft(): void {
    this.draftCats = [];
    this.draftConds = [];
    this.minText = '';
    this.maxText = '';
    this.sortIndex = 0;
  }

  private apply(): void {
    const result: ItemFilter = {
      keyword: this.filter.keyword,
      categories: this.draftCats.slice(),
      conditions: this.draftConds.slice(),
      minValue: this.parseNum(this.minText),
      maxValue: this.parseNum(this.maxText),
      sort: SORT_OPTIONS[this.sortIndex].key
    };
    this.onApply(result);
    this.show = false;
  }

  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor(C_TEXT)
      .margin({ top: 18, bottom: 10 })
      .width('100%')
  }

  build() {
    if (this.show) {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#66000000')
          .onClick(() => this.show = false)

        Column() {
          Row() {
            Text('筛选')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(C_TEXT)
            Blank()
            Text('×')
              .fontSize(24)
              .fontColor(C_SUB)
              .onClick(() => this.show = false)
          }
          .width('100%')
          .padding({ bottom: 4 })

          Scroll() {
            Column() {
              this.SectionTitle('品类')

              Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
                ForEach(this.categories, (cat: Category) => {
                  Text(cat.name)
                    .fontSize(13)
                    .fontColor(this.draftCats.indexOf(cat.key) >= 0 ? 0xFFFFFF : C_SUB)
                    .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                    .margin({ right: 8, bottom: 8 })
                    .borderRadius(16)
                    .backgroundColor(this.draftCats.indexOf(cat.key) >= 0 ? categoryColor(cat.key) : C_BG)
                    .border({ width: 1, color: this.draftCats.indexOf(cat.key) >= 0 ? categoryColor(cat.key) : C_LINE })
                    .onClick(() => this.toggleCategory(cat.key))
                }, (cat: Category) => cat.key)
              }
              .width('100%')

              this.SectionTitle('成色')

              Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
                ForEach(CONDITIONS, (cond: string) => {
                  Text(cond)
                    .fontSize(13)
                    .fontColor(this.draftConds.indexOf(cond) >= 0 ? 0xFFFFFF : C_SUB)
                    .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                    .margin({ right: 8, bottom: 8 })
                    .borderRadius(16)
                    .backgroundColor(this.draftConds.indexOf(cond) >= 0 ? conditionColor(cond) : C_BG)
                    .border({ width: 1, color: this.draftConds.indexOf(cond) >= 0 ? conditionColor(cond) : C_LINE })
                    .onClick(() => this.toggleCondition(cond))
                }, (cond: string) => cond)
              }
              .width('100%')

              this.SectionTitle('估值区间（元）')

              Row() {
                TextInput({ text: this.minText, placeholder: '最低' })
                  .type(InputType.Number)
                  .layoutWeight(1)
                  .height(42)
                  .fontSize(14)
                  .backgroundColor(C_BG)
                  .borderRadius(10)
                  .onChange((value: string) => this.minText = value)
                Text('—')
                  .fontSize(14)
                  .fontColor(C_SUB)
                  .margin({ left: 10, right: 10 })
                TextInput({ text: this.maxText, placeholder: '最高' })
                  .type(InputType.Number)
                  .layoutWeight(1)
                  .height(42)
                  .fontSize(14)
                  .backgroundColor(C_BG)
                  .borderRadius(10)
                  .onChange((value: string) => this.maxText = value)
              }
              .width('100%')

              this.SectionTitle('排序')

              SegmentBar({
                options: this.sortLabels(),
                selectedIndex: this.sortIndex,
                onChange: (index: number) => this.sortIndex = index
              })
            }
            .width('100%')
          }
          .constraintSize({ maxHeight: 460 })
          .scrollBar(BarState.Off)

          Row() {
            Button('重置')
              .layoutWeight(1)
              .height(44)
              .fontSize(15)
              .fontColor(C_TEXT)
              .backgroundColor(C_BG)
              .borderRadius(22)
              .onClick(() => this.resetDraft())
            Button('应用筛选')
              .layoutWeight(1)
              .height(44)
              .fontSize(15)
              .fontColor(0xFFFFFF)
              .backgroundColor(C_BRAND)
              .borderRadius(22)
              .margin({ left: 12 })
              .onClick(() => this.apply())
          }
          .width('100%')
          .margin({ top: 18 })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 18, bottom: 24 })
        .backgroundColor(C_CARD)
        .borderRadius({ topLeft: 22, topRight: 22 })
      }
      .width('100%')
      .height('100%')
    }
  }
}
