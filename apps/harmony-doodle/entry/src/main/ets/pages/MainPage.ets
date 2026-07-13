import { router } from '@ohos.router';
import { ToolType, Point, ToolConfig, PRESET_COLORS } from '../models/Types';
import { CanvasEngine } from '../engine/CanvasEngine';
import { ToolManager } from '../manager/ToolManager';
import { ArtworkService } from '../service/ArtworkService';
import { ColorPicker } from '../components/ColorPicker';
import { ToolBar } from '../components/ToolBar';
import { LayerPanel } from '../components/LayerPanel';
import { BrushSizeSlider } from '../components/BrushSizeSlider';
import { promptAction } from '@ohos.arkui';

@Component
export struct MainPage {
  @State canvasWidth: number = 1080;
  @State canvasHeight: number = 1920;
  @State currentTool: ToolType = ToolType.Pencil;
  @State currentSize: number = 5;
  @State currentColor: string = '#000000';
  @State currentOpacity: number = 1.0;
  @State showColorPanel: boolean = false;
  @State showToolPanel: boolean = false;
  @State showLayerPanel: boolean = false;
  @State canUndo: boolean = false;
  @State canRedo: boolean = false;
  @State layerCount: number = 1;
  @State activeLayerIndex: number = 0;
  @State toolManager: ToolManager = new ToolManager();
  @State canvasEngine: CanvasEngine | null = null;
  @State canvasContext: CanvasRenderingContext2D | null = null;
  @State canvasElement: Canvas | null = null;
  @State artworkName: string = '';
  @State isDrawing: boolean = false;
  private artworkService: ArtworkService | null = null;
  private touchStartX: number = 0;
  private touchStartY: number = 0;

  aboutToAppear() {
    this.artworkService = new ArtworkService(getContext(this) as Context);
    this.canvasEngine = new CanvasEngine(1080, 1920);
    this.toolManager.onToolChange((tool: ToolConfig) => {
      this.currentTool = tool.type;
      this.currentSize = tool.size;
      this.currentColor = tool.color;
      this.currentOpacity = tool.opacity;
    });
  }

  onPageShow() {
    this.canvasEngine = new CanvasEngine(1080, 1920);
  }

  private updateToolConfig(): ToolConfig {
    return {
      type: this.currentTool,
      size: this.currentSize,
      color: this.currentColor,
      opacity: this.currentOpacity
    };
  }

  private renderCanvas() {
    if (this.canvasEngine && this.canvasContext) {
      this.canvasEngine.renderToContext(this.canvasContext);
    }
  }

  private onTouchStart(event: TouchEvent) {
    if (!this.canvasEngine) return;
    const touch = event.touches[0];
    const point: Point = { x: touch.x, y: touch.y };
    this.canvasEngine.onTouchStart(point, this.updateToolConfig());
    this.isDrawing = true;
    this.renderCanvas();
  }

  private onTouchMove(event: TouchEvent) {
    if (!this.canvasEngine || !this.isDrawing) return;
    const touch = event.touches[0];
    const point: Point = { x: touch.x, y: touch.y };
    this.canvasEngine.onTouchMove(point, this.updateToolConfig());
    this.renderCanvas();
  }

  private onTouchEnd(event: TouchEvent) {
    if (!this.canvasEngine || !this.isDrawing) return;
    const touch = event.changedTouches[0];
    const point: Point = { x: touch.x, y: touch.y };
    this.canvasEngine.onTouchEnd(point, this.updateToolConfig());
    this.isDrawing = false;
    this.canUndo = this.canvasEngine.canUndo();
    this.canRedo = this.canvasEngine.canRedo();
    this.renderCanvas();
  }

  private handleUndo() {
    if (this.canvasEngine?.undo()) {
      this.canUndo = this.canvasEngine.canUndo();
      this.canRedo = this.canvasEngine.canRedo();
      this.renderCanvas();
    }
  }

  private handleRedo() {
    if (this.canvasEngine?.redo()) {
      this.canUndo = this.canvasEngine.canUndo();
      this.canRedo = this.canvasEngine.canRedo();
      this.renderCanvas();
    }
  }

  private handleClear() {
    this.canvasEngine?.clearCanvas();
    this.canUndo = this.canvasEngine?.canUndo() ?? false;
    this.renderCanvas();
  }

  private handleSave() {
    if (!this.canvasEngine) return;
    const exportCanvas = this.canvasEngine.getExportCanvas();
    if (!exportCanvas) return;
    const name = this.artworkName || 'Artwork_' + Date.now();
    this.artworkService?.saveArtwork(name, exportCanvas).then((success) => {
      if (success) {
        promptAction.showToast({ message: 'Artwork saved!', duration: 2000 });
      } else {
        promptAction.showToast({ message: 'Save failed', duration: 2000 });
      }
    });
  }

  private handleAddLayer() {
    if (this.canvasEngine) {
      const id = this.canvasEngine.addLayer('Layer ' + (this.layerCount + 1));
      this.layerCount++;
      this.activeLayerIndex = this.canvasEngine.getActiveLayerIndex();
    }
  }

  private handleLayerSelect(index: number) {
    this.canvasEngine?.setActiveLayer(index);
    this.activeLayerIndex = index;
  }

  private handleLayerToggle(index: number) {
    this.renderCanvas();
  }

  private handleLayerDelete(index: number) {
    this.canvasEngine?.deleteLayer(index);
    this.layerCount--;
    this.activeLayerIndex = this.canvasEngine?.getActiveLayerIndex() ?? 0;
    this.renderCanvas();
  }

  private handleToolChange(tool: ToolType) {
    this.toolManager.setToolType(tool);
  }

  private handleSizeChange(size: number) {
    this.toolManager.setSize(size);
  }

  private handleColorChange(color: string) {
    this.toolManager.setColor(color);
  }

  private handleOpacityChange(opacity: number) {
    this.toolManager.setOpacity(opacity);
  }

  build() {
    Column() {
      // Top bar
      Row() {
        Button('🎨')
          .width(40)
          .height(40)
          .fontSize(20)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onClick(() => {
            this.showColorPanel = !this.showColorPanel;
            this.showToolPanel = false;
            this.showLayerPanel = false;
          })

        Text('HarmonyDoodle')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('🗂️')
          .width(40)
          .height(40)
          .fontSize(20)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onClick(() => {
            router.pushUrl({ url: 'pages/GalleryPage' });
          })

        Button('⚙️')
          .width(40)
          .height(40)
          .fontSize(20)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .margin({ left: 8 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/SettingsPage' });
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E0E0E0' })

      // Action bar
      Row() {
        Button('↩️')
          .width(40)
          .height(40)
          .fontSize(18)
          .backgroundColor(this.canUndo ? '#E6F0FF' : '#F5F5F5')
          .fontColor(this.canUndo ? '#007DFF' : '#999999')
          .borderRadius(8)
          .onClick(() => this.handleUndo())

        Button('↪️')
          .width(40)
          .height(40)
          .fontSize(18)
          .backgroundColor(this.canRedo ? '#E6F0FF' : '#F5F5F5')
          .fontColor(this.canRedo ? '#007DFF' : '#999999')
          .borderRadius(8)
          .margin({ left: 8 })
          .onClick(() => this.handleRedo())

        Button('🧹')
          .width(40)
          .height(40)
          .fontSize(18)
          .backgroundColor('#FFF3E0')
          .fontColor('#FF9800')
          .borderRadius(8)
          .margin({ left: 8 })
          .onClick(() => this.handleClear())

        Button('🔧')
          .width(40)
          .height(40)
          .fontSize(18)
          .backgroundColor('#F5F5F5')
          .fontColor('#666666')
          .borderRadius(8)
          .margin({ left: 8 })
          .onClick(() => {
            this.showToolPanel = !this.showToolPanel;
            this.showColorPanel = false;
            this.showLayerPanel = false;
          })

        Button('📐')
          .width(40)
          .height(40)
          .fontSize(18)
          .backgroundColor('#F5F5F5')
          .fontColor('#666666')
          .borderRadius(8)
          .margin({ left: 8 })
          .onClick(() => {
            this.showLayerPanel = !this.showLayerPanel;
            this.showColorPanel = false;
            this.showToolPanel = false;
          })

        Button('💾')
          .width(40)
          .height(40)
          .fontSize(18)
          .backgroundColor('#E8F5E9')
          .fontColor('#4CAF50')
          .borderRadius(8)
          .margin({ left: 8 })
          .onClick(() => this.handleSave())
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E0E0E0' })

      // Canvas
      Canvas(this.canvasContext)
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: '#E0E0E0' })
        .onReady((event) => {
          this.canvasContext = event.renderingContext;
          this.canvasWidth = event.width;
          this.canvasHeight = event.height;
          this.canvasEngine = new CanvasEngine(this.canvasWidth, this.canvasHeight);
          this.renderCanvas();
        })
        .onTouch((event) => {
          if (event.type === TouchType.Down) {
            this.onTouchStart(event);
          } else if (event.type === TouchType.Move) {
            this.onTouchMove(event);
          } else if (event.type === TouchType.Up) {
            this.onTouchEnd(event);
          }
        })

      // Bottom panels
      if (this.showColorPanel) {
        ColorPicker({
          currentColor: $currentColor,
          currentOpacity: $currentOpacity
        })
        .onColorChange(this.handleColorChange)
        .onOpacityChange(this.handleOpacityChange)
      }

      if (this.showToolPanel) {
        ToolBar({
          currentTool: $currentTool,
          currentSize: $currentSize
        })
        .onToolChange(this.handleToolChange)
        .onSizeChange(this.handleSizeChange)
      }

      if (this.showLayerPanel) {
        LayerPanel({
          layers: this.canvasEngine?.getLayers() ?? [],
          activeIndex: $activeLayerIndex,
          onLayerSelect: this.handleLayerSelect,
          onLayerToggle: this.handleLayerToggle,
          onLayerDelete: this.handleLayerDelete,
          onAddLayer: this.handleAddLayer
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }
}
