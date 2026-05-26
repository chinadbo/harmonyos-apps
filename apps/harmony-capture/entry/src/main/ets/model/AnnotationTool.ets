export enum AnnotationTool {
  BRUSH = 'brush',
  ERASER = 'eraser',
  ARROW = 'arrow',
  RECT = 'rect',
  MOSAIC = 'mosaic',
  TEXT = 'text'
}

export interface ToolOptionState {
  color: string
  lineWidth: number
  mosaicSize: number
  textValue: string
}

export interface EditorRouteParam {
  imageUri: string
  imagePath?: string
  fromHistory?: boolean
}

export interface DrawPoint {
  x: number
  y: number
}
