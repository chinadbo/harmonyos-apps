import { moonPhase, phaseNameOf, julianFromDate } from '../engine/astro';
import { pad2 } from '../utils/format';
import { MoonPhaseCanvas } from '../components/MoonPhaseCanvas';
import { StarSkyCanvas } from '../components/StarSkyCanvas';
import { SkyCard } from '../components/SkyCard';
import { NavBar } from '../components/NavBar';

interface DayCell {
  day: number;
  phase: number;
  isMajor: boolean;
  isToday: boolean;
}

@Entry
@Component
struct MoonCalendar {
  @State year: number = new Date().getFullYear();
  @State month: number = new Date().getMonth() + 1;
  @State cells: DayCell[] = [];
  @State selectedDay: number = new Date().getDate();
  @State selectedPhase: number = 0;
  @State selectedName: string = '';
  @State selectedIll: number = 0;

  aboutToAppear(): void {
    this.buildCells();
  }

  private buildCells(): void {
    const today = new Date();
    const firstDay = new Date(this.year, this.month - 1, 1);
    const daysInMonth = new Date(this.year, this.month, 0).getDate();
    const lead = firstDay.getDay(); // 周日=0
    const arr: DayCell[] = [];
    for (let i = 0; i < lead; i++) {
      arr.push({ day: 0, phase: -1, isMajor: false, isToday: false });
    }
    for (let d = 1; d <= daysInMonth; d++) {
      const date = new Date(this.year, this.month - 1, d, 12, 0, 0);
      const p = moonPhase(julianFromDate(date));
      // 四相（朔/上弦/望/下弦）附近标记
      const q = p * 4;
      const dist = Math.min(q - Math.floor(q), Math.ceil(q) - q) / 4;
      const isMajor = dist < 2.5 / 29.530588853;
      arr.push({
        day: d,
        phase: p,
        isMajor: isMajor,
        isToday: today.getFullYear() === this.year && today.getMonth() + 1 === this.month && today.getDate() === d
      });
    }
    this.cells = arr;
    this.selectDay(this.selectedDay <= daysInMonth ? this.selectedDay : daysInMonth);
  }

  private selectDay(day: number): void {
    this.selectedDay = day;
    const date = new Date(this.year, this.month - 1, day, 12, 0, 0);
    const p = moonPhase(julianFromDate(date));
    this.selectedPhase = p;
    this.selectedName = phaseNameOf(p);
    this.selectedIll = (1 - Math.cos(2 * Math.PI * p)) / 2;
  }

  private shiftMonth(delta: number): void {
    let m = this.month + delta;
    let y = this.year;
    if (m < 1) {
      m = 12;
      y--;
    }
    if (m > 12) {
      m = 1;
      y++;
    }
    this.year = y;
    this.month = m;
    this.selectedDay = 1;
    this.buildCells();
  }

  build() {
    Stack() {
      StarSkyCanvas()
      Column() {
        Scroll() {
          Column({ space: 12 }) {
            Text('月相日历')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F2F5FF')

            // 月份切换
            Row({ space: 16 }) {
              Button('◀ 上月')
                .fontSize(13)
                .height(34)
                .backgroundColor('#161B3A')
                .fontColor('#F2F5FF')
                .onClick(() => {
                  this.shiftMonth(-1);
                })
              Text(`${this.year} 年 ${pad2(this.month)} 月`)
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor('#F5D76E')
              Button('下月 ▶')
                .fontSize(13)
                .height(34)
                .backgroundColor('#161B3A')
                .fontColor('#F2F5FF')
                .onClick(() => {
                  this.shiftMonth(1);
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)

            // 当月选中详情
            SkyCard() {
              Row({ space: 16 }) {
                MoonPhaseCanvas({ phase: this.selectedPhase, size: 96 })
                Column({ space: 6 }) {
                  Text(`${this.month} 月 ${this.selectedDay} 日`)
                    .fontSize(17)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#F2F5FF')
                  Text(this.selectedName)
                    .fontSize(14)
                    .fontColor('#F5D76E')
                  Text(`照亮 ${Math.round(this.selectedIll * 100)}%`)
                    .fontSize(13)
                    .fontColor('#9AA3C7')
                }
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
            }

            // 整月网格
            SkyCard({ title: '整月月相', subtitle: '◉ 为朔/弦/望附近，金色为今日' }) {
              Column({ space: 8 }) {
                Row() {
                  ForEach(['日', '一', '二', '三', '四', '五', '六'], (w: string) => {
                    Text(w)
                      .fontSize(12)
                      .fontColor('#9AA3C7')
                      .width('14.2%')
                      .textAlign(TextAlign.Center)
                  }, (w: string) => w)
                }
                .width('100%')

                Grid() {
                  ForEach(this.cells, (cell: DayCell, idx: number) => {
                    GridItem() {
                      Column({ space: 2 }) {
                        if (cell.day > 0) {
                          MoonPhaseCanvas({ phase: cell.phase, size: 34 })
                          Text(`${cell.day}`)
                            .fontSize(10)
                            .fontColor(cell.isToday ? '#F5D76E' : (cell.isMajor ? '#F2F5FF' : '#9AA3C7'))
                        } else {
                          Text('')
                            .height(56)
                        }
                      }
                      .width(38)
                      .height(56)
                      .justifyContent(FlexAlign.Center)
                      .borderRadius(8)
                      .backgroundColor(this.selectedDay === cell.day && cell.day > 0 ? 'rgba(91, 141, 239, 0.3)' : 'transparent')
                      .onClick(() => {
                        if (cell.day > 0) {
                          this.selectDay(cell.day);
                        }
                      })
                    }
                  }, (cell: DayCell, idx: number) => `${idx}`)
                }
                .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
                .columnsGap(0)
                .rowsGap(6)
                .width('100%')
              }
              .width('100%')
            }
          }
          .padding(16)
          .constraintSize({ minHeight: '100%' })
        }
        .align(Alignment.Top)
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        NavBar({ current: 1 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0B1026')
  }
}
