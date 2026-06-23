import { MindMap } from '../models/MindMap';
import { MindNode } from '../models/MindNode';
import { Constants } from '../utils/Constants';

@Component
export struct MindCanvas {
  @Prop mindMap: MindMap;
  @Prop selectedNodeId: string;
  @Prop isDarkMode: boolean;
  @Link scale: number;
  @Link offsetX: number;
  @Link offsetY: number;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  @State private canvasWidth: number = 1;
  @State private canvasHeight: number = 1;
  @State private lastPanX: number = 0;
  @State private lastPanY: number = 0;
  onSelectNode?: (nodeId: string) => void;
  onViewportChange?: (scale: number, offsetX: number, offsetY: number) => void;

  private drawCanvas(): void {
    try {
      this.context2D.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
      this.context2D.save();
      this.context2D.translate(this.canvasWidth / 2 + this.offsetX, this.canvasHeight / 2 + this.offsetY);
      this.context2D.scale(this.scale, this.scale);
      this.drawLinks();
      this.drawNodes();
      this.context2D.restore();
    } catch (error) {
      console.error(`drawCanvas failed: ${JSON.stringify(error)}`);
    }
  }

  private drawLinks(): void {
    try {
      Object.keys(this.mindMap.nodes).forEach((nodeId: string) => {
        const node: MindNode = this.mindMap.nodes[nodeId];
        if (!node.parentId) {
          return;
        }
        const parentNode: MindNode = this.mindMap.nodes[node.parentId];
        if (!parentNode) {
          return;
        }
        const startX: number = parentNode.x + parentNode.width / 2;
        const startY: number = parentNode.y;
        const endX: number = node.x - node.width / 2;
        const endY: number = node.y;
        const middleX: number = (startX + endX) / 2;
        this.context2D.beginPath();
        this.context2D.strokeStyle = this.isDarkMode ? '#FF70839A' : '#FFB2BDCB';
        this.context2D.lineWidth = 2;
        this.context2D.moveTo(startX, startY);
        this.context2D.bezierCurveTo(middleX, startY, middleX, endY, endX, endY);
        this.context2D.stroke();
      });
    } catch (error) {
      console.error(`drawLinks failed: ${JSON.stringify(error)}`);
    }
  }

  private drawNodes(): void {
    try {
      Object.keys(this.mindMap.nodes).forEach((nodeId: string) => {
        const node: MindNode = this.mindMap.nodes[nodeId];
        const left: number = node.x - node.width / 2;
        const top: number = node.y - node.height / 2;
        this.context2D.beginPath();
        this.context2D.fillStyle = node.color;
        this.context2D.strokeStyle = nodeId === this.selectedNodeId ? '#FFFFFFFF' : '#26000000';
        this.context2D.lineWidth = nodeId === this.selectedNodeId ? 4 : 1;
        this.context2D.roundRect(left, top, node.width, node.height, 16);
        this.context2D.fill();
        this.context2D.stroke();
        this.context2D.fillStyle = '#FFFFFFFF';
        this.context2D.font = '16px sans-serif';
        this.context2D.textAlign = 'center';
        this.context2D.textBaseline = 'middle';
        this.context2D.fillText(node.text, node.x, node.y, node.width - 20);
      });
    } catch (error) {
      console.error(`drawNodes failed: ${JSON.stringify(error)}`);
    }
  }

  private hitTest(localX: number, localY: number): string {
    try {
      const logicalX: number = (localX - this.canvasWidth / 2 - this.offsetX) / this.scale;
      const logicalY: number = (localY - this.canvasHeight / 2 - this.offsetY) / this.scale;
      const nodeIds: Array<string> = Object.keys(this.mindMap.nodes);
      for (let index: number = nodeIds.length - 1; index >= 0; index--) {
        const nodeId: string = nodeIds[index];
        const node: MindNode = this.mindMap.nodes[nodeId];
        const left: number = node.x - node.width / 2 - Constants.HIT_PADDING;
        const right: number = node.x + node.width / 2 + Constants.HIT_PADDING;
        const top: number = node.y - node.height / 2 - Constants.HIT_PADDING;
        const bottom: number = node.y + node.height / 2 + Constants.HIT_PADDING;
        if (logicalX >= left && logicalX <= right && logicalY >= top && logicalY <= bottom) {
          return nodeId;
        }
      }
    } catch (error) {
      console.error(`hitTest failed: ${JSON.stringify(error)}`);
    }
    return '';
  }

  private emitViewport(): void {
    if (this.onViewportChange) {
      this.onViewportChange(this.scale, this.offsetX, this.offsetY);
    }
  }

  build() {
    Stack() {
      Canvas(this.context2D)
        .width('100%')
        .height('100%')
        .backgroundColor(this.isDarkMode ? '#FF14181F' : '#FFF7F8FC')
        .onReady(() => {
          try {
            this.canvasWidth = this.context2D.width;
            this.canvasHeight = this.context2D.height;
            this.drawCanvas();
          } catch (error) {
            console.error(`canvas onReady failed: ${JSON.stringify(error)}`);
          }
        })
        .gesture(
          GestureGroup(GestureMode.Parallel,
            TapGesture()
              .onAction((event: GestureEvent) => {
                const nodeId: string = this.hitTest(event.fingerList[0].localX, event.fingerList[0].localY);
                if (nodeId && this.onSelectNode) {
                  this.onSelectNode(nodeId);
                }
              }),
            PanGesture()
              .onActionStart((event: GestureEvent) => {
                this.lastPanX = event.offsetX;
                this.lastPanY = event.offsetY;
              })
              .onActionUpdate((event: GestureEvent) => {
                this.offsetX += event.offsetX - this.lastPanX;
                this.offsetY += event.offsetY - this.lastPanY;
                this.lastPanX = event.offsetX;
                this.lastPanY = event.offsetY;
                this.drawCanvas();
                this.emitViewport();
              }),
            PinchGesture()
              .onActionUpdate((event: GestureEvent) => {
                const nextScale: number = this.scale * event.scale;
                this.scale = Math.min(Constants.MAX_SCALE, Math.max(Constants.MIN_SCALE, nextScale));
                this.drawCanvas();
                this.emitViewport();
              })
          )
        )
    }
    .width('100%')
    .height('100%')
    .onAreaChange((oldValue: Area, newValue: Area) => {
      try {
        this.canvasWidth = Number(newValue.width);
        this.canvasHeight = Number(newValue.height);
        this.drawCanvas();
      } catch (error) {
        console.error(`canvas area failed: ${JSON.stringify(error)}`);
      }
    })
    .onAppear(() => {
      this.drawCanvas();
    })
    .onClick(() => {
      this.drawCanvas();
    })
  }
}
