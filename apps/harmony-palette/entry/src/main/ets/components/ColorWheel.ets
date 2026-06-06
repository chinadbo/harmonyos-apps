import { ColorModel } from '../model/ColorModel';
import { ColorConverter } from '../utils/ColorConverter';

@Component
export struct ColorWheel {
  currentColor: ColorModel = ColorConverter.fromHex('#5B8CFF', 'Azure');
  onColorChange: (color: ColorModel) => void = () => {};

  @State private wheelSize: number = 260;
  @State private wheelReady: boolean = false;
  @State private valueLevel: number = 1;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  aboutToAppear(): void {
    this.valueLevel = this.currentColor.value;
  }

  build() {
    Column({ space: 12 }) {
      Canvas(this.context2D)
        .width(this.wheelSize)
        .height(this.wheelSize)
        .backgroundColor(Color.White)
        .borderRadius(this.wheelSize / 2)
        .onReady(() => {
          this.wheelReady = true;
          this.drawWheel();
        })
        .gesture(
          PanGesture({ direction: PanDirection.All })
            .onActionStart((event: GestureEvent) => {
              this.handlePoint(event.fingerList[0].localX, event.fingerList[0].localY);
            })
            .onActionUpdate((event: GestureEvent) => {
              this.handlePoint(event.fingerList[0].localX, event.fingerList[0].localY);
            })
        );

      Column({ space: 8 }) {
        Text(`Value ${Math.round(this.valueLevel * 100)}%`)
          .fontSize(14)
          .fontColor('#6B7280');
        Slider({
          min: 0.05,
          max: 1,
          step: 0.01,
          value: this.valueLevel,
          style: SliderStyle.OutSet
        })
          .width('100%')
          .onChange((value: number) => {
            this.valueLevel = value;
            this.onColorChange(ColorConverter.fromHsv(this.currentColor.hue, this.currentColor.saturation, this.valueLevel));
            this.drawWheel();
          });
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(24);
  }

  private handlePoint(offsetX: number, offsetY: number): void {
    const radius: number = this.wheelSize / 2;
    const centerX: number = radius;
    const centerY: number = radius;
    const dx: number = offsetX - centerX;
    const dy: number = offsetY - centerY;
    const distance: number = Math.sqrt(dx * dx + dy * dy);
    if (distance > radius) {
      return;
    }
    let hue: number = Math.atan2(dy, dx) * 180 / Math.PI;
    if (hue < 0) {
      hue += 360;
    }
    const saturation: number = Math.min(1, distance / radius);
    const color: ColorModel = ColorConverter.fromHsv(hue, saturation, this.valueLevel);
    this.onColorChange(color);
    this.drawWheel();
  }

  private drawWheel(): void {
    if (!this.wheelReady) {
      return;
    }
    const radius: number = this.wheelSize / 2;
    const center: number = radius;
    this.context2D.clearRect(0, 0, this.wheelSize, this.wheelSize);
    for (let angle = 0; angle < 360; angle += 1) {
      const start: number = (angle - 1) * Math.PI / 180;
      const end: number = angle * Math.PI / 180;
      const gradient = this.context2D.createRadialGradient(center, center, 0, center, center, radius);
      gradient.addColorStop(0, '#FFFFFF');
      gradient.addColorStop(1, ColorConverter.fromHsv(angle, 1, this.valueLevel).hex);
      this.context2D.beginPath();
      this.context2D.moveTo(center, center);
      this.context2D.arc(center, center, radius, start, end, false);
      this.context2D.closePath();
      this.context2D.fillStyle = gradient;
      this.context2D.fill();
    }
    this.drawSelector();
  }

  private drawSelector(): void {
    const radius: number = this.wheelSize / 2;
    const selectorRadius: number = this.currentColor.saturation * radius;
    const radians: number = this.currentColor.hue * Math.PI / 180;
    const x: number = radius + Math.cos(radians) * selectorRadius;
    const y: number = radius + Math.sin(radians) * selectorRadius;
    this.context2D.beginPath();
    this.context2D.arc(x, y, 10, 0, Math.PI * 2, false);
    this.context2D.strokeStyle = '#FFFFFF';
    this.context2D.lineWidth = 3;
    this.context2D.stroke();
    this.context2D.beginPath();
    this.context2D.arc(x, y, 6, 0, Math.PI * 2, false);
    this.context2D.fillStyle = this.currentColor.hex;
    this.context2D.fill();
  }
}


