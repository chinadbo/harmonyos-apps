import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { AnnotationTool, DrawPoint, EditorRouteParam } from '../model/AnnotationTool';
import { ToolBar } from '../components/ToolBar';
import { ColorPicker } from '../components/ColorPicker';
import ImageExportService from '../service/ImageExportService';

const SNAPSHOT_COMPONENT_ID: string = 'annotate_editor_snapshot';

@Component
export struct AnnotateEditor {
  @Prop routeParam: EditorRouteParam = { imageUri: '' };
  @State selectedTool: AnnotationTool = AnnotationTool.BRUSH;
  @State selectedColor: string = '#F44336';
  @State lineWidth: number = 4;
  @State mosaicSize: number = 12;
  @State textValue: string = '文字';
  @State imageUri: string = '';
  @State imagePath: string = '';
  @State canvasWidth: number = 1080;
  @State canvasHeight: number = 1440;
  @State canUndo: boolean = false;

  private readonly navStack: NavPathStack = AppStorage.get('navStack') as NavPathStack;
  private readonly contextSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private readonly canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.contextSettings);
  private undoStack: ImageData[] = [];
  private baselineSnapshot?: ImageData;
  private startPoint?: DrawPoint;
  private lastPoint?: DrawPoint;
  private isDrawing: boolean = false;

  aboutToAppear(): void {
    this.imageUri = this.routeParam.imageUri;
    this.imagePath = this.routeParam.imagePath ?? this.routeParam.imageUri;
    this.canvasContext.lineCap = 'round';
    this.canvasContext.lineJoin = 'round';
  }

  private initUndoStack(): void {
    if (this.undoStack.length > 0) {
      return;
    }
    const initial = this.canvasContext.getImageData(0, 0, this.canvasWidth, this.canvasHeight);
    this.undoStack.push(initial);
    this.updateUndoState();
  }

  private updateUndoState(): void {
    this.canUndo = this.undoStack.length > 1;
  }

  private normalizePoint(event: TouchEvent): DrawPoint | undefined {
    const touches = event.touches && event.touches.length > 0 ? event.touches : event.changedTouches;
    if (!touches || touches.length === 0) {
      return undefined;
    }
    const touch = touches[0];
    return {
      x: touch.x,
      y: touch.y
    };
  }

  private applyStrokeStyle(): void {
    this.canvasContext.strokeStyle = this.selectedColor;
    this.canvasContext.fillStyle = this.selectedColor;
    this.canvasContext.lineWidth = this.lineWidth;
  }

  private handleTouch(event: TouchEvent): void {
    this.initUndoStack();
    const point = this.normalizePoint(event);
    if (!point) {
      return;
    }
    if (event.type === TouchType.Down) {
      this.handleTouchDown(point);
      return;
    }
    if (event.type === TouchType.Move) {
      this.handleTouchMove(point);
      return;
    }
    if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      this.handleTouchUp(point);
    }
  }

  private handleTouchDown(point: DrawPoint): void {
    this.isDrawing = true;
    this.startPoint = point;
    this.lastPoint = point;
    this.applyStrokeStyle();
    if (this.selectedTool === AnnotationTool.BRUSH) {
      this.canvasContext.beginPath();
      this.canvasContext.moveTo(point.x, point.y);
    } else if (this.selectedTool === AnnotationTool.ERASER) {
      this.eraseAt(point);
    } else if (this.selectedTool === AnnotationTool.MOSAIC) {
      this.applyMosaic(point);
    } else if (this.selectedTool === AnnotationTool.TEXT) {
      this.drawText(point);
      this.commitSnapshot();
      this.isDrawing = false;
    } else {
      this.baselineSnapshot = this.canvasContext.getImageData(0, 0, this.canvasWidth, this.canvasHeight);
    }
  }

  private handleTouchMove(point: DrawPoint): void {
    if (!this.isDrawing || !this.startPoint) {
      return;
    }
    if (this.selectedTool === AnnotationTool.BRUSH) {
      this.canvasContext.lineTo(point.x, point.y);
      this.canvasContext.stroke();
      this.lastPoint = point;
      return;
    }
    if (this.selectedTool === AnnotationTool.ERASER) {
      this.eraseLine(this.lastPoint ?? point, point);
      this.lastPoint = point;
      return;
    }
    if (this.selectedTool === AnnotationTool.MOSAIC) {
      this.applyMosaic(point);
      this.lastPoint = point;
      return;
    }
    if (!this.baselineSnapshot) {
      return;
    }
    this.canvasContext.putImageData(this.baselineSnapshot, 0, 0);
    if (this.selectedTool === AnnotationTool.RECT) {
      this.drawRectPreview(this.startPoint, point);
    } else if (this.selectedTool === AnnotationTool.ARROW) {
      this.drawArrow(this.startPoint, point);
    }
    this.lastPoint = point;
  }

  private handleTouchUp(point: DrawPoint): void {
    if (!this.isDrawing) {
      return;
    }
    if (this.selectedTool === AnnotationTool.BRUSH) {
      this.canvasContext.lineTo(point.x, point.y);
      this.canvasContext.stroke();
      this.canvasContext.closePath();
    } else if (this.selectedTool === AnnotationTool.ERASER) {
      this.eraseLine(this.lastPoint ?? point, point);
    } else if (this.selectedTool === AnnotationTool.MOSAIC) {
      this.applyMosaic(point);
    } else if (this.selectedTool === AnnotationTool.RECT && this.startPoint && this.baselineSnapshot) {
      this.canvasContext.putImageData(this.baselineSnapshot, 0, 0);
      this.drawRectPreview(this.startPoint, point);
    } else if (this.selectedTool === AnnotationTool.ARROW && this.startPoint && this.baselineSnapshot) {
      this.canvasContext.putImageData(this.baselineSnapshot, 0, 0);
      this.drawArrow(this.startPoint, point);
    }
    if (this.selectedTool !== AnnotationTool.TEXT) {
      this.commitSnapshot();
    }
    this.isDrawing = false;
    this.startPoint = undefined;
    this.lastPoint = undefined;
    this.baselineSnapshot = undefined;
  }

  private commitSnapshot(): void {
    const snapshot = this.canvasContext.getImageData(0, 0, this.canvasWidth, this.canvasHeight);
    this.undoStack.push(snapshot);
    if (this.undoStack.length > 30) {
      this.undoStack.shift();
    }
    this.updateUndoState();
  }

  private undo(): void {
    if (this.undoStack.length <= 1) {
      return;
    }
    this.undoStack.pop();
    const previous = this.undoStack[this.undoStack.length - 1];
    this.canvasContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    this.canvasContext.putImageData(previous, 0, 0);
    this.updateUndoState();
  }

  private eraseAt(point: DrawPoint): void {
    const size = this.lineWidth * 2;
    this.canvasContext.clearRect(point.x - size / 2, point.y - size / 2, size, size);
  }

  private eraseLine(from: DrawPoint, to: DrawPoint): void {
    const distance = Math.max(Math.abs(to.x - from.x), Math.abs(to.y - from.y));
    const steps = Math.max(1, Math.floor(distance / 2));
    for (let index = 0; index <= steps; index++) {
      const x = from.x + ((to.x - from.x) * index) / steps;
      const y = from.y + ((to.y - from.y) * index) / steps;
      this.eraseAt({ x, y });
    }
  }

  private drawRectPreview(start: DrawPoint, end: DrawPoint): void {
    this.applyStrokeStyle();
    const width = end.x - start.x;
    const height = end.y - start.y;
    this.canvasContext.strokeRect(start.x, start.y, width, height);
  }

  private drawArrow(start: DrawPoint, end: DrawPoint): void {
    this.applyStrokeStyle();
    const headLength = Math.max(12, this.lineWidth * 3);
    const angle = Math.atan2(end.y - start.y, end.x - start.x);
    this.canvasContext.beginPath();
    this.canvasContext.moveTo(start.x, start.y);
    this.canvasContext.lineTo(end.x, end.y);
    this.canvasContext.stroke();
    this.canvasContext.beginPath();
    this.canvasContext.moveTo(end.x, end.y);
    this.canvasContext.lineTo(
      end.x - headLength * Math.cos(angle - Math.PI / 6),
      end.y - headLength * Math.sin(angle - Math.PI / 6)
    );
    this.canvasContext.moveTo(end.x, end.y);
    this.canvasContext.lineTo(
      end.x - headLength * Math.cos(angle + Math.PI / 6),
      end.y - headLength * Math.sin(angle + Math.PI / 6)
    );
    this.canvasContext.stroke();
    this.canvasContext.closePath();
  }

  private applyMosaic(point: DrawPoint): void {
    const blockSize = this.mosaicSize;
    const half = Math.floor(blockSize / 2);
    const left = Math.max(0, Math.floor(point.x - half));
    const top = Math.max(0, Math.floor(point.y - half));
    const width = Math.min(blockSize, this.canvasWidth - left);
    const height = Math.min(blockSize, this.canvasHeight - top);
    if (width <= 0 || height <= 0) {
      return;
    }
    const imageData = this.canvasContext.getImageData(left, top, width, height);
    const pixels = imageData.data;
    for (let y = 0; y < height; y += blockSize) {
      for (let x = 0; x < width; x += blockSize) {
        const baseIndex = (y * width + x) * 4;
        const red = pixels[baseIndex];
        const green = pixels[baseIndex + 1];
        const blue = pixels[baseIndex + 2];
        const alpha = pixels[baseIndex + 3];
        for (let innerY = y; innerY < Math.min(y + blockSize, height); innerY++) {
          for (let innerX = x; innerX < Math.min(x + blockSize, width); innerX++) {
            const offset = (innerY * width + innerX) * 4;
            pixels[offset] = red;
            pixels[offset + 1] = green;
            pixels[offset + 2] = blue;
            pixels[offset + 3] = alpha;
          }
        }
      }
    }
    this.canvasContext.putImageData(imageData, left, top);
  }

  private drawText(point: DrawPoint): void {
    this.applyStrokeStyle();
    this.canvasContext.font = `${Math.max(18, this.lineWidth * 6)}px sans-serif`;
    this.canvasContext.fillText(this.textValue.length > 0 ? this.textValue : '文字', point.x, point.y);
  }

  private async saveCurrentImage(): Promise<void> {
    try {
      const hostContext = getContext(this) as common.UIAbilityContext;
      const result = await ImageExportService.exportAndSave(SNAPSHOT_COMPONENT_ID, hostContext, this.imagePath || this.imageUri);
      promptAction.showToast({ message: `已保存: ${result.savedPath}` });
    } catch (error) {
      const message = (error as Error).message ?? '保存失败';
      promptAction.showToast({ message });
    }
  }

  build() {
    Column({ space: 0 }) {
      Row({ space: 12 }) {
        Button('返回')
          .onClick(() => this.navStack.pop())
        Text($r('app.string.editor_title'))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        SaveButton({
          icon: SaveIconStyle.FULL_FILLED,
          text: SaveDescription.SAVE_IMAGE,
          buttonType: ButtonType.Capsule
        })
          .onClick(async () => {
            await this.saveCurrentImage();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      Stack() {
        Image(this.imageUri)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)

        Canvas(this.canvasContext)
          .width('100%')
          .height('100%')
          .onReady(() => {
            this.initUndoStack();
          })
          .onTouch((event: TouchEvent) => {
            this.handleTouch(event);
          })
      }
      .id(SNAPSHOT_COMPONENT_ID)
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#111827')
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.canvasWidth = Number(newValue.width);
        this.canvasHeight = Number(newValue.height);
      })

      ColorPicker({
        selectedTool: this.selectedTool,
        selectedColor: $selectedColor,
        lineWidth: $lineWidth,
        mosaicSize: $mosaicSize,
        textValue: $textValue
      })

      ToolBar({
        selectedTool: $selectedTool,
        onUndo: () => this.undo(),
        onSave: async () => {
          await this.saveCurrentImage();
        },
        canUndo: this.canUndo
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#E2E8F0')
  }
}
