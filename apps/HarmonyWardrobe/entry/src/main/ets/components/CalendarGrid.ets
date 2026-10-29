import { OutfitLog, toDateString, daysInMonth, firstWeekdayOfMonth, todayDateString } from '../model/WardrobeModels'

const WEEK_LABELS: string[] = ['一', '二', '三', '四', '五', '六', '日']

@Component
export struct CalendarGrid {
  @Prop @Watch('onDataChanged') year: number
  @Prop @Watch('onDataChanged') month: number
  @Prop @Watch('onDataChanged') selectedDate: string
  @Prop @Watch('onDataChanged') logs: OutfitLog[]
  onDayClick: (date: string) => void = (date: string) => {
  }
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context2d: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private ready: boolean = false

  onDataChanged(): void {
    if (this.ready) {
      this.draw()
    }
  }

  private loggedDates(): Set<string> {
    const set = new Set<string>()
    this.logs.forEach((log: OutfitLog) => {
      set.add(log.logDate)
    })
    return set
  }

  private draw(): void {
    const ctx = this.context2d
    const w: number = ctx.width
    const h: number = ctx.height
    if (w <= 0 || h <= 0) {
      return
    }
    ctx.clearRect(0, 0, w, h)
    const headerH: number = vp2px(30)
    const cellW: number = w / 7
    const cellH: number = (h - headerH) / 6
    const logged: Set<string> = this.loggedDates()
    const today: string = todayDateString()
    const offset: number = firstWeekdayOfMonth(this.year, this.month)
    const days: number = daysInMonth(this.year, this.month)

    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.font = `${vp2px(13)}px sans-serif`
    for (let i = 0; i < 7; i++) {
      ctx.fillStyle = '#8A97A5'
      ctx.fillText(WEEK_LABELS[i], cellW * i + cellW / 2, headerH / 2)
    }

    for (let day = 1; day <= days; day++) {
      const cellIndex: number = day - 1 + offset
      const col: number = cellIndex % 7
      const row: number = Math.floor(cellIndex / 7)
      const cx: number = cellW * col + cellW / 2
      const cy: number = headerH + cellH * row + cellH / 2
      const dateStr: string = toDateString(this.year, this.month, day)

      if (dateStr === this.selectedDate) {
        ctx.beginPath()
        ctx.arc(cx, cy, cellH * 0.36, 0, Math.PI * 2)
        ctx.fillStyle = '#3E5C76'
        ctx.fill()
        ctx.fillStyle = '#FFFFFF'
      } else {
        ctx.fillStyle = dateStr === today ? '#3E5C76' : '#2B3A4A'
      }
      ctx.font = `${vp2px(15)}px sans-serif`
      ctx.fillText(day.toString(), cx, cy)

      if (logged.has(dateStr)) {
        ctx.beginPath()
        ctx.arc(cx, cy + cellH * 0.3, vp2px(3), 0, Math.PI * 2)
        ctx.fillStyle = '#C98A5B'
        ctx.fill()
      }
    }
  }

  private handleTouch(event: TouchEvent): void {
    if (event.type !== TouchType.Down) {
      return
    }
    const touch = event.touches[0]
    const w: number = this.context2d.width
    const h: number = this.context2d.height
    const headerH: number = vp2px(30)
    const cellW: number = w / 7
    const cellH: number = (h - headerH) / 6
    const px: number = vp2px(touch.x)
    const py: number = vp2px(touch.y)
    const col: number = Math.floor(px / cellW)
    if (col < 0 || col > 6) {
      return
    }
    const relY: number = py - headerH
    if (relY < 0) {
      return
    }
    const row: number = Math.floor(relY / cellH)
    const offset: number = firstWeekdayOfMonth(this.year, this.month)
    const days: number = daysInMonth(this.year, this.month)
    const day: number = row * 7 + col + 1 - offset
    if (day >= 1 && day <= days) {
      this.onDayClick(toDateString(this.year, this.month, day))
    }
  }

  build() {
    Column() {
      Canvas(this.context2d)
        .width('100%')
        .height(324)
        .onReady(() => {
          this.ready = true
          this.draw()
        })
        .onTouch((event: TouchEvent) => this.handleTouch(event))
    }
  }
}
