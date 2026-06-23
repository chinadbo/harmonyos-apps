import { MindNode, createMindNode } from './MindNode';

export interface MindMap {
  id: string;
  title: string;
  rootNodeId: string;
  nodes: Record<string, MindNode>;
  createdAt: number;
  updatedAt: number;
  scale: number;
  offsetX: number;
  offsetY: number;
}

export interface MindMapMeta {
  id: string;
  title: string;
  fileName: string;
  createdAt: number;
  updatedAt: number;
  nodeCount: number;
}

export interface AppSettings {
  isDarkMode: boolean;
}

export function createMindMap(id: string, title: string, rootColor: string): MindMap {
  const rootId: string = `${id}_root`;
  const rootNode: MindNode = createMindNode(rootId, '', title, rootColor, 0);
  return {
    id,
    title,
    rootNodeId: rootId,
    nodes: {
      [rootId]: rootNode
    },
    createdAt: Date.now(),
    updatedAt: Date.now(),
    scale: 1,
    offsetX: 0,
    offsetY: 0
  };
}
