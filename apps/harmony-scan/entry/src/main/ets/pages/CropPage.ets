import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { DocumentDB } from '../database/DocumentDB';
import { CropPoint, CropRegion, ImageMode } from '../model/DocumentModel';
import { ImageProcessor } from '../utils/ImageProcessor';

@Component
struct CropPage {
  @State docId: number = 0;
  @State imagePath: string = '';
  @State mode: ImageMode = ImageMode.COLOR;
  @State points: CropPoint[] = [
    { x: 36, y: 36 },
    { x: 324, y: 36 },
    { x: 324, y: 484 },
    { x: 36, y: 484 }
  ];
  @State activeHandle: number = -1;
  @State saving: boolean = false;

  private imageWidth: number = 360;
  private imageHeight: number = 520;
  private canvasSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.canvasSettings);

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string | number>;
    this.docId = Number(params?.docId ?? 0);
    this.imagePath = `${params?.imagePath ?? ''}`;
  }

  private drawOverlay(): void {
    this.canvasContext.clearRect(0, 0, this.imageWidth, this.imageHeight);
    this.canvasContext.lineWidth = 3;
    this.canvasContext.strokeStyle = '#4F46E5';
    this.canvasContext.fillStyle = 'rgba(96, 165, 250, 0.18)';
    this.canvasContext.beginPath();
    this.canvasContext.moveTo(this.points[0].x, this.points[0].y);
    this.canvasContext.lineTo(this.points[1].x, this.points[1].y);
    this.canvasContext.lineTo(this.points[2].x, this.points[2].y);
    this.canvasContext.lineTo(this.points[3].x, this.points[3].y);
    this.canvasContext.closePath();
    this.canvasContext.fill();
    this.canvasContext.stroke();

    this.points.forEach((point: CropPoint, index: number) => {
      this.canvasContext.beginPath();
      this.canvasContext.fillStyle = index === this.activeHandle ? '#F97316' : '#FFFFFF';
      this.canvasContext.strokeStyle = '#4F46E5';
      this.canvasContext.arc(point.x, point.y, 11, 0, Math.PI * 2);
      this.canvasContext.fill();
      this.canvasContext.stroke();
    });
  }

  private buildCropRegion(): CropRegion {
    const xs = this.points.map((item: CropPoint) => item.x);
    const ys = this.points.map((item: CropPoint) => item.y);
    const minX = Math.max(0, Math.min(...xs));
    const minY = Math.max(0, Math.min(...ys));
    const maxX = Math.min(this.imageWidth, Math.max(...xs));
    const maxY = Math.min(this.imageHeight, Math.max(...ys));
    return {
      x: Math.floor(minX),
      y: Math.floor(minY),
      width: Math.max(1, Math.floor(maxX - minX)),
      height: Math.max(1, Math.floor(maxY - minY))
    };
  }

  private nearestHandle(x: number, y: number): number {
    let nearest = -1;
    let minDistance = 999999;
    this.points.forEach((point: CropPoint, index: number) => {
      const dx = point.x - x;
      const dy = point.y - y;
      const distance = Math.sqrt(dx * dx + dy * dy);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = index;
      }
    });
    return minDistance <= 36 ? nearest : -1;
  }

  private updateHandle(x: number, y: number): void {
    if (this.activeHandle < 0) {
      return;
    }
    this.points[this.activeHandle] = {
      x: Math.max(0, Math.min(this.imageWidth, x)),
      y: Math.max(0, Math.min(this.imageHeight, y))
    };
    this.points = this.points.slice();
    this.drawOverlay();
  }

  private async confirmCrop(): Promise<void> {
    if (this.saving || this.imagePath.length === 0) {
      return;
    }
    this.saving = true;
    try {
      const outputPath = `${(getContext(this) as Record<string, string>).filesDir}/scans/${this.docId}/page_${Date.now()}.jpg`;
      const imageInfo = await ImageProcessor.cropAndEnhance(this.imagePath, outputPath, this.buildCropRegion(), this.mode);
      await DocumentDB.addPage(this.docId, outputPath, imageInfo.size.width, imageInfo.size.height);
      promptAction.showToast({ message: '页面已保存' });
      router.replaceUrl({
        url: 'pages/DocumentDetail',
        params: { docId: this.docId }
      });
    } catch (error) {
      promptAction.showToast({ message: '处理图片失败' });
    }
    this.saving = false;
  }

  build() {
    Column({ space: 16 }) {
      Text('裁剪与增强')
        .width('100%')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      Stack() {
        Image(this.imagePath)
          .width(this.imageWidth)
          .height(this.imageHeight)
          .objectFit(ImageFit.Contain)
          .borderRadius(20)

        Canvas(this.canvasContext)
          .width(this.imageWidth)
          .height(this.imageHeight)
          .borderRadius(20)
          .onReady(() => {
            this.drawOverlay();
          })
          .onTouch((event: TouchEvent) => {
            const touch = event.touches[0];
            if (!touch) {
              return;
            }
            if (event.type === TouchType.Down) {
              this.activeHandle = this.nearestHandle(touch.x, touch.y);
              this.drawOverlay();
            } else if (event.type === TouchType.Move) {
              this.updateHandle(touch.x, touch.y);
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.activeHandle = -1;
              this.drawOverlay();
            }
          })
      }
      .width(this.imageWidth)
      .height(this.imageHeight)
      .alignSelf(ItemAlign.Center)

      Row({ space: 12 }) {
        this.modeButton('彩色', ImageMode.COLOR)
        this.modeButton('灰度', ImageMode.GRAYSCALE)
        this.modeButton('黑白', ImageMode.BINARY)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Button(this.saving ? '处理中...' : '确认保存')
        .width('100%')
        .height(52)
        .fontSize(18)
        .fontColor('#FFFFFF')
        .backgroundColor('#4F46E5')
        .borderRadius(18)
        .onClick(async () => {
          await this.confirmCrop();
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F8FAFC')
  }

  @Builder
  private modeButton(label: string, mode: ImageMode) {
    Button(label)
      .layoutWeight(1)
      .height(42)
      .fontSize(15)
      .backgroundColor(this.mode === mode ? '#4F46E5' : '#E2E8F0')
      .fontColor(this.mode === mode ? '#FFFFFF' : '#1E293B')
      .borderRadius(14)
      .onClick(() => {
        this.mode = mode;
      })
  }
}

export default CropPage;
