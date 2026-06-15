import relationalStore from '@ohos.data.relationalStore';
import fs from '@ohos.file.fs';
import { DocumentModel, PageModel } from '../model/DocumentModel';

const DB_NAME: string = 'harmonyscan.db';
const STORE_CONFIG: relationalStore.StoreConfig = {
  name: DB_NAME,
  securityLevel: relationalStore.SecurityLevel.S1
};

export class DocumentDB {
  private static store: relationalStore.RdbStore | null = null;

  static async init(context: Object): Promise<void> {
    if (this.store !== null) {
      return;
    }
    this.store = await relationalStore.getRdbStore(context, STORE_CONFIG);
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS documents (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, created_at TEXT NOT NULL, page_count INTEGER DEFAULT 0, thumbnail_path TEXT, pdf_path TEXT)');
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS pages (id INTEGER PRIMARY KEY AUTOINCREMENT, doc_id INTEGER NOT NULL, page_index INTEGER NOT NULL, image_path TEXT NOT NULL, width INTEGER, height INTEGER)');
  }

  static getStore(): relationalStore.RdbStore {
    if (this.store === null) {
      throw new Error('DocumentDB not initialized');
    }
    return this.store;
  }

  static async createDocument(name: string): Promise<number> {
    return await this.getStore().insert('documents', {
      name: name,
      created_at: new Date().toISOString(),
      page_count: 0,
      thumbnail_path: '',
      pdf_path: ''
    });
  }

  static async renameDocument(id: number, name: string): Promise<void> {
    await this.getStore().executeSql('UPDATE documents SET name = ? WHERE id = ?', [name, `${id}`]);
  }

  static async updatePdfPath(id: number, pdfPath: string): Promise<void> {
    await this.getStore().executeSql('UPDATE documents SET pdf_path = ? WHERE id = ?', [pdfPath, `${id}`]);
  }

  static async addPage(docId: number, imagePath: string, width: number, height: number): Promise<number> {
    const pageIndex = await this.getNextPageIndex(docId);
    const pageId = await this.getStore().insert('pages', {
      doc_id: docId,
      page_index: pageIndex,
      image_path: imagePath,
      width: width,
      height: height
    });
    await this.refreshDocumentMeta(docId, imagePath);
    return pageId;
  }

  static async deletePage(pageId: number, docId: number): Promise<void> {
    const page = await this.getPage(pageId);
    if (page !== null && page.imagePath.length > 0 && this.exists(page.imagePath)) {
      fs.unlinkSync(page.imagePath);
    }
    await this.getStore().executeSql('DELETE FROM pages WHERE id = ?', [`${pageId}`]);
    await this.reindexPages(docId);
    await this.refreshDocumentMeta(docId, '');
  }

  static async deleteDocument(docId: number): Promise<void> {
    const document = await this.getDocument(docId);
    if (document === null) {
      return;
    }
    document.pages.forEach((page: PageModel) => {
      if (page.imagePath.length > 0 && this.exists(page.imagePath)) {
        fs.unlinkSync(page.imagePath);
      }
    });
    if (document.pdfPath.length > 0 && this.exists(document.pdfPath)) {
      fs.unlinkSync(document.pdfPath);
    }
    await this.getStore().executeSql('DELETE FROM pages WHERE doc_id = ?', [`${docId}`]);
    await this.getStore().executeSql('DELETE FROM documents WHERE id = ?', [`${docId}`]);
  }

  static async listDocuments(): Promise<DocumentModel[]> {
    const resultSet = await this.getStore().querySql('SELECT id, name, created_at, page_count, thumbnail_path, pdf_path FROM documents ORDER BY created_at DESC');
    const documents: DocumentModel[] = [];
    while (resultSet.goToNextRow()) {
      const id = resultSet.getLong(resultSet.getColumnIndex('id'));
      documents.push({
        id: id,
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        createdAt: resultSet.getString(resultSet.getColumnIndex('created_at')),
        pageCount: resultSet.getLong(resultSet.getColumnIndex('page_count')),
        thumbnailPath: resultSet.getString(resultSet.getColumnIndex('thumbnail_path')),
        pdfPath: resultSet.getString(resultSet.getColumnIndex('pdf_path')),
        pages: await this.listPages(id)
      });
    }
    resultSet.close();
    return documents;
  }

  static async getDocument(id: number): Promise<DocumentModel | null> {
    const resultSet = await this.getStore().querySql('SELECT id, name, created_at, page_count, thumbnail_path, pdf_path FROM documents WHERE id = ?', [`${id}`]);
    let document: DocumentModel | null = null;
    if (resultSet.goToFirstRow()) {
      document = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        createdAt: resultSet.getString(resultSet.getColumnIndex('created_at')),
        pageCount: resultSet.getLong(resultSet.getColumnIndex('page_count')),
        thumbnailPath: resultSet.getString(resultSet.getColumnIndex('thumbnail_path')),
        pdfPath: resultSet.getString(resultSet.getColumnIndex('pdf_path')),
        pages: await this.listPages(id)
      };
    }
    resultSet.close();
    return document;
  }

  static async listPages(docId: number): Promise<PageModel[]> {
    const resultSet = await this.getStore().querySql('SELECT id, doc_id, page_index, image_path, width, height FROM pages WHERE doc_id = ? ORDER BY page_index ASC', [`${docId}`]);
    const pages: PageModel[] = [];
    while (resultSet.goToNextRow()) {
      pages.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        docId: resultSet.getLong(resultSet.getColumnIndex('doc_id')),
        index: resultSet.getLong(resultSet.getColumnIndex('page_index')),
        imagePath: resultSet.getString(resultSet.getColumnIndex('image_path')),
        width: resultSet.getLong(resultSet.getColumnIndex('width')),
        height: resultSet.getLong(resultSet.getColumnIndex('height')),
      });
    }
    resultSet.close();
    return pages;
  }

  private static async getNextPageIndex(docId: number): Promise<number> {
    const resultSet = await this.getStore().querySql('SELECT COALESCE(MAX(page_index), -1) AS max_index FROM pages WHERE doc_id = ?', [`${docId}`]);
    let next = 0;
    if (resultSet.goToFirstRow()) {
      next = resultSet.getLong(resultSet.getColumnIndex('max_index')) + 1;
    }
    resultSet.close();
    return next;
  }

  private static async reindexPages(docId: number): Promise<void> {
    const pages = await this.listPages(docId);
    for (let index = 0; index < pages.length; index++) {
      await this.getStore().executeSql('UPDATE pages SET page_index = ? WHERE id = ?', [`${index}`, `${pages[index].id}`]);
    }
  }

  private static async refreshDocumentMeta(docId: number, thumbnailPath: string): Promise<void> {
    const pages = await this.listPages(docId);
    const nextThumbnail = pages.length > 0 ? pages[0].imagePath : thumbnailPath;
    await this.getStore().executeSql('UPDATE documents SET page_count = ?, thumbnail_path = ? WHERE id = ?', [`${pages.length}`, nextThumbnail, `${docId}`]);
  }

  private static async getPage(pageId: number): Promise<PageModel | null> {
    const resultSet = await this.getStore().querySql('SELECT id, doc_id, page_index, image_path, width, height FROM pages WHERE id = ?', [`${pageId}`]);
    let page: PageModel | null = null;
    if (resultSet.goToFirstRow()) {
      page = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        docId: resultSet.getLong(resultSet.getColumnIndex('doc_id')),
        index: resultSet.getLong(resultSet.getColumnIndex('page_index')),
        imagePath: resultSet.getString(resultSet.getColumnIndex('image_path')),
        width: resultSet.getLong(resultSet.getColumnIndex('width')),
        height: resultSet.getLong(resultSet.getColumnIndex('height'))
      };
    }
    resultSet.close();
    return page;
  }

  private static exists(path: string): boolean {
    try {
      fs.accessSync(path);
      return true;
    } catch (error) {
      return false;
    }
  }
}
