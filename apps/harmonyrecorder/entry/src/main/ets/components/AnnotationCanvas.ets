import { AnnotationTool } from './AnnotationToolbar';

export interface DrawPoint {
  x: number;
  y: number;
}

export interface DrawStroke {
  tool: AnnotationTool;
  color: string;
  points: Array<DrawPoint>;
}

@Component
export struct AnnotationCanvas {
  @Watch('onStrokesChange') @Link strokes: Array<DrawStroke>;
  @Prop selectedTool: AnnotationTool;
  @Prop selectedColor: string;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  @State private activePoints: Array<DrawPoint> = [];

  private onStrokesChange(): void {
    this.redraw();
  }

  private redraw(): void {
    this.context2D.clearRect(0, 0, 4000, 4000);
    this.strokes.forEach((stroke: DrawStroke) => this.drawStroke(stroke));
    if (this.activePoints.length > 0) {
      this.drawStroke({
        tool: this.selectedTool,
        color: this.selectedColor,
        points: this.activePoints
      });
    }
  }

  private drawStroke(stroke: DrawStroke): void {
    if (stroke.points.length === 0) {
      return;
    }

    this.context2D.beginPath();
    this.context2D.strokeStyle = stroke.color;
    this.context2D.fillStyle = stroke.color;
    this.context2D.lineWidth = 6;
    this.context2D.lineJoin = 'round';
    this.context2D.lineCap = 'round';

    if (stroke.tool === 'pen') {
      this.context2D.moveTo(stroke.points[0].x, stroke.points[0].y);
      for (let index: number = 1; index < stroke.points.length; index += 1) {
        this.context2D.lineTo(stroke.points[index].x, stroke.points[index].y);
      }
      this.context2D.stroke();
      return;
    }

    const start: DrawPoint = stroke.points[0];
    const end: DrawPoint = stroke.points[stroke.points.length - 1];
    const width: number = end.x - start.x;
    const height: number = end.y - start.y;

    if (stroke.tool === 'rect') {
      this.context2D.strokeRect(start.x, start.y, width, height);
      return;
    }

    if (stroke.tool === 'circle') {
      const radiusX: number = Math.abs(width) / 2;
      const radiusY: number = Math.abs(height) / 2;
      this.context2D.ellipse(start.x + width / 2, start.y + height / 2, radiusX, radiusY, 0, 0, Math.PI * 2);
      this.context2D.stroke();
      return;
    }

    this.context2D.moveTo(start.x, start.y);
    this.context2D.lineTo(end.x, end.y);
    this.context2D.stroke();
    const angle: number = Math.atan2(end.y - start.y, end.x - start.x);
    const arrowLength: number = 20;
    this.context2D.beginPath();
    this.context2D.moveTo(end.x, end.y);
    this.context2D.lineTo(end.x - arrowLength * Math.cos(angle - Math.PI / 6), end.y - arrowLength * Math.sin(angle - Math.PI / 6));
    this.context2D.lineTo(end.x - arrowLength * Math.cos(angle + Math.PI / 6), end.y - arrowLength * Math.sin(angle + Math.PI / 6));
    this.context2D.closePath();
    this.context2D.fill();
  }

  private handleTouch(event: TouchEvent): void {
    if (!event.touches || event.touches.length === 0) {
      return;
    }

    const point: DrawPoint = {
      x: event.touches[0].x,
      y: event.touches[0].y
    };

    if (event.type === TouchType.Down) {
      this.activePoints = [point];
      this.strokes = [...this.strokes, {
        tool: this.selectedTool,
        color: this.selectedColor,
        points: [point]
      }];
      this.redraw();
      return;
    }

    if ((event.type === TouchType.Move || event.type === TouchType.Up) && this.strokes.length > 0) {
      this.activePoints = [...this.activePoints, point];
      const lastStroke: DrawStroke = this.strokes[this.strokes.length - 1];
      const updatedStroke: DrawStroke = {
        ...lastStroke,
        points: [...lastStroke.points, point]
      };
      this.strokes = [...this.strokes.slice(0, this.strokes.length - 1), updatedStroke];
      if (event.type === TouchType.Up) {
        this.activePoints = [];
      }
      this.redraw();
    }
  }

  build() {
    Canvas(this.context2D)
      .width('100%')
      .height(260)
      .backgroundColor('#10FFFFFF')
      .borderRadius(20)
      .onReady(() => this.redraw())
      .onTouch((event: TouchEvent) => this.handleTouch(event))
  }
}
