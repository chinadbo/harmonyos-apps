export interface MindNode {
  id: string;
  parentId: string;
  text: string;
  color: string;
  childrenIds: Array<string>;
  depth: number;
  x: number;
  y: number;
  width: number;
  height: number;
}

export function createMindNode(id: string, parentId: string, text: string, color: string, depth: number): MindNode {
  return {
    id,
    parentId,
    text,
    color,
    childrenIds: [],
    depth,
    x: 0,
    y: 0,
    width: 172,
    height: 52
  };
}
