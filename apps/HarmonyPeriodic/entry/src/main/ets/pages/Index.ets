import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';
import { Element, loadElements, getCategoryColor } from '../model/Element';
import { ElementCell, CELL_WIDTH, CELL_HEIGHT } from '../components/ElementCell';
import { CategoryLegend } from '../components/CategoryLegend';
import {
  getLayoutPosition,
  TABLE_COLUMNS,
  LANTHANIDE_ROW,
  ACTINIDE_ROW,
  LANTHANIDE_PLACEHOLDER,
  ACTINIDE_PLACEHOLDER
} from '../utils/tableLayout';
import { preferencesHelper } from '../utils/preferences';

const DOMAIN: number = 0x0000;
const TAG: string = 'Index';
const ROW_ORDER: number[] = [1, 2, 3, 4, 5, 6, 7, LANTHANIDE_ROW, ACTINIDE_ROW];
const ROW_GAP: number = 4;
const TABLE_WIDTH: number = TABLE_COLUMNS * CELL_WIDTH + (TABLE_COLUMNS - 1) * 3;
const TABLE_HEIGHT: number = ROW_ORDER.length * CELL_HEIGHT
  + (ROW_ORDER.length - 1) * ROW_GAP + 14;

interface CategoryChip {
  key: string;
  label: string;
}

interface DetailParams {
  atomicNumber: number;
}

const CATEGORY_CHIPS: CategoryChip[] = [
  { key: 'all', label: '全部' },
  { key: 'alkali-metal', label: '碱金属' },
  { key: 'alkaline-earth', label: '碱土金属' },
  { key: 'transition', label: '过渡金属' },
  { key: 'post-transition', label: '后过渡金属' },
  { key: 'metalloid', label: '类金属' },
  { key: 'nonmetal', label: '非金属' },
  { key: 'halogen', label: '卤素' },
  { key: 'noble-gas', label: '稀有气体' },
  { key: 'lanthanide', label: '镧系' },
  { key: 'actinide', label: '锕系' }
];

class TableSlot {
  key: string;
  col: number;
  element: Element | null;
  placeholder: string;

  constructor(key: string, col: number, element: Element | null, placeholder: string) {
    this.key = key;
    this.col = col;
    this.element = element;
    this.placeholder = placeholder;
  }
}

@Entry
@Component
struct Index {
  @State elements: Element[] = [];
  @State rows: TableSlot[][] = [];
  @State query: string = '';
  @State activeCategory: string = 'all';
  @State colorScheme: string = 'category';
  @State errorMessage: string = '';
  private loaded: boolean = false;

  aboutToAppear(): void {
    this.loadColorScheme();
    this.loadElementsData();
  }

  onPageShow(): void {
    this.loadColorScheme();
  }

  private async loadColorScheme(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      await preferencesHelper.init(context);
      const scheme: string = await preferencesHelper.getColorScheme();
      this.colorScheme = scheme;
    } catch (err) {
      hilog.warn(DOMAIN, TAG, 'read color scheme failed: %{public}s', JSON.stringify(err));
    }
  }

  private async loadElementsData(): Promise<void> {
    if (this.loaded) {
      return;
    }
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const list: Element[] = await loadElements(context);
      this.elements = list;
      this.rows = this.buildRows(list);
      this.loaded = true;
    } catch (err) {
      this.errorMessage = '元素数据加载失败，请重启应用重试';
      hilog.error(DOMAIN, TAG, 'load elements failed: %{public}s', JSON.stringify(err));
    }
  }

  // 按 tableLayout 坐标把元素填入 18 列 × 7 行主表与镧系/锕系两行
  private buildRows(elements: Element[]): TableSlot[][] {
    const matrix: Map<number, TableSlot[]> = new Map<number, TableSlot[]>();
    for (const rowNumber of ROW_ORDER) {
      const slots: TableSlot[] = [];
      for (let col = 1; col <= TABLE_COLUMNS; col++) {
        slots.push(new TableSlot('r' + rowNumber + 'c' + col, col, null, ''));
      }
      matrix.set(rowNumber, slots);
    }

    for (const element of elements) {
      const position = getLayoutPosition(element.atomicNumber);
      const rowSlots = matrix.get(position.row);
      if (rowSlots === undefined) {
        continue;
      }
      if (position.col < 1 || position.col > TABLE_COLUMNS) {
        continue;
      }
      rowSlots[position.col - 1].element = element;
    }

    this.applyPlaceholder(matrix, LANTHANIDE_PLACEHOLDER.row, LANTHANIDE_PLACEHOLDER.col, '57-71\n镧系');
    this.applyPlaceholder(matrix, ACTINIDE_PLACEHOLDER.row, ACTINIDE_PLACEHOLDER.col, '89-103\n锕系');

    const rows: TableSlot[][] = [];
    for (const rowNumber of ROW_ORDER) {
      const rowSlots = matrix.get(rowNumber);
      if (rowSlots !== undefined) {
        rows.push(rowSlots);
      }
    }
    return rows;
  }

  private applyPlaceholder(matrix: Map<number, TableSlot[]>, row: number, col: number,
    label: string): void {
    const rowSlots = matrix.get(row);
    if (rowSlots === undefined) {
      return;
    }
    if (col < 1 || col > TABLE_COLUMNS) {
      return;
    }
    rowSlots[col - 1].placeholder = label;
  }

  private matchesFilter(element: Element): boolean {
    if (this.activeCategory !== 'all' && element.category !== this.activeCategory) {
      return false;
    }
    const query: string = this.query.trim().toLowerCase();
    if (query.length === 0) {
      return true;
    }
    let numeric: boolean = true;
    for (let i = 0; i < query.length; i++) {
      const code: number = query.charCodeAt(i);
      if (code < 48 || code > 57) {
        numeric = false;
        break;
      }
    }
    if (numeric) {
      return element.atomicNumber === parseInt(query, 10);
    }
    if (element.symbol.toLowerCase().includes(query)) {
      return true;
    }
    if (element.nameZh.includes(query)) {
      return true;
    }
    return element.nameEn.toLowerCase().includes(query);
  }

  private filteredCount(): number {
    let count: number = 0;
    for (const element of this.elements) {
      if (this.matchesFilter(element)) {
        count++;
      }
    }
    return count;
  }

  private schemeLabel(): string {
    if (this.colorScheme === 'state') {
      return '当前配色：按状态';
    }
    if (this.colorScheme === 'block') {
      return '当前配色：按区';
    }
    return '当前配色：按类别';
  }

  private chipBackground(key: string): string {
    if (this.activeCategory !== key) {
      return '#FFFFFF';
    }
    return key === 'all' ? '#0A59F7' : getCategoryColor(key);
  }

  private chipTextColor(key: string): string {
    if (this.activeCategory !== key) {
      return '#99000000';
    }
    return key === 'all' ? '#FFFFFF' : '#E6000000';
  }

  private chipBorderColor(key: string): string {
    if (this.activeCategory !== key) {
      return '#1A000000';
    }
    return key === 'all' ? '#0A59F7' : getCategoryColor(key);
  }

  private openElement(element: Element): void {
    const params: DetailParams = { atomicNumber: element.atomicNumber };
    router.pushUrl({ url: 'pages/ElementDetail', params: params }).catch((err: Error) => {
      hilog.error(DOMAIN, TAG, 'open element detail failed: %{public}s', err.message);
    });
  }

  private navigate(url: string): void {
    router.pushUrl({ url: url }).catch((err: Error) => {
      hilog.error(DOMAIN, TAG, 'navigate failed: %{public}s', err.message);
    });
  }

  build() {
    Column() {
      this.Header()
      Scroll() {
        Column({ space: 10 }) {
          this.SearchBox()
          this.CategoryChips()
          this.TableView()
          this.LegendSection()
        }
        .width('100%')
        .padding({ left: 10, right: 10, bottom: 12 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      this.BottomNav()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }

  @Builder
  Header() {
    Row() {
      Column({ space: 2 }) {
        Text('元素周期表')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E6000000')
        Text(this.schemeLabel())
          .fontSize(11)
          .fontColor('#99000000')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text(this.filteredCount().toString() + ' / ' + this.elements.length)
        .fontSize(12)
        .fontColor('#0A59F7')
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 8 })
  }

  @Builder
  SearchBox() {
    Row({ space: 8 }) {
      TextInput({ placeholder: '搜索名称 / 符号 / 序数', text: this.query })
        .type(InputType.Normal)
        .height(40)
        .layoutWeight(1)
        .fontSize(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .padding({ left: 12, right: 12 })
        .onChange((value: string) => {
          this.query = value;
        })
      if (this.query.length > 0) {
        Text('清除')
          .fontSize(13)
          .fontColor('#0A59F7')
          .padding({ left: 10, right: 10, top: 8, bottom: 8 })
          .onClick(() => {
            this.query = '';
          })
      }
    }
    .width('100%')
  }

  @Builder
  CategoryChips() {
    Scroll() {
      Row({ space: 8 }) {
        ForEach(CATEGORY_CHIPS, (chip: CategoryChip) => {
          Text(chip.label)
            .fontSize(12)
            .fontColor(this.chipTextColor(chip.key))
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(this.chipBackground(chip.key))
            .borderRadius(14)
            .border({ width: 1, color: this.chipBorderColor(chip.key) })
            .maxLines(1)
            .onClick(() => {
              this.activeCategory = chip.key;
            })
        }, (chip: CategoryChip) => chip.key)
      }
      .padding({ right: 4 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(34)
  }

  @Builder
  TableView() {
    if (this.rows.length === 0) {
      Column({ space: 6 }) {
        if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(13)
            .fontColor('#99000000')
        } else {
          LoadingProgress()
            .width(32)
            .height(32)
            .color('#0A59F7')
          Text('正在加载元素数据')
            .fontSize(12)
            .fontColor('#99000000')
        }
      }
      .width('100%')
      .height(220)
      .justifyContent(FlexAlign.Center)
    } else {
      Scroll() {
        Column({ space: ROW_GAP }) {
          ForEach(this.rows, (slots: TableSlot[], rowIndex: number) => {
            Row({ space: 3 }) {
              ForEach(slots, (slot: TableSlot) => {
                if (slot.placeholder.length > 0) {
                  this.PlaceholderCell(slot.placeholder)
                } else if (slot.element !== null) {
                  ElementCell({
                    element: slot.element as Element,
                    colorScheme: this.colorScheme,
                    dimmed: !this.matchesFilter(slot.element as Element)
                  })
                    .onClick(() => {
                      this.openElement(slot.element as Element);
                    })
                } else {
                  Row()
                    .width(CELL_WIDTH)
                    .height(CELL_HEIGHT)
                }
              }, (slot: TableSlot) => slot.key)
            }
            .margin({ top: rowIndex === 7 ? 14 : 0 })
          }, (slots: TableSlot[], rowIndex: number) => 'row-' + rowIndex)
        }
        .width(TABLE_WIDTH)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height(TABLE_HEIGHT)
    }
  }

  @Builder
  PlaceholderCell(label: string) {
    Column() {
      Text(label)
        .fontSize(9)
        .fontColor('#99000000')
        .textAlign(TextAlign.Center)
        .lineHeight(11)
        .maxLines(2)
    }
    .width(CELL_WIDTH)
    .height(CELL_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#E9EDF2')
    .borderRadius(6)
    .border({ width: 0.5, color: '#26000000' })
  }

  @Builder
  LegendSection() {
    Column({ space: 6 }) {
      Text('类别图例')
        .fontSize(11)
        .fontColor('#66000000')
        .width('100%')
        .textAlign(TextAlign.Start)
      CategoryLegend()
    }
    .width('100%')
    .padding({ top: 4 })
  }

  @Builder
  BottomNav() {
    Column() {
      Divider()
        .width('100%')
        .color('#14000000')
      Row({ space: 10 }) {
        this.NavButton('收藏', 'pages/FavoritesPage')
        this.NavButton('测验', 'pages/QuizPage')
        this.NavButton('设置', 'pages/SettingsPage')
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  NavButton(label: string, url: string) {
    Button(label, { type: ButtonType.Normal })
      .layoutWeight(1)
      .height(38)
      .fontSize(14)
      .fontColor('#0A59F7')
      .backgroundColor('#EAF1FE')
      .borderRadius(10)
      .onClick(() => {
        this.navigate(url);
      })
  }
}
