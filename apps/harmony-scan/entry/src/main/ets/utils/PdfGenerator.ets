import fs from '@ohos.file.fs';
import { PageModel } from '../model/DocumentModel';

interface PdfObject {
  id: number;
  bytes: Uint8Array;
}

export class PdfGenerator {
  static async generate(pages: PageModel[], outputPath: string): Promise<string> {
    const objects: PdfObject[] = [];
    const pageIds: number[] = [];
    let objectId = 1;
    const catalogId = objectId++;
    const pagesId = objectId++;

    pages.forEach((page: PageModel) => {
      const imageId = objectId++;
      const contentId = objectId++;
      const pageId = objectId++;
      pageIds.push(pageId);
      const imageBytes = this.readFile(page.imagePath);
      const mediaWidth = page.width > 0 ? page.width : 595;
      const mediaHeight = page.height > 0 ? page.height : 842;
      const imageHeader = this.text(`${imageId} 0 obj\n<< /Type /XObject /Subtype /Image /Width ${mediaWidth} /Height ${mediaHeight} /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length ${imageBytes.length} >>\nstream\n`);
      const imageFooter = this.text(`\nendstream\nendobj\n`);
      objects.push({ id: imageId, bytes: this.concat([imageHeader, imageBytes, imageFooter]) });
      const contentBody = `q\n${mediaWidth} 0 0 ${mediaHeight} 0 0 cm\n/Im${imageId} Do\nQ\n`;
      objects.push({
        id: contentId,
        bytes: this.text(`${contentId} 0 obj\n<< /Length ${contentBody.length} >>\nstream\n${contentBody}endstream\nendobj\n`)
      });
      objects.push({
        id: pageId,
        bytes: this.text(`${pageId} 0 obj\n<< /Type /Page /Parent ${pagesId} 0 R /Resources << /XObject << /Im${imageId} ${imageId} 0 R >> >> /MediaBox [0 0 ${mediaWidth} ${mediaHeight}] /Contents ${contentId} 0 R >>\nendobj\n`)
      });
    });

    objects.push({
      id: pagesId,
      bytes: this.text(`${pagesId} 0 obj\n<< /Type /Pages /Count ${pageIds.length} /Kids [${pageIds.map((pageId: number) => `${pageId} 0 R`).join(' ')}] >>\nendobj\n`)
    });
    objects.push({
      id: catalogId,
      bytes: this.text(`${catalogId} 0 obj\n<< /Type /Catalog /Pages ${pagesId} 0 R >>\nendobj\n`)
    });
    objects.sort((left: PdfObject, right: PdfObject) => left.id - right.id);

    const header = new Uint8Array([0x25, 0x50, 0x44, 0x46, 0x2d, 0x31, 0x2e, 0x34, 0x0a, 0x25, 0xff, 0xff, 0xff, 0xff, 0x0a]);
    const chunks: Uint8Array[] = [header];
    const offsets: number[] = [0];
    let totalLength = header.length;

    objects.forEach((object: PdfObject) => {
      offsets[object.id] = totalLength;
      chunks.push(object.bytes);
      totalLength += object.bytes.length;
    });

    const xrefOffset = totalLength;
    const xrefLines: string[] = ['xref', `0 ${objects.length + 1}`, '0000000000 65535 f '];
    for (let index = 1; index <= objects.length; index++) {
      xrefLines.push(`${offsets[index].toString().padStart(10, '0')} 00000 n `);
    }
    const trailer = ['trailer', `<< /Size ${objects.length + 1} /Root ${catalogId} 0 R >>`, 'startxref', `${xrefOffset}`, '%%EOF', ''].join('\n');
    chunks.push(this.text(`${xrefLines.join('\n')}\n${trailer}`));
    const pdfBytes = this.concat(chunks);
    const file = fs.openSync(outputPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
    fs.writeSync(file.fd, pdfBytes.buffer);
    fs.closeSync(file);
    return outputPath;
  }

  private static readFile(path: string): Uint8Array {
    const stat = fs.statSync(path);
    const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
    const buffer = new ArrayBuffer(stat.size);
    fs.readSync(file.fd, buffer);
    fs.closeSync(file);
    return new Uint8Array(buffer);
  }

  private static text(value: string): Uint8Array {
    const bytes: number[] = [];
    for (let index = 0; index < value.length; index++) {
      bytes.push(value.charCodeAt(index) & 0xff);
    }
    return new Uint8Array(bytes);
  }

  private static concat(parts: Uint8Array[]): Uint8Array {
    const total = parts.reduce((sum: number, current: Uint8Array) => sum + current.length, 0);
    const merged = new Uint8Array(total);
    let offset = 0;
    parts.forEach((part: Uint8Array) => {
      merged.set(part, offset);
      offset += part.length;
    });
    return merged;
  }
}
