export enum ImageMode {
  COLOR = 'color',
  GRAYSCALE = 'grayscale',
  BINARY = 'binary'
}

export interface CropPoint {
  x: number;
  y: number;
}

export interface CropRegion {
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface PageModel {
  id: number;
  docId: number;
  index: number;
  imagePath: string;
  width: number;
  height: number;
}

export interface DocumentModel {
  id: number;
  name: string;
  createdAt: string;
  pageCount: number;
  thumbnailPath: string;
  pdfPath: string;
  pages: PageModel[];
}

export interface DocumentGroup {
  title: string;
  items: DocumentModel[];
}

export class DocumentDataSource implements IDataSource {
  private data: DocumentModel[] = [];
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return this.data.length;
  }

  getData(index: number): DocumentModel {
    return this.data[index];
  }

  setData(data: DocumentModel[]): void {
    this.data = data.slice();
    this.notifyDataReload();
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    this.listeners.push(listener);
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataReloaded());
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataAdd(index));
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataDelete(index));
  }
}
