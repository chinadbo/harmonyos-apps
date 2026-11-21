interface CalendarCell {
  day: number;
  dateStr: string;
  inMonth: boolean;
  marked: boolean;
}

const WEEK_LABELS: string[] = ['日', '一', '二', '三', '四', '五', '六'];
const PINK: string = '#F062A3';
const TRANSPARENT: string = '#00000000';

@Component
export struct CalendarView {
  @Prop @Watch('onMonthPropChanged') year: number = 0;
  @Prop @Watch('onMonthPropChanged') month: number = 0;
  @Prop markDates: string[] = [];
  @State selectedDay: number = 0;
  onMonthChange?: (year: number, month: number) => void;
  onDatePick?: (dateStr: string) => void;

  aboutToAppear(): void {
    const now: Date = new Date();
    if (now.getFullYear() === this.year && now.getMonth() + 1 === this.month) {
      this.selectedDay = now.getDate();
    }
  }

  onMonthPropChanged(): void {
    this.selectedDay = 0;
  }

  private pad2(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  private dateString(day: number): string {
    return `${this.year}-${this.pad2(this.month)}-${this.pad2(day)}`;
  }

  private buildCells(): CalendarCell[] {
    const offset: number = new Date(this.year, this.month - 1, 1).getDay();
    const total: number = new Date(this.year, this.month, 0).getDate();
    const cells: CalendarCell[] = [];
    for (let i = 0; i < 42; i++) {
      const dayNum: number = i - offset + 1;
      const inMonth: boolean = dayNum >= 1 && dayNum <= total;
      let dateStr: string = '';
      let marked: boolean = false;
      if (inMonth) {
        dateStr = this.dateString(dayNum);
        marked = this.markDates.indexOf(dateStr) >= 0;
      }
      cells.push({ day: dayNum, dateStr: dateStr, inMonth: inMonth, marked: marked });
    }
    return cells;
  }

  private buildRows(): CalendarCell[][] {
    const cells: CalendarCell[] = this.buildCells();
    const rows: CalendarCell[][] = [];
    for (let r = 0; r < 6; r++) {
      const row: CalendarCell[] = [];
      for (let c = 0; c < 7; c++) {
        row.push(cells[r * 7 + c]);
      }
      rows.push(row);
    }
    return rows;
  }

  private markSignature(): string {
    const sorted: string[] = this.markDates.slice();
    sorted.sort();
    return sorted.join(',');
  }

  private changeMonth(step: number): void {
    let newYear: number = this.year;
    let newMonth: number = this.month + step;
    if (newMonth < 1) {
      newMonth = 12;
      newYear = newYear - 1;
    } else if (newMonth > 12) {
      newMonth = 1;
      newYear = newYear + 1;
    }
    this.selectedDay = 0;
    if (this.onMonthChange !== undefined) {
      this.onMonthChange(newYear, newMonth);
    }
  }

  private pickDate(cell: CalendarCell): void {
    this.selectedDay = cell.day;
    if (this.onDatePick !== undefined) {
      this.onDatePick(cell.dateStr);
    }
  }

  @Builder
  dayCell(cell: CalendarCell) {
    if (!cell.inMonth) {
      Column()
        .layoutWeight(1)
        .height(44)
    } else {
      Column() {
        Column() {
          Text(`${cell.day}`)
            .fontSize(15)
            .fontColor(this.selectedDay === cell.day ? '#FFFFFF' : '#3A3A3A')
        }
        .width(32)
        .height(32)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .borderRadius(16)
        .backgroundColor(this.selectedDay === cell.day ? PINK : TRANSPARENT)

        if (cell.marked) {
          Circle({ width: 4, height: 4 })
            .fill(this.selectedDay === cell.day ? '#FFFFFF' : PINK)
            .margin({ top: 2 })
        }
      }
      .layoutWeight(1)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.pickDate(cell))
    }
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(26)
          .fontColor('#D6336C')
          .padding({ left: 10, right: 10 })
          .onClick(() => this.changeMonth(-1))

        Text(`${this.year}年${this.month}月`)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#3A3A3A')

        Text('›')
          .fontSize(26)
          .fontColor('#D6336C')
          .padding({ left: 10, right: 10 })
          .onClick(() => this.changeMonth(1))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Row() {
        ForEach(WEEK_LABELS, (label: string) => {
          Text(label)
            .fontSize(13)
            .fontColor('#9A8A94')
            .textAlign(TextAlign.Center)
            .layoutWeight(1)
        }, (label: string) => label)
      }
      .width('100%')
      .margin({ top: 10, bottom: 4 })

      ForEach(this.buildRows(), (row: CalendarCell[]) => {
        Row() {
          ForEach(row, (cell: CalendarCell) => {
            this.dayCell(cell)
          }, (cell: CalendarCell, colIndex: number) => {
            return `${colIndex}-${cell.dateStr}-${cell.marked ? 'm' : 'n'}`;
          })
        }
        .width('100%')
      }, (row: CalendarCell[], rowIndex: number) => {
        return `row-${rowIndex}-${this.year}-${this.month}-${this.selectedDay}-${this.markSignature()}`;
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
