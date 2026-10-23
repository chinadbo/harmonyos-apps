let storage = new LocalStorage();

@Entry(storage)
@Component
struct MoonWidgetCard {
  @LocalStorageProp('title') title: string = '今日月相';
  @LocalStorageProp('dateLabel') dateLabel: string = '';
  @LocalStorageProp('phase') phase: number = 0;
  @LocalStorageProp('phaseName') phaseName: string = '';
  @LocalStorageProp('illumination') illumination: string = '';
  @LocalStorageProp('ageDays') ageDays: string = '';
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private ready: boolean = false;

  build() {
    Column({ space: 6 }) {
      Row() {
        Text(this.title)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F5D76E')
        Text(this.dateLabel)
          .fontSize(11)
          .fontColor('#9AA3C7')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Canvas(this.ctx)
        .width(96)
        .height(96)
        .onReady(() => {
          this.ready = true;
          this.drawMoon();
        })

      Text(this.phaseName)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#F2F5FF')
      Text(`${this.illumination} · ${this.ageDays}`)
        .fontSize(11)
        .fontColor('#9AA3C7')
    }
    .width('100%')
    .height('100%')
    .padding(10)
    .borderRadius(16)
    .backgroundColor('#161B3A')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      postCardAction(this, {
        'action': 'router',
        'abilityName': 'EntryAbility',
        'params': {
          'url': 'pages/Index'
        }
      });
    })
  }

  private drawMoon(): void {
    const ctx = this.ctx;
    const cx = 48;
    const cy = 48;
    const r = 42;
    ctx.clearRect(0, 0, 96, 96);

    const glow = ctx.createRadialGradient(cx, cy, r * 0.5, cx, cy, r * 1.2);
    glow.addColorStop(0, 'rgba(245, 215, 110, 0.2)');
    glow.addColorStop(1, 'rgba(245, 215, 110, 0)');
    ctx.fillStyle = glow;
    ctx.beginPath();
    ctx.arc(cx, cy, r * 1.2, 0, Math.PI * 2);
    ctx.fill();

    ctx.fillStyle = '#1A2038';
    ctx.beginPath();
    ctx.arc(cx, cy, r, 0, Math.PI * 2);
    ctx.fill();

    const p = ((this.phase % 1) + 1) % 1;
    if (p > 0.02 && p < 0.98) {
      const lit = ctx.createRadialGradient(cx, cy - r * 0.3, r * 0.2, cx, cy, r);
      lit.addColorStop(0, '#FFF7DC');
      lit.addColorStop(1, '#E3BE62');
      ctx.fillStyle = lit;
      const waxing = p <= 0.5;
      const t = waxing ? p * 2 : (p - 0.5) * 2;
      const k = Math.abs(1 - 2 * t);
      const cw = t > 0.5;
      ctx.beginPath();
      if (waxing) {
        ctx.arc(cx, cy, r, -Math.PI / 2, Math.PI / 2, false);
        ctx.ellipse(cx, cy, k * r, r, 0, Math.PI / 2, -Math.PI / 2, cw);
      } else {
        ctx.arc(cx, cy, r, Math.PI / 2, -Math.PI / 2, false);
        ctx.ellipse(cx, cy, k * r, r, 0, -Math.PI / 2, Math.PI / 2, cw);
      }
      ctx.closePath();
      ctx.fill();
    }

    ctx.strokeStyle = 'rgba(242, 245, 255, 0.2)';
    ctx.lineWidth = 0.8;
    ctx.beginPath();
    ctx.arc(cx, cy, r, 0, Math.PI * 2);
    ctx.stroke();
  }
}
