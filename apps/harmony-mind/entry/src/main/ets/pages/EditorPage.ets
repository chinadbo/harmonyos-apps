import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { MindMap } from '../models/MindMap';
import { MindNode, createMindNode } from '../models/MindNode';
import { FileStorage } from '../utils/FileStorage';
import { Constants } from '../utils/Constants';
import { MindCanvas } from '../components/MindCanvas';
import { MindToolbar } from '../components/MindToolbar';
import { NodeEditDialog } from '../components/NodeEditDialog';

@Entry
@Component
struct EditorPage {
  @StorageLink('isDarkMode') isDarkMode: boolean = false;
  @State private storage?: FileStorage;
  @State private mindMap: MindMap = {
    id: '',
    title: '脑图',
    rootNodeId: '',
    nodes: {},
    createdAt: Date.now(),
    updatedAt: Date.now(),
    scale: 1,
    offsetX: 0,
    offsetY: 0
  };
  @State private selectedNodeId: string = '';
  @State private editorTitle: string = '';
  @State private scaleValue: number = 1;
  @State private offsetXValue: number = 0;
  @State private offsetYValue: number = 0;
  @State private dialogVisible: boolean = false;
  @State private dialogTitle: string = '编辑节点';
  @State private dialogDraft: string = '';
  @State private dialogMode: string = 'edit';
  @State private errorMessage: string = '';

  aboutToAppear(): void {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      this.storage = new FileStorage(context);
      this.storage.initialize().then(() => {
        if (this.storage) {
          this.storage.loadSettings().then((settings) => {
            this.isDarkMode = settings.isDarkMode;
          });
        }
        this.loadCurrentMindMap();
      });
    } catch (error) {
      this.errorMessage = '编辑器初始化失败';
    }
  }

  aboutToDisappear(): void {
    this.saveCurrentMindMap();
  }

  private async loadCurrentMindMap(): Promise<void> {
    try {
      const params = router.getParams() as Record<string, Object>;
      const id: string = params && params['mindMapId'] ? params['mindMapId'] as string : '';
      if (!this.storage || !id) {
        this.errorMessage = '脑图参数无效';
        return;
      }
      const loaded: MindMap | null = await this.storage.loadMindMapById(id);
      if (!loaded) {
        this.errorMessage = '未找到脑图数据';
        return;
      }
      this.mindMap = loaded;
      this.editorTitle = loaded.title;
      this.selectedNodeId = loaded.rootNodeId;
      this.scaleValue = loaded.scale;
      this.offsetXValue = loaded.offsetX;
      this.offsetYValue = loaded.offsetY;
      this.relayout();
    } catch (error) {
      this.errorMessage = '脑图加载失败';
    }
  }

  private async saveCurrentMindMap(): Promise<void> {
    try {
      if (!this.storage || !this.mindMap.id) {
        return;
      }
      this.mindMap.scale = this.scaleValue;
      this.mindMap.offsetX = this.offsetXValue;
      this.mindMap.offsetY = this.offsetYValue;
      this.mindMap.title = this.editorTitle.trim().length > 0 ? this.editorTitle.trim() : this.mindMap.title;
      await this.storage.saveMindMap(this.mindMap);
    } catch (error) {
      this.errorMessage = '脑图保存失败';
    }
  }

  private relayout(): void {
    try {
      const rootNode: MindNode = this.mindMap.nodes[this.mindMap.rootNodeId];
      if (!rootNode) {
        return;
      }
      rootNode.x = Constants.ROOT_X;
      rootNode.y = Constants.ROOT_Y;
      rootNode.width = Constants.NODE_WIDTH;
      rootNode.height = Constants.NODE_HEIGHT;
      const subtreeHeight: number = this.measureSubtree(this.mindMap.rootNodeId);
      this.layoutChildren(this.mindMap.rootNodeId, Constants.ROOT_X, Constants.ROOT_Y - subtreeHeight / 2, 1);
      this.mindMap = { ...this.mindMap };
    } catch (error) {
      this.errorMessage = '布局计算失败';
    }
  }

  private measureSubtree(nodeId: string): number {
    const node: MindNode = this.mindMap.nodes[nodeId];
    if (!node || node.childrenIds.length === 0) {
      return Constants.NODE_HEIGHT + Constants.VERTICAL_GAP;
    }
    let totalHeight: number = 0;
    node.childrenIds.forEach((childId: string) => {
      totalHeight += this.measureSubtree(childId);
    });
    return Math.max(totalHeight, Constants.NODE_HEIGHT + Constants.VERTICAL_GAP);
  }

  private layoutChildren(parentId: string, parentX: number, startY: number, depth: number): number {
    const parentNode: MindNode = this.mindMap.nodes[parentId];
    if (!parentNode) {
      return startY;
    }
    if (parentNode.childrenIds.length === 0) {
      return startY + Constants.NODE_HEIGHT + Constants.VERTICAL_GAP;
    }
    const childSubtreeHeights: Array<number> = parentNode.childrenIds.map((childId: string) => this.measureSubtree(childId));
    let cursorY: number = startY;
    parentNode.childrenIds.forEach((childId: string, index: number) => {
      const childNode: MindNode = this.mindMap.nodes[childId];
      const blockHeight: number = childSubtreeHeights[index];
      childNode.depth = depth;
      childNode.width = Constants.NODE_WIDTH;
      childNode.height = Constants.NODE_HEIGHT;
      childNode.x = parentX + Constants.HORIZONTAL_GAP;
      childNode.y = cursorY + blockHeight / 2;
      this.layoutChildren(childId, childNode.x, cursorY, depth + 1);
      cursorY += blockHeight;
    });
    let topEdge: number = Number.MAX_VALUE;
    let bottomEdge: number = Number.MIN_VALUE;
    parentNode.childrenIds.forEach((childId: string) => {
      const childNode: MindNode = this.mindMap.nodes[childId];
      topEdge = Math.min(topEdge, childNode.y - childNode.height / 2);
      bottomEdge = Math.max(bottomEdge, childNode.y + childNode.height / 2);
    });
    parentNode.y = (topEdge + bottomEdge) / 2;
    return cursorY;
  }

  private getSelectedNode(): MindNode | undefined {
    return this.mindMap.nodes[this.selectedNodeId];
  }

  private openEditDialog(mode: string): void {
    try {
      const selectedNode: MindNode | undefined = this.getSelectedNode();
      this.dialogMode = mode;
      this.dialogVisible = true;
      this.dialogTitle = mode === 'add' ? '输入子节点文本' : '编辑节点文本';
      this.dialogDraft = mode === 'edit' && selectedNode ? selectedNode.text : Constants.DEFAULT_CHILD_TEXT;
    } catch (error) {
      this.errorMessage = '打开编辑框失败';
    }
  }

  private handleDialogConfirm(text: string): void {
    try {
      const safeText: string = text.trim().length > 0 ? text.trim() : Constants.DEFAULT_CHILD_TEXT;
      if (this.dialogMode === 'add') {
        this.addChildNode(safeText);
        return;
      }
      this.updateSelectedNodeText(safeText);
    } catch (error) {
      this.errorMessage = '节点编辑失败';
    }
  }

  private addChildNode(text: string): void {
    try {
      const targetNodeId: string = this.selectedNodeId || this.mindMap.rootNodeId;
      const parentNode: MindNode = this.mindMap.nodes[targetNodeId];
      if (!parentNode) {
        return;
      }
      const nodeId: string = `node_${Date.now()}_${Math.floor(Math.random() * 100000)}`;
      const nextColor: string = Constants.COLOR_PALETTE[(parentNode.childrenIds.length + 1) % Constants.COLOR_PALETTE.length];
      const childNode: MindNode = createMindNode(nodeId, targetNodeId, text, nextColor, parentNode.depth + 1);
      this.mindMap.nodes[nodeId] = childNode;
      parentNode.childrenIds = [...parentNode.childrenIds, nodeId];
      this.selectedNodeId = nodeId;
      this.relayout();
      this.saveCurrentMindMap();
    } catch (error) {
      this.errorMessage = '新增子节点失败';
    }
  }

  private updateSelectedNodeText(text: string): void {
    try {
      const node: MindNode | undefined = this.getSelectedNode();
      if (!node) {
        return;
      }
      node.text = text;
      if (node.id === this.mindMap.rootNodeId) {
        this.mindMap.title = text;
        this.editorTitle = text;
      }
      this.mindMap = { ...this.mindMap };
      this.saveCurrentMindMap();
    } catch (error) {
      this.errorMessage = '更新节点文本失败';
    }
  }

  private updateSelectedNodeColor(color: string): void {
    try {
      const node: MindNode | undefined = this.getSelectedNode();
      if (!node) {
        return;
      }
      node.color = color;
      this.mindMap = { ...this.mindMap };
      this.saveCurrentMindMap();
    } catch (error) {
      this.errorMessage = '更新节点颜色失败';
    }
  }

  private deleteSelectedNode(): void {
    try {
      const node: MindNode | undefined = this.getSelectedNode();
      if (!node || node.id === this.mindMap.rootNodeId) {
        return;
      }
      const parentNode: MindNode = this.mindMap.nodes[node.parentId];
      if (parentNode) {
        parentNode.childrenIds = parentNode.childrenIds.filter((childId: string) => childId !== node.id);
      }
      this.deleteNodeTree(node.id);
      this.selectedNodeId = this.mindMap.rootNodeId;
      this.relayout();
      this.saveCurrentMindMap();
    } catch (error) {
      this.errorMessage = '删除节点失败';
    }
  }

  private deleteNodeTree(nodeId: string): void {
    const node: MindNode = this.mindMap.nodes[nodeId];
    if (!node) {
      return;
    }
    node.childrenIds.forEach((childId: string) => {
      this.deleteNodeTree(childId);
    });
    delete this.mindMap.nodes[nodeId];
  }

  private resetViewport(): void {
    this.scaleValue = 1;
    this.offsetXValue = 0;
    this.offsetYValue = 0;
    this.saveCurrentMindMap();
  }

  build() {
    Stack() {
      Column({ space: 14 }) {
        Row() {
          Button('返回')
            .backgroundColor(this.isDarkMode ? '#FF303B48' : '#FFE7ECF3')
            .fontColor(this.isDarkMode ? '#FFF4F7FB' : '#FF1F2530')
            .onClick(() => {
              this.saveCurrentMindMap();
              router.back();
            })

          TextInput({ text: this.editorTitle, placeholder: '请输入脑图标题' })
            .layoutWeight(1)
            .margin({ left: 12, right: 12 })
            .fontSize(18)
            .onChange((value: string) => {
              this.editorTitle = value;
            })
            .onSubmit(() => {
              this.mindMap.title = this.editorTitle.trim().length > 0 ? this.editorTitle.trim() : this.mindMap.title;
              this.saveCurrentMindMap();
            })
        }
        .width('100%')

        MindToolbar({
          selectedNodeText: this.getSelectedNode() ? this.getSelectedNode()!.text : '未选中节点',
          selectedColor: this.getSelectedNode() ? this.getSelectedNode()!.color : Constants.COLOR_PALETTE[0],
          canDelete: this.selectedNodeId !== '' && this.selectedNodeId !== this.mindMap.rootNodeId,
          isDarkMode: this.isDarkMode,
          onAddChild: () => {
            this.openEditDialog('add');
          },
          onEditNode: () => {
            this.openEditDialog('edit');
          },
          onDeleteNode: () => {
            this.deleteSelectedNode();
          },
          onColorChange: (color: string) => {
            this.updateSelectedNodeColor(color);
          },
          onResetView: () => {
            this.resetViewport();
          }
        })

        if (this.errorMessage) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#FFE14D4D')
        }

        MindCanvas({
          mindMap: this.mindMap,
          selectedNodeId: this.selectedNodeId,
          isDarkMode: this.isDarkMode,
          scale: $scaleValue,
          offsetX: $offsetXValue,
          offsetY: $offsetYValue,
          onSelectNode: (nodeId: string) => {
            this.selectedNodeId = nodeId;
          },
          onViewportChange: (scale: number, offsetX: number, offsetY: number) => {
            this.scaleValue = scale;
            this.offsetXValue = offsetX;
            this.offsetYValue = offsetY;
          }
        })
        .layoutWeight(1)
      }
      .padding(16)
      .width('100%')
      .height('100%')
      .backgroundColor(this.isDarkMode ? '#FF14181F' : '#FFF7F8FC')

      NodeEditDialog({
        isVisible: $dialogVisible,
        draftText: $dialogDraft,
        title: this.dialogTitle,
        isDarkMode: this.isDarkMode,
        onConfirm: (text: string) => {
          this.handleDialogConfirm(text);
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}
